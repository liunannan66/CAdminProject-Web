import { request } from '../request';

/** 角色分页 */
export function getSysRolePage(params?: Api.SystemManage.RoleSearchParams) {
  return request<Api.SystemManage.RolePageList>({
    url: '/SysRole/PageList',
    method: 'get',
    params
  });
}

// 修改角色
export function addSysRole(data?: any) {
  return request<boolean>({
    url: '/SysRole/Add',
    method: 'post',
    data
  });
}

// 修改角色
export function updateSysRole(data?: any) {
  return request<boolean>({
    url: '/SysRole/Update',
    method: 'post',
    data
  });
}

// 修改角色
export function delSysRole(data?: any) {
  return request<boolean>({
    url: `/SysRole/Delete/${data}`,
    method: 'post'
  });
}

/** 角色列表 * */

export function getRolesList() {
  return request<Api.SystemManage.RoleList>({
    url: '/SysRole/List',
    method: 'get'
  });
}
