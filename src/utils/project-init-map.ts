import type { ContractType } from '@/constants/contract';
import type { ProjectInitStatus, ProjectInitType } from '@/constants/project-init';
import type {
  ProjectInitDto,
  ProjectInitImplementationLineDto,
  ProjectInitDataConversionLineDto,
  ProjectInitIntegrationLineDto,
  ProjectInitOrgScopeLineDto,
  ProjectInitTrainingLineDto,
  ProjectInitGoLiveSupportLineDto,
  ProjectInitImplementationStrategyLineDto,
  ProjectInitPaymentLineDto,
  ProjectInitProductLineDto,
  ProjectInitSaveDto
} from '@/service/api/project-init';
import type {
  ProjectImplementationLine,
  ProjectInitRecord,
  ProjectDataConversionLine,
  ProjectIntegrationLine,
  ProjectOrgScopeLine,
  ProjectTrainingLine,
  ProjectGoLiveSupportLine,
  ProjectImplementationStrategyLine
} from '@/utils/project-init';
import type { ContractAttachmentDto } from '@/service/api/contract';
import type {
  ContractPaymentLine,
  ContractProductLine
} from '@/views/contract/manage/modules/contract-operate-drawer.vue';

function collectAttachmentIds(attachments?: ContractAttachmentDto[]) {
  return (attachments ?? []).map(item => item.id).filter(id => id > 0);
}

function newLineId() {
  return `${Date.now()}_${Math.random().toString(36).slice(2, 8)}`;
}

function mapPaymentLine(dto: ProjectInitPaymentLineDto): ContractPaymentLine {
  return {
    id: String(dto.id),
    termName: dto.termName,
    settlementMethod: (dto.settlementMethod || '') as ContractPaymentLine['settlementMethod'],
    paymentRatio: dto.paymentRatio,
    node: dto.node,
    remark: dto.remark ?? ''
  };
}

function mapProductLine(dto: ProjectInitProductLineDto): ContractProductLine {
  return {
    id: String(dto.id),
    productId: dto.productId,
    productName: dto.productName,
    categoryLabel: dto.categoryLabel,
    version: dto.version,
    quantity: dto.quantity,
    amountWithTax: dto.amountWithTax
  };
}

function mapImplementationLine(dto: ProjectInitImplementationLineDto): ProjectImplementationLine {
  return {
    id: String(dto.id),
    moduleName: dto.moduleName,
    subModuleName: dto.subModuleName,
    description: dto.description ?? '',
    remark: dto.remark ?? ''
  };
}

function mapOrgScopeLine(dto: ProjectInitOrgScopeLineDto): ProjectOrgScopeLine {
  return {
    id: String(dto.id),
    seq: dto.seq,
    orgName: dto.orgName ?? '',
    companyName: dto.companyName,
    companyQualification: dto.companyQualification ?? ''
  };
}

function mapIntegrationLine(dto: ProjectInitIntegrationLineDto): ProjectIntegrationLine {
  return {
    id: String(dto.id),
    involvedSystem: dto.involvedSystem ?? '',
    integrationContent: dto.integrationContent ?? '',
    interfaceCaller: dto.interfaceCaller ?? '',
    interfaceProvider: dto.interfaceProvider ?? '',
    interfaceDescription: dto.interfaceDescription ?? '',
    integrationMethod: dto.integrationMethod ?? ''
  };
}

function mapDataConversionLine(dto: ProjectInitDataConversionLineDto): ProjectDataConversionLine {
  return {
    id: String(dto.id),
    seq: dto.seq,
    dataName: dto.dataName ?? '',
    scopeDescription: dto.scopeDescription ?? ''
  };
}

function mapTrainingLine(dto: ProjectInitTrainingLineDto): ProjectTrainingLine {
  return {
    id: String(dto.id),
    trainingContent: dto.trainingContent ?? '',
    trainer: dto.trainer ?? '',
    targetAudience: dto.targetAudience ?? '',
    trainingMethod: dto.trainingMethod ?? '',
    trainingLocation: dto.trainingLocation ?? ''
  };
}

function mapGoLiveSupportLine(dto: ProjectInitGoLiveSupportLineDto): ProjectGoLiveSupportLine {
  return {
    id: String(dto.id),
    seq: dto.seq,
    supportContent: dto.supportContent ?? '',
    completionCriteria: dto.completionCriteria ?? ''
  };
}

