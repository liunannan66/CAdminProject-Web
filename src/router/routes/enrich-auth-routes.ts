import type { ElegantConstRoute } from '@elegant-router/types';
import { generatedRoutes } from '../elegant/routes';
import { ROUTE_DEFAULT_ICONS } from './normalize-backend-routes';

/**
 * 菜单里误填的路由名 → elegant 目录中的标准路由名
 * （例如文档曾写 contract_project_init，实际应为 contract_project-init）
 */
const ROUTE_NAME_ALIASES: Record<string, string> = {
  contract_project_init: 'contract_project-init'
};

function resolveCatalogRouteName(routeName: string) {
  return ROUTE_NAME_ALIASES[routeName] ?? routeName;
}

/** 收集路由树中的 route name（含别名映射后的 catalog 名） */
function collectRouteNames(routes: ElegantConstRoute[], names = new Set<string>()) {
  routes.forEach(route => {
    names.add(route.name);
    names.add(resolveCatalogRouteName(route.name));
    route.children?.forEach(child => collectRouteNames([child], names));
  });

  return names;
}

/** 动态权限路由不使用模板中的静态 roles（如 R_ADMIN），避免与后端角色 Id 冲突导致 403 */
function stripStaticRouteRoles(route: ElegantConstRoute): ElegantConstRoute {
  const meta = route.meta ? { ...route.meta } : undefined;

  if (meta && 'roles' in meta) {
    delete meta.roles;
  }

  const children = route.children?.map(child => stripStaticRouteRoles(child));

  return children ? { ...route, meta, children } : { ...route, meta };
}

/** 合并本地 catalog 与后端返回的路由元数据 */
function mergeRoute(base: ElegantConstRoute, patch?: ElegantConstRoute): ElegantConstRoute {
  if (!patch) return stripStaticRouteRoles(base);

  const useCatalogIdentity =
    patch.name === base.name || resolveCatalogRouteName(patch.name) === base.name;

  return stripStaticRouteRoles({
    ...base,
    ...patch,
    name: useCatalogIdentity ? base.name : patch.name,
    path: useCatalogIdentity ? base.path : patch.path,
    component: useCatalogIdentity ? base.component : patch.component || base.component,
    meta: {
      ...base.meta,
      ...patch.meta,
      /** 子菜单排序以本地 catalog（routes.ts）为准，避免库中 Sort 与约定不一致 */
      order: base.meta?.order ?? patch.meta?.order,
      icon:
        patch.meta?.icon?.trim() ||
        base.meta?.icon?.trim() ||
        ROUTE_DEFAULT_ICONS[base.name] ||
        ROUTE_DEFAULT_ICONS[patch.name],
      i18nKey: patch.meta?.i18nKey || base.meta?.i18nKey
    },
    children: base.children
  });
}

/**
 * 按后端已授权的路由名，用本地 catalog 补全父级目录与组件信息
 * （解决仅勾选子菜单时后端树缺失、或 component 不完整导致侧栏不显示）
 */
function buildCatalogBranch(
  catalogRoute: ElegantConstRoute,
  allowedNames: Set<string>,
  backendByName: Map<string, ElegantConstRoute>
): ElegantConstRoute | null {
  const children =
    catalogRoute.children
      ?.map(child => buildCatalogBranch(child, allowedNames, backendByName))
      .filter((child): child is ElegantConstRoute => child !== null) ?? [];

  const allowedSelf =
    allowedNames.has(catalogRoute.name) ||
    [...allowedNames].some(name => resolveCatalogRouteName(name) === catalogRoute.name);

  if (!allowedSelf && children.length === 0) return null;

  const backendRoute =
    backendByName.get(catalogRoute.name) ??
    [...backendByName.entries()].find(([name]) => resolveCatalogRouteName(name) === catalogRoute.name)?.[1];

  const merged = mergeRoute(catalogRoute, backendRoute);

  if (children.length > 0) {
    merged.children = children;
  }

  return merged;
}

/** 将后端动态路由与本地 elegant 路由目录对齐、补全 */
export function enrichAuthRoutes(backendRoutes: ElegantConstRoute[]): ElegantConstRoute[] {
  if (!backendRoutes.length) return backendRoutes;

  const allowedNames = collectRouteNames(backendRoutes);
  const backendByName = new Map<string, ElegantConstRoute>();

  const indexBackend = (routes: ElegantConstRoute[]) => {
    routes.forEach(route => {
      backendByName.set(route.name, route);
      route.children?.forEach(child => indexBackend([child]));
    });
  };

  indexBackend(backendRoutes);

  const enrichedCatalogRoots = generatedRoutes
    .map(route => buildCatalogBranch(route, allowedNames, backendByName))
    .filter((route): route is ElegantConstRoute => route !== null);

  const enrichedNames = collectRouteNames(enrichedCatalogRoots);
  const extraBackendRoutes = backendRoutes.filter(route => !enrichedNames.has(route.name));

  return [...enrichedCatalogRoots, ...extraBackendRoutes];
}
