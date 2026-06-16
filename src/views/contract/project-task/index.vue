<script setup lang="ts">
import { computed, onMounted, reactive, ref, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { ElMessage, ElMessageBox } from 'element-plus';
import {
  PROJECT_INIT_STATUS_LABEL,
  type ProjectInitStatus
} from '@/constants/project-init';
import {
  PROJECT_TASK_AUTH,
  PROJECT_TASK_PRIORITY_LABEL,
  PROJECT_TASK_STATUS_LABEL,
  PROJECT_TASK_STATUS_OPTIONS,
  PROJECT_TASK_STATUS_TAG_TYPE,
  type ProjectTaskPriority,
  type ProjectTaskStatus
} from '@/constants/project-task';
import { useAuth } from '@/hooks/business/auth';
import { useAuthStore } from '@/store/modules/auth';
import { getProjectInitDetail } from '@/service/api/project-init';
import { deleteProjectTask, getProjectTaskPage, type ProjectTaskDto } from '@/service/api/project-task';
import ProjectTaskOperateDialog from './modules/project-task-operate-dialog.vue';

defineOptions({ name: 'ContractProjectTask' });

const route = useRoute();
const router = useRouter();
const { hasAuth } = useAuth();
const authStore = useAuthStore();

function checkAuth(code: string) {
  const configured = authStore.userInfo.buttons.some(item => item.startsWith('api:ProjectTask:'));
  if (!configured) return true;
  return hasAuth(code);
}

const canAdd = computed(() => checkAuth(PROJECT_TASK_AUTH.add));
const canUpdate = computed(() => checkAuth(PROJECT_TASK_AUTH.update));
const canDelete = computed(() => checkAuth(PROJECT_TASK_AUTH.delete));

const projectId = computed(() => Number(route.query.projectId ?? 0));
const projectNo = ref('');
const projectName = ref('');
const projectStatus = ref<ProjectInitStatus | ''>('');

const searchParams = reactive({
  pageNo: 1,
  pageSize: 10,
  keyword: '',
  status: '' as ProjectTaskStatus | ''
});

const loading = ref(false);
const totalRows = ref(0);
const tableData = ref<ProjectTaskDto[]>([]);
const showDialog = ref(false);
const editingRecord = ref<ProjectTaskDto | null>(null);

const isApprovedProject = computed(() => projectStatus.value === 'approved');

async function loadProjectHeader() {
  if (!projectId.value) return;
  try {
    const detail = await getProjectInitDetail(projectId.value);
    projectNo.value = detail.projectNo;
    projectName.value = detail.projectName;
    projectStatus.value = (detail.status || '') as ProjectInitStatus;
    if (!isApprovedProject.value) {
      ElMessage.warning('仅已立项项目可维护任务清单');
    }
  } catch {
    ElMessage.error('加载项目信息失败');
  }
}

async function fetchTaskList() {
  if (!projectId.value || !isApprovedProject.value) {
    tableData.value = [];
    totalRows.value = 0;
    return;
  }

  loading.value = true;
  try {
    const result = await getProjectTaskPage({
      pageNo: searchParams.pageNo,
      pageSize: searchParams.pageSize,
      projectId: projectId.value,
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

function goBack() {
  router.push({ name: 'contract_project-init' });
}

function openAddDialog() {
  editingRecord.value = null;
  showDialog.value = true;
}

function openEditDialog(row: ProjectTaskDto) {
  editingRecord.value = { ...row };
  showDialog.value = true;
}

async function handleDelete(row: ProjectTaskDto) {
  if (!canDelete.value) {
    ElMessage.warning('暂无删除权限');
    return;
  }
  try {
    await ElMessageBox.confirm(`确定删除任务「${row.taskName}」吗？`, '提示', { type: 'warning' });
    await deleteProjectTask(row.id);
    ElMessage.success('删除成功');
    fetchTaskList();
  } catch {
    /* cancel */
  }
}

function search() {
  searchParams.pageNo = 1;
  fetchTaskList();
}

function resetSearch() {
  searchParams.keyword = '';
  searchParams.status = '';
  searchParams.pageNo = 1;
  fetchTaskList();
}

watch(projectId, async () => {
  await loadProjectHeader();
  await fetchTaskList();
});

onMounted(async () => {
  if (!projectId.value) {
    ElMessage.warning('请从已立项项目进入任务清单');
    goBack();
    return;
  }
  await loadProjectHeader();
  await fetchTaskList();
});
</script>

<template>
  <div class="min-h-500px flex-col-stretch gap-16px overflow-hidden lt-sm:overflow-auto">
    <ElCard class="card-wrapper">
      <div class="flex flex-wrap items-center justify-between gap-12px">
        <div>
          <ElButton link type="primary" @click="goBack">← 返回项目立项</ElButton>
          <h3 class="task-title">{{ projectName || '项目任务清单' }}</h3>
          <p class="task-subtitle">
            项目编号：{{ projectNo || '—' }}
            <span v-if="projectStatus">｜立项状态：{{ PROJECT_INIT_STATUS_LABEL[projectStatus as ProjectInitStatus] }}</span>
          </p>
        </div>
        <ElSpace>
          <ElButton @click="fetchTaskList">刷新</ElButton>
          <ElButton v-if="canAdd && isApprovedProject" type="primary" @click="openAddDialog">新增任务</ElButton>
        </ElSpace>
      </div>
    </ElCard>

    <ElCard v-loading="loading" class="card-wrapper">
      <ElForm :model="searchParams" label-width="72px" class="mb-12px">
        <ElRow :gutter="16">
          <ElCol :lg="8" :md="12" :sm="24">
            <ElFormItem label="关键字">
              <ElInput v-model="searchParams.keyword" placeholder="任务名称 / 责任人" clearable />
            </ElFormItem>
          </ElCol>
          <ElCol :lg="8" :md="12" :sm="24">
            <ElFormItem label="状态">
              <ElSelect v-model="searchParams.status" clearable placeholder="全部" class="w-full">
                <ElOption
                  v-for="item in PROJECT_TASK_STATUS_OPTIONS"
                  :key="item.value"
                  :label="item.label"
                  :value="item.value"
                />
              </ElSelect>
            </ElFormItem>
          </ElCol>
          <ElCol :lg="8" :md="24" :sm="24">
            <ElSpace class="w-full justify-end">
              <ElButton @click="resetSearch">重置</ElButton>
              <ElButton type="primary" plain @click="search">查询</ElButton>
            </ElSpace>
          </ElCol>
        </ElRow>
      </ElForm>

      <ElAlert
        v-if="!isApprovedProject"
        type="warning"
        :closable="false"
        show-icon
        title="当前项目未立项，无法维护任务清单"
        class="mb-12px"
      />

      <ElTable v-else border :data="tableData" row-key="id">
        <ElTableColumn prop="taskName" label="任务名称" min-width="160" show-overflow-tooltip />
        <ElTableColumn label="时间" width="200" align="center">
          <template #default="{ row }">{{ row.startDate }} ~ {{ row.endDate }}</template>
        </ElTableColumn>
        <ElTableColumn prop="assigneeName" label="责任人" width="100" align="center" />
        <ElTableColumn label="优先级" width="80" align="center">
          <template #default="{ row }">
            {{ PROJECT_TASK_PRIORITY_LABEL[row.priority as ProjectTaskPriority] ?? row.priority }}
          </template>
        </ElTableColumn>
        <ElTableColumn label="进度" width="90" align="center">
          <template #default="{ row }">{{ row.progress }}%</template>
        </ElTableColumn>
        <ElTableColumn label="状态" width="90" align="center">
          <template #default="{ row }">
            <ElTag :type="PROJECT_TASK_STATUS_TAG_TYPE[row.status as ProjectTaskStatus]" size="small" round>
              {{ PROJECT_TASK_STATUS_LABEL[row.status as ProjectTaskStatus] ?? row.status }}
            </ElTag>
          </template>
        </ElTableColumn>
        <ElTableColumn label="延期(天)" width="90" align="center">
          <template #default="{ row }">{{ row.delayDays > 0 ? row.delayDays : '—' }}</template>
        </ElTableColumn>
        <ElTableColumn label="操作" width="140" fixed="right" align="center">
          <template #default="{ row }">
            <ElButton v-if="canUpdate" size="small" type="primary" link @click="openEditDialog(row)">编辑</ElButton>
            <ElButton v-if="canDelete" size="small" type="danger" link @click="handleDelete(row)">删除</ElButton>
          </template>
        </ElTableColumn>
      </ElTable>

      <div class="flex justify-end mt-12px">
        <ElPagination
          v-model:current-page="searchParams.pageNo"
          v-model:page-size="searchParams.pageSize"
          :page-sizes="[10, 20, 30, 50]"
          :total="totalRows"
          layout="total, sizes, prev, pager, next"
          @current-change="fetchTaskList"
          @size-change="search"
        />
      </div>
    </ElCard>

    <ProjectTaskOperateDialog
      v-model:visible="showDialog"
      :project-id="projectId"
      :record="editingRecord"
      @submitted="fetchTaskList"
    />
  </div>
</template>

<style scoped lang="scss">
.task-title {
  margin: 4px 0 0;
  font-size: 18px;
  font-weight: 600;
}

.task-subtitle {
  margin: 4px 0 0;
  color: var(--el-text-color-secondary);
  font-size: 13px;
}
</style>
