<script setup lang="ts">
import { computed } from 'vue';
import { ElMessage } from 'element-plus';

defineOptions({
  name: 'OpLogDetailDialog'
});

export interface OpLogRecord {
  id: number;
  userId: number;
  userName: string;
  userType: string;
  opType: string;
  opModule: string;
  opDesc: string;
  requestMethod: string;
  requestUrl: string;
  requestParam: string;
  responseResult: string;
  ip: string;
  location: string;
  opTime: string;
  opTimestamp: number;
  success?: boolean;
  elapsedTime?: number;
  browser?: string;
  os?: string;
}

interface Props {
  modelValue: boolean;
  record: OpLogRecord | null;
}

interface Emits {
  (e: 'update:modelValue', value: boolean): void;
}

const props = defineProps<Props>();
const emit = defineEmits<Emits>();

const visible = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
});

const userTypeLabel: Record<string, string> = {
  SuperAdmin: '超级管理员',
  Admin: '管理员',
  User: '普通用户',
  Visitor: '游客'
};

function formatJsonText(value?: string) {
  if (!value?.trim()) {
    return '（无）';
  }

  try {
    return JSON.stringify(JSON.parse(value), null, 2);
  } catch {
    return value;
  }
}

const formattedRequestParam = computed(() => formatJsonText(props.record?.requestParam));
const formattedResponseResult = computed(() => formatJsonText(props.record?.responseResult));

async function copyText(content: string, label: string) {
  if (!content || content === '（无）') {
    ElMessage.warning(`${label}为空，无法复制`);
    return;
  }

  try {
    await navigator.clipboard.writeText(content);
    ElMessage.success(`${label}已复制`);
  } catch {
    ElMessage.error('复制失败，请手动选择复制');
  }
}

function handleClose() {
  visible.value = false;
}
</script>

<template>
  <ElDialog
    v-model="visible"
    title="操作日志详情"
    width="860px"
    destroy-on-close
    class="op-log-detail-dialog"
    @close="handleClose"
  >
    <template v-if="record">
      <ElDescriptions :column="2" border>
        <ElDescriptionsItem label="日志 ID">
          {{ record.id }}
        </ElDescriptionsItem>
        <ElDescriptionsItem label="操作用户">
          {{ record.userName || '-' }}
          <span v-if="record.userId" class="text-secondary">（ID: {{ record.userId }}）</span>
        </ElDescriptionsItem>
        <ElDescriptionsItem label="用户类型">
          <ElTag size="small" round>
            {{ userTypeLabel[record.userType] || record.userType || '未知' }}
          </ElTag>
        </ElDescriptionsItem>
        <ElDescriptionsItem label="执行结果">
          <ElTag :type="record.success === false ? 'danger' : 'success'" size="small">
            {{ record.success === false ? '失败' : '成功' }}
          </ElTag>
        </ElDescriptionsItem>
        <ElDescriptionsItem label="操作模块">
          {{ record.opModule || '-' }}
        </ElDescriptionsItem>
        <ElDescriptionsItem label="操作类型">
          {{ record.opType || '-' }}
        </ElDescriptionsItem>
        <ElDescriptionsItem label="操作描述" :span="2">
          {{ record.opDesc || '-' }}
        </ElDescriptionsItem>
        <ElDescriptionsItem label="请求方式">
          <ElTag :type="record.requestMethod === 'GET' ? 'success' : 'warning'" size="small">
            {{ record.requestMethod || '-' }}
          </ElTag>
        </ElDescriptionsItem>
        <ElDescriptionsItem label="耗时">
          {{ record.elapsedTime != null ? `${record.elapsedTime} ms` : '-' }}
        </ElDescriptionsItem>
        <ElDescriptionsItem label="请求地址" :span="2">
          <span class="break-all">{{ record.requestUrl || '-' }}</span>
        </ElDescriptionsItem>
        <ElDescriptionsItem label="IP 地址">
          {{ record.ip || '-' }}
        </ElDescriptionsItem>
        <ElDescriptionsItem label="操作时间">
          {{ record.opTime || '-' }}
        </ElDescriptionsItem>
        <ElDescriptionsItem label="操作地点" :span="2">
          <span class="break-all">{{ record.location || '-' }}</span>
        </ElDescriptionsItem>
        <ElDescriptionsItem label="浏览器">
          {{ record.browser || '-' }}
        </ElDescriptionsItem>
        <ElDescriptionsItem label="操作系统">
          {{ record.os || '-' }}
        </ElDescriptionsItem>
      </ElDescriptions>

      <div class="detail-block">
        <div class="detail-block__header">
          <span class="detail-block__title">请求参数</span>
          <ElButton size="small" @click="copyText(formattedRequestParam, '请求参数')">
            复制
          </ElButton>
        </div>
        <pre class="detail-block__content">{{ formattedRequestParam }}</pre>
      </div>

      <div class="detail-block">
        <div class="detail-block__header">
          <span class="detail-block__title">响应结果</span>
          <ElButton size="small" @click="copyText(formattedResponseResult, '响应结果')">
            复制
          </ElButton>
        </div>
        <pre class="detail-block__content">{{ formattedResponseResult }}</pre>
      </div>
    </template>

    <template #footer>
      <ElButton @click="handleClose">
        关闭
      </ElButton>
    </template>
  </ElDialog>
</template>

<style lang="scss" scoped>
.text-secondary {
  margin-left: 6px;
  color: var(--el-text-color-secondary);
  font-size: 12px;
}

.break-all {
  word-break: break-all;
}

.detail-block {
  margin-top: 16px;

  &__header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 8px;
  }

  &__title {
    font-size: 14px;
    font-weight: 600;
    color: var(--el-text-color-primary);
  }

  &__content {
    max-height: 240px;
    margin: 0;
    padding: 12px;
    overflow: auto;
    border: 1px solid var(--el-border-color);
    border-radius: 6px;
    background: var(--el-fill-color-light);
    color: var(--el-text-color-primary);
    font-size: 12px;
    line-height: 1.6;
    white-space: pre-wrap;
    word-break: break-all;
  }
}
</style>
