<script setup lang="ts">
import { computed, reactive, ref } from 'vue';
import { ElMessage, ElMessageBox, type FormInstance, type FormRules } from 'element-plus';
import {
  PROJECT_TASK_PRIORITY_LABEL,
  PROJECT_TASK_PRIORITY_OPTIONS,
  PROJECT_TASK_STATUS_LABEL,
  PROJECT_TASK_STATUS_OPTIONS,
  PROJECT_TASK_STATUS_TAG_TYPE,
  type ProjectTaskPriority,
  type ProjectTaskStatus
} from '@/constants/project-task';

defineOptions({ name: 'TaskWbs' });

interface WbsTask {
  id: number;
  wbsCode: string;
  projectName: string;
  taskName: string;
  parentName: string;
  ownerName: string;
  startDate: string;
  endDate: string;
  priority: ProjectTaskPriority;
  status: ProjectTaskStatus;
  progress: number;
  deliverable: string;
  remark?: string;
}

type TaskFormModel = Omit<WbsTask, 'id'>;

const STORAGE_KEY = 'soybean-task-wbs-v1';

const initialTasks: WbsTask[] = [
  {
    id: 1,
    wbsCode: '1.0',
    projectName: '合同履约数字化项目',
    taskName: '项目启动',
    parentName: '根节点',
    ownerName: '张三',
    startDate: '2026-06-01',
    endDate: '2026-06-05',
    priority: 'high',
    status: 'completed',
    progress: 100,
    deliverable: '启动会纪要、项目章程'
  },
  {
    id: 2,
    wbsCode: '1.1',
    projectName: '合同履约数字化项目',
    taskName: '需求调研与确认',
    parentName: '项目启动',
    ownerName: '李四',
    startDate: '2026-06-06',
    endDate: '2026-06-18',
    priority: 'normal',
    status: 'in_progress',
    progress: 65,
    deliverable: '需求规格说明书'
  },
  {
    id: 3,
    wbsCode: '1.2',
    projectName: '合同履约数字化项目',
    taskName: '任务分解结构设计',
    parentName: '需求调研与确认',
    ownerName: '王五',
    startDate: '2026-06-19',
    endDate: '2026-06-25',
    priority: 'normal',
    status: 'pending',
    progress: 0,
    deliverable: 'WBS 分解表'
  },
  {
    id: 4,
    wbsCode: '2.0',
    projectName: '客户报价管理优化',
    taskName: '报价模板梳理',
    parentName: '根节点',
    ownerName: '赵六',
    startDate: '2026-05-20',
    endDate: '2026-06-10',
    priority: 'low',
    status: 'overdue',
    progress: 80,
    deliverable: '报价模板清单',
    remark: '等待业务确认最终模板'
  }
];

const loading = ref(false);
const taskList = ref<WbsTask[]>(loadLocalTasks());
const dialogVisible = ref(false);
const saving = ref(false);
const editingId = ref<number | null>(null);
const formRef = ref<FormInstance>();

const searchParams = reactive({
  keyword: '',
  projectName: '',
  status: '' as ProjectTaskStatus | ''
});

const formModel = reactive<TaskFormModel>(createEmptyForm());

const rules: FormRules<TaskFormModel> = {
  wbsCode: [{ required: true, message: '请输入 WBS 编码', trigger: 'blur' }],
  projectName: [{ required: true, message: '请输入所属项目', trigger: 'blur' }],
  taskName: [{ required: true, message: '请输入任务名称', trigger: 'blur' }],
  ownerName: [{ required: true, message: '请输入责任人', trigger: 'blur' }],
  startDate: [{ required: true, message: '请选择计划开始日期', trigger: 'change' }],
  endDate: [{ required: true, message: '请选择计划完成日期', trigger: 'change' }],
  deliverable: [{ required: true, message: '请输入交付物', trigger: 'blur' }]
};

