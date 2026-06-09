<script setup lang="ts">
import { reactive, ref, watch } from 'vue';
import type { FormInstance, FormRules } from 'element-plus';
type ProductCategory = Api.Basedata.ProductCategory;
type ProductRecord = Api.Basedata.ProductRecord;

interface ProductForm {
  category: ProductCategory;
  name: string;
  version: string;
  description: string;
  status: 0 | 1;
}

interface Props {
  title?: string;
  product?: ProductRecord | null;
}

const props = withDefaults(defineProps<Props>(), {
  title: '新增产品',
  product: null
});

const visible = defineModel<boolean>('visible', { default: false });

const emit = defineEmits<{
  submitted: [payload: Omit<ProductRecord, 'id'>];
}>();

const formRef = ref<FormInstance>();
const submitting = ref(false);

const defaultForm = (): ProductForm => ({
  category: 'main',
  name: '',
  version: '',
  description: '',
  status: 1
});

const formModel = reactive<ProductForm>(defaultForm());

const rules: FormRules<ProductForm> = {
  category: [{ required: true, message: '请选择产品类别', trigger: 'change' }],
  name: [{ required: true, message: '请输入产品名称', trigger: 'blur' }],
  version: [{ required: true, message: '请输入产品版本', trigger: 'blur' }],
  status: [{ required: true, message: '请选择状态', trigger: 'change' }]
};

watch(
  () => visible.value,
  value => {
    if (!value) return;
    if (props.product) {
      Object.assign(formModel, {
        category: props.product.category,
        name: props.product.name,
        version: props.product.version,
        description: props.product.description ?? '',
        status: props.product.status
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
      category: formModel.category,
      name: formModel.name.trim(),
      version: formModel.version.trim(),
      description: formModel.description.trim(),
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
    width="520px"
    :close-on-click-modal="false"
    :destroy-on-close="true"
  >
    <ElForm ref="formRef" :model="formModel" :rules="rules" label-width="100px" class="product-form">
      <ElFormItem label="产品类别" prop="category" required>
        <ElSelect v-model="formModel.category" placeholder="请选择产品类别" style="width: 100%" clearable size="default">
          <ElOption label="主产品" value="main" />
          <ElOption label="第三方产品" value="third" />
        </ElSelect>
      </ElFormItem>

      <ElFormItem label="产品名称" prop="name" required>
        <ElInput
          v-model="formModel.name"
          placeholder="例如：金蝶云·星空 / KIS"
          maxlength="50"
          show-word-limit
          clearable
          size="default"
        />
      </ElFormItem>

      <ElFormItem label="产品版本" prop="version" required>
        <ElInput
          v-model="formModel.version"
          placeholder="例如：旗舰版、生鲜版"
          maxlength="30"
          show-word-limit
          clearable
          size="default"
        />
      </ElFormItem>

      <ElFormItem label="描述">
        <ElInput
          v-model="formModel.description"
          type="textarea"
          placeholder="请输入产品描述"
          :rows="4"
          maxlength="200"
          show-word-limit
          :autosize="{ minRows: 3, maxRows: 6 }"
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
