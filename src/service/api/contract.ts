import { request } from '../request';

/** 合同分页参数 */
export interface ContractPageParams {
  pageNo: number;
  pageSize: number;
  keyWord?: string;
  contractType?: string;
}

/** 后端合同收款行 */
export interface ContractPaymentLineDto {
  id: number;
  termName: string;
  settlementMethod: string;
  paymentRatio: number;
  node: string;
  remark?: string;
}

/** 后端合同产品行 */
export interface ContractProductLineDto {
  id: number;
  productId: number;
  productName: string;
  categoryLabel: string;
  version: string;
  quantity: number;
  amountWithTax: number;
}

/** 合同附件 */
export interface ContractAttachmentDto {
  id: number;
  fileName: string;
  fileSize: number;
  contentType?: string;
}

/** 后端合同记录 */
export interface ContractDto {
  id: number;
  contractNo: string;
  contractName: string;
  status: string;
  customerName: string;
  signDate: string;
  contractType: string;
  deliveryDate: string;
  salesOwner: string;
  quoteAmount: number;
  milestone?: string;
  remark?: string;
  approvalFlow?: string;
  contractAttachmentNames: string[];
  requirementAttachmentNames: string[];
  contractAttachments?: ContractAttachmentDto[];
  requirementAttachments?: ContractAttachmentDto[];
  paymentLines: ContractPaymentLineDto[];
  productLines: ContractProductLineDto[];
  createTime?: string;
  creator?: string;
  receivedTotal?: number;
  invoicedAmount?: number;
  salesOpportunity?: string;
}

export interface ContractPageResult {
  pageNo: number;
  pageSize: number;
  totalPage: number;
  totalRows: number;
  records: ContractDto[];
}

/** 合同保存入参 */
export interface ContractSaveDto {
  id?: number;
  contractNo: string;
  contractName?: string;
  customerName: string;
  signDate: string;
  contractType: string;
  deliveryDate: string;
  salesOwner: string;
  quoteAmount: number;
  milestone?: string;
  remark?: string;
  approvalFlow?: string;
  contractAttachmentNames?: string[];
  requirementAttachmentNames?: string[];
  contractAttachmentIds?: number[];
  requirementAttachmentIds?: number[];
  paymentLines: Array<{
    id?: number;
    termName: string;
    settlementMethod: string;
    paymentRatio: number;
    node: string;
    remark?: string;
  }>;
  productLines: Array<{
    id?: number;
    productId: number;
    productName: string;
    categoryLabel: string;
    version: string;
    quantity: number;
    amountWithTax: number;
  }>;
}

export function getContractPage(params: ContractPageParams) {
  return request<ContractPageResult>({
    url: '/Contract/PageList',
    method: 'get',
    params
  });
}

export function getContractDetail(id: number) {
  return request<ContractDto>({
    url: `/Contract/Detail/${id}`,
    method: 'get'
  });
}

export function addContract(data: ContractSaveDto) {
  return request<boolean>({
    url: '/Contract/Add',
    method: 'post',
    data
  });
}

export function updateContract(data: ContractSaveDto) {
  return request<boolean>({
    url: '/Contract/Update',
    method: 'post',
    data
  });
}

export function deleteContract(id: number) {
  return request<boolean>({
    url: `/Contract/Delete/${id}`,
    method: 'get'
  });
}

/** 提交审批（接口预留，一期未启用） */
export function submitContractApproval(data?: Record<string, unknown>) {
  return request<boolean>({
    url: '/Contract/SubmitApproval',
    method: 'post',
    data
  });
}

/** 从合同生成立项草稿 */
export function initContractProject(id: number) {
  return request<import('./project-init').ProjectInitDto>({
    url: `/Contract/ProjectInit/${id}`,
    method: 'post'
  });
}
