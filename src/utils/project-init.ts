import type { ContractRecord, ContractPaymentLine, ContractProductLine } from '@/views/contract/manage/modules/contract-operate-drawer.vue';
import {
  PROJECT_INIT_TYPE_LABEL,
  type ProjectInitStatus,
  type ProjectInitType
} from '@/constants/project-init';
import type { ContractType } from '@/constants/contract';

/** 实施功能范围行（对应 SOW） */
export interface ProjectImplementationLine {
  id: string;
  moduleName: string;
  subModuleName: string;
  description: string;
  remark: string;
}

/** 项目组织范围行 */
export interface ProjectOrgScopeLine {
  id: string;
  seq: number;
  orgName: string;
  companyName: string;
  companyQualification: string;
}

/** 系统集成范围行（对应 SOW 12.6） */
export interface ProjectIntegrationLine {
  id: string;
  involvedSystem: string;
  integrationContent: string;
  interfaceCaller: string;
  interfaceProvider: string;
  interfaceDescription: string;
  integrationMethod: string;
}

/** 初始数据转换范围行（对应 SOW 3.6） */
export interface ProjectDataConversionLine {
  id: string;
  seq: number;
  dataName: string;
  scopeDescription: string;
}

/** 培训服务行（对应 SOW 3.8） */
export interface ProjectTrainingLine {
  id: string;
  trainingContent: string;
  trainer: string;
  targetAudience: string;
  trainingMethod: string;
  trainingLocation: string;
}

/** 上线支持行（对应 SOW） */
export interface ProjectGoLiveSupportLine {
  id: string;
  seq: number;
  supportContent: string;
  completionCriteria: string;
}

/** 项目立项记录 */
export interface ProjectInitRecord {
  id: number;
  projectNo: string;
  projectName: string;
  projectType: ProjectInitType;
  status: ProjectInitStatus;
  contractId: number;
  contractNo: string;
  contractName: string;
  customerName: string;
  planStartDate: string;
  planEndDate: string;
  background: string;
  objective: string;
  milestone: string;
  customDevelopmentScope: string;
  attachmentNames: string[];
  contractType: ContractType;
  signDate: string;
  contactPerson: string;
  partyA: string;
  projectManager: string;
  phone: string;
  wechat: string;
  address: string;
  email: string;
  paymentLines: ContractPaymentLine[];
  productLines: ContractProductLine[];
  implementationLines: ProjectImplementationLine[];
  orgScopeLines: ProjectOrgScopeLine[];
  integrationLines: ProjectIntegrationLine[];
  dataConversionLines: ProjectDataConversionLine[];
  trainingLines: ProjectTrainingLine[];
  goLiveSupportLines: ProjectGoLiveSupportLine[];
  /** 合同价税合计(元)，对应合同 quoteAmount，由合同带入，不在组织范围页签维护 */
  contractQuoteAmount: number;
  requirementAttachmentNames: string[];
  createTime?: string;
  creator?: string;
}

function newLineId() {
  return `${Date.now()}_${Math.random().toString(36).slice(2, 8)}`;
}

export function mapContractTypeToProjectType(contractType: ContractType): ProjectInitType {
  return contractType === 'self' ? 'self' : 'integration';
}

export function generateProjectNo(contractNo: string, date = new Date()) {
  const dateStr = `${date.getFullYear()}${String(date.getMonth() + 1).padStart(2, '0')}${String(date.getDate()).padStart(2, '0')}`;
  return `${contractNo}-${dateStr}`;
}

export function createEmptyImplementationLine(): ProjectImplementationLine {
  return {
    id: newLineId(),
    moduleName: '',
    subModuleName: '',
    description: '',
    remark: ''
  };
}

export function createEmptyOrgScopeLine(seq = 1): ProjectOrgScopeLine {
  return {
    id: newLineId(),
    seq,
    orgName: '',
    companyName: '',
    companyQualification: ''
  };
}

export function createEmptyIntegrationLine(): ProjectIntegrationLine {
  return {
    id: newLineId(),
    involvedSystem: '',
    integrationContent: '',
    interfaceCaller: '',
    interfaceProvider: '',
    interfaceDescription: '',
    integrationMethod: ''
  };
}

export function createEmptyDataConversionLine(seq = 1): ProjectDataConversionLine {
  return {
    id: newLineId(),
    seq,
    dataName: '',
    scopeDescription: ''
  };
}

export function createEmptyTrainingLine(): ProjectTrainingLine {
  return {
    id: newLineId(),
    trainingContent: '',
    trainer: '',
    targetAudience: '',
    trainingMethod: '',
    trainingLocation: ''
  };
}

export function createEmptyGoLiveSupportLine(seq = 1): ProjectGoLiveSupportLine {
  return {
    id: newLineId(),
    seq,
    supportContent: '',
    completionCriteria: ''
  };
}

/** 从合同记录生成立项草稿（文档：合同页点击「项目立项」自动带入） */
export function buildProjectInitFromContract(contract: ContractRecord): ProjectInitRecord {
  const now = new Date();
  const createTime = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')} ${String(now.getHours()).padStart(2, '0')}:${String(now.getMinutes()).padStart(2, '0')}:00`;

  return {
    id: 0,
    projectNo: generateProjectNo(contract.contractNo, now),
    projectName: contract.contractName,
    projectType: mapContractTypeToProjectType(contract.contractType),
    status: 'draft',
    contractId: contract.id,
    contractNo: contract.contractNo,
    contractName: contract.contractName,
    customerName: contract.customerName,
    planStartDate: contract.signDate,
    planEndDate: contract.deliveryDate,
    background: '',
    objective: contract.remark,
    milestone: contract.milestone ?? '',
    customDevelopmentScope: '',
    attachmentNames: [...contract.contractAttachmentNames],
    contractType: contract.contractType,
    signDate: contract.signDate,
    contactPerson: '',
    partyA: contract.customerName,
    projectManager: contract.salesOwner,
    phone: '',
    wechat: '',
    address: '',
    email: '',
    paymentLines: contract.paymentLines.map(item => ({ ...item, id: newLineId() })),
    productLines: contract.productLines.map(item => ({ ...item, id: newLineId() })),
    implementationLines: [createEmptyImplementationLine()],
    orgScopeLines: [
      {
        ...createEmptyOrgScopeLine(1),
        companyName: contract.customerName
      }
    ],
    integrationLines: [createEmptyIntegrationLine()],
    dataConversionLines: [createEmptyDataConversionLine(1)],
    trainingLines: [createEmptyTrainingLine()],
    goLiveSupportLines: [createEmptyGoLiveSupportLine(1)],
    contractQuoteAmount: contract.quoteAmount ?? 0,
    requirementAttachmentNames: [...contract.requirementAttachmentNames],
    createTime,
    creator: '当前用户'
  };
}

export function projectTypeLabel(type: ProjectInitType) {
  return PROJECT_INIT_TYPE_LABEL[type];
}
