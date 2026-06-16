<script setup lang="ts">
import { computed, ref } from 'vue';
import { ElMessage } from 'element-plus';
import {
  CONTRACT_TYPE_LABEL,
  type ContractType
} from '@/constants/contract';
import {
  PROJECT_INIT_STATUS_LABEL,
  PROJECT_INIT_STATUS_TAG_TYPE,
  PROJECT_INIT_TYPE_LABEL,
  type ProjectInitStatus
} from '@/constants/project-init';
import { PAYMENT_TERM_SETTLEMENT_OPTIONS } from '@/constants/basedata-payment-term';
import { downloadFile, resolveStaticFileUrl } from '@/service/api/file';
import { formatTabLabel, type ProjectInitRecord } from '@/utils/project-init';

defineOptions({ name: 'ProjectInitDetailDrawer' });

const props = defineProps<{
  record: ProjectInitRecord | null;
}>();

const visible = defineModel<boolean>('visible', { default: false });

const activeTab = ref('basic');

const status = computed<ProjectInitStatus>(() => props.record?.status ?? 'draft');

const summaryItems = computed(() => {
  const r = props.record;
  if (!r) return [];
  return [
    { label: '项目名称', value: r.projectName },
    { label: '项目编号', value: r.projectNo },
    { label: '项目类型', value: PROJECT_INIT_TYPE_LABEL[r.projectType] },
    { label: '合同编号', value: r.contractNo },
    { label: '客户名称', value: r.customerName },
    { label: '价税合计(元)', value: formatAmount(r.contractQuoteAmount ?? 0) },
    { label: '预计开始', value: r.planStartDate },
    { label: '预计完工', value: r.planEndDate },
    { label: '项目经理', value: r.projectManager }
  ];
});

