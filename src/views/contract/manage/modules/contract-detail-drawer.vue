<script setup lang="ts">
import { computed, ref } from 'vue';
import { ElMessage } from 'element-plus';
import { useClipboard } from '@vueuse/core';
import {
  CONTRACT_STATUS_LABEL,
  CONTRACT_STATUS_TAG_TYPE,
  CONTRACT_TYPE_LABEL,
  type ContractStatus
} from '@/constants/contract';
import { SETTLEMENT_METHOD_LABEL, type PaymentSettlementMethod } from '@/constants/basedata-payment-term';
import { downloadFile } from '@/service/api/file';
import type { ContractRecord } from './contract-operate-drawer.vue';

defineOptions({ name: 'ContractDetailDrawer' });

const props = defineProps<{
  contract: ContractRecord | null;
}>();

const visible = defineModel<boolean>('visible', { default: false });

const activeTab = ref('detail');
const basicCollapse = ref(['milestone', 'remark', 'attachments', 'requirements']);

const { copy, isSupported } = useClipboard();

const status = computed<ContractStatus>(() => props.contract?.status ?? 'draft');

const paymentPlanCount = computed(() => props.contract?.paymentLines.length ?? 0);
const productCount = computed(() => props.contract?.productLines.length ?? 0);

/** 摘要区：与添加页核心字段一致，不与下方详情重复 */
const summaryItems = computed(() => {
  const c = props.contract;
  if (!c) return [];
  return [
    { label: '合同名称', value: c.contractName },
    { label: '客户名称', value: c.customerName, link: true },
    { label: '合同类型', value: CONTRACT_TYPE_LABEL[c.contractType], link: true },
    { label: '签约日期', value: c.signDate },
    { label: '交付日期', value: c.deliveryDate },
    { label: '销售负责人', value: c.salesOwner, link: true },
    { label: '产品报价(元)', value: formatAmount(c.quoteAmount) }
  ];
});

