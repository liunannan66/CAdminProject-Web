import type { SystemInfo } from '@/typings/response/systemInfo';
// import type { ApiResponse } from '@/typings/response/apiresponse';
import { request } from '../request';

/** 获取服务器信息 */
export function getSystemInfo(params?: any) {
  return request<SystemInfo>({
    url: '/SysData/GetSystemInfo',
    method: 'get',
    params
  });
}
