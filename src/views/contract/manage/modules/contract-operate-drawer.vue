<script setup lang="ts">
import { computed, reactive, ref, watch } from 'vue';
import type { FormInstance, FormRules, UploadFile, UploadRawFile, UploadUserFile } from 'element-plus';
import { ElMessage } from 'element-plus';
import {
  CONTRACT_SALES_OWNER_OPTIONS,
  CONTRACT_TYPE_OPTIONS,
  type ContractStatus,
  type ContractType
} from '@/constants/contract';
import {
  PAYMENT_TERM_SETTLEMENT_OPTIONS,
  SETTLEMENT_METHOD_LABEL,
  type PaymentSettlementMethod
} from '@/constants/basedata-payment-term';
import { addContract, updateContract } from '@/service/api/contract';
import type { ContractAttachmentDto } from '@/service/api/contract';
import { getPaymentTermListEnabled, getProductListEnabled } from '@/service/api/basedata';
import { deleteFile, uploadFile as uploadFileApi } from '@/service/api/file';
import type { FileUploadResult } from '@/service/api/file';
import { mapContractRecordToSave } from '@/utils/contract-map';

defineOptions({ name: 'ContractOperateDrawer' });

/** 收款条件行 */
export interface ContractPaymentLine {
  id: string;
  termName: string;
  settlementMethod: PaymentSettlementMethod | '';
  paymentRatio: number | null;
  node: string;
  remark: string;
}

/** 项目产品行 */
export interface ContractProductLine {
  id: string;
  productId: number | null;
  productName: string;
  categoryLabel: string;
  version: string;
  quantity: number;
  amountWithTax: number;
}

/** 合同记录 */
export interface ContractRecord {
  id: number;
  contractNo: string;
  contractName: string;
  status: ContractStatus;
  customerName: string;
  signDate: string;
  contractType: ContractType;
  deliveryDate: string;
  salesOwner: string;
  quoteAmount: number;
  milestone: string;
  remark: string;
  approvalFlow: string;
  paymentLines: ContractPaymentLine[];
  productLines: ContractProductLine[];
  contractAttachmentNames: string[];
  requirementAttachmentNames: string[];
  contractAttachments?: ContractAttachmentDto[];
  requirementAttachments?: ContractAttachmentDto[];
  createTime?: string;
  creator?: string;
  salesOpportunity?: string;
  receivedTotal?: number;
  invoicedAmount?: number;
}

interface Props {
  title: string;
  contract: ContractRecord | null;
}

const props = defineProps<Props>();
const visible = defineModel<boolean>('visible', { default: false });

const emit = defineEmits<{
  submitted: [];
}>();

const activeTab = ref('basic');
const formRef = ref<FormInstance>();
const saving = ref(false);
const productOptions = ref<Api.Basedata.ProductEnabledItem[]>([]);
const paymentTermOptions = ref<Api.Basedata.PaymentTermRecord[]>([]);
const showPaymentTermDialog = ref(false);
const selectedPaymentTerms = ref<Api.Basedata.PaymentTermRecord[]>([]);

const contractUploadList = ref<UploadUserFile[]>([]);
const requirementUploadList = ref<UploadUserFile[]>([]);

const paymentLines = ref<ContractPaymentLine[]>([]);
const productLines = ref<ContractProductLine[]>([]);

const formModel = reactive({
  contractNo: '',
  customerName: '',
  signDate: '',
  contractType: 'self' as ContractType,
  deliveryDate: '',
  salesOwner: '',
  quoteAmount: null as number | null,
  milestone: '',
  remark: '',
  approvalFlow: ''
});

const rules: FormRules = {
  contractNo: [{ required: true, message: '请输入合同编号', trigger: 'blur' }],
  customerName: [{ required: true, message: '请输入客户名称', trigger: 'blur' }],
  signDate: [{ required: true, message: '请选择签约日期', trigger: 'change' }],
  contractType: [{ required: true, message: '请选择合同类型', trigger: 'change' }],
  deliveryDate: [{ required: true, message: '请选择交付日期', trigger: 'change' }],
  salesOwner: [{ required: true, message: '请选择销售负责人', trigger: 'change' }]
};