const filteredTasks = computed(() => {
  const keyword = searchParams.keyword.trim().toLowerCase();
  const project = searchParams.projectName.trim().toLowerCase();

  return taskList.value.filter(item => {
    const matchKeyword =
      !keyword ||
      [item.wbsCode, item.taskName, item.ownerName, item.deliverable].some(value => value.toLowerCase().includes(keyword));
    const matchProject = !project || item.projectName.toLowerCase().includes(project);
    const matchStatus = !searchParams.status || item.status === searchParams.status;

    return matchKeyword && matchProject && matchStatus;
  });
});

const summary = computed(() => ({
  total: taskList.value.length,
  processing: taskList.value.filter(item => item.status === 'in_progress').length,
  overdue: taskList.value.filter(item => item.status === 'overdue').length,
  averageProgress: taskList.value.length
    ? Math.round(taskList.value.reduce((sum, item) => sum + item.progress, 0) / taskList.value.length)
    : 0
}));

function createEmptyForm(): TaskFormModel {
  return {
    wbsCode: '',
    projectName: '',
    taskName: '',
    parentName: '根节点',
    ownerName: '',
    startDate: '',
    endDate: '',
    priority: 'normal',
    status: 'pending',
    progress: 0,
    deliverable: '',
    remark: ''
  };
}

function loadLocalTasks() {
  try {
    const cache = window.localStorage.getItem(STORAGE_KEY);
    if (!cache) return [...initialTasks];
    const data = JSON.parse(cache) as WbsTask[];
    return Array.isArray(data) && data.length ? data : [...initialTasks];
  } catch {
    return [...initialTasks];
  }
}

function persistTasks() {
  window.localStorage.setItem(STORAGE_KEY, JSON.stringify(taskList.value));
}

function resetForm() {
  Object.assign(formModel, createEmptyForm());
}

function openAddDialog() {
  editingId.value = null;
  resetForm();
  dialogVisible.value = true;
}

function openEditDialog(row: WbsTask) {
  editingId.value = row.id;
  Object.assign(formModel, row);
  dialogVisible.value = true;
}

function refreshList() {
  loading.value = true;
  window.setTimeout(() => {
    taskList.value = loadLocalTasks();
    loading.value = false;
    ElMessage.success('任务池数据已刷新');
  }, 300);
}

function resetSearch() {
  searchParams.keyword = '';
  searchParams.projectName = '';
  searchParams.status = '';
}

async function submitForm() {
  if (saving.value) return;
  await formRef.value?.validate();

  if (formModel.startDate > formModel.endDate) {
    ElMessage.warning('计划开始日期不能晚于计划完成日期');
    return;
  }

  saving.value = true;
  try {
    const payload = { ...formModel };
    if (editingId.value) {
      const index = taskList.value.findIndex(item => item.id === editingId.value);
      if (index > -1) {
        taskList.value[index] = { id: editingId.value, ...payload };
      }
      ElMessage.success('任务已更新');
    } else {
      taskList.value.unshift({ id: Date.now(), ...payload });
      ElMessage.success('任务已新增');
    }
    persistTasks();
    dialogVisible.value = false;
  } finally {
    saving.value = false;
  }
}

async function handleDelete(row: WbsTask) {
  try {
    await ElMessageBox.confirm(`确定删除任务「${row.taskName}」吗？`, '提示', { type: 'warning' });
    taskList.value = taskList.value.filter(item => item.id !== row.id);
    persistTasks();
    ElMessage.success('任务已删除');
  } catch {
    /* cancel */
  }
}
</script>

