import { request } from '../request';

/** 获取菜单树列表 */
export function getMenuAllTreeList() {
  return request<Api.SystemManage.MenuPage>({
    url: 'SysMenu/MenuTreeList',
    method: 'get'
  });
}

export function addMenu(data?: any) {
  return request<boolean>({
    url: '/SysMenu/Add',
    method: 'post',
    data
  });
}

/** 更新菜单 */
export function updateMenu(data?: any) {
  return request<boolean>({
    url: '/SysMenu/Update',
    method: 'post',
    data
  });
}

/** 删除菜单 */
export function deleteMenu(params: any) {
  return request<boolean>({
    url: `/SysMenu/Delete/${params.id}`,
    method: 'get',
    params
  });
}
