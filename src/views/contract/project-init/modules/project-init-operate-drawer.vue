<script setup lang="ts">
import { computed, reactive, ref, watch } from 'vue';
import type { FormInstance, FormRules, UploadFile, UploadUserFile } from 'element-plus';
import type { UploadRawFile } from 'element-plus';
import { ElMessage } from 'element-plus';
import type { ContractAttachmentDto } from '@/service/api/contract';
import {
  deleteFile,
  resolveStaticFileUrl,
  uploadFile as uploadFileApi,
  type FileUploadResult
} from '@/service/api/file';
import {
  CONTRACT_SALES_OWNER_OPTIONS,
  CONTRACT_TYPE_OPTIONS,
  type ContractType
} from '@/constants/contract';
import { PAYMENT_TERM_SETTLEMENT_OPTIONS, type PaymentSettlementMethod } from '@/constants/basedata-payment-term';
import { PROJECT_INIT_TYPE_OPTIONS, type ProjectInitType } from '@/constants/project-init';
import { addProjectInit, updateProjectInit } from '@/service/api/project-init';
import { getProductListEnabled } from '@/service/api/basedata';
import { mapProjectInitRecordToSave } from '@/utils/project-init-map';
import {
  createEmptyDataConversionLine,
  createEmptyGoLiveSupportLine,
  createEmptyImplementationStrategyLine,
  createEmptyImplementationLine,
  createEmptyIntegrationLine,
  createEmptyOrgScopeLine,
  createEmptyTrainingLine,
  formatTabLabel,
  type ProjectInitRecord,
  type ProjectDataConversionLine,
  type ProjectGoLiveSupportLine,
  type ProjectImplementationStrategyLine,
  type ProjectImplementationLine,
  type ProjectIntegrationLine,
  type ProjectOrgScopeLine,
  type ProjectTrainingLine
} from '@/utils/project-init';
import type { ContractPaymentLine, ContractProductLine } from '@/views/contract/manage/modules/contract-operate-drawer.vue';

defineOptions({ name: 'ProjectInitOperateDrawer' });

