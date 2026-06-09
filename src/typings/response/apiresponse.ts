// 接口返回数据格式

export interface ApiResponse<T = unknown> {
  /** 请求是否成功 */
  // success: boolean;
  /** 请求错误信息 */
  message: string;
  /** 状态码 */
  code: number;
  /** 响应体 */
  body: PageList<T> | T | null;
}

export interface PageList<T = any> {
  pageNo: number;
  pageSize: number;
  totalPage: number;
  totalRows: number;
  records: T[];
}