function formatAmount(amount: number) {
  return amount.toLocaleString('zh-CN', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
}

function settlementLabel(method: string) {
  if (!method) return '—';
  return SETTLEMENT_METHOD_LABEL[method as PaymentSettlementMethod] ?? method;
}

async function copyContractNo() {
  if (!props.contract?.contractNo) return;
  if (!isSupported.value) {
    ElMessage.warning('当前浏览器不支持复制');
    return;
  }
  await copy(props.contract.contractNo);
  ElMessage.success('合同编号已复制');
}

const contractAttachmentItems = computed(() => {
  const c = props.contract;
  if (!c) return [];
  if (c.contractAttachments?.length) return c.contractAttachments;
  return (c.contractAttachmentNames ?? []).map(fileName => ({ id: 0, fileName, fileSize: 0 }));
});

const requirementAttachmentItems = computed(() => {
  const c = props.contract;
  if (!c) return [];
  if (c.requirementAttachments?.length) return c.requirementAttachments;
  return (c.requirementAttachmentNames ?? []).map(fileName => ({ id: 0, fileName, fileSize: 0 }));
});

async function handleDownloadAttachment(id: number, fileName: string) {
  if (!id) {
    ElMessage.warning('该附件为历史数据，无法下载');
    return;
  }
  try {
    await downloadFile(id, fileName);
  } catch (error) {
    const message = error instanceof Error ? error.message : '下载失败';
    ElMessage.error(message || '下载失败');
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
    :with-header="false"
    class="contract-detail-drawer"
  >
    <div v-if="contract" class="detail-page">
      <!-- 页头：右上角取消 -->
      <div class="detail-page-header">
        <div class="detail-page-header__title">
          <span class="detail-page-header__label">合同详情</span>
          <span class="detail-page-header__name">{{ contract.contractName }}</span>
        </div>
        <ElButton @click="handleClose">
          {{ $t('common.cancel') }}
        </ElButton>
      </div>

      <!-- 顶栏：编号 + 状态 + 操作 -->
      <div class="detail-toolbar card-wrapper">
        <div class="toolbar-left">
          <span class="contract-no-badge">合同编号</span>
          <span class="contract-no-text">{{ contract.contractNo }}</span>
          <ElButton link type="primary" class="copy-btn" @click="copyContractNo">
            <icon-mdi:content-copy class="text-icon" />
          </ElButton>
          <ElTag :type="CONTRACT_STATUS_TAG_TYPE[status]" effect="light" round class="status-tag">
            {{ CONTRACT_STATUS_LABEL[status] }}
          </ElTag>
        </div>
        <ElSpace wrap class="toolbar-actions">
          <ElButton type="primary" @click="onMockAction('分配')">分配</ElButton>
          <ElButton @click="onMockAction('复制')">复制</ElButton>
          <ElButton @click="onMockAction('共享')">共享</ElButton>
          <ElButton @click="onMockAction('打印工具')">打印工具</ElButton>
          <ElButton @click="onMockAction('更改创建人')">更改创建人</ElButton>
          <ElButton circle @click="onMockAction('更多')">
            <icon-mdi:dots-horizontal class="text-icon" />
          </ElButton>
        </ElSpace>
      </div>

      <!-- 摘要区 -->
      <div class="detail-summary">
        <ElRow :gutter="16">
          <ElCol v-for="(item, index) in summaryItems" :key="index" :lg="6" :md="8" :sm="12" :xs="24">
            <div class="summary-item">
              <span class="summary-label">{{ item.label }}</span>
              <span class="summary-value" :class="{ 'is-link': item.link }">{{ item.value }}</span>
            </div>
          </ElCol>
        </ElRow>
      </div>

      <!-- 页签：与添加页一致 — 详情 / 收款条件 / 项目产品 -->
      <div class="detail-body card-wrapper">
        <ElTabs v-model="activeTab" class="detail-tabs">
          <ElTabPane label="详情" name="detail">
            <ElCollapse v-model="basicCollapse">
              <ElCollapseItem title="里程碑" name="milestone">
                <p class="section-text">{{ contract.milestone || '—' }}</p>
              </ElCollapseItem>
              <ElCollapseItem title="备注" name="remark">
                <p class="section-text">{{ contract.remark || '—' }}</p>
              </ElCollapseItem>
              <ElCollapseItem title="合同附件" name="attachments">
                <ul v-if="contractAttachmentItems.length" class="attachment-list">
                  <li v-for="item in contractAttachmentItems" :key="`${item.id}-${item.fileName}`">
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
                <p v-else class="section-text">—</p>
              </ElCollapseItem>
              <ElCollapseItem title="项目需求" name="requirements">
                <ul v-if="requirementAttachmentItems.length" class="attachment-list">
                  <li v-for="item in requirementAttachmentItems" :key="`${item.id}-${item.fileName}`">
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
                <p v-else class="section-text">—</p>
              </ElCollapseItem>
            </ElCollapse>
          </ElTabPane>

          <ElTabPane :label="`收款条件[${paymentPlanCount}]`" name="payment">
            <ElTable v-if="paymentPlanCount" border :data="contract.paymentLines" row-key="id">
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
            <ElEmpty v-else description="暂无收款条件" />
          </ElTabPane>

          <ElTabPane :label="`项目产品[${productCount}]`" name="products">
            <ElTable v-if="productCount" border :data="contract.productLines" row-key="id">
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
            <ElEmpty v-else description="暂无项目产品" />
          </ElTabPane>
        </ElTabs>
      </div>
    </div>
  </ElDrawer>
</template>

<style lang="scss" scoped>
.contract-detail-drawer {
  /* ElDrawer 不识别 fullscreen，需 size="100%" + 样式兜底 */
  :deep(.el-drawer.rtl) {
    width: 100% !important;
    max-width: 100vw;
  }

  :deep(.el-drawer__body) {
    padding: 0;
    background: var(--el-bg-color-page);
  }
}

.detail-page {
  display: flex;
  flex-direction: column;
  gap: 12px;
  box-sizing: border-box;
  min-height: 100%;
  padding: 0 16px 16px;
}

.detail-page-header {
  position: sticky;
  top: 0;
  z-index: 10;
  display: flex;
  flex-shrink: 0;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  margin: 0 -16px;
  padding: 12px 16px;
  background: var(--el-bg-color);
  border-bottom: 1px solid var(--el-border-color-lighter);
}

.detail-page-header__title {
  display: flex;
  flex-wrap: wrap;
  align-items: baseline;
  gap: 8px;
  min-width: 0;
}

.detail-page-header__label {
  flex-shrink: 0;
  font-size: 16px;
  font-weight: 600;
  color: var(--el-text-color-primary);
}

.detail-page-header__name {
  overflow: hidden;
  font-size: 14px;
  color: var(--el-text-color-secondary);
  text-overflow: ellipsis;
  white-space: nowrap;
}

.detail-toolbar {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  padding: 12px 16px;
  background: var(--el-bg-color);
  border: 1px solid var(--el-border-color-lighter);
  border-radius: 4px;
}

.toolbar-left {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 8px;
}

.contract-no-badge {
  padding: 2px 8px;
  font-size: 12px;
  color: #fff;
  background: var(--el-color-primary);
  border-radius: 2px;
}

.contract-no-text {
  font-size: 16px;
  font-weight: 600;
  color: var(--el-text-color-primary);
}

.status-tag {
  margin-left: 4px;
}

.detail-summary {
  padding: 16px;
  background: var(--el-fill-color-light);
  border: 1px solid var(--el-border-color-lighter);
  border-radius: 4px;
}

.summary-item {
  margin-bottom: 12px;
  line-height: 1.6;
}

.summary-label {
  display: block;
  font-size: 12px;
  color: var(--el-text-color-secondary);
}

.summary-value {
  font-size: 14px;
  color: var(--el-text-color-primary);

  &.is-link {
    color: var(--el-color-primary);
    cursor: pointer;
  }
}

.detail-body {
  flex: 1;
  min-height: 0;
  padding: 0 16px 16px;
  background: var(--el-bg-color);
  border: 1px solid var(--el-border-color-lighter);
  border-radius: 4px;
}

.detail-tabs {
  :deep(.el-tabs__header) {
    margin-bottom: 0;
  }

  :deep(.el-tabs__content) {
    padding-top: 12px;
  }
}

.section-text {
  margin: 0;
  padding: 8px 0 16px;
  font-size: 13px;
  line-height: 1.7;
  color: var(--el-text-color-regular);
}

.attachment-list {
  margin: 0;
  padding: 8px 0 16px 20px;
  font-size: 13px;
  line-height: 1.8;
  color: var(--el-text-color-regular);
}
</style>