interface Props {
  title: string;
  record: ProjectInitRecord | null;
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

const paymentLines = ref<ContractPaymentLine[]>([]);
const productLines = ref<ContractProductLine[]>([]);
const implementationLines = ref<ProjectImplementationLine[]>([]);
const orgScopeLines = ref<ProjectOrgScopeLine[]>([]);
const integrationLines = ref<ProjectIntegrationLine[]>([]);
const dataConversionLines = ref<ProjectDataConversionLine[]>([]);
const trainingLines = ref<ProjectTrainingLine[]>([]);
const goLiveSupportLines = ref<ProjectGoLiveSupportLine[]>([]);
const implementationStrategyLines = ref<ProjectImplementationStrategyLine[]>([]);

const formModel = reactive({
  projectNo: '',
  projectName: '',
  projectType: 'self' as ProjectInitType,
  contractId: 0,
  contractNo: '',
  contractName: '',
  customerName: '',
  planStartDate: '',
  planEndDate: '',
  background: '',
  objective: '',
  milestone: '',
  customDevelopmentScope: '',
  contractType: 'self' as ContractType,
  signDate: '',
  contactPerson: '',
  partyA: '',
  projectManager: '',
  phone: '',
  wechat: '',
  address: '',
  email: '',
  contractQuoteAmount: 0
});

function formatAmount(amount: number) {
  return amount.toLocaleString('zh-CN', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
}

const attachmentNames = ref<string[]>([]);
const requirementAttachmentNames = ref<string[]>([]);
const sowReferenceUploadList = ref<UploadUserFile[]>([]);
const sowReferenceAttachments = ref<ContractAttachmentDto[]>([]);
const orgStructureUploadList = ref<UploadUserFile[]>([]);
const orgStructureAttachments = ref<ContractAttachmentDto[]>([]);

const rules: FormRules = {
  projectName: [{ required: true, message: '请输入项目名称', trigger: 'blur' }],
  planStartDate: [{ required: true, message: '请选择预计开始日期', trigger: 'change' }],
  planEndDate: [{ required: true, message: '请选择预计完工日期', trigger: 'change' }],
  partyA: [{ required: true, message: '请输入甲方', trigger: 'blur' }],
  projectManager: [{ required: true, message: '请选择项目经理', trigger: 'change' }]
};

const isEdit = computed(() => Boolean(props.record?.id));

const paymentCount = computed(() => paymentLines.value.length);
const productCount = computed(() => productLines.value.length);
const implementationCount = computed(() => implementationLines.value.length);
const orgScopeCount = computed(() => orgScopeLines.value.length);
const dataConversionCount = computed(() => dataConversionLines.value.length);
const trainingCount = computed(() => trainingLines.value.length);
const integrationCount = computed(() => integrationLines.value.length);
const goLiveSupportCount = computed(() => goLiveSupportLines.value.length);
const implementationStrategyCount = computed(() => implementationStrategyLines.value.length);
const sowReferenceCount = computed(() => sowReferenceUploadList.value.length);
const orgStructureCount = computed(() => orgStructureUploadList.value.length);
const requirementCount = computed(() => requirementAttachmentNames.value.length);

function resetForm() {
  formModel.projectNo = '';
  formModel.projectName = '';
  formModel.projectType = 'self';
  formModel.contractId = 0;
  formModel.contractNo = '';
  formModel.contractName = '';
  formModel.customerName = '';
  formModel.planStartDate = '';
  formModel.planEndDate = '';
  formModel.background = '';
  formModel.objective = '';
  formModel.milestone = '';
  formModel.customDevelopmentScope = '';
  formModel.contractType = 'self';
  formModel.signDate = '';
  formModel.contactPerson = '';
  formModel.partyA = '';
  formModel.projectManager = '';
  formModel.phone = '';
  formModel.wechat = '';
  formModel.address = '';
  formModel.email = '';
  formModel.contractQuoteAmount = 0;
  attachmentNames.value = [];
  requirementAttachmentNames.value = [];
  sowReferenceUploadList.value = [];
  sowReferenceAttachments.value = [];
  orgStructureUploadList.value = [];
  orgStructureAttachments.value = [];
  paymentLines.value = [];
  productLines.value = [];
  implementationLines.value = [createEmptyImplementationLine()];
  orgScopeLines.value = [createEmptyOrgScopeLine(1)];
  integrationLines.value = [createEmptyIntegrationLine()];
  dataConversionLines.value = [createEmptyDataConversionLine(1)];
  trainingLines.value = [createEmptyTrainingLine()];
  goLiveSupportLines.value = [createEmptyGoLiveSupportLine(1)];
  implementationStrategyLines.value = [createEmptyImplementationStrategyLine(1)];
  activeTab.value = 'basic';
  formRef.value?.clearValidate();
}

function fillForm(record: ProjectInitRecord) {
  formModel.projectNo = record.projectNo;
  formModel.projectName = record.projectName;
  formModel.projectType = record.projectType;
  formModel.contractId = record.contractId;
  formModel.contractNo = record.contractNo;
  formModel.contractName = record.contractName;
  formModel.customerName = record.customerName;
  formModel.planStartDate = record.planStartDate;
  formModel.planEndDate = record.planEndDate;
  formModel.background = record.background;
  formModel.objective = record.objective;
  formModel.milestone = record.milestone;
  formModel.customDevelopmentScope = record.customDevelopmentScope;
  formModel.contractType = record.contractType;
  formModel.signDate = record.signDate;
  formModel.contactPerson = record.contactPerson;
  formModel.partyA = record.partyA;
  formModel.projectManager = record.projectManager;
  formModel.phone = record.phone;
  formModel.wechat = record.wechat;
  formModel.address = record.address;
  formModel.email = record.email;
  formModel.contractQuoteAmount = record.contractQuoteAmount ?? 0;
  attachmentNames.value = [...record.attachmentNames];
  requirementAttachmentNames.value = [...record.requirementAttachmentNames];
  sowReferenceAttachments.value = [...(record.sowReferenceAttachments ?? [])];
  sowReferenceUploadList.value = mapAttachmentsToUploadList(record.sowReferenceAttachments);
  orgStructureAttachments.value = [...(record.orgStructureAttachments ?? [])];
  orgStructureUploadList.value = mapImageAttachmentsToUploadList(record.orgStructureAttachments);
  paymentLines.value = record.paymentLines.map(item => ({ ...item }));
  productLines.value = record.productLines.map(item => ({ ...item }));
  implementationLines.value = record.implementationLines.length
    ? record.implementationLines.map(item => ({ ...item }))
    : [createEmptyImplementationLine()];
  orgScopeLines.value = record.orgScopeLines.length
    ? record.orgScopeLines.map(item => ({ ...item }))
    : [createEmptyOrgScopeLine(1)];
  integrationLines.value = record.integrationLines?.length
    ? record.integrationLines.map(item => ({ ...item }))
    : [createEmptyIntegrationLine()];
  dataConversionLines.value = record.dataConversionLines?.length
    ? record.dataConversionLines.map(item => ({ ...item }))
    : [createEmptyDataConversionLine(1)];
  trainingLines.value = record.trainingLines?.length
    ? record.trainingLines.map(item => ({ ...item }))
    : [createEmptyTrainingLine()];
  goLiveSupportLines.value = record.goLiveSupportLines?.length
    ? record.goLiveSupportLines.map(item => ({ ...item }))
    : [createEmptyGoLiveSupportLine(1)];
  implementationStrategyLines.value = record.implementationStrategyLines?.length
    ? record.implementationStrategyLines.map(item => ({ ...item }))
    : [createEmptyImplementationStrategyLine(1, record.customerName || record.partyA)];
}

watch(
  () => visible.value,
  val => {
    if (!val) return;
    loadProductOptions();
    if (props.record) {
      fillForm(props.record);
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
  }
}

function onProductChange(row: ContractProductLine, productId: number) {
  const product = productOptions.value.find(item => item.id === productId);
  if (!product) return;
  row.productId = product.id;
  row.productName = product.name;
  row.categoryLabel = product.categoryLabel;
  row.version = product.version;
}

function addImplementationLine() {
  implementationLines.value.push(createEmptyImplementationLine());
}

function removeImplementationLine(id: string) {
  if (implementationLines.value.length <= 1) {
    ElMessage.warning('至少保留一条实施功能范围');
    return;
  }
  implementationLines.value = implementationLines.value.filter(item => item.id !== id);
}

function addOrgScopeLine() {
  orgScopeLines.value.push(createEmptyOrgScopeLine(orgScopeLines.value.length + 1));
}

function removeOrgScopeLine(id: string) {
  if (orgScopeLines.value.length <= 1) {
    ElMessage.warning('至少保留一条组织范围');
    return;
  }
  orgScopeLines.value = orgScopeLines.value.filter(item => item.id !== id);
}

function addIntegrationLine() {
  integrationLines.value.push(createEmptyIntegrationLine());
}

function removeIntegrationLine(id: string) {
  if (integrationLines.value.length <= 1) {
    ElMessage.warning('至少保留一条系统集成范围');
    return;
  }
  integrationLines.value = integrationLines.value.filter(item => item.id !== id);
}

function addDataConversionLine() {
  dataConversionLines.value.push(createEmptyDataConversionLine(dataConversionLines.value.length + 1));
}

function removeDataConversionLine(id: string) {
  if (dataConversionLines.value.length <= 1) {
    ElMessage.warning('至少保留一条初始数据转换范围');
    return;
  }
  dataConversionLines.value = dataConversionLines.value.filter(item => item.id !== id);
}

function addTrainingLine() {
  trainingLines.value.push(createEmptyTrainingLine());
}

function removeTrainingLine(id: string) {
  if (trainingLines.value.length <= 1) {
    ElMessage.warning('至少保留一条培训服务');
    return;
  }
  trainingLines.value = trainingLines.value.filter(item => item.id !== id);
}

function addGoLiveSupportLine() {
  goLiveSupportLines.value.push(createEmptyGoLiveSupportLine(goLiveSupportLines.value.length + 1));
}

function removeGoLiveSupportLine(id: string) {
  if (goLiveSupportLines.value.length <= 1) {
    ElMessage.warning('至少保留一条上线支持');
    return;
  }
  goLiveSupportLines.value = goLiveSupportLines.value.filter(item => item.id !== id);
}

function addImplementationStrategyLine() {
  implementationStrategyLines.value.push(
    createEmptyImplementationStrategyLine(
      implementationStrategyLines.value.length + 1,
      formModel.customerName || formModel.partyA
    )
  );
}

function removeImplementationStrategyLine(id: string) {
  if (implementationStrategyLines.value.length <= 1) {
    ElMessage.warning('至少保留一条实施策略');
    return;
  }
  implementationStrategyLines.value = implementationStrategyLines.value.filter(item => item.id !== id);
}

const MAX_ATTACHMENT_ID = 2147483647;

function mapAttachmentsToUploadList(attachments?: ContractAttachmentDto[]) {
  return (attachments ?? [])
    .filter(item => item.id > 0)
    .map(item => ({
      name: item.fileName,
      uid: item.id,
      status: 'success' as const,
      response: {
        id: item.id,
        fileName: item.fileName,
        fileSize: item.fileSize,
        storedPath: item.storedPath
      }
    }));
}

function mapImageAttachmentsToUploadList(attachments?: ContractAttachmentDto[]) {
  return (attachments ?? [])
    .filter(item => item.id > 0)
    .map(item => ({
      name: item.fileName,
      uid: item.id,
      status: 'success' as const,
      url: item.storedPath ? resolveStaticFileUrl(item.storedPath) : undefined,
      response: {
        id: item.id,
        fileName: item.fileName,
        fileSize: item.fileSize,
        storedPath: item.storedPath,
        contentType: item.contentType
      }
    }));
}

function parseUploadResponse(response: unknown): FileUploadResult | null {
  if (!response || typeof response !== 'object') return null;
  const root = response as Record<string, unknown>;
  const payload = (root.body && typeof root.body === 'object' ? root.body : root) as Record<string, unknown>;
  const id = Number(payload.id ?? payload.Id);
  if (!Number.isFinite(id) || id <= 0 || id > MAX_ATTACHMENT_ID) return null;
  const storedPath = String(payload.storedPath ?? payload.StoredPath ?? '');
  return {
    id,
    fileName: String(payload.fileName ?? payload.FileName ?? ''),
    fileSize: Number(payload.fileSize ?? payload.FileSize ?? 0),
    contentType: (payload.contentType ?? payload.ContentType) as string | undefined,
    storedPath: storedPath || undefined
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
        contentType: parsed?.contentType,
        storedPath: parsed?.storedPath
      };
    })
    .filter((item): item is ContractAttachmentDto => item !== null);
}

function resolveUploadErrorMessage(error: unknown) {
  const err = error as { response?: { data?: { message?: string; body?: string } }; message?: string };
  return err.response?.data?.message || (typeof err.response?.data?.body === 'string' ? err.response.data.body : '') || err.message || '上传失败';
}

async function handleSowReferenceAttachmentChange(uploadFileItem: UploadFile) {
  if (uploadFileItem.status !== 'ready' || !uploadFileItem.raw) return;

  uploadFileItem.status = 'uploading';
  uploadFileItem.percentage = 30;

  try {
    const rawFile = uploadFileItem.raw instanceof File ? uploadFileItem.raw : (uploadFileItem.raw as UploadRawFile);
    const result = await uploadFileApi(rawFile, 'project_init_sow_ref');
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
    sowReferenceUploadList.value = sowReferenceUploadList.value.filter(item => item.uid !== uploadFileItem.uid);
  }
}

const IMAGE_FILE_PATTERN = /\.(png|jpe?g|gif|webp|bmp)$/i;

function isImageFile(file: File | UploadRawFile) {
  if (file.type?.startsWith('image/')) return true;
  return IMAGE_FILE_PATTERN.test(file.name);
}

async function handleOrgStructureAttachmentChange(uploadFileItem: UploadFile) {
  if (uploadFileItem.status !== 'ready' || !uploadFileItem.raw) return;

  const rawFile = uploadFileItem.raw instanceof File ? uploadFileItem.raw : (uploadFileItem.raw as UploadRawFile);
  if (!isImageFile(rawFile)) {
    ElMessage.warning('仅支持上传图片（png/jpg/jpeg/gif/webp/bmp）');
    orgStructureUploadList.value = orgStructureUploadList.value.filter(item => item.uid !== uploadFileItem.uid);
    return;
  }

  uploadFileItem.status = 'uploading';
  uploadFileItem.percentage = 30;

  try {
    const result = await uploadFileApi(rawFile, 'project_init_org_structure');
    const parsed = parseUploadResponse(result);
    if (!parsed) {
      throw new Error('上传响应无效，未获取到附件编号');
    }
    uploadFileItem.status = 'success';
    uploadFileItem.response = parsed;
    uploadFileItem.uid = parsed.id;
    uploadFileItem.name = parsed.fileName || uploadFileItem.name;
    uploadFileItem.percentage = 100;
    uploadFileItem.url = parsed.storedPath ? resolveStaticFileUrl(parsed.storedPath) : undefined;
  } catch (error) {
    uploadFileItem.status = 'fail';
    ElMessage.error(resolveUploadErrorMessage(error));
    orgStructureUploadList.value = orgStructureUploadList.value.filter(item => item.uid !== uploadFileItem.uid);
  }
}

async function handleOrgStructureUploadRemove(file: UploadUserFile) {
  const id = resolveUploadAttachmentId(file);
  if (!id) return true;

  if (props.record?.orgStructureAttachments?.some(item => item.id === id)) {
    return true;
  }

  try {
    await deleteFile(id);
    return true;
  } catch {
    ElMessage.warning('删除图片失败');
    return false;
  }
}

async function handleSowReferenceUploadRemove(file: UploadUserFile) {
  const id = resolveUploadAttachmentId(file);
  if (!id) return true;

  if (props.record?.sowReferenceAttachments?.some(item => item.id === id)) {
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

function buildPayload(): ProjectInitRecord {
  const base = props.record;
  return {
    id: base?.id ?? 0,
    projectNo: formModel.projectNo,
    projectName: formModel.projectName.trim(),
    projectType: formModel.projectType,
    status: base?.status ?? 'draft',
    contractId: formModel.contractId,
    contractNo: formModel.contractNo,
    contractName: formModel.contractName,
    customerName: formModel.customerName || formModel.partyA,
    planStartDate: formModel.planStartDate,
    planEndDate: formModel.planEndDate,
    background: formModel.background.trim(),
    objective: formModel.objective.trim(),
    milestone: formModel.milestone.trim(),
    customDevelopmentScope: formModel.customDevelopmentScope.trim(),
    attachmentNames: [...attachmentNames.value],
    contractType: formModel.contractType,
    signDate: formModel.signDate,
    contactPerson: formModel.contactPerson.trim(),
    partyA: formModel.partyA.trim(),
    projectManager: formModel.projectManager,
    phone: formModel.phone.trim(),
    wechat: formModel.wechat.trim(),
    address: formModel.address.trim(),
    email: formModel.email.trim(),
    paymentLines: paymentLines.value.map(item => ({ ...item })),
    productLines: productLines.value.map(item => ({ ...item })),
    implementationLines: implementationLines.value.map(item => ({ ...item })),
    orgScopeLines: orgScopeLines.value.map((item, index) => ({ ...item, seq: index + 1 })),
    integrationLines: integrationLines.value.map(item => ({ ...item })),
    dataConversionLines: dataConversionLines.value.map((item, index) => ({ ...item, seq: index + 1 })),
    trainingLines: trainingLines.value.map(item => ({ ...item })),
    goLiveSupportLines: goLiveSupportLines.value.map((item, index) => ({ ...item, seq: index + 1 })),
    implementationStrategyLines: implementationStrategyLines.value.map((item, index) => ({ ...item, seq: index + 1 })),
    contractQuoteAmount: formModel.contractQuoteAmount,
    requirementAttachmentNames: [...requirementAttachmentNames.value],
    sowReferenceAttachments: collectAttachmentsFromUploadList(sowReferenceUploadList.value),
    sowReferenceAttachmentNames: collectAttachmentsFromUploadList(sowReferenceUploadList.value).map(item => item.fileName),
    orgStructureAttachments: collectAttachmentsFromUploadList(orgStructureUploadList.value),
    orgStructureAttachmentNames: collectAttachmentsFromUploadList(orgStructureUploadList.value).map(item => item.fileName),
    createTime: base?.createTime,
    creator: base?.creator
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
  if (hasPendingUploads(sowReferenceUploadList.value)) {
    ElMessage.warning('参考文档正在上传，请稍候再保存');
    activeTab.value = 'sowReference';
    return;
  }
  if (hasFailedUploads(sowReferenceUploadList.value)) {
    ElMessage.warning('存在上传失败的参考文档，请移除后重新上传');
    activeTab.value = 'sowReference';
    return;
  }
  if (hasInvalidAttachmentIds(sowReferenceUploadList.value)) {
    ElMessage.warning('参考文档未获取到有效编号，请移除后重新上传');
    activeTab.value = 'sowReference';
    return;
  }
  if (hasPendingUploads(orgStructureUploadList.value)) {
    ElMessage.warning('组织架构图片正在上传，请稍候再保存');
    activeTab.value = 'orgStructure';
    return;
  }
  if (hasFailedUploads(orgStructureUploadList.value)) {
    ElMessage.warning('存在上传失败的组织架构图片，请移除后重新上传');
    activeTab.value = 'orgStructure';
    return;
  }
  if (hasInvalidAttachmentIds(orgStructureUploadList.value)) {
    ElMessage.warning('组织架构图片未获取到有效编号，请移除后重新上传');
    activeTab.value = 'orgStructure';
    return;
  }
  const payload = mapProjectInitRecordToSave(buildPayload());
  saving.value = true;
  try {
    if (isEdit.value) {
      await updateProjectInit(payload);
      ElMessage.success('保存成功');
    } else {
      await addProjectInit(payload);
      ElMessage.success('立项成功');
    }
    emit('submitted');
    visible.value = false;
  } finally {
    saving.value = false;
  }
}
</script>

<template>
  <ElDrawer v-model="visible" :title="title" size="100%" append-to-body destroy-on-close class="project-init-drawer">
    <ElTabs v-model="activeTab" class="project-init-tabs">
      <ElTabPane lazy label="基本信息" name="basic">
        <ElForm ref="formRef" :model="formModel" :rules="rules" label-width="120px" class="pr-16px">
          <ElRow :gutter="16">
            <ElCol :lg="8" :md="12" :sm="24">
              <ElFormItem label="项目编号">
                <ElInput v-model="formModel.projectNo" readonly placeholder="自动生成" />
              </ElFormItem>
            </ElCol>
            <ElCol :lg="8" :md="12" :sm="24">
              <ElFormItem label="项目名称" prop="projectName">
                <ElInput v-model="formModel.projectName" placeholder="默认带入合同名称" clearable />
              </ElFormItem>
            </ElCol>
            <ElCol :lg="8" :md="12" :sm="24">
              <ElFormItem label="项目类型">
                <ElSelect v-model="formModel.projectType" disabled class="w-full">
                  <ElOption
                    v-for="item in PROJECT_INIT_TYPE_OPTIONS"
                    :key="item.value"
                    :label="item.label"
                    :value="item.value"
                  />
                </ElSelect>
              </ElFormItem>
            </ElCol>
            <ElCol :lg="8" :md="12" :sm="24">
              <ElFormItem label="合同编号">
                <ElInput v-model="formModel.contractNo" readonly />
              </ElFormItem>
            </ElCol>
            <ElCol :lg="8" :md="12" :sm="24">
              <ElFormItem label="合同名称">
                <ElInput v-model="formModel.contractName" readonly />
              </ElFormItem>
            </ElCol>
            <ElCol :lg="8" :md="12" :sm="24">
              <ElFormItem label="客户名称">
                <ElInput v-model="formModel.customerName" readonly />
              </ElFormItem>
            </ElCol>
            <ElCol :lg="8" :md="12" :sm="24">
              <ElFormItem label="价税合计(元)">
                <ElInput :model-value="formatAmount(formModel.contractQuoteAmount)" readonly placeholder="来自合同" />
              </ElFormItem>
            </ElCol>
            <ElCol :lg="8" :md="12" :sm="24">
              <ElFormItem label="预计开始日期" prop="planStartDate">
                <ElDatePicker
                  v-model="formModel.planStartDate"
                  type="date"
                  value-format="YYYY-MM-DD"
                  placeholder="选择日期"
                  class="w-full"
                />
              </ElFormItem>
            </ElCol>
            <ElCol :lg="8" :md="12" :sm="24">
              <ElFormItem label="预计完工日期" prop="planEndDate">
                <ElDatePicker
                  v-model="formModel.planEndDate"
                  type="date"
                  value-format="YYYY-MM-DD"
                  placeholder="选择日期"
                  class="w-full"
                />
              </ElFormItem>
            </ElCol>
            <ElCol :span="24">
              <ElFormItem label="项目背景">
                <ElInput v-model="formModel.background" type="textarea" :rows="3" placeholder="项目背景说明" />
              </ElFormItem>
            </ElCol>
            <ElCol :span="24">
              <ElFormItem label="项目目标">
                <ElInput v-model="formModel.objective" type="textarea" :rows="3" placeholder="项目目标说明" />
              </ElFormItem>
            </ElCol>
            <ElCol :span="24">
              <ElFormItem label="合同附件">
                <ul v-if="attachmentNames.length" class="attachment-list">
                  <li v-for="name in attachmentNames" :key="name">{{ name }}</li>
                </ul>
                <span v-else class="text-secondary">（无，来自合同自动带入）</span>
              </ElFormItem>
            </ElCol>
          </ElRow>
        </ElForm>
      </ElTabPane>

      <ElTabPane lazy label="里程碑" name="milestone">
        <ElForm :model="formModel" label-width="120px" class="pr-16px">
          <ElFormItem label="里程碑">
            <ElInput
              v-model="formModel.milestone"
              type="textarea"
              :rows="12"
              placeholder="来自合同自动带入，可在此补充或调整"
            />
          </ElFormItem>
        </ElForm>
      </ElTabPane>

      <ElTabPane lazy :label="formatTabLabel('实施策略', implementationStrategyCount)" name="implementationStrategy">
        <p class="implementation-strategy-tip">本项目整体实施策略如下：</p>
        <div class="mb-12px flex justify-end">
          <ElButton type="primary" plain @click="addImplementationStrategyLine">新增实施策略</ElButton>
        </div>
        <ElTable border :data="implementationStrategyLines" row-key="id" max-height="480">
          <ElTableColumn label="序号" width="70" align="center">
            <template #default="{ $index }">
              {{ $index + 1 }}
            </template>
          </ElTableColumn>
          <ElTableColumn label="业务板块" min-width="130">
            <template #default="{ row }">
              <ElInput v-model="row.businessSegment" placeholder="如：财务+供应链" />
            </template>
          </ElTableColumn>
          <ElTableColumn label="组织范围" min-width="150">
            <template #default="{ row }">
              <ElInput v-model="row.orgScope" placeholder="组织范围" />
            </template>
          </ElTableColumn>
          <ElTableColumn label="下属分支机构" min-width="130">
            <template #default="{ row }">
              <ElInput v-model="row.subBranches" placeholder="如：4家组织" />
            </template>
          </ElTableColumn>
          <ElTableColumn label="分期策略" width="110">
            <template #default="{ row }">
              <ElInput v-model="row.phaseStrategy" placeholder="如：一期" />
            </template>
          </ElTableColumn>
          <ElTableColumn label="推广策略" align="center">
            <ElTableColumn label="试点" width="70" align="center">
              <template #default="{ row }">
                <ElCheckbox v-model="row.pilot" />
              </template>
            </ElTableColumn>
            <ElTableColumn label="推广" width="70" align="center">
              <template #default="{ row }">
                <ElCheckbox v-model="row.promotion" />
              </template>
            </ElTableColumn>
            <ElTableColumn label="推广责任方" min-width="120">
              <template #default="{ row }">
                <ElInput v-model="row.promotionResponsible" placeholder="如：甲、乙方" />
              </template>
            </ElTableColumn>
          </ElTableColumn>
          <ElTableColumn label="实施地点" align="center">
            <ElTableColumn label="集中" width="70" align="center">
              <template #default="{ row }">
                <ElCheckbox v-model="row.locationCentralized" />
              </template>
            </ElTableColumn>
            <ElTableColumn label="分散" width="70" align="center">
              <template #default="{ row }">
                <ElCheckbox v-model="row.locationDecentralized" />
              </template>
            </ElTableColumn>
            <ElTableColumn label="异地集中" width="90" align="center">
              <template #default="{ row }">
                <ElCheckbox v-model="row.locationRemoteCentralized" />
              </template>
            </ElTableColumn>
            <ElTableColumn label="异地分散" width="90" align="center">
              <template #default="{ row }">
                <ElCheckbox v-model="row.locationRemoteDecentralized" />
              </template>
            </ElTableColumn>
          </ElTableColumn>
          <ElTableColumn label="操作" width="80" align="center" fixed="right">
            <template #default="{ row }">
              <ElButton type="danger" link @click="removeImplementationStrategyLine(row.id)">删除</ElButton>
            </template>
          </ElTableColumn>
        </ElTable>
      </ElTabPane>

      <ElTabPane lazy label="签约信息" name="sign">
        <ElForm :model="formModel" label-width="120px" class="pr-16px">
          <ElRow :gutter="16">
            <ElCol :lg="8" :md="12" :sm="24">
              <ElFormItem label="合同类型">
                <ElSelect v-model="formModel.contractType" disabled class="w-full">
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
              <ElFormItem label="签约日期">
                <ElInput v-model="formModel.signDate" readonly />
              </ElFormItem>
            </ElCol>
            <ElCol :lg="8" :md="12" :sm="24">
              <ElFormItem label="联系人">
                <ElInput v-model="formModel.contactPerson" placeholder="甲方联系人" clearable />
              </ElFormItem>
            </ElCol>
            <ElCol :lg="8" :md="12" :sm="24">
              <ElFormItem label="甲方" prop="partyA">
                <ElInput v-model="formModel.partyA" placeholder="甲方全称" clearable />
              </ElFormItem>
            </ElCol>
            <ElCol :lg="8" :md="12" :sm="24">
              <ElFormItem label="项目经理" prop="projectManager">
                <ElSelect v-model="formModel.projectManager" placeholder="请选择" clearable class="w-full">
                  <ElOption v-for="name in CONTRACT_SALES_OWNER_OPTIONS" :key="name" :label="name" :value="name" />
                </ElSelect>
              </ElFormItem>
            </ElCol>
            <ElCol :lg="8" :md="12" :sm="24">
              <ElFormItem label="电话">
                <ElInput v-model="formModel.phone" placeholder="联系电话" clearable />
              </ElFormItem>
            </ElCol>
            <ElCol :lg="8" :md="12" :sm="24">
              <ElFormItem label="微信">
                <ElInput v-model="formModel.wechat" placeholder="微信号" clearable />
              </ElFormItem>
            </ElCol>
            <ElCol :lg="8" :md="12" :sm="24">
              <ElFormItem label="邮箱">
                <ElInput v-model="formModel.email" placeholder="电子邮箱" clearable />
              </ElFormItem>
            </ElCol>
            <ElCol :span="24">
              <ElFormItem label="地址">
                <ElInput v-model="formModel.address" placeholder="联系地址" clearable />
              </ElFormItem>
            </ElCol>
          </ElRow>
        </ElForm>
      </ElTabPane>

      <ElTabPane lazy :label="formatTabLabel('付款条件', paymentCount)" name="payment">
        <ElTable border :data="paymentLines" row-key="id" max-height="420">
          <ElTableColumn prop="termName" label="条件名称" min-width="140" show-overflow-tooltip />
          <ElTableColumn label="结算方式" width="110" align="center">
            <template #default="{ row }">
              {{
                row.settlementMethod
                  ? PAYMENT_TERM_SETTLEMENT_OPTIONS.find(o => o.value === row.settlementMethod)?.label ?? row.settlementMethod
                  : '—'
              }}
            </template>
          </ElTableColumn>
          <ElTableColumn prop="paymentRatio" label="支付比例(%)" width="110" align="center" />
          <ElTableColumn prop="node" label="节点" min-width="160" show-overflow-tooltip />
          <ElTableColumn prop="remark" label="备注" min-width="120" show-overflow-tooltip />
        </ElTable>
        <p v-if="!paymentLines.length" class="empty-tip">暂无付款条件（来自合同自动带入）</p>
      </ElTabPane>

      <ElTabPane lazy :label="formatTabLabel('产品范围', productCount)" name="products">
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
          <ElTableColumn prop="quantity" label="数量" width="80" align="center" />
          <ElTableColumn prop="amountWithTax" label="价税合计(元)" width="130" align="right" />
        </ElTable>
      </ElTabPane>

      <ElTabPane lazy :label="formatTabLabel('实施功能范围', implementationCount)" name="implementation">
        <div class="mb-12px flex justify-end">
          <ElButton type="primary" plain @click="addImplementationLine">新增实施功能范围</ElButton>
        </div>
        <ElTable border :data="implementationLines" row-key="id" max-height="420">
          <ElTableColumn label="一级模块" min-width="140">
            <template #default="{ row }">
              <ElInput v-model="row.moduleName" placeholder="模块名称" />
            </template>
          </ElTableColumn>
          <ElTableColumn label="子模块" min-width="140">
            <template #default="{ row }">
              <ElInput v-model="row.subModuleName" placeholder="子模块名称" />
            </template>
          </ElTableColumn>
          <ElTableColumn label="功能说明" min-width="200">
            <template #default="{ row }">
              <ElInput v-model="row.description" placeholder="实施说明" />
            </template>
          </ElTableColumn>
          <ElTableColumn label="备注" min-width="120">
            <template #default="{ row }">
              <ElInput v-model="row.remark" placeholder="备注" />
            </template>
          </ElTableColumn>
          <ElTableColumn label="操作" width="80" align="center" fixed="right">
            <template #default="{ row }">
              <ElButton type="danger" link @click="removeImplementationLine(row.id)">删除</ElButton>
            </template>
          </ElTableColumn>
        </ElTable>
      </ElTabPane>

      <ElTabPane lazy label="定制化开发范围" name="customDevelopment">
        <ElForm :model="formModel" label-width="120px" class="pr-16px">
          <ElFormItem label="定制化开发范围">
            <ElInput
              v-model="formModel.customDevelopmentScope"
              type="textarea"
              :rows="12"
              placeholder="请输入定制化开发范围"
            />
          </ElFormItem>
        </ElForm>
      </ElTabPane>

      <ElTabPane lazy :label="formatTabLabel('项目组织范围', orgScopeCount)" name="org">
        <div class="mb-12px flex justify-end">
          <ElButton type="primary" plain @click="addOrgScopeLine">新增组织</ElButton>
        </div>
        <ElTable border :data="orgScopeLines" row-key="id" max-height="420">
          <ElTableColumn prop="seq" label="序号" width="70" align="center" />
          <ElTableColumn label="组织" min-width="120">
            <template #default="{ row }">
              <ElInput v-model="row.orgName" placeholder="组织名称" />
            </template>
          </ElTableColumn>
          <ElTableColumn label="公司名称" min-width="160">
            <template #default="{ row }">
              <ElInput v-model="row.companyName" placeholder="公司名称" />
            </template>
          </ElTableColumn>
          <ElTableColumn label="公司资质" min-width="140">
            <template #default="{ row }">
              <ElInput v-model="row.companyQualification" placeholder="资质说明" />
            </template>
          </ElTableColumn>
          <ElTableColumn label="操作" width="80" align="center" fixed="right">
            <template #default="{ row }">
              <ElButton type="danger" link @click="removeOrgScopeLine(row.id)">删除</ElButton>
            </template>
          </ElTableColumn>
        </ElTable>
      </ElTabPane>

      <ElTabPane lazy :label="formatTabLabel('项目组织架构', orgStructureCount)" name="orgStructure">
        <p class="org-structure-tip">上传项目组织架构图，支持多张图片，点击缩略图可预览。</p>
        <ElUpload
          v-model:file-list="orgStructureUploadList"
          action="#"
          list-type="picture-card"
          accept="image/png,image/jpeg,image/jpg,image/gif,image/webp,image/bmp"
          :auto-upload="false"
          :on-change="handleOrgStructureAttachmentChange"
          :before-remove="handleOrgStructureUploadRemove"
          multiple
          class="org-structure-upload"
        >
          <span class="text-24px">+</span>
          <template #tip>
            <div class="text-12px text-gray-500">支持 png/jpg/jpeg/gif/webp/bmp，单张最大 100MB</div>
          </template>
        </ElUpload>
      </ElTabPane>

      <ElTabPane lazy :label="formatTabLabel('初始数据转换范围', dataConversionCount)" name="dataConversion">
        <div class="mb-12px flex justify-end">
          <ElButton type="primary" plain @click="addDataConversionLine">新增数据项</ElButton>
        </div>
        <ElTable border :data="dataConversionLines" row-key="id" max-height="420">
          <ElTableColumn label="序号" width="70" align="center">
            <template #default="{ $index }">
              {{ $index + 1 }}
            </template>
          </ElTableColumn>
          <ElTableColumn label="初始数据名称" min-width="160">
            <template #default="{ row }">
              <ElInput v-model="row.dataName" placeholder="如：总账" />
            </template>
          </ElTableColumn>
          <ElTableColumn label="数据范围描述" min-width="280">
            <template #default="{ row }">
              <ElInput v-model="row.scopeDescription" placeholder="如：科目余额数据引入" />
            </template>
          </ElTableColumn>
          <ElTableColumn label="操作" width="80" align="center" fixed="right">
            <template #default="{ row }">
              <ElButton type="danger" link @click="removeDataConversionLine(row.id)">删除</ElButton>
            </template>
          </ElTableColumn>
        </ElTable>
      </ElTabPane>

      <ElTabPane lazy :label="formatTabLabel('培训服务', trainingCount)" name="training">
        <div class="mb-12px flex justify-end">
          <ElButton type="primary" plain @click="addTrainingLine">新增培训项</ElButton>
        </div>
        <ElTable border :data="trainingLines" row-key="id" max-height="420">
          <ElTableColumn label="培训内容" min-width="150">
            <template #default="{ row }">
              <ElInput v-model="row.trainingContent" placeholder="如：标准功能培训" />
            </template>
          </ElTableColumn>
          <ElTableColumn label="培训讲师" min-width="110">
            <template #default="{ row }">
              <ElInput v-model="row.trainer" placeholder="如：乙方顾问" />
            </template>
          </ElTableColumn>
          <ElTableColumn label="培训对象" min-width="160">
            <template #default="{ row }">
              <ElInput v-model="row.targetAudience" placeholder="如：关键用户、IT维护人员" />
            </template>
          </ElTableColumn>
          <ElTableColumn label="培训方式" min-width="150">
            <template #default="{ row }">
              <ElInput v-model="row.trainingMethod" placeholder="如：课堂培训" />
            </template>
          </ElTableColumn>
          <ElTableColumn label="培训地点" min-width="120">
            <template #default="{ row }">
              <ElInput v-model="row.trainingLocation" placeholder="如：客户现场" />
            </template>
          </ElTableColumn>
          <ElTableColumn label="操作" width="80" align="center" fixed="right">
            <template #default="{ row }">
              <ElButton type="danger" link @click="removeTrainingLine(row.id)">删除</ElButton>
            </template>
          </ElTableColumn>
        </ElTable>
      </ElTabPane>

      <ElTabPane lazy :label="formatTabLabel('系统集成范围', integrationCount)" name="integration">
        <div class="mb-12px flex justify-end">
          <ElButton type="primary" plain @click="addIntegrationLine">新增集成项</ElButton>
        </div>
        <ElTable border :data="integrationLines" row-key="id" max-height="420">
          <ElTableColumn label="涉及系统" min-width="130">
            <template #default="{ row }">
              <ElInput v-model="row.involvedSystem" placeholder="如：地磅集成" />
            </template>
          </ElTableColumn>
          <ElTableColumn label="集成内容" min-width="130">
            <template #default="{ row }">
              <ElInput v-model="row.integrationContent" placeholder="如：称重数据对接" />
            </template>
          </ElTableColumn>
          <ElTableColumn label="接口调用方" min-width="110">
            <template #default="{ row }">
              <ElInput v-model="row.interfaceCaller" placeholder="调用方" />
            </template>
          </ElTableColumn>
          <ElTableColumn label="接口提供方" min-width="110">
            <template #default="{ row }">
              <ElInput v-model="row.interfaceProvider" placeholder="提供方" />
            </template>
          </ElTableColumn>
          <ElTableColumn label="涉及集成接口描述" min-width="150">
            <template #default="{ row }">
              <ElInput v-model="row.interfaceDescription" placeholder="接口描述" />
            </template>
          </ElTableColumn>
          <ElTableColumn label="集成技术方式" min-width="120">
            <template #default="{ row }">
              <ElInput v-model="row.integrationMethod" placeholder="如：硬件集成" />
            </template>
          </ElTableColumn>
          <ElTableColumn label="操作" width="80" align="center" fixed="right">
            <template #default="{ row }">
              <ElButton type="danger" link @click="removeIntegrationLine(row.id)">删除</ElButton>
            </template>
          </ElTableColumn>
        </ElTable>
      </ElTabPane>

      <ElTabPane lazy :label="formatTabLabel('上线支持', goLiveSupportCount)" name="goLiveSupport">
        <div class="mb-12px flex justify-end">
          <ElButton type="primary" plain @click="addGoLiveSupportLine">新增上线支持</ElButton>
        </div>
        <ElTable border :data="goLiveSupportLines" row-key="id" max-height="420">
          <ElTableColumn label="序号" width="70" align="center">
            <template #default="{ $index }">
              {{ $index + 1 }}
            </template>
          </ElTableColumn>
          <ElTableColumn label="上线支持内容" min-width="160">
            <template #default="{ row }">
              <ElInput v-model="row.supportContent" placeholder="如：总账" />
            </template>
          </ElTableColumn>
          <ElTableColumn label="上线支持完成标准" min-width="280">
            <template #default="{ row }">
              <ElInput v-model="row.completionCriteria" placeholder="如：完成一个月的月末结账" />
            </template>
          </ElTableColumn>
          <ElTableColumn label="操作" width="80" align="center" fixed="right">
            <template #default="{ row }">
              <ElButton type="danger" link @click="removeGoLiveSupportLine(row.id)">删除</ElButton>
            </template>
          </ElTableColumn>
        </ElTable>
      </ElTabPane>

      <ElTabPane lazy :label="formatTabLabel('SOW撰写参考文档', sowReferenceCount)" name="sowReference">
        <ElUpload
          v-model:file-list="sowReferenceUploadList"
          action="#"
          :auto-upload="false"
          :on-change="handleSowReferenceAttachmentChange"
          :before-remove="handleSowReferenceUploadRemove"
          multiple
          class="sow-reference-upload"
        >
          <ElButton type="primary" plain>选择文件</ElButton>
          <template #tip>
            <div class="text-12px text-gray-500">支持上传多个参考文档，pdf/doc/xls/图片等，单文件最大 100MB</div>
          </template>
        </ElUpload>
      </ElTabPane>

      <ElTabPane lazy :label="formatTabLabel('项目需求', requirementCount)" name="requirements">
        <ul v-if="requirementAttachmentNames.length" class="attachment-list">
          <li v-for="name in requirementAttachmentNames" :key="name">{{ name }}</li>
        </ul>
        <ElEmpty v-else description="暂无项目需求附件（来自合同自动带入）" />
      </ElTabPane>
    </ElTabs>

    <template #footer>
      <ElSpace class="drawer-footer">
        <ElButton @click="visible = false">{{ $t('common.cancel') }}</ElButton>
        <ElButton type="primary" :loading="saving" @click="handleSave">保存</ElButton>
      </ElSpace>
    </template>
  </ElDrawer>
</template>

<style lang="scss" scoped>
.project-init-tabs {
  min-height: 360px;
}

.drawer-footer {
  justify-content: flex-end;
  width: 100%;
}

.attachment-list {
  margin: 0;
  padding-left: 20px;
  line-height: 1.8;
}

.text-secondary {
  color: var(--el-text-color-secondary);
  font-size: 13px;
}

.empty-tip {
  margin: 12px 0 0;
  color: var(--el-text-color-secondary);
  font-size: 13px;
}

.implementation-strategy-tip {
  margin: 0 0 12px;
  color: var(--el-text-color-regular);
  font-size: 14px;
}

.org-structure-tip {
  margin: 0 0 12px;
  color: var(--el-text-color-regular);
  font-size: 14px;
}

.org-structure-upload :deep(.el-upload-list--picture-card .el-upload-list__item) {
  transition: none;
}
</style>
