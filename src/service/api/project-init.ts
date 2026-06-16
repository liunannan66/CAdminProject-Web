import type { ContractAttachmentDto } from './contract';
import { downloadBlobFile } from './file';
import { request } from '../request';

export interface ProjectInitPageParams {
  pageNo: number;
  pageSize: number;
  keyWord?: string;
  projectType?: string;
  status?: string;
}

export interface ProjectInitPaymentLineDto {
  id: number;
  termName: string;
  settlementMethod: string;
  paymentRatio: number;
  node: string;
  remark?: string;
}

export interface ProjectInitProductLineDto {
  id: number;
  productId: number;
  productName: string;
  categoryLabel: string;
  version: string;
  quantity: number;
  amountWithTax: number;
}

export interface ProjectInitImplementationLineDto {
  id: number;
  moduleName: string;
  subModuleName: string;
  description?: string;
  remark?: string;
}

export interface ProjectInitOrgScopeLineDto {
  id: number;
  seq: number;
  orgName?: string;
  companyName: string;
  companyQualification?: string;
}

export interface ProjectInitIntegrationLineDto {
  id: number;
  involvedSystem: string;
  integrationContent: string;
  interfaceCaller: string;
  interfaceProvider: string;
  interfaceDescription?: string;
  integrationMethod: string;
}

export interface ProjectInitDataConversionLineDto {
  id: number;
  seq: number;
  dataName: string;
  scopeDescription?: string;
}

export interface ProjectInitTrainingLineDto {
  id: number;
  trainingContent: string;
  trainer: string;
  targetAudience: string;
  trainingMethod: string;
  trainingLocation: string;
}

export interface ProjectInitGoLiveSupportLineDto {
  id: number;
  seq: number;
  supportContent: string;
  completionCriteria?: string;
}

export interface ProjectInitImplementationStrategyLineDto {
  id: number;
  seq: number;
  businessSegment: string;
  orgScope: string;
  subBranches: string;
  phaseStrategy: string;
  pilot: boolean;
  promotion: boolean;
  promotionResponsible: string;
  locationCentralized: boolean;
  locationDecentralized: boolean;
  locationRemoteCentralized: boolean;
  locationRemoteDecentralized: boolean;
}

export interface ProjectInitDto {
  id: number;
  projectNo: string;
  projectName: string;
  projectType: string;
  status: string;
  contractId: number;
  contractNo: string;
  contractName: string;
  customerName: string;
  planStartDate: string;
  planEndDate: string;
  background?: string;
  objective?: string;
  milestone?: string;
  customDevelopmentScope?: string;
  contractAttachmentNames: string[];
  requirementAttachmentNames: string[];
  sowReferenceAttachmentNames: string[];
  sowReferenceAttachments?: ContractAttachmentDto[];
  orgStructureAttachmentNames: string[];
  orgStructureAttachments?: ContractAttachmentDto[];
  contractType: string;
  signDate: string;
  contactPerson?: string;
  partyA?: string;
  projectManager?: string;
  phone?: string;
  wechat?: string;
  address?: string;
  email?: string;
  contractQuoteAmount: number;
  paymentLines: ProjectInitPaymentLineDto[];
  productLines: ProjectInitProductLineDto[];
  implementationLines: ProjectInitImplementationLineDto[];
  orgScopeLines: ProjectInitOrgScopeLineDto[];
  integrationLines: ProjectInitIntegrationLineDto[];
  dataConversionLines: ProjectInitDataConversionLineDto[];
  trainingLines: ProjectInitTrainingLineDto[];
  goLiveSupportLines: ProjectInitGoLiveSupportLineDto[];
  implementationStrategyLines: ProjectInitImplementationStrategyLineDto[];
  createTime?: string;
  creator?: string;
}

export interface ProjectInitPageResult {
  pageNo: number;
  pageSize: number;
  totalPage: number;
  totalRows: number;
  records: ProjectInitDto[];
}

export interface ProjectInitSaveDto {
  id?: number;
  projectNo: string;
  projectName: string;
  projectType: string;
  contractId: number;
  contractNo: string;
  contractName: string;
  customerName: string;
  planStartDate: string;
  planEndDate: string;
  background?: string;
  objective?: string;
  milestone?: string;
  customDevelopmentScope?: string;
  contractAttachmentNames?: string[];
  requirementAttachmentNames?: string[];
  sowReferenceAttachmentNames?: string[];
  sowReferenceAttachmentIds?: number[];
  orgStructureAttachmentNames?: string[];
  orgStructureAttachmentIds?: number[];
  contractType: string;
  signDate: string;
  contactPerson?: string;
  partyA?: string;
  projectManager?: string;
  phone?: string;
  wechat?: string;
  address?: string;
  email?: string;
  contractQuoteAmount?: number;
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
  implementationLines: Array<{
    id?: number;
    moduleName: string;
    subModuleName: string;
    description?: string;
    remark?: string;
  }>;
  orgScopeLines: Array<{
    id?: number;
    seq: number;
    orgName?: string;
    companyName: string;
    companyQualification?: string;
  }>;
  integrationLines: Array<{
    id?: number;
    involvedSystem: string;
    integrationContent: string;
    interfaceCaller: string;
    interfaceProvider: string;
    interfaceDescription?: string;
    integrationMethod: string;
  }>;
  dataConversionLines: Array<{
    id?: number;
    seq: number;
    dataName: string;
    scopeDescription?: string;
  }>;
  trainingLines: Array<{
    id?: number;
    trainingContent: string;
    trainer: string;
    targetAudience: string;
    trainingMethod: string;
    trainingLocation: string;
  }>;
  goLiveSupportLines: Array<{
    id?: number;
    seq: number;
    supportContent: string;
    completionCriteria?: string;
  }>;
  implementationStrategyLines: Array<{
    id?: number;
    seq: number;
    businessSegment: string;
    orgScope: string;
    subBranches: string;
    phaseStrategy: string;
    pilot: boolean;
    promotion: boolean;
    promotionResponsible: string;
    locationCentralized: boolean;
    locationDecentralized: boolean;
    locationRemoteCentralized: boolean;
    locationRemoteDecentralized: boolean;
  }>;
}

export function getProjectInitPage(params: ProjectInitPageParams) {
  return request<ProjectInitPageResult>({
    url: '/ProjectInit/PageList',
    method: 'get',
    params
  });
}

export function getProjectInitDetail(id: number) {
  return request<ProjectInitDto>({
    url: `/ProjectInit/Detail/${id}`,
    method: 'get'
  });
}

export function addProjectInit(data: ProjectInitSaveDto) {
  return request<boolean>({
    url: '/ProjectInit/Add',
    method: 'post',
    data
  });
}

export function updateProjectInit(data: ProjectInitSaveDto) {
  return request<boolean>({
    url: '/ProjectInit/Update',
    method: 'post',
    data
  });
}

export function deleteProjectInit(id: number) {
  return request<boolean>({
    url: `/ProjectInit/Delete/${id}`,
    method: 'get'
  });
}

/** 根据立项生成 SOW Word 文档并下载 */
export async function generateProjectInitSow(id: number, fileName: string) {
  await downloadBlobFile(`/ProjectInit/GenerateSow/${id}`, fileName, 'post');
}
