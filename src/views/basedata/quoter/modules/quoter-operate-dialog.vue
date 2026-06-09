<script setup lang="ts">
import { reactive, ref, watch } from 'vue';
import type { FormInstance, FormRules } from 'element-plus';

type QuoterRecord = Api.Basedata.QuoterRecord;

interface QuoterForm {
  moduleName: string;
  subModuleName: string;
  description: string;
  unitPrice: number | null;
  status: 0 | 1;
}

interface Props {
  title?: string;
  quoter?: QuoterRecord | null;
}

const props = withDefaults(defineProps<Props>(), {
  title: '新增报价项',
  quoter: null
});

const visible = defineModel<boolean>('visible', { default: false });

const emit = defineEmits<{
  submitted: [payload: Omit<QuoterRecord, 'id'>];
}>();

const formRef = ref<FormInstance>();
const submitting = ref(false);

const defaultForm = (): QuoterForm => ({
  moduleName: '',
  subModuleName: '',
  description: '',
  unitPrice: null,
  status: 1
});

const formModel = reactive<QuoterForm>(defaultForm());

const rules: FormRules<QuoterForm> = {
  moduleName: [{ required: true, message: '请输入模块名称', trigger: 'blur' }],
  subModuleName: [{ required: true, message: '请输入子模块名称', trigger: 'blur' }],
  description: [{ required: true, message: '请输入功能说明', trigger: 'blur' }],
  status: [{ required: true, message: '请选择状态', trigger: 'change' }]
};

watch(
  () => visible.value,
  value => {
    if (!value) return;
    if (props.quoter) {
      Object.assign(formModel, {
        moduleName: props.quoter.moduleName,
        subModuleName: props.quoter.subModuleName,
        description: props.quoter.description,
        unitPrice: props.quoter.unitPrice,
        status: props.quoter.status
      });
    } else {
      Object.assign(formModel, defaultForm());
    }
    formRef.value?.clearValidate();
  }
);

async function handleConfirm() {
  if (!formRef.value || submitting.value) return;
  try {
    await formRef.value.validate();
  } catch {
    return;
  }
  submitting.value = true;
  try {
    emit('submitted', {
      moduleName: formModel.moduleName.trim(),
      subModuleName: formModel.subModuleName.trim(),
      description: formModel.description.trim(),
      unitPrice: formModel.unitPrice,
      status: formModel.status
    });
    visible.value = false;
  } finally {
    submitting.value = false;
  }
}
</script>

<template>
  <ElDialog
    v-model="visible"
    :title="title"
    width="560px"
    :close-on-click-modal="false"
    :destroy-on-close="true"
  >
    <ElForm ref="formRef" :model="formModel" :rules="rules" label-width="110px" class="quoter-form">
      <ElFormItem label="模块名称" prop="moduleName" required>
        <ElInput
          v-model="formModel.moduleName"
          placeholder="一级模块 / 功能组，如：财务云"
          maxlength="50"
          show-word-limit
          clearable
          size="default"
        />
      </ElFormItem>

      <ElFormItem label="子模块名称" prop="subModuleName" required>
        <ElInput
          v-model="formModel.subModuleName"
          placeholder="二级功能，如：总账初始化"
          maxlength="50"
          show-word-limit
          clearable
          size="default"
        />
      </ElFormItem>

      <ElFormItem label="功能说明" prop="description" required>
        <ElInput
          v-model="formModel.description"
          type="textarea"
          placeholder="请输入功能说明"
          :rows="4"
          maxlength="300"
          show-word-limit
          :autosize="{ minRows: 3, maxRows: 6 }"
          size="default"
        />
      </ElFormItem>

      <ElFormItem label="单价（元）">
        <ElInputNumber
          v-model="formModel.unitPrice"
          :min="0"
          :precision="2"
          :step="100"
          placeholder="可选，按模块报价"
          controls-position="right"
          class="w-full"
          size="default"
        />
      </ElFormItem>

      <ElFormItem label="状态" prop="status" required>
        <ElRadioGroup v-model="formModel.status" size="default">
          <ElRadioButton :label="1">启用</ElRadioButton>
          <ElRadioButton :label="0">禁用</ElRadioButton>
        </ElRadioGroup>
      </ElFormItem>
    </ElForm>

    <template #footer>
      <div class="dialog-footer">
        <ElButton @click="visible = false">{{ $t('common.cancel') }}</ElButton>
        <ElButton type="primary" :loading="submitting" @click="handleConfirm">{{ $t('common.confirm') }}</ElButton>
      </div>
    </template>
  </ElDialog>
</template>