const isEdit = computed(() => Boolean(props.contract?.id));

function newLineId() {
  return `${Date.now()}_${Math.random().toString(36).slice(2, 8)}`;
}

function createEmptyPaymentLine(): ContractPaymentLine {
  return {
    id: newLineId(),
    termName: '',
    settlementMethod: '',
    paymentRatio: null,
    node: '',
    remark: ''
  };
}

function createEmptyProductLine(): ContractProductLine {
  return {
    id: newLineId(),
    productId: null,
    productName: '',
    categoryLabel: '',
    version: '',
    quantity: 1,
    amountWithTax: 0
  };
}

function resetForm() {
  formModel.contractNo = '';
  formModel.customerName = '';
  formModel.signDate = '';
  formModel.contractType = 'self';
  formModel.deliveryDate = '';
  formModel.salesOwner = '';
  formModel.quoteAmount = null;
  formModel.milestone = '';
  formModel.remark = '';
  formModel.approvalFlow = '';
  paymentLines.value = [createEmptyPaymentLine()];
  productLines.value = [createEmptyProductLine()];
  contractUploadList.value = [];
  requirementUploadList.value = [];
  activeTab.value = 'basic';
  formRef.value?.clearValidate();
}

function fillForm(record: ContractRecord) {
  formModel.contractNo = record.contractNo;
  formModel.customerName = record.customerName;
  formModel.signDate = record.signDate;
  formModel.contractType = record.contractType;
  formModel.deliveryDate = record.deliveryDate;
  formModel.salesOwner = record.salesOwner;
  formModel.quoteAmount = record.quoteAmount;
  formModel.milestone = record.milestone;
  formModel.remark = record.remark;
  formModel.approvalFlow = record.approvalFlow;
  paymentLines.value = record.paymentLines.map(item => ({ ...item }));
  productLines.value = record.productLines.map(item => ({ ...item }));
  contractUploadList.value = mapAttachmentsToUploadList(record.contractAttachments);
  requirementUploadList.value = mapAttachmentsToUploadList(record.requirementAttachments);
}

function mapAttachmentsToUploadList(attachments?: ContractAttachmentDto[]) {
  return (attachments ?? [])
    .filter(item => item.id > 0)
    .map(item => ({
      name: item.fileName,
      uid: item.id,
      status: 'success' as const,
      response: { id: item.id, fileName: item.fileName, fileSize: item.fileSize }
    }));
}

/** 与后端 BizAttachment.Id（int）一致，ElUpload 默认 uid 为时间戳，不能当作附件 id */
const MAX_ATTACHMENT_ID = 2147483647;

function parseUploadResponse(response: unknown): FileUploadResult | null {
  if (!response || typeof response !== 'object') return null;
  const root = response as Record<string, unknown>;
  const payload = (root.body && typeof root.body === 'object' ? root.body : root) as Record<string, unknown>;
  const id = Number(payload.id ?? payload.Id);
  if (!Number.isFinite(id) || id <= 0 || id > MAX_ATTACHMENT_ID) return null;
  return {
    id,
    fileName: String(payload.fileName ?? payload.FileName ?? ''),
    fileSize: Number(payload.fileSize ?? payload.FileSize ?? 0),
    contentType: (payload.contentType ?? payload.ContentType) as string | undefined
  };
}

function resolveUploadAttachmentId(file: UploadUserFile): number | null {
  const parsed = parseUploadResponse(file.response);
  if (parsed) return parsed.id;
  if (typeof file.uid === 'number' && file.uid > 0 && file.uid <= MAX_ATTACHMENT_ID) return file.uid;
  if (typeof file.uid === 'string' && /^\d+$/.test(file.uid)) {
    const uidNum = Number(file.uid);
    if (uidNum > 0 && uidNum <= MAX_ATTACHMENT_ID) return uidNum;
  }
  return null;
}

