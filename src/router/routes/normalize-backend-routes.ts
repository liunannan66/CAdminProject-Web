import type { ElegantConstRoute } from '@elegant-router/types';

/** 路由默认图标（后端 meta 缺失或缓存旧数据时使用） */
export const ROUTE_DEFAULT_ICONS: Record<string, string> = {
  'contract_project-init': 'mdi:rocket-launch-outline',
  contract_project_init: 'mdi:rocket-launch-outline'
};

function readMeta(route: Record<string, unknown>) {
  const raw = (route.meta ?? route.Meta) as Record<string, unknown> | undefined;
  return raw ?? {};
}

function pickMetaString(meta: Record<string, unknown>, camel: string, pascal: string) {
  const value = meta[camel] ?? meta[pascal];
  return typeof value === 'string' ? value : undefined;
}

function normalizeOne(route: Record<string, unknown>): ElegantConstRoute {
  const meta = readMeta(route);
  const name = String(route.name ?? route.Name ?? '');
  const icon =
    pickMetaString(meta, 'icon', 'Icon')?.trim() ||
    ROUTE_DEFAULT_ICONS[name] ||
    undefined;

  const children = route.children ?? route.Children;
  const normalizedChildren = Array.isArray(children)
    ? (children as Record<string, unknown>[]).map(item => normalizeOne(item))
    : undefined;

  return {
    name,
    path: String(route.path ?? route.Path ?? ''),
    component: (route.component ?? route.Component) as ElegantConstRoute['component'],
    meta: {
      title: pickMetaString(meta, 'title', 'Title') ?? name,
      icon,
      order: (meta.order ?? meta.Order) as number | undefined,
      hideInMenu: Boolean(meta.hideInMenu ?? meta.HideInMenu),
      href: pickMetaString(meta, 'href', 'Href'),
      i18nKey: pickMetaString(meta, 'i18nKey', 'I18nKey') ?? (`route.${name}` as App.I18n.I18nKey),
      keepAlive: meta.keepAlive as boolean | undefined
    },
    children: normalizedChildren?.length ? normalizedChildren : undefined
  } as ElegantConstRoute;
}

/** 将 GetUserMenu 返回结构规范为 elegant 路由（保证 meta.icon 等字段可用） */
export function normalizeBackendRoutes(routes: unknown[]): ElegantConstRoute[] {
  if (!Array.isArray(routes)) return [];
  return routes.map(item => normalizeOne(item as Record<string, unknown>));
}

export function resolveRouteIcon(route: ElegantConstRoute) {
  const name = String(route.name ?? '');
  const icon = route.meta?.icon?.trim();
  return icon || ROUTE_DEFAULT_ICONS[name] || import.meta.env.VITE_MENU_ICON || '';
}
