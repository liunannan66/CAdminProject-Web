<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue';
import { useRouter } from 'vue-router';
import { ElMessage } from 'element-plus';
import {
  PROJECT_TASK_PRIORITY_LABEL,
  PROJECT_TASK_STATUS_LABEL,
  PROJECT_TASK_STATUS_OPTIONS,
  PROJECT_TASK_STATUS_TAG_TYPE,
  type ProjectTaskPriority,
  type ProjectTaskStatus
} from '@/constants/project-task';
import {
  getMyProjectTaskPage,
  updateProjectTaskProgress,
  type ProjectTaskDto
} from '@/service/api/project-task';

defineOptions({ name: 'MobileTask' });

const router = useRouter();

const searchParams = reactive({
  pageNo: 1,
  pageSize: 20,
  keyword: '',
  status: '' as ProjectTaskStatus | ''
});

const loading = ref(false);
const totalRows = ref(0);
const tableData = ref<ProjectTaskDto[]>([]);
const showProgressDrawer = ref(false);
const activeTask = ref<ProjectTaskDto | null>(null);
const progressValue = ref(0);
const progressStatus = ref<ProjectTaskStatus>('in_progress');
const progressRemark = ref('');
const saving = ref(false);

const statusTabs = computed(() => [{ label: '全部', value: '' as const }, ...PROJECT_TASK_STATUS_OPTIONS]);

async function fetchList() {
  loading.value = true;
  try {
    const result = await getMyProjectTaskPage({
      pageNo: searchParams.pageNo,
      pageSize: searchParams.pageSize,
      keyWord: searchParams.keyword.trim() || undefined,
      status: searchParams.status || undefined
    });
    tableData.value = result?.records ?? [];
    totalRows.value = result?.totalRows ?? 0;
  } catch {
    tableData.value = [];
    totalRows.value = 0;
  } finally {
    loading.value = false;
  }
}

function selectStatus(status: ProjectTaskStatus | '') {
  searchParams.status = status;
  searchParams.pageNo = 1;
  fetchList();
}

function openProgressDrawer(task: ProjectTaskDto) {
  activeTask.value = task;
  progressValue.value = task.progress ?? 0;
  progressStatus.value = (task.status === 'overdue' ? 'in_progress' : task.status) as ProjectTaskStatus;
  progressRemark.value = task.remark ?? '';
  showProgressDrawer.value = true;
}

function closeProgressDrawer() {
  showProgressDrawer.value = false;
  activeTask.value = null;
}

async function submitProgress() {
  if (!activeTask.value || saving.value) return;
  saving.value = true;
  try {
    await updateProjectTaskProgress({
      id: activeTask.value.id,
      progress: progressValue.value,
      status: progressStatus.value,
      remark: progressRemark.value.trim()
    });
    ElMessage.success('进度已更新');
    closeProgressDrawer();
    fetchList();
  } finally {
    saving.value = false;
  }
}

function goPcHome() {
  router.push({ name: 'home' });
}

onMounted(fetchList);
</script>