function mapImplementationStrategyLine(dto: ProjectInitImplementationStrategyLineDto): ProjectImplementationStrategyLine {
  return {
    id: String(dto.id),
    seq: dto.seq,
    businessSegment: dto.businessSegment ?? '',
    orgScope: dto.orgScope ?? '',
    subBranches: dto.subBranches ?? '',
    phaseStrategy: dto.phaseStrategy ?? '',
    pilot: Boolean(dto.pilot),
    promotion: Boolean(dto.promotion),
    promotionResponsible: dto.promotionResponsible ?? '',
    locationCentralized: Boolean(dto.locationCentralized),
    locationDecentralized: Boolean(dto.locationDecentralized),
    locationRemoteCentralized: Boolean(dto.locationRemoteCentralized),
    locationRemoteDecentralized: Boolean(dto.locationRemoteDecentralized)
  };
}

/** 后端 DTO → 页面 ProjectInitRecord */
export function mapProjectInitDtoToRecord(dto: ProjectInitDto): ProjectInitRecord {
  return {
    id: dto.id,
    projectNo: dto.projectNo,
    projectName: dto.projectName,
    projectType: dto.projectType as ProjectInitType,
    status: (dto.status || 'draft') as ProjectInitStatus,
    contractId: dto.contractId,
    contractNo: dto.contractNo,
    contractName: dto.contractName,
    customerName: dto.customerName,
    planStartDate: dto.planStartDate,
    planEndDate: dto.planEndDate,
    background: dto.background ?? '',
    objective: dto.objective ?? '',
    milestone: dto.milestone ?? '',
    customDevelopmentScope: dto.customDevelopmentScope ?? '',
    implementationStrategyLines: (dto.implementationStrategyLines ?? []).map(mapImplementationStrategyLine),
    attachmentNames: dto.contractAttachmentNames ?? [],
    contractType: dto.contractType as ContractType,
    signDate: dto.signDate,
    contactPerson: dto.contactPerson ?? '',
    partyA: dto.partyA ?? '',
    projectManager: dto.projectManager ?? '',
    phone: dto.phone ?? '',
    wechat: dto.wechat ?? '',
    address: dto.address ?? '',
    email: dto.email ?? '',
    paymentLines: (dto.paymentLines ?? []).map(mapPaymentLine),
    productLines: (dto.productLines ?? []).map(mapProductLine),
    implementationLines: (dto.implementationLines ?? []).map(mapImplementationLine),
    orgScopeLines: (dto.orgScopeLines ?? []).map(mapOrgScopeLine),
    integrationLines: (dto.integrationLines ?? []).map(mapIntegrationLine),
    dataConversionLines: (dto.dataConversionLines ?? []).map(mapDataConversionLine),
    trainingLines: (dto.trainingLines ?? []).map(mapTrainingLine),
    goLiveSupportLines: (dto.goLiveSupportLines ?? []).map(mapGoLiveSupportLine),
    contractQuoteAmount: dto.contractQuoteAmount,
    requirementAttachmentNames: dto.requirementAttachmentNames ?? [],
    sowReferenceAttachmentNames: dto.sowReferenceAttachmentNames ?? [],
    sowReferenceAttachments: dto.sowReferenceAttachments ?? [],
    orgStructureAttachmentNames: dto.orgStructureAttachmentNames ?? [],
    orgStructureAttachments: dto.orgStructureAttachments ?? [],
    createTime: dto.createTime,
    creator: dto.creator
  };
}

