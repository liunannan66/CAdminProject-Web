import { request } from '../request';
// import { ApiResponse } from '../request/apiresponse';
// export interface SysLogRecord {
//   id: number;
//   logType: string;
//   message: string;
//   logDateTime: string;
// }
function normalizeLogPageParams(params?: Record<string, unknown>) {
  if (!params) {
    return params;
  }

  const { keyword, keyWord, ...rest } = params;
  return {
    ...rest,
    keyWord: keyWord ?? keyword
  };
}

/** 操作日志 */
export function getSysOplogPage(params?: any) {
  return request<any>({
    url: '/SysLog/OpPageList',
    method: 'get',
    params: normalizeLogPageParams(params)
  });
}

// 异常日志
export function getSysErrlogPage(params?: any) {
  return request<any>({
    url: '/SysLog/ErrPageList',
    method: 'get',
    params: normalizeLogPageParams(params)
  });
}

// 访问日志

export function getSysVislogPage(params?: any) {
  return request<any>({
    url: '/SysLog/VisPageList',
    method: 'get',
    params: normalizeLogPageParams(params)
  });
}