<template>
  <div class="mobile-task-page">
    <header class="mobile-header">
      <h1>我的任务</h1>
      <p class="mobile-subtitle">H5 移动端 · 仅显示分配给您的已立项项目任务</p>
    </header>

    <div class="mobile-toolbar">
      <ElInput v-model="searchParams.keyword" placeholder="搜索任务" clearable @keyup.enter="fetchList" />
      <ElButton type="primary" class="mt-8px w-full" @click="fetchList">查询</ElButton>
    </div>

    <div class="status-tabs">
      <button
        v-for="tab in statusTabs"
        :key="tab.label"
        type="button"
        class="status-tab"
        :class="{ active: searchParams.status === tab.value }"
        @click="selectStatus(tab.value)"
      >
        {{ tab.label }}
      </button>
    </div>

    <div v-loading="loading" class="task-list">
      <div v-for="task in tableData" :key="task.id" class="task-card" @click="openProgressDrawer(task)">
        <div class="task-card-header">
          <span class="task-name">{{ task.taskName }}</span>
          <ElTag :type="PROJECT_TASK_STATUS_TAG_TYPE[task.status as ProjectTaskStatus]" size="small" round>
            {{ PROJECT_TASK_STATUS_LABEL[task.status as ProjectTaskStatus] ?? task.status }}
          </ElTag>
        </div>
        <p class="task-project">{{ task.projectName }}</p>
        <p class="task-meta">
          {{ task.startDate }} ~ {{ task.endDate }}
          · 优先级 {{ PROJECT_TASK_PRIORITY_LABEL[task.priority as ProjectTaskPriority] ?? task.priority }}
        </p>
        <div class="task-progress-row">
          <span>进度 {{ task.progress }}%</span>
          <span v-if="task.delayDays > 0" class="delay-text">逾期 {{ task.delayDays }} 天</span>
        </div>
        <ElProgress :percentage="task.progress" :stroke-width="8" :show-text="false" />
      </div>

      <ElEmpty v-if="!loading && !tableData.length" description="暂无任务" />
    </div>

    <footer class="mobile-footer">
      <ElButton text type="primary" @click="goPcHome">返回 PC 首页</ElButton>
    </footer>

    <ElDrawer
      v-model="showProgressDrawer"
      :with-header="false"
      direction="btt"
      size="72%"
      append-to-body
      destroy-on-close
      @close="closeProgressDrawer"
    >
      <template v-if="activeTask">
        <h3 class="drawer-title">{{ activeTask.taskName }}</h3>
        <p class="drawer-project">{{ activeTask.projectName }}</p>
        <ElForm label-position="top">
          <ElFormItem label="进度 (%)">
            <ElSlider v-model="progressValue" :min="0" :max="100" show-input />
          </ElFormItem>
          <ElFormItem label="状态">
            <ElSelect v-model="progressStatus" class="w-full">
              <ElOption
                v-for="item in PROJECT_TASK_STATUS_OPTIONS.filter(s => s.value !== 'overdue')"
                :key="item.value"
                :label="item.label"
                :value="item.value"
              />
            </ElSelect>
          </ElFormItem>
          <ElFormItem label="进展说明">
            <ElInput v-model="progressRemark" type="textarea" :rows="4" placeholder="填写本次进展" />
          </ElFormItem>
        </ElForm>
        <div class="drawer-actions">
          <ElButton class="w-full" @click="closeProgressDrawer">取消</ElButton>
          <ElButton class="w-full" type="primary" :loading="saving" @click="submitProgress">提交进度</ElButton>
        </div>
      </template>
    </ElDrawer>
  </div>
</template>

<style scoped lang="scss">
.mobile-task-page {
  min-height: 100vh;
  padding: 16px 16px 72px;
  background: var(--el-bg-color-page);
}

.mobile-header h1 {
  margin: 0;
  font-size: 22px;
}

.mobile-subtitle {
  margin: 6px 0 0;
  color: var(--el-text-color-secondary);
  font-size: 12px;
}

.mobile-toolbar {
  margin-top: 16px;
}

.status-tabs {
  display: flex;
  gap: 8px;
  margin: 16px 0 12px;
  overflow-x: auto;
}

.status-tab {
  flex-shrink: 0;
  padding: 6px 12px;
  border: 1px solid var(--el-border-color);
  border-radius: 999px;
  background: var(--el-bg-color);
  color: var(--el-text-color-regular);
  font-size: 13px;
}

.status-tab.active {
  border-color: var(--el-color-primary);
  background: var(--el-color-primary-light-9);
  color: var(--el-color-primary);
}

.task-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.task-card {
  padding: 14px;
  border: 1px solid var(--el-border-color-light);
  border-radius: 12px;
  background: var(--el-bg-color);
}

.task-card-header {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 8px;
}

.task-name {
  font-size: 16px;
  font-weight: 600;
}

.task-project {
  margin: 8px 0 4px;
  color: var(--el-text-color-secondary);
  font-size: 13px;
}

.task-meta {
  margin: 0 0 8px;
  color: var(--el-text-color-secondary);
  font-size: 12px;
}

.task-progress-row {
  display: flex;
  justify-content: space-between;
  margin-bottom: 6px;
  font-size: 12px;
}

.delay-text {
  color: var(--el-color-danger);
}

.mobile-footer {
  position: fixed;
  right: 0;
  bottom: 0;
  left: 0;
  padding: 12px 16px;
  border-top: 1px solid var(--el-border-color-light);
  background: var(--el-bg-color);
  text-align: center;
}

.drawer-title {
  margin: 0 0 4px;
  font-size: 18px;
}

.drawer-project {
  margin: 0 0 16px;
  color: var(--el-text-color-secondary);
  font-size: 13px;
}

.drawer-actions {
  display: grid;
  gap: 10px;
  margin-top: 20px;
}
</style>
