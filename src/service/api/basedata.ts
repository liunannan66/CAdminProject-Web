import { request } from '../request';

/** 产品分页列表 */
export interface ProductPageParams {
  pageNo: number;
  pageSize: number;
  keyWord?: string;
  category?: string;
  status?: number;
}

export interface ProductPageResult {
  pageNo: number;
  pageSize: number;
  totalPage: number;
  totalRows: number;
  records: Api.Basedata.ProductRecord[];
}

export function getProductPage(params: ProductPageParams) {
  return request<ProductPageResult>({
    url: '/Product/PageList',
    method: 'get',
    params
  });
}

export function addProduct(data: Omit<Api.Basedata.ProductRecord, 'id'>) {
  return request<boolean>({
    url: '/Product/Add',
    method: 'post',
    data
  });
}

export function updateProduct(data: Api.Basedata.ProductRecord) {
  return request<boolean>({
    url: '/Product/Update',
    method: 'post',
    data: {
      id: data.id,
      category: data.category,
      name: data.name,
      version: data.version,
      description: data.description,
      status: data.status
    }
  });
}

export function deleteProduct(id: number) {
  return request<boolean>({
    url: `/Product/Delete/${id}`,
    method: 'get'
  });
}

/** 启用产品列表（合同/立项下拉） */
export function getProductListEnabled() {
  return request<Api.Basedata.ProductEnabledItem[]>({
    url: '/Product/ListEnabled',
    method: 'get'
  });
}

/** 报价器分页列表 */
export interface QuoterPageParams {
  pageNo: number;
  pageSize: number;
  keyWord?: string;
  moduleName?: string;
  status?: number;
}

export interface QuoterPageResult {
  pageNo: number;
  pageSize: number;
  totalPage: number;
  totalRows: number;
  records: Api.Basedata.QuoterRecord[];
}

export function getQuoterPage(params: QuoterPageParams) {
  return request<QuoterPageResult>({
    url: '/Quoter/PageList',
    method: 'get',
    params
  });
}

export function getQuoterModuleNames() {
  return request<string[]>({
    url: '/Quoter/ListModuleNames',
    method: 'get'
  });
}

export function addQuoter(data: Omit<Api.Basedata.QuoterRecord, 'id'>) {
  return request<boolean>({
    url: '/Quoter/Add',
    method: 'post',
    data
  });
}

export function updateQuoter(data: Api.Basedata.QuoterRecord) {
  return request<boolean>({
    url: '/Quoter/Update',
    method: 'post',
    data: {
      id: data.id,
      moduleName: data.moduleName,
      subModuleName: data.subModuleName,
      description: data.description,
      unitPrice: data.unitPrice,
      status: data.status
    }
  });
}

export function deleteQuoter(id: number) {
  return request<boolean>({
    url: `/Quoter/Delete/${id}`,
    method: 'get'
  });
}

export function getQuoterListEnabled() {
  return request<Api.Basedata.QuoterRecord[]>({
    url: '/Quoter/ListEnabled',
    method: 'get'
  });
}

/** 付款条件分页列表 */
export interface PaymentTermPageParams {
  pageNo: number;
  pageSize: number;
  keyWord?: string;
  settlementMethod?: string;
  status?: number;
}

export interface PaymentTermPageResult {
  pageNo: number;
  pageSize: number;
  totalPage: number;
  totalRows: number;
  records: Api.Basedata.PaymentTermRecord[];
}

export function getPaymentTermPage(params: PaymentTermPageParams) {
  return request<PaymentTermPageResult>({
    url: '/PaymentTerm/PageList',
    method: 'get',
    params
  });
}

export function addPaymentTerm(data: Omit<Api.Basedata.PaymentTermRecord, 'id'>) {
  return request<boolean>({
    url: '/PaymentTerm/Add',
    method: 'post',
    data
  });
}

export function updatePaymentTerm(data: Api.Basedata.PaymentTermRecord) {
  return request<boolean>({
    url: '/PaymentTerm/Update',
    method: 'post',
    data: {
      id: data.id,
      name: data.name,
      settlementMethod: data.settlementMethod,
      paymentRatio: data.paymentRatio,
      node: data.node,
      remark: data.remark,
      status: data.status
    }
  });
}

export function deletePaymentTerm(id: number) {
  return request<boolean>({
    url: `/PaymentTerm/Delete/${id}`,
    method: 'get'
  });
}

export function getPaymentTermListEnabled() {
  return request<Api.Basedata.PaymentTermRecord[]>({
    url: '/PaymentTerm/ListEnabled',
    method: 'get'
  });
}
