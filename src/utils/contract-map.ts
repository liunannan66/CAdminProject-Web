import type { ContractStatus, ContractType } from '@/constants/contract';
import type {
  ContractAttachmentDto,
  ContractDto,
  ContractPaymentLineDto,
  ContractProductLineDto,
  ContractSaveDto
} from '@/service/api/contract';
import type {
  ContractPaymentLine,
  ContractProductLine,
  ContractRecord
} from '@/views/contract/manage/modules/contract-operate-drawer.vue';

const MAX_ATTACHMENT_ID = 2147483647;

function collectAttachmentIds(attachments?: ContractAttachmentDto[]) {
  return (attachments ?? [])
    .map(item => Number(item.id))
    .filter(id => Number.isFinite(id) && id > 0 && id <= MAX_ATTACHMENT_ID);
}

function mapPaymentLine(dto: ContractPaymentLineDto): ContractPaymentLine {
  return {
    id: String(dto.id),
    termName: dto.termName,
    settlementMethod: (dto.settlementMethod || '') as ContractPaymentLine['settlementMethod'],
    paymentRatio: dto.paymentRatio,
    node: dto.node,
    remark: dto.remark ?? ''
  };
}

function mapProductLine(dto: ContractProductLineDto): ContractProductLine {
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

/** 后端 DTO → 页面 ContractRecord */
export function mapContractDtoToRecord(dto: ContractDto): ContractRecord {
  const contractAttachments =
    dto.contractAttachments ??
    (dto.contractAttachmentNames ?? []).map(fileName => ({
      id: 0,
      fileName,
      fileSize: 0
    }));
  const requirementAttachments =
    dto.requirementAttachments ??
    (dto.requirementAttachmentNames ?? []).map(fileName => ({
      id: 0,
      fileName,
      fileSize: 0
    }));

  return {
    id: dto.id,
    contractNo: dto.contractNo,
    contractName: dto.contractName,
    status: (dto.status || 'draft') as ContractStatus,
    customerName: dto.customerName,
    signDate: dto.signDate,
    contractType: dto.contractType as ContractType,
    deliveryDate: dto.deliveryDate,
    salesOwner: dto.salesOwner,
    quoteAmount: dto.quoteAmount,
    milestone: dto.milestone ?? '',
    remark: dto.remark ?? '',
    approvalFlow: dto.approvalFlow ?? '',
    paymentLines: (dto.paymentLines ?? []).map(mapPaymentLine),
    productLines: (dto.productLines ?? []).map(mapProductLine),
    contractAttachmentNames: dto.contractAttachmentNames ?? [],
    requirementAttachmentNames: dto.requirementAttachmentNames ?? [],
    contractAttachments,
    requirementAttachments,
    createTime: dto.createTime,
    creator: dto.creator,
    salesOpportunity: dto.salesOpportunity,
    receivedTotal: dto.receivedTotal,
    invoicedAmount: dto.invoicedAmount
  };
}

/** 页面 ContractRecord → 后端保存 DTO */
export function mapContractRecordToSave(record: ContractRecord): ContractSaveDto {
  return {
    id: record.id > 0 ? record.id : undefined,
    contractNo: record.contractNo,
    contractName: record.contractName,
    customerName: record.customerName,
    signDate: record.signDate,
    contractType: record.contractType,
    deliveryDate: record.deliveryDate,
    salesOwner: record.salesOwner,
    quoteAmount: Number(record.quoteAmount ?? 0),
    milestone: record.milestone,
    remark: record.remark,
    approvalFlow: record.approvalFlow || undefined,
    contractAttachmentNames: record.contractAttachmentNames,
    requirementAttachmentNames: record.requirementAttachmentNames,
    contractAttachmentIds: collectAttachmentIds(record.contractAttachments),
    requirementAttachmentIds: collectAttachmentIds(record.requirementAttachments),
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
    }))
  };
}