function hasInvalidAttachmentIds(fileList: UploadUserFile[]) {
  return fileList.some(file => {
    if (file.status === 'uploading' || file.status === 'ready') return false;
    if (file.status === 'fail') return true;
    return !resolveUploadAttachmentId(file);
  });
}

function isUploadFinished(file: UploadUserFile) {
  if (file.status === 'success') return true;
  if (file.status === 'fail') return false;
  // 自定义 http-request 已写入有效 response 时视为上传完成（避免 uid 未同步导致一直 ready/uploading）
  return resolveUploadAttachmentId(file) != null;
}

function hasPendingUploads(fileList: UploadUserFile[]) {
  return fileList.some(file => {
    if (isUploadFinished(file)) return false;
    return file.status === 'uploading' || file.status === 'ready';
  });
}

function hasFailedUploads(fileList: UploadUserFile[]) {
  return fileList.some(file => file.status === 'fail');
}

function collectAttachmentsFromUploadList(fileList: UploadUserFile[]): ContractAttachmentDto[] {
  return fileList
    .map(file => {
      const parsed = parseUploadResponse(file.response);
      const id = parsed?.id ?? resolveUploadAttachmentId(file);
      if (!id) return null;
      return {
        id,
        fileName: parsed?.fileName || file.name,
        fileSize: parsed?.fileSize ?? 0,
        contentType: parsed?.contentType
      };
    })
    .filter((item): item is ContractAttachmentDto => item !== null);
}

function resolveUploadErrorMessage(error: unknown) {
  const err = error as { response?: { data?: { message?: string; body?: string } }; message?: string };
  return err.response?.data?.message || (typeof err.response?.data?.body === 'string' ? err.response.data.body : '') || err.message || '上传失败';
}

async function handleAttachmentChange(
  uploadFileItem: UploadFile,
  bizType: 'contract' | 'requirement'
) {
  if (uploadFileItem.status !== 'ready' || !uploadFileItem.raw) return;

  uploadFileItem.status = 'uploading';
  uploadFileItem.percentage = 30;

  try {
    const rawFile = uploadFileItem.raw instanceof File ? uploadFileItem.raw : (uploadFileItem.raw as UploadRawFile);
    const result = await uploadFileApi(rawFile, bizType);
    const parsed = parseUploadResponse(result);
    if (!parsed) {
      throw new Error('上传响应无效，未获取到附件编号');
    }
    uploadFileItem.status = 'success';
    uploadFileItem.response = parsed;
    uploadFileItem.uid = parsed.id;
    uploadFileItem.name = parsed.fileName || uploadFileItem.name;
    uploadFileItem.percentage = 100;
  } catch (error) {
    uploadFileItem.status = 'fail';
    ElMessage.error(resolveUploadErrorMessage(error));
    const listRef = bizType === 'contract' ? contractUploadList : requirementUploadList;
    listRef.value = listRef.value.filter(item => item.uid !== uploadFileItem.uid);
  }
}

async function handleUploadRemove(file: UploadUserFile, target: 'contract' | 'requirement') {
  const id = resolveUploadAttachmentId(file);
  if (!id) return true;

  const existing =
    target === 'contract'
      ? props.contract?.contractAttachments
      : props.contract?.requirementAttachments;
  if (existing?.some(item => item.id === id)) {
    return true;
  }

  try {
    await deleteFile(id);
    return true;
  } catch {
    ElMessage.warning('删除附件失败');
    return false;
  }
}

watch(
  () => visible.value,
  val => {
    if (!val) return;
    loadProductOptions();
    loadPaymentTermOptions();
    if (props.contract) {
      fillForm(props.contract);
    } else {
      resetForm();
    }
  }
);

async function loadProductOptions() {
  try {
    productOptions.value = (await getProductListEnabled()) ?? [];
  } catch {
    productOptions.value = [];
    ElMessage.warning('获取产品列表失败');
  }
}

