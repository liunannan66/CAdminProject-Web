import { request } from '../request';

/** 角色分页 */
export function getMenuTreeList2() {
  return request<Api.SystemManage.MenuList>({
    url: 'SysMenu/MenuTreeList',
    method: 'get'
  });
}

/** 添加菜单 */
export function addMenu2(data?: any) {
  return request<boolean>({
    url: '/SysMenu/Add',
    method: 'post',
    data
  });
}

/** 更新菜单 */
export function updateMenu2(data?: any) {
  return request<boolean>({
    url: '/SysMenu/Update',
    method: 'post',
    data
  });
}

/** 删除菜单 */
export function deleteMenu2(params: any) {
  return request<boolean>({
    url: '/SysMenu/Delete',
    method: 'get',
    params
  });
}