/** 页面 ProjectInitRecord → 后端保存 DTO */
export function mapProjectInitRecordToSave(record: ProjectInitRecord): ProjectInitSaveDto {
  return {
    id: record.id > 0 ? record.id : undefined,
    projectNo: record.projectNo,
    projectName: record.projectName,
    projectType: record.projectType,
    contractId: record.contractId,
    contractNo: record.contractNo,
    contractName: record.contractName,
    customerName: record.customerName,
    planStartDate: record.planStartDate,
    planEndDate: record.planEndDate,
    background: record.background,
    objective: record.objective,
    milestone: record.milestone,
    customDevelopmentScope: record.customDevelopmentScope,
    contractAttachmentNames: record.attachmentNames,
    requirementAttachmentNames: record.requirementAttachmentNames,
    sowReferenceAttachmentNames: record.sowReferenceAttachmentNames,
    sowReferenceAttachmentIds: collectAttachmentIds(record.sowReferenceAttachments),
    orgStructureAttachmentNames: record.orgStructureAttachmentNames,
    orgStructureAttachmentIds: collectAttachmentIds(record.orgStructureAttachments),
    contractType: record.contractType,
    signDate: record.signDate,
    contactPerson: record.contactPerson,
    partyA: record.partyA,
    projectManager: record.projectManager,
    phone: record.phone,
    wechat: record.wechat,
    address: record.address,
    email: record.email,
    contractQuoteAmount: record.contractQuoteAmount,
    paymentLines: record.paymentLines.map(line => ({
      id: /^\d+$/.test(line.id) ? Number(line.id) : undefined,
      termName: line.termName,
      settlementMethod: line.settlementMethod || '',
      paymentRatio: line.paymentRatio ?? 0,
      node: line.node,
      remark: line.remark
    })),
    productLines: record.productLines.map(line => ({
      id: /^\d+$/.test(line.id) ? Number(line.id) : undefined,
      productId: line.productId!,
      productName: line.productName,
      categoryLabel: line.categoryLabel,
      version: line.version,
      quantity: line.quantity,
      amountWithTax: line.amountWithTax
    })),
    implementationLines: record.implementationLines.map(line => ({
      id: /^\d+$/.test(line.id) ? Number(line.id) : undefined,
      moduleName: line.moduleName,
      subModuleName: line.subModuleName,
      description: line.description,
      remark: line.remark
    })),
    orgScopeLines: record.orgScopeLines.map((line, index) => ({
      id: /^\d+$/.test(line.id) ? Number(line.id) : undefined,
      seq: line.seq || index + 1,
      orgName: line.orgName,
      companyName: line.companyName,
      companyQualification: line.companyQualification
    })),
    integrationLines: record.integrationLines.map(line => ({
      id: /^\d+$/.test(line.id) ? Number(line.id) : undefined,
      involvedSystem: line.involvedSystem,
      integrationContent: line.integrationContent,
      interfaceCaller: line.interfaceCaller,
      interfaceProvider: line.interfaceProvider,
      interfaceDescription: line.interfaceDescription,
      integrationMethod: line.integrationMethod
    })),
    dataConversionLines: record.dataConversionLines.map((line, index) => ({
      id: /^\d+$/.test(line.id) ? Number(line.id) : undefined,
      seq: line.seq || index + 1,
      dataName: line.dataName,
      scopeDescription: line.scopeDescription
    })),
    trainingLines: record.trainingLines.map(line => ({
      id: /^\d+$/.test(line.id) ? Number(line.id) : undefined,
      trainingContent: line.trainingContent,
      trainer: line.trainer,
      targetAudience: line.targetAudience,
      trainingMethod: line.trainingMethod,
      trainingLocation: line.trainingLocation
    })),
    goLiveSupportLines: record.goLiveSupportLines.map((line, index) => ({
      id: /^\d+$/.test(line.id) ? Number(line.id) : undefined,
      seq: line.seq || index + 1,
      supportContent: line.supportContent,
      completionCriteria: line.completionCriteria
    })),
    implementationStrategyLines: record.implementationStrategyLines.map((line, index) => ({
      id: /^\d+$/.test(line.id) ? Number(line.id) : undefined,
      seq: line.seq || index + 1,
      businessSegment: line.businessSegment,
      orgScope: line.orgScope,
      subBranches: line.subBranches,
      phaseStrategy: line.phaseStrategy,
      pilot: line.pilot,
      promotion: line.promotion,
      promotionResponsible: line.promotionResponsible,
      locationCentralized: line.locationCentralized,
      locationDecentralized: line.locationDecentralized,
      locationRemoteCentralized: line.locationRemoteCentralized,
      locationRemoteDecentralized: line.locationRemoteDecentralized
    }))
  };
}

/** 从合同立项接口返回后，为子表行生成前端临时 id */
export function withFreshLineIds(record: ProjectInitRecord): ProjectInitRecord {
  return {
    ...record,
    paymentLines: record.paymentLines.map(item => ({ ...item, id: newLineId() })),
    productLines: record.productLines.map(item => ({ ...item, id: newLineId() })),
    implementationLines: record.implementationLines.map(item => ({ ...item, id: newLineId() })),
    orgScopeLines: record.orgScopeLines.map(item => ({ ...item, id: newLineId() })),
    integrationLines: record.integrationLines.map(item => ({ ...item, id: newLineId() })),
    dataConversionLines: record.dataConversionLines.map(item => ({ ...item, id: newLineId() })),
    trainingLines: record.trainingLines.map(item => ({ ...item, id: newLineId() })),
    goLiveSupportLines: record.goLiveSupportLines.map(item => ({ ...item, id: newLineId() })),
    implementationStrategyLines: record.implementationStrategyLines.map(item => ({ ...item, id: newLineId() }))
  };
}
