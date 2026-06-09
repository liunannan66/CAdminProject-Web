import { request } from '../request';

/**
 * Login
 *
 * @param userName User name
 * @param password Password
 */
export function fetchLogin(account: string, password: string) {
  return request<Api.Auth.LoginToken>({
    url: '/SysLogin/Login',
    method: 'post',
    data: {
      account,
      // 后端 DTO 字段为 PassWord，camelCase 序列化为 passWord（不是 password）
      passWord: password
    }
  });
}

/** Get user info */
export function fetchGetUserInfo() {
  return request<Api.Auth.UserInfo>({ url: '/SysLogin/GetUserInfo' });
}

/**
 * Refresh token
 *
 * @param refreshToken Refresh token
 */
export function fetchRefreshToken(refreshToken: string) {
  return request<Api.Auth.LoginToken>({
    url: '/auth/refreshToken',
    method: 'post',
    data: {
      refreshToken
    }
  });
}

/**
 * return custom backend error
 *
 * @param code error code
 * @param msg error message
 */
export function fetchCustomBackendError(code: string, msg: string) {
  return request({ url: '/auth/error', params: { code, msg } });
}

// 获取用户信息
export function getTokenUserInfo() {
  return request<Api.Auth.UserInfo>({ url: '/SysLogin/GetUserInfo' });
}

// 重置密码
export function resetPassWord(data: any) {
  return request<boolean>({
    url: '/syslogin/resetpassword',
    method: 'post',
    data
  });
}

// 修改基本资料;
export function updateUserInfo(data: any) {
  return request<boolean>({
    url: '/syslogin/updateuserinfo',
    method: 'post',
    data
  });
}
