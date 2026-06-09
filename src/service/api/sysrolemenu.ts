import { request } from '../request';

/** get role list */
export function getRoleUserMenu(params?: any) {
  return request<number[]>({
    url: '/SysRoleMenu/RoleUserMenu',
    method: 'get',
    params
  });
}

export function setRoleUserMenu(data?: any) {
  return request<ResRolePermission[]>({
    url: '/SysRoleMenu/SetRoleUserMenu',
    method: 'post',
    data
  });
}

export function getMenuTreeList() {
  return request<Api.SystemManage.MenuPage>({
    url: 'SysMenu/MenuTreeList',
    method: 'get'
  });
}