function formatAmount(amount: number) {
  return amount.toLocaleString('zh-CN', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
}

function settlementLabel(method: string) {
  if (!method) return '—';
  return PAYMENT_TERM_SETTLEMENT_OPTIONS.find(o => o.value === method)?.label ?? method;
}

const sowReferenceAttachmentItems = computed(() => {
  const r = props.record;
  if (!r) return [];
  if (r.sowReferenceAttachments?.length) return r.sowReferenceAttachments;
  return (r.sowReferenceAttachmentNames ?? []).map(fileName => ({ id: 0, fileName, fileSize: 0 }));
});

const paymentCount = computed(() => props.record?.paymentLines.length ?? 0);
const productCount = computed(() => props.record?.productLines.length ?? 0);
const implementationCount = computed(() => props.record?.implementationLines.length ?? 0);
const orgScopeCount = computed(() => props.record?.orgScopeLines.length ?? 0);
const dataConversionCount = computed(() => props.record?.dataConversionLines.length ?? 0);
const trainingCount = computed(() => props.record?.trainingLines.length ?? 0);
const integrationCount = computed(() => props.record?.integrationLines.length ?? 0);
const goLiveSupportCount = computed(() => props.record?.goLiveSupportLines.length ?? 0);
const implementationStrategyCount = computed(() => props.record?.implementationStrategyLines.length ?? 0);
const sowReferenceCount = computed(() => sowReferenceAttachmentItems.value.length);
const requirementCount = computed(() => props.record?.requirementAttachmentNames.length ?? 0);

const orgStructureImageItems = computed(() => {
  const r = props.record;
  if (!r) return [] as Array<{ id: number; fileName: string; url: string }>;
  if (r.orgStructureAttachments?.length) {
    return r.orgStructureAttachments
      .filter(item => item.storedPath)
      .map(item => ({
        id: item.id,
        fileName: item.fileName,
        url: resolveStaticFileUrl(item.storedPath!)
      }));
  }
  return (r.orgStructureAttachmentNames ?? []).map(fileName => ({
    id: 0,
    fileName,
    url: ''
  }));
});

const orgStructureCount = computed(() => orgStructureImageItems.value.length);
const orgStructurePreviewUrls = computed(() => orgStructureImageItems.value.map(item => item.url).filter(Boolean));

function formatCheckMark(checked: boolean) {
  return checked ? '√' : '';
}

async function handleDownloadAttachment(id: number, fileName: string) {
  if (!id) {
    ElMessage.warning('该附件为历史数据，无法下载');
    return;
  }
  try {
    await downloadFile(id, fileName);
  } catch (error) {
    ElMessage.error(error instanceof Error ? error.message : '下载失败');
  }
}

function handleClose() {
  visible.value = false;
}
</script>

<template>
  <ElDrawer
    v-model="visible"
    size="100%"
    direction="rtl"
    append-to-body
    destroy-on-close
    :show-close="false"
    class="project-init-detail-drawer"
  >
    <template #header>
      <div class="detail-header">
        <div class="detail-header-main">
          <h2 class="detail-title">{{ record?.projectName || '项目立项详情' }}</h2>
          <ElTag v-if="record" :type="PROJECT_INIT_STATUS_TAG_TYPE[status]" size="small" round>
            {{ PROJECT_INIT_STATUS_LABEL[status] }}
          </ElTag>
        </div>
        <ElButton @click="handleClose">取消</ElButton>
      </div>
    </template>

    <template v-if="record">
      <ElDescriptions :column="4" border class="summary-desc mb-16px">
        <ElDescriptionsItem v-for="item in summaryItems" :key="item.label" :label="item.label">
          {{ item.value || '—' }}
        </ElDescriptionsItem>
      </ElDescriptions>

      <ElTabs v-model="activeTab" class="detail-tabs">
        <ElTabPane label="基本信息" name="basic">
          <ElDescriptions :column="2" border>
            <ElDescriptionsItem label="价税合计(元)">
              {{ formatAmount(record.contractQuoteAmount ?? 0) }}
            </ElDescriptionsItem>
            <ElDescriptionsItem label="合同编号">{{ record.contractNo || '—' }}</ElDescriptionsItem>
            <ElDescriptionsItem label="项目背景" :span="2">{{ record.background || '—' }}</ElDescriptionsItem>
            <ElDescriptionsItem label="项目目标" :span="2">{{ record.objective || '—' }}</ElDescriptionsItem>
            <ElDescriptionsItem label="合同附件" :span="2">
              <ul v-if="record.attachmentNames.length" class="attachment-list">
                <li v-for="name in record.attachmentNames" :key="name">{{ name }}</li>
              </ul>
              <span v-else>—</span>
            </ElDescriptionsItem>
            <ElDescriptionsItem label="创建人">{{ record.creator || '—' }}</ElDescriptionsItem>
            <ElDescriptionsItem label="创建时间">{{ record.createTime || '—' }}</ElDescriptionsItem>
          </ElDescriptions>
        </ElTabPane>

        <ElTabPane label="里程碑" name="milestone">
          <p class="section-text">{{ record.milestone || '—' }}</p>
        </ElTabPane>

        <ElTabPane :label="formatTabLabel('实施策略', implementationStrategyCount)" name="implementationStrategy">
          <p class="implementation-strategy-tip">本项目整体实施策略如下：</p>
          <ElTable v-if="record.implementationStrategyLines.length" border :data="record.implementationStrategyLines" row-key="id" max-height="480">
            <ElTableColumn prop="seq" label="序号" width="70" align="center" />
            <ElTableColumn prop="businessSegment" label="业务板块" min-width="130" show-overflow-tooltip />
            <ElTableColumn prop="orgScope" label="组织范围" min-width="150" show-overflow-tooltip />
            <ElTableColumn prop="subBranches" label="下属分支机构" min-width="130" show-overflow-tooltip />
            <ElTableColumn prop="phaseStrategy" label="分期策略" width="110" show-overflow-tooltip />
            <ElTableColumn label="推广策略" align="center">
              <ElTableColumn label="试点" width="70" align="center">
                <template #default="{ row }">
                  {{ formatCheckMark(row.pilot) }}
                </template>
              </ElTableColumn>
              <ElTableColumn label="推广" width="70" align="center">
                <template #default="{ row }">
                  {{ formatCheckMark(row.promotion) }}
                </template>
              </ElTableColumn>
              <ElTableColumn prop="promotionResponsible" label="推广责任方" min-width="120" show-overflow-tooltip />
            </ElTableColumn>
            <ElTableColumn label="实施地点" align="center">
              <ElTableColumn label="集中" width="70" align="center">
                <template #default="{ row }">
                  {{ formatCheckMark(row.locationCentralized) }}
                </template>
              </ElTableColumn>
              <ElTableColumn label="分散" width="70" align="center">
                <template #default="{ row }">
                  {{ formatCheckMark(row.locationDecentralized) }}
                </template>
              </ElTableColumn>
              <ElTableColumn label="异地集中" width="90" align="center">
                <template #default="{ row }">
                  {{ formatCheckMark(row.locationRemoteCentralized) }}
                </template>
              </ElTableColumn>
              <ElTableColumn label="异地分散" width="90" align="center">
                <template #default="{ row }">
                  {{ formatCheckMark(row.locationRemoteDecentralized) }}
                </template>
              </ElTableColumn>
            </ElTableColumn>
          </ElTable>
          <p v-else class="empty-tip">暂无实施策略</p>
        </ElTabPane>

        <ElTabPane label="签约信息" name="sign">
          <ElDescriptions :column="3" border>
            <ElDescriptionsItem label="合同类型">
              {{ CONTRACT_TYPE_LABEL[record.contractType as ContractType] }}
            </ElDescriptionsItem>
            <ElDescriptionsItem label="签约日期">{{ record.signDate || '—' }}</ElDescriptionsItem>
            <ElDescriptionsItem label="联系人">{{ record.contactPerson || '—' }}</ElDescriptionsItem>
            <ElDescriptionsItem label="甲方">{{ record.partyA || '—' }}</ElDescriptionsItem>
            <ElDescriptionsItem label="电话">{{ record.phone || '—' }}</ElDescriptionsItem>
            <ElDescriptionsItem label="微信">{{ record.wechat || '—' }}</ElDescriptionsItem>
            <ElDescriptionsItem label="邮箱">{{ record.email || '—' }}</ElDescriptionsItem>
            <ElDescriptionsItem label="地址" :span="3">{{ record.address || '—' }}</ElDescriptionsItem>
          </ElDescriptions>
        </ElTabPane>

        <ElTabPane :label="formatTabLabel('付款条件', paymentCount)" name="payment">
          <ElTable border :data="record.paymentLines" row-key="id" max-height="420">
            <ElTableColumn prop="termName" label="条件名称" min-width="140" show-overflow-tooltip />
            <ElTableColumn label="结算方式" width="110" align="center">
              <template #default="{ row }">
                {{ settlementLabel(row.settlementMethod) }}
              </template>
            </ElTableColumn>
            <ElTableColumn prop="paymentRatio" label="支付比例(%)" width="110" align="center" />
            <ElTableColumn prop="node" label="节点" min-width="160" show-overflow-tooltip />
            <ElTableColumn prop="remark" label="备注" min-width="120" show-overflow-tooltip />
          </ElTable>
          <p v-if="!record.paymentLines.length" class="empty-tip">暂无付款条件</p>
        </ElTabPane>

        <ElTabPane :label="formatTabLabel('产品范围', productCount)" name="products">
          <ElTable border :data="record.productLines" row-key="id" max-height="420">
            <ElTableColumn prop="productName" label="产品名称" min-width="160" show-overflow-tooltip />
            <ElTableColumn prop="categoryLabel" label="产品类别" width="110" />
            <ElTableColumn prop="version" label="产品版本" width="100" />
            <ElTableColumn prop="quantity" label="数量" width="80" align="center" />
            <ElTableColumn label="价税合计(元)" width="130" align="right">
              <template #default="{ row }">
                {{ formatAmount(row.amountWithTax) }}
              </template>
            </ElTableColumn>
          </ElTable>
        </ElTabPane>

        <ElTabPane :label="formatTabLabel('实施功能范围', implementationCount)" name="implementation">
          <ElTable border :data="record.implementationLines" row-key="id" max-height="420">
            <ElTableColumn prop="moduleName" label="一级模块" min-width="140" />
            <ElTableColumn prop="subModuleName" label="子模块" min-width="140" />
            <ElTableColumn prop="description" label="功能说明" min-width="200" show-overflow-tooltip />
            <ElTableColumn prop="remark" label="备注" min-width="120" show-overflow-tooltip />
          </ElTable>
        </ElTabPane>

        <ElTabPane label="定制化开发范围" name="customDevelopment">
          <p class="section-text">{{ record.customDevelopmentScope || '—' }}</p>
        </ElTabPane>

        <ElTabPane :label="formatTabLabel('项目组织范围', orgScopeCount)" name="org">
          <ElTable border :data="record.orgScopeLines" row-key="id" max-height="420">
            <ElTableColumn prop="seq" label="序号" width="70" align="center" />
            <ElTableColumn prop="orgName" label="组织" min-width="120" style="display:none;" />
            <ElTableColumn prop="companyName" label="公司名称" min-width="160" show-overflow-tooltip />
            <ElTableColumn prop="companyQualification" label="公司性质" min-width="140" show-overflow-tooltip />
          </ElTable>
        </ElTabPane>

        <ElTabPane :label="formatTabLabel('项目组织架构', orgStructureCount)" name="orgStructure">
          <div v-if="orgStructurePreviewUrls.length" class="org-structure-gallery">
            <ElImage
              v-for="(item, index) in orgStructureImageItems.filter(img => img.url)"
              :key="`${item.id}-${item.fileName}`"
              :src="item.url"
              :preview-src-list="orgStructurePreviewUrls"
              :initial-index="index"
              fit="contain"
              class="org-structure-image"
              :preview-teleported="true"
            />
          </div>
          <ul v-else-if="orgStructureImageItems.length" class="attachment-list">
            <li v-for="item in orgStructureImageItems" :key="item.fileName">{{ item.fileName }}（历史数据，无预览）</li>
          </ul>
          <ElEmpty v-else description="暂无项目组织架构图" />
        </ElTabPane>

        <ElTabPane :label="formatTabLabel('初始数据转换范围', dataConversionCount)" name="dataConversion">
          <ElTable border :data="record.dataConversionLines" row-key="id" max-height="420">
            <ElTableColumn prop="seq" label="序号" width="70" align="center" />
            <ElTableColumn prop="dataName" label="初始数据名称" min-width="160" show-overflow-tooltip />
            <ElTableColumn prop="scopeDescription" label="数据范围描述" min-width="280" show-overflow-tooltip />
          </ElTable>
          <p v-if="!record.dataConversionLines?.length" class="empty-tip">暂无初始数据转换范围</p>
        </ElTabPane>

        <ElTabPane :label="formatTabLabel('培训服务', trainingCount)" name="training">
          <ElTable border :data="record.trainingLines" row-key="id" max-height="420">
            <ElTableColumn prop="trainingContent" label="培训内容" min-width="150" show-overflow-tooltip />
            <ElTableColumn prop="trainer" label="培训讲师" min-width="110" show-overflow-tooltip />
            <ElTableColumn prop="targetAudience" label="培训对象" min-width="160" show-overflow-tooltip />
            <ElTableColumn prop="trainingMethod" label="培训方式" min-width="150" show-overflow-tooltip />
            <ElTableColumn prop="trainingLocation" label="培训地点" min-width="120" show-overflow-tooltip />
          </ElTable>
          <p v-if="!record.trainingLines?.length" class="empty-tip">暂无培训服务</p>
        </ElTabPane>

        <ElTabPane :label="formatTabLabel('系统集成范围', integrationCount)" name="integration">
          <ElTable border :data="record.integrationLines" row-key="id" max-height="420">
            <ElTableColumn prop="involvedSystem" label="涉及系统" min-width="130" show-overflow-tooltip />
            <ElTableColumn prop="integrationContent" label="集成内容" min-width="130" show-overflow-tooltip />
            <ElTableColumn prop="interfaceCaller" label="接口调用方" min-width="110" show-overflow-tooltip />
            <ElTableColumn prop="interfaceProvider" label="接口提供方" min-width="110" show-overflow-tooltip />
            <ElTableColumn prop="interfaceDescription" label="涉及集成接口描述" min-width="150" show-overflow-tooltip />
            <ElTableColumn prop="integrationMethod" label="集成技术方式" min-width="120" show-overflow-tooltip />
          </ElTable>
          <p v-if="!record.integrationLines?.length" class="empty-tip">暂无系统集成范围</p>
        </ElTabPane>

        <ElTabPane :label="formatTabLabel('上线支持', goLiveSupportCount)" name="goLiveSupport">
          <ElTable border :data="record.goLiveSupportLines" row-key="id" max-height="420">
            <ElTableColumn prop="seq" label="序号" width="70" align="center" />
            <ElTableColumn prop="supportContent" label="上线支持内容" min-width="160" show-overflow-tooltip />
            <ElTableColumn prop="completionCriteria" label="上线支持完成标准" min-width="280" show-overflow-tooltip />
          </ElTable>
          <p v-if="!record.goLiveSupportLines?.length" class="empty-tip">暂无上线支持</p>
        </ElTabPane>

        <ElTabPane :label="formatTabLabel('SOW撰写参考文档', sowReferenceCount)" name="sowReference">
          <ul v-if="sowReferenceAttachmentItems.length" class="attachment-list">
            <li v-for="item in sowReferenceAttachmentItems" :key="`${item.id}-${item.fileName}`">
              <ElButton
                v-if="item.id"
                type="primary"
                link
                @click="handleDownloadAttachment(item.id, item.fileName)"
              >
                {{ item.fileName }}
              </ElButton>
              <span v-else>{{ item.fileName }}</span>
            </li>
          </ul>
          <ElEmpty v-else description="暂无 SOW 撰写参考文档" />
        </ElTabPane>

        <ElTabPane :label="formatTabLabel('项目需求', requirementCount)" name="requirements">
          <ul v-if="record.requirementAttachmentNames.length" class="attachment-list">
            <li v-for="name in record.requirementAttachmentNames" :key="name">{{ name }}</li>
          </ul>
          <ElEmpty v-else description="暂无项目需求附件" />
        </ElTabPane>
      </ElTabs>
    </template>

    <ElEmpty v-else description="暂无数据" />
  </ElDrawer>
</template>

<style lang="scss" scoped>
:global(.project-init-detail-drawer.el-drawer) {
  width: 100% !important;
  max-width: 100% !important;
}

.detail-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  width: 100%;
  padding-right: 8px;
}

.detail-header-main {
  display: flex;
  align-items: center;
  gap: 12px;
}

.detail-title {
  margin: 0;
  font-size: 18px;
  font-weight: 600;
}

.detail-tabs {
  min-height: 360px;
}

.attachment-list {
  margin: 0;
  padding-left: 20px;
  line-height: 1.8;
}

.empty-tip {
  margin: 12px 0 0;
  color: var(--el-text-color-secondary);
  font-size: 13px;
}

.section-text {
  margin: 0;
  line-height: 1.8;
  white-space: pre-wrap;
  word-break: break-word;
}

.implementation-strategy-tip {
  margin: 0 0 12px;
  color: var(--el-text-color-regular);
  font-size: 14px;
}

.org-structure-gallery {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
}

.org-structure-image {
  width: 200px;
  height: 200px;
  border: 1px solid var(--el-border-color);
  border-radius: 6px;
  cursor: zoom-in;
  background: var(--el-fill-color-light);
}
</style>