<template>
  <div class="min-h-500px flex-col-stretch gap-16px overflow-hidden lt-sm:overflow-auto">
    <ElCard class="card-wrapper">
      <div class="flex flex-wrap items-center justify-between gap-12px">
        <div>
          <h3 class="page-title">任务池（WBS）</h3>
          <p class="page-desc">集中维护项目任务分解结构，支持 WBS 编码、责任人、计划周期、状态和交付物跟踪。</p>
        </div>
        <ElSpace>
          <ElButton @click="refreshList">刷新</ElButton>
          <ElButton type="primary" @click="openAddDialog">新增任务</ElButton>
        </ElSpace>
      </div>
    </ElCard>

    <ElRow :gutter="16">
      <ElCol :lg="6" :md="12" :sm="24">
        <ElCard class="card-wrapper stat-card">
          <span class="stat-label">任务总数</span>
          <strong>{{ summary.total }}</strong>
        </ElCard>
      </ElCol>
      <ElCol :lg="6" :md="12" :sm="24">
        <ElCard class="card-wrapper stat-card">
          <span class="stat-label">进行中</span>
          <strong>{{ summary.processing }}</strong>
        </ElCard>
      </ElCol>
      <ElCol :lg="6" :md="12" :sm="24">
        <ElCard class="card-wrapper stat-card danger">
          <span class="stat-label">逾期任务</span>
          <strong>{{ summary.overdue }}</strong>
        </ElCard>
      </ElCol>
      <ElCol :lg="6" :md="12" :sm="24">
        <ElCard class="card-wrapper stat-card success">
          <span class="stat-label">平均进度</span>
          <strong>{{ summary.averageProgress }}%</strong>
        </ElCard>
      </ElCol>
    </ElRow>

    <ElCard v-loading="loading" class="card-wrapper">
      <ElForm :model="searchParams" label-width="72px" class="mb-12px">
        <ElRow :gutter="16">
          <ElCol :lg="7" :md="12" :sm="24">
            <ElFormItem label="关键字">
              <ElInput v-model="searchParams.keyword" placeholder="WBS 编码 / 任务 / 责任人 / 交付物" clearable />
            </ElFormItem>
          </ElCol>
          <ElCol :lg="7" :md="12" :sm="24">
            <ElFormItem label="所属项目">
              <ElInput v-model="searchParams.projectName" placeholder="请输入项目名称" clearable />
            </ElFormItem>
          </ElCol>
          <ElCol :lg="6" :md="12" :sm="24">
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
          <ElCol :lg="4" :md="12" :sm="24">
            <ElSpace class="w-full justify-end">
              <ElButton @click="resetSearch">重置</ElButton>
            </ElSpace>
          </ElCol>
        </ElRow>
      </ElForm>

      <ElTable border :data="filteredTasks" row-key="id">
        <ElTableColumn prop="wbsCode" label="WBS 编码" width="110" align="center" />
        <ElTableColumn prop="taskName" label="任务名称" min-width="170" show-overflow-tooltip />
        <ElTableColumn prop="projectName" label="所属项目" min-width="180" show-overflow-tooltip />
        <ElTableColumn prop="parentName" label="上级任务" min-width="130" show-overflow-tooltip />
        <ElTableColumn prop="ownerName" label="责任人" width="100" align="center" />
        <ElTableColumn label="计划周期" width="210" align="center">
          <template #default="{ row }">{{ row.startDate }} ~ {{ row.endDate }}</template>
        </ElTableColumn>
        <ElTableColumn label="优先级" width="90" align="center">
          <template #default="{ row }">{{ PROJECT_TASK_PRIORITY_LABEL[row.priority as ProjectTaskPriority] }}</template>
        </ElTableColumn>
        <ElTableColumn label="进度" width="130" align="center">
          <template #default="{ row }">
            <ElProgress :percentage="row.progress" :stroke-width="8" />
          </template>
        </ElTableColumn>
        <ElTableColumn label="状态" width="100" align="center">
          <template #default="{ row }">
            <ElTag :type="PROJECT_TASK_STATUS_TAG_TYPE[row.status as ProjectTaskStatus]" size="small" round>
              {{ PROJECT_TASK_STATUS_LABEL[row.status as ProjectTaskStatus] }}
            </ElTag>
          </template>
        </ElTableColumn>
        <ElTableColumn prop="deliverable" label="交付物" min-width="160" show-overflow-tooltip />
        <ElTableColumn label="操作" width="130" fixed="right" align="center">
          <template #default="{ row }">
            <ElButton size="small" type="primary" link @click="openEditDialog(row)">编辑</ElButton>
            <ElButton size="small" type="danger" link @click="handleDelete(row)">删除</ElButton>
          </template>
        </ElTableColumn>
      </ElTable>
    </ElCard>

    <ElDialog
      v-model="dialogVisible"
      :title="editingId ? '编辑 WBS 任务' : '新增 WBS 任务'"
      width="760px"
      destroy-on-close
    >
      <ElForm ref="formRef" :model="formModel" :rules="rules" label-width="96px">
        <ElRow :gutter="16">
          <ElCol :span="12">
            <ElFormItem label="WBS 编码" prop="wbsCode">
              <ElInput v-model="formModel.wbsCode" placeholder="如：1.1.1" />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="所属项目" prop="projectName">
              <ElInput v-model="formModel.projectName" placeholder="请输入项目名称" />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="任务名称" prop="taskName">
              <ElInput v-model="formModel.taskName" placeholder="请输入任务名称" />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="上级任务">
              <ElInput v-model="formModel.parentName" placeholder="默认根节点" />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="责任人" prop="ownerName">
              <ElInput v-model="formModel.ownerName" placeholder="请输入责任人" />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="优先级">
              <ElSelect v-model="formModel.priority" class="w-full">
                <ElOption
                  v-for="item in PROJECT_TASK_PRIORITY_OPTIONS"
                  :key="item.value"
                  :label="item.label"
                  :value="item.value"
                />
              </ElSelect>
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="开始日期" prop="startDate">
              <ElDatePicker v-model="formModel.startDate" value-format="YYYY-MM-DD" class="w-full" />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="完成日期" prop="endDate">
              <ElDatePicker v-model="formModel.endDate" value-format="YYYY-MM-DD" class="w-full" />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="任务状态">
              <ElSelect v-model="formModel.status" class="w-full">
                <ElOption
                  v-for="item in PROJECT_TASK_STATUS_OPTIONS"
                  :key="item.value"
                  :label="item.label"
                  :value="item.value"
                />
              </ElSelect>
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="进度">
              <ElSlider v-model="formModel.progress" :min="0" :max="100" show-input />
            </ElFormItem>
          </ElCol>
          <ElCol :span="24">
            <ElFormItem label="交付物" prop="deliverable">
              <ElInput v-model="formModel.deliverable" placeholder="请输入交付物" />
            </ElFormItem>
          </ElCol>
          <ElCol :span="24">
            <ElFormItem label="备注">
              <ElInput v-model="formModel.remark" type="textarea" :rows="3" placeholder="请输入备注" />
            </ElFormItem>
          </ElCol>
        </ElRow>
      </ElForm>
      <template #footer>
        <ElButton @click="dialogVisible = false">取消</ElButton>
        <ElButton type="primary" :loading="saving" @click="submitForm">保存</ElButton>
      </template>
    </ElDialog>
  </div>
</template>

<style scoped lang="scss">
.page-title {
  margin: 4px 0 0;
  font-size: 18px;
  font-weight: 600;
}

.page-desc {
  margin: 4px 0 0;
  color: var(--el-text-color-secondary);
  font-size: 13px;
}

.stat-card {
  :deep(.el-card__body) {
    display: flex;
    align-items: center;
    justify-content: space-between;
  }

  strong {
    color: var(--el-color-primary);
    font-size: 26px;
  }

  &.danger strong {
    color: var(--el-color-danger);
  }

  &.success strong {
    color: var(--el-color-success);
  }
}

.stat-label {
  color: var(--el-text-color-secondary);
  font-size: 13px;
}
</style>
