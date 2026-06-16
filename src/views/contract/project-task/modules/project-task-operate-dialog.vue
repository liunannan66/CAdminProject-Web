<script setup lang="ts">
import { computed, reactive, ref, watch } from 'vue';
import type { FormInstance, FormRules } from 'element-plus';
import { ElMessage } from 'element-plus';
import {
  PROJECT_TASK_PRIORITY_OPTIONS,
  PROJECT_TASK_STATUS_OPTIONS,
  type ProjectTaskPriority,
  type ProjectTaskStatus
} from '@/constants/project-task';
import { addProjectTask, updateProjectTask, type ProjectTaskDto } from '@/service/api/project-task';
import { getSysUserPage } from '@/service/api/sysuser';

defineOptions({ name: 'ProjectTaskOperateDialog' });

const props = defineProps<{
  projectId: number;
  record: ProjectTaskDto | null;
}>();

const visible = defineModel<boolean>('visible', { default: false });

const emit = defineEmits<{
  submitted: [];
}>();

const formRef = ref<FormInstance>();
const saving = ref(false);
const userOptions = ref<Array<{ id: number; name: string }>>([]);

const formModel = reactive({
  taskName: '',
  description: '',
  startDate: '',
  endDate: '',
  assigneeUserId: undefined as number | undefined,
  priority: 'normal' as ProjectTaskPriority,
  progress: 0,
  status: 'pending' as ProjectTaskStatus,
  remark: ''
});

const isEdit = computed(() => Boolean(props.record?.id));

const rules: FormRules = {
  taskName: [{ required: true, message: '请输入任务名称', trigger: 'blur' }],
  startDate: [{ required: true, message: '请选择开始日期', trigger: 'change' }],
  endDate: [{ required: true, message: '请选择结束日期', trigger: 'change' }],
  assigneeUserId: [{ required: true, message: '请选择责任人', trigger: 'change' }]
};

async function loadUsers() {
  try {
    const result = await getSysUserPage({ pageNo: 1, pageSize: 200 });
    userOptions.value = (result?.records ?? []).map(item => ({
      id: item.id,
      name: item.name || item.account
    }));
  } catch {
    userOptions.value = [];
  }
}

function resetForm() {
  formModel.taskName = '';
  formModel.description = '';
  formModel.startDate = '';
  formModel.endDate = '';
  formModel.assigneeUserId = undefined;
  formModel.priority = 'normal';
  formModel.progress = 0;
  formModel.status = 'pending';
  formModel.remark = '';
  formRef.value?.clearValidate();
}

function fillForm(record: ProjectTaskDto) {
  formModel.taskName = record.taskName;
  formModel.description = record.description ?? '';
  formModel.startDate = record.startDate;
  formModel.endDate = record.endDate;
  formModel.assigneeUserId = record.assigneeUserId;
  formModel.priority = (record.priority || 'normal') as ProjectTaskPriority;
  formModel.progress = record.progress ?? 0;
  formModel.status = (record.status || 'pending') as ProjectTaskStatus;
  formModel.remark = record.remark ?? '';
}

watch(
  () => visible.value,
  async open => {
    if (!open) return;
    await loadUsers();
    if (props.record) fillForm(props.record);
    else resetForm();
  }
);

async function handleSubmit() {
  if (!formRef.value || saving.value || !props.projectId) return;
  try {
    await formRef.value.validate();
  } catch {
    return;
  }

  const payload = {
    id: props.record?.id,
    projectId: props.projectId,
    sortNo: props.record?.sortNo ?? 1,
    taskName: formModel.taskName.trim(),
    description: formModel.description.trim(),
    startDate: formModel.startDate,
    endDate: formModel.endDate,
    assigneeUserId: formModel.assigneeUserId!,
    priority: formModel.priority,
    progress: formModel.progress,
    status: formModel.status,
    remark: formModel.remark.trim()
  };

  saving.value = true;
  try {
    if (isEdit.value) {
      await updateProjectTask(payload);
      ElMessage.success('保存成功');
    } else {
      await addProjectTask(payload);
      ElMessage.success('新增成功');
    }
    emit('submitted');
    visible.value = false;
  } finally {
    saving.value = false;
  }
}
</script>

<template>
  <ElDialog
    v-model="visible"
    :title="isEdit ? '编辑任务' : '新增任务'"
    width="560px"
    append-to-body
    destroy-on-close
  >
    <ElForm ref="formRef" :model="formModel" :rules="rules" label-width="96px">
      <ElFormItem label="任务名称" prop="taskName">
        <ElInput v-model="formModel.taskName" placeholder="任务名称" clearable />
      </ElFormItem>
      <ElFormItem label="任务描述">
        <ElInput v-model="formModel.description" type="textarea" :rows="3" placeholder="可选" />
      </ElFormItem>
      <ElFormItem label="开始日期" prop="startDate">
        <ElDatePicker v-model="formModel.startDate" type="date" value-format="YYYY-MM-DD" class="w-full" />
      </ElFormItem>
      <ElFormItem label="结束日期" prop="endDate">
        <ElDatePicker v-model="formModel.endDate" type="date" value-format="YYYY-MM-DD" class="w-full" />
      </ElFormItem>
      <ElFormItem label="责任人" prop="assigneeUserId">
        <ElSelect v-model="formModel.assigneeUserId" filterable placeholder="选择责任人" class="w-full">
          <ElOption v-for="user in userOptions" :key="user.id" :label="user.name" :value="user.id" />
        </ElSelect>
      </ElFormItem>
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
      <ElFormItem label="进度(%)">
        <ElSlider v-model="formModel.progress" :min="0" :max="100" show-input />
      </ElFormItem>
      <ElFormItem label="状态">
        <ElSelect v-model="formModel.status" class="w-full">
          <ElOption
            v-for="item in PROJECT_TASK_STATUS_OPTIONS"
            :key="item.value"
            :label="item.label"
            :value="item.value"
          />
        </ElSelect>
      </ElFormItem>
      <ElFormItem label="备注">
        <ElInput v-model="formModel.remark" type="textarea" :rows="2" />
      </ElFormItem>
    </ElForm>
    <template #footer>
      <ElButton @click="visible = false">取消</ElButton>
      <ElButton type="primary" :loading="saving" @click="handleSubmit">保存</ElButton>
    </template>
  </ElDialog>
</template>