async function loadPaymentTermOptions() {
  try {
    paymentTermOptions.value = (await getPaymentTermListEnabled()) ?? [];
  } catch {
    paymentTermOptions.value = [];
  }
}

function openPaymentTermDialog() {
  selectedPaymentTerms.value = [];
  showPaymentTermDialog.value = true;
}

function onPaymentTermSelectionChange(rows: Api.Basedata.PaymentTermRecord[]) {
  selectedPaymentTerms.value = rows;
}

function applySelectedPaymentTerms() {
  if (!selectedPaymentTerms.value.length) {
    ElMessage.warning('请至少选择一条付款条件');
    return;
  }
  const existingNames = new Set(paymentLines.value.map(item => item.termName.trim()));
  let added = 0;
  for (const term of selectedPaymentTerms.value) {
    if (existingNames.has(term.name.trim())) continue;
    paymentLines.value.push({
      id: newLineId(),
      termName: term.name,
      settlementMethod: (term.settlementMethod || '') as PaymentSettlementMethod,
      paymentRatio: term.paymentRatio,
      node: term.node,
      remark: term.remark ?? ''
    });
    existingNames.add(term.name.trim());
    added += 1;
  }
  if (added === 0) {
    ElMessage.info('所选条件均已存在，未重复添加');
  } else {
    ElMessage.success(`已添加 ${added} 条收款条件`);
  }
  showPaymentTermDialog.value = false;
}

function onProductChange(row: ContractProductLine, productId: number) {
  const product = productOptions.value.find(item => item.id === productId);
  if (!product) return;
  row.productId = product.id;
  row.productName = product.name;
  row.categoryLabel = product.categoryLabel;
  row.version = product.version;
}

function addPaymentLine() {
  paymentLines.value.push(createEmptyPaymentLine());
}

function removePaymentLine(id: string) {
  if (paymentLines.value.length <= 1) {
    ElMessage.warning('至少保留一条收款条件');
    return;
  }
  paymentLines.value = paymentLines.value.filter(item => item.id !== id);
}

function addProductLine() {
  productLines.value.push(createEmptyProductLine());
}

function removeProductLine(id: string) {
  if (productLines.value.length <= 1) {
    ElMessage.warning('至少保留一条项目产品');
    return;
  }
  productLines.value = productLines.value.filter(item => item.id !== id);
}

function buildPayload(): ContractRecord {
  const contractAttachments = collectAttachmentsFromUploadList(contractUploadList.value);
  const requirementAttachments = collectAttachmentsFromUploadList(requirementUploadList.value);
  const contractAttachmentNames = contractAttachments.map(item => item.fileName);
  const requirementAttachmentNames = requirementAttachments.map(item => item.fileName);
  const base = props.contract;

  return {
    id: base?.id ?? 0,
    contractNo: formModel.contractNo.trim(),
    contractName: base?.contractName ?? `${formModel.customerName.trim()}合同`,
    status: base?.status ?? 'draft',
    customerName: formModel.customerName.trim(),
    signDate: formModel.signDate,
    contractType: formModel.contractType,
    deliveryDate: formModel.deliveryDate,
    salesOwner: formModel.salesOwner,
    quoteAmount: Number(formModel.quoteAmount ?? 0),
    milestone: formModel.milestone.trim(),
    remark: formModel.remark.trim(),
    approvalFlow: formModel.approvalFlow,
    paymentLines: paymentLines.value.map(item => ({ ...item })),
    productLines: productLines.value.map(item => ({ ...item })),
    contractAttachmentNames,
    requirementAttachmentNames,
    contractAttachments,
    requirementAttachments,
    createTime: base?.createTime,
    creator: base?.creator,
    salesOpportunity: base?.salesOpportunity,
    receivedTotal: base?.receivedTotal,
    invoicedAmount: base?.invoicedAmount
  };
}

