const LAYOUT_PREFIX = 'layout.';
const VIEW_PREFIX = 'view.';
const FIRST_LEVEL_ROUTE_COMPONENT_SPLIT = '$';

export function getLayoutAndPage(component?: string | null) {
  let layout = '';
  let page = '';

  const [layoutOrPage = '', pageItem = ''] = component?.split(FIRST_LEVEL_ROUTE_COMPONENT_SPLIT) || [];

  layout = getLayout(layoutOrPage);
  page = getPage(pageItem || layoutOrPage);

  return { layout, page };
}

function getLayout(layout: string) {
  return layout.startsWith(LAYOUT_PREFIX) ? layout.replace(LAYOUT_PREFIX, '') : '';
}

function getPage(page: string) {
  return page.startsWith(VIEW_PREFIX) ? page.replace(VIEW_PREFIX, '') : '';
}

export function transformLayoutAndPageToComponent(layout: string, page: string) {
  const hasLayout = Boolean(layout);
  const hasPage = Boolean(page);

  if (hasLayout && hasPage) {
    return `${LAYOUT_PREFIX}${layout}${FIRST_LEVEL_ROUTE_COMPONENT_SPLIT}${VIEW_PREFIX}${page}`;
  }

  if (hasLayout) {
    return `${LAYOUT_PREFIX}${layout}`;
  }

  if (hasPage) {
    return `${VIEW_PREFIX}${page}`;
  }

  return '';
}

/**
 * Get route name by route path
 *
 * @param routeName
 */
export function getRoutePathByRouteName(routeName: string) {
  return `/${routeName.replace(/_/g, '/')}`;
}

/**
 * Get path param from route path
 *
 * @param routePath route path
 */
export function getPathParamFromRoutePath(routePath: string) {
  const [path, param = ''] = routePath.split('/:');

  return {
    path,
    param
  };
}

/**
 * Get route path with param
 *
 * @param routePath route path
 * @param param path param
 */
export function getRoutePathWithParam(routePath: string, param: string) {
  if (param.trim()) {
    return `${routePath}/:${param}`;
  }

  return routePath;
}

/** 后端 IconType：1=内置(iconify)，2=本地；0 为历史错误数据，按内置处理 */
export function normalizeMenuIconType(iconType?: string | number | boolean | null): '1' | '2' {
  if (iconType === 2 || iconType === '2') return '2';
  return '1';
}

export function isMenuLocalIcon(iconType?: string | number | boolean | null) {
  return normalizeMenuIconType(iconType) === '2';
}

/** 菜单列表 SvgIcon 属性（兼容 IconType=0） */
export function getMenuSvgIconProps(row: { icon?: string; iconType?: string | number | boolean | null }) {
  if (!row.icon?.trim()) return { icon: undefined, localIcon: undefined };
  if (isMenuLocalIcon(row.iconType)) {
    return { icon: undefined, localIcon: row.icon };
  }
  return { icon: row.icon, localIcon: undefined };
}

/** 提交后端：IconType 为 int 1 或 2 */
export function menuIconTypeToApi(iconType: string | number | boolean) {
  return normalizeMenuIconType(iconType) === '2' ? 2 : 1;
}