async function handleSave() {
  if (!formRef.value || saving.value) return;
  try {
    await formRef.value.validate();
  } catch {
    activeTab.value = 'basic';
    return;
  }
  const invalidPayment = paymentLines.value.some(
    item => !item.termName.trim() || !item.settlementMethod || !item.node.trim()
  );
  if (invalidPayment) {
    ElMessage.warning('请完善收款条件信息');
    activeTab.value = 'payment';
    return;
  }
  const invalidProduct = productLines.value.some(item => !item.productId);
  if (invalidProduct) {
    ElMessage.warning('请完善项目产品信息');
    activeTab.value = 'products';
    return;
  }
  if (hasPendingUploads(contractUploadList.value) || hasPendingUploads(requirementUploadList.value)) {
    ElMessage.warning('附件正在上传，请稍候再保存');
    activeTab.value = 'basic';
    return;
  }
  if (hasFailedUploads(contractUploadList.value) || hasFailedUploads(requirementUploadList.value)) {
    ElMessage.warning('存在上传失败的附件，请移除后重新上传');
    activeTab.value = 'basic';
    return;
  }
  if (hasInvalidAttachmentIds(contractUploadList.value) || hasInvalidAttachmentIds(requirementUploadList.value)) {
    ElMessage.warning('附件未获取到有效编号，请移除后重新上传');
    activeTab.value = 'basic';
    return;
  }

  const payload = buildPayload();
  saving.value = true;
  try {
    const apiData = mapContractRecordToSave(payload);
    if (isEdit.value) {
      await updateContract(apiData);
      ElMessage.success('保存成功');
    } else {
      await addContract(apiData);
      ElMessage.success('新增成功');
    }
    visible.value = false;
    emit('submitted');
  } catch {
    /* 业务错误由 request.onError 统一提示 */
  } finally {
    saving.value = false;
  }
}

</script>

<template>
  <ElDrawer v-model="visible" :title="title" size="100%" fullscreen destroy-on-close class="contract-drawer">
    <ElTabs v-model="activeTab" class="contract-tabs">
      <ElTabPane label="基本信息" name="basic">
        <ElForm ref="formRef" :model="formModel" :rules="rules" label-width="110px" class="pr-16px">
          <ElRow :gutter="16">
            <ElCol :lg="8" :md="12" :sm="24">
              <ElFormItem label="合同编号" prop="contractNo">
                <ElInput v-model="formModel.contractNo" placeholder="如 HT-2026-001" clearable />
              </ElFormItem>
            </ElCol>
            <ElCol :lg="8" :md="12" :sm="24">
              <ElFormItem label="客户名称" prop="customerName">
                <ElInput v-model="formModel.customerName" placeholder="签约客户全称" clearable />
              </ElFormItem>
            </ElCol>
            <ElCol :lg="8" :md="12" :sm="24">
              <ElFormItem label="合同类型" prop="contractType">
                <ElSelect v-model="formModel.contractType" class="w-full">
                  <ElOption
                    v-for="item in CONTRACT_TYPE_OPTIONS"
                    :key="item.value"
                    :label="item.label"
                    :value="item.value"
                  />
                </ElSelect>
              </ElFormItem>
            </ElCol>
            <ElCol :lg="8" :md="12" :sm="24">
              <ElFormItem label="签约日期" prop="signDate">
                <ElDatePicker
                  v-model="formModel.signDate"
                  type="date"
                  value-format="YYYY-MM-DD"
                  placeholder="选择签约日期"
                  class="w-full"
                />
              </ElFormItem>
            </ElCol>
            <ElCol :lg="8" :md="12" :sm="24">
              <ElFormItem label="交付日期" prop="deliveryDate">
                <ElDatePicker
                  v-model="formModel.deliveryDate"
                  type="date"
                  value-format="YYYY-MM-DD"
                  placeholder="选择交付日期"
                  class="w-full"
                />
              </ElFormItem>
            </ElCol>
            <ElCol :lg="8" :md="12" :sm="24">
              <ElFormItem label="销售负责人" prop="salesOwner">
                <ElSelect v-model="formModel.salesOwner" placeholder="请选择" clearable class="w-full">
                  <ElOption v-for="name in CONTRACT_SALES_OWNER_OPTIONS" :key="name" :label="name" :value="name" />
                </ElSelect>
              </ElFormItem>
            </ElCol>
            <ElCol :lg="8" :md="12" :sm="24">
              <ElFormItem label="产品报价(元)">
                <ElInputNumber
                  v-model="formModel.quoteAmount"
                  :min="0"
                  :precision="2"
                  :step="1000"
                  controls-position="right"
                  class="w-full"
                />
              </ElFormItem>
            </ElCol>
            <ElCol :span="24">
              <ElFormItem label="里程碑">
                <ElInput
                  v-model="formModel.milestone"
                  type="textarea"
                  :rows="2"
                  placeholder="项目关键节点说明，如一期上线、二期验收等"
                />
              </ElFormItem>
            </ElCol>
            <ElCol :span="24">
              <ElFormItem label="备注">
                <ElInput v-model="formModel.remark" type="textarea" :rows="2" placeholder="合同补充说明" />
              </ElFormItem>
            </ElCol>
            <ElCol :lg="12" :span="24">
              <ElFormItem label="合同附件">
                <ElUpload
                  v-model:file-list="contractUploadList"
                  action="#"
                  :auto-upload="false"
                  :on-change="file => handleAttachmentChange(file, 'contract')"
                  :before-remove="file => handleUploadRemove(file, 'contract')"
                  multiple
                >
                  <ElButton type="primary" plain>选择文件</ElButton>
                  <template #tip>
                    <div class="text-12px text-gray-500">支持 pdf/doc/xls/图片/音视频等，单文件最大 100MB</div>
                  </template>
                </ElUpload>
              </ElFormItem>
            </ElCol>
            <ElCol :lg="12" :span="24">
              <ElFormItem label="项目需求">
                <ElUpload
                  v-model:file-list="requirementUploadList"
                  action="#"
                  :auto-upload="false"
                  :on-change="file => handleAttachmentChange(file, 'requirement')"
                  :before-remove="file => handleUploadRemove(file, 'requirement')"
                  multiple
                >
                  <ElButton type="primary" plain>选择文件（可多选）</ElButton>
                  <template #tip>
                    <div class="text-12px text-gray-500">可上传需求文档、语音或视频</div>
                  </template>
                </ElUpload>
              </ElFormItem>
            </ElCol>
          </ElRow>
        </ElForm>
      </ElTabPane>

      <ElTabPane label="收款条件" name="payment">
        <div class="mb-12px flex justify-end gap-8px">
          <ElButton type="primary" plain @click="openPaymentTermDialog">从付款条件库选择</ElButton>
          <ElButton type="primary" plain @click="addPaymentLine">新增收款条件</ElButton>
        </div>
        <ElTable border :data="paymentLines" row-key="id" max-height="420">
          <ElTableColumn label="条件名称" min-width="140">
            <template #default="{ row }">
              <ElInput v-model="row.termName" placeholder="如合同签订预付款" />
            </template>
          </ElTableColumn>
          <ElTableColumn label="结算方式" width="140">
            <template #default="{ row }">
              <ElSelect v-model="row.settlementMethod" placeholder="请选择" class="w-full">
                <ElOption
                  v-for="opt in PAYMENT_TERM_SETTLEMENT_OPTIONS"
                  :key="opt.value"
                  :label="opt.label"
                  :value="opt.value"
                />
              </ElSelect>
            </template>
          </ElTableColumn>
          <ElTableColumn label="支付比例(%)" width="120">
            <template #default="{ row }">
              <ElInputNumber v-model="row.paymentRatio" :min="0" :max="100" :precision="2" class="w-full" />
            </template>
          </ElTableColumn>
          <ElTableColumn label="节点" min-width="160">
            <template #default="{ row }">
              <ElInput v-model="row.node" placeholder="付款触发节点" />
            </template>
          </ElTableColumn>
          <ElTableColumn label="备注" min-width="120">
            <template #default="{ row }">
              <ElInput v-model="row.remark" placeholder="备注" />
            </template>
          </ElTableColumn>
          <ElTableColumn label="操作" width="80" align="center" fixed="right">
            <template #default="{ row }">
              <ElButton type="danger" link @click="removePaymentLine(row.id)">删除</ElButton>
            </template>
          </ElTableColumn>
        </ElTable>
      </ElTabPane>

      <ElTabPane label="项目产品" name="products">
        <div class="mb-12px flex justify-end">
          <ElButton type="primary" plain @click="addProductLine">新增产品行</ElButton>
        </div>
        <ElTable border :data="productLines" row-key="id" max-height="420">
          <ElTableColumn label="产品名称" min-width="180">
            <template #default="{ row }">
              <ElSelect
                :model-value="row.productId"
                placeholder="选择产品"
                class="w-full"
                filterable
                @update:model-value="(val: number) => onProductChange(row, val)"
              >
                <ElOption
                  v-for="p in productOptions"
                  :key="p.id"
                  :label="`${p.name} (${p.version})`"
                  :value="p.id"
                />
              </ElSelect>
            </template>
          </ElTableColumn>
          <ElTableColumn prop="categoryLabel" label="产品类别" width="110" />
          <ElTableColumn prop="version" label="产品版本" width="100" />
          <ElTableColumn label="数量" width="100">
            <template #default="{ row }">
              <ElInputNumber v-model="row.quantity" :min="1" :precision="0" class="w-full" />
            </template>
          </ElTableColumn>
          <ElTableColumn label="价税合计(元)" width="140">
            <template #default="{ row }">
              <ElInputNumber v-model="row.amountWithTax" :min="0" :precision="2" class="w-full" />
            </template>
          </ElTableColumn>
          <ElTableColumn label="操作" width="80" align="center" fixed="right">
            <template #default="{ row }">
              <ElButton type="danger" link @click="removeProductLine(row.id)">删除</ElButton>
            </template>
          </ElTableColumn>
        </ElTable>
      </ElTabPane>
    </ElTabs>

    <template #footer>
      <ElSpace class="drawer-footer">
        <ElButton @click="visible = false">取消</ElButton>
        <ElButton type="primary" :loading="saving" @click="handleSave">保存</ElButton>
      </ElSpace>
    </template>
  </ElDrawer>

  <ElDialog v-model="showPaymentTermDialog" title="从付款条件库选择" width="720px" append-to-body destroy-on-close>
    <ElTable
      border
      :data="paymentTermOptions"
      row-key="id"
      max-height="400"
      @selection-change="onPaymentTermSelectionChange"
    >
      <ElTableColumn type="selection" width="48" />
      <ElTableColumn prop="name" label="条件名称" min-width="140" show-overflow-tooltip />
      <ElTableColumn label="结算方式" width="100">
        <template #default="{ row }">
          {{ SETTLEMENT_METHOD_LABEL[row.settlementMethod as PaymentSettlementMethod] ?? row.settlementMethod }}
        </template>
      </ElTableColumn>
      <ElTableColumn prop="paymentRatio" label="比例(%)" width="90" align="center" />
      <ElTableColumn prop="node" label="节点" min-width="160" show-overflow-tooltip />
      <ElTableColumn prop="remark" label="备注" min-width="100" show-overflow-tooltip />
    </ElTable>
    <template #footer>
      <ElButton @click="showPaymentTermDialog = false">取消</ElButton>
      <ElButton type="primary" @click="applySelectedPaymentTerms">确定添加</ElButton>
    </template>
  </ElDialog>
</template>

<style lang="scss" scoped>
.contract-tabs {
  min-height: 360px;
}

.drawer-footer {
  justify-content: flex-end;
  width: 100%;
}
</style>
