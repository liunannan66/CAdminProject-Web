<script setup lang="ts">
import { reactive, ref, watch } from 'vue';
import type { FormInstance, FormRules } from 'element-plus';
import {
  PAYMENT_TERM_SETTLEMENT_OPTIONS,
  type PaymentSettlementMethod
} from '@/constants/basedata-payment-term';

export interface PaymentTermRecord {
  id: number;
  name: string;
  settlementMethod: PaymentSettlementMethod;
  paymentRatio: number;
  node: string;
  remark: string;
  status: 0 | 1;
}

interface PaymentTermForm {
  name: string;
  settlementMethod: PaymentSettlementMethod | '';
  paymentRatio: number | undefined;
  node: string;
  remark: string;
  status: 0 | 1;
}

interface Props {
  title?: string;
  paymentTerm?: PaymentTermRecord | null;
}

const props = withDefaults(defineProps<Props>(), {
  title: '新增付款条件',
  paymentTerm: null
});

const visible = defineModel<boolean>('visible', { default: false });

const formRef = ref<FormInstance>();

const defaultForm = (): PaymentTermForm => ({
  name: '',
  settlementMethod: '',
  paymentRatio: undefined,
  node: '',
  remark: '',
  status: 1
});

const formModel = reactive<PaymentTermForm>(defaultForm());

const rules: FormRules<PaymentTermForm> = {
  name: [{ required: true, message: '请输入条件名称', trigger: 'blur' }],
  settlementMethod: [{ required: true, message: '请选择结算方式', trigger: 'change' }],
  paymentRatio: [
    { required: true, message: '请输入支付比例', trigger: 'blur' },
    {
      validator: (_rule, value, callback) => {
        if (value === undefined || value === null) {
          callback(new Error('请输入支付比例'));
          return;
        }
        if (value < 0 || value > 100) {
          callback(new Error('支付比例需在 0～100 之间'));
          return;
        }
        callback();
      },
      trigger: 'blur'
    }
  ],
  node: [{ required: true, message: '请输入节点说明', trigger: 'blur' }],
  status: [{ required: true, message: '请选择状态', trigger: 'change' }]
};

watch(
  () => visible.value,
  value => {
    if (!value) return;
    if (props.paymentTerm) {
      Object.assign(formModel, {
        name: props.paymentTerm.name,
        settlementMethod: props.paymentTerm.settlementMethod,
        paymentRatio: props.paymentTerm.paymentRatio,
        node: props.paymentTerm.node,
        remark: props.paymentTerm.remark,
        status: props.paymentTerm.status
      });
      return;
    }
    Object.assign(formModel, defaultForm());
    formRef.value?.clearValidate();
  }
);

interface Emits {
  (e: 'submitted', payload: PaymentTermForm): void;
}

const emit = defineEmits<Emits>();

const submitting = ref(false);

async function handleConfirm() {
  if (!formRef.value || submitting.value) return;
  try {
    await formRef.value.validate();
  } catch {
    return;
  }
  submitting.value = true;
  try {
    emit('submitted', { ...formModel });
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
    <ElForm ref="formRef" :model="formModel" :rules="rules" label-width="100px">
      <ElFormItem label="条件名称" prop="name">
        <ElInput
          v-model="formModel.name"
          placeholder="例如：合同签订预付款"
          maxlength="50"
          show-word-limit
          clearable
        />
      </ElFormItem>

      <ElFormItem label="结算方式" prop="settlementMethod">
        <ElSelect v-model="formModel.settlementMethod" placeholder="请选择结算方式" clearable class="w-full">
          <ElOption
            v-for="item in PAYMENT_TERM_SETTLEMENT_OPTIONS"
            :key="item.value"
            :label="item.label"
            :value="item.value"
          />
        </ElSelect>
      </ElFormItem>

      <ElFormItem label="支付比例" prop="paymentRatio">
        <ElInputNumber
          v-model="formModel.paymentRatio"
          :min="0"
          :max="100"
          :precision="2"
          :step="5"
          controls-position="right"
          placeholder="0～100"
          class="w-full"
        />
        <span class="ml-8px text-#909399">%</span>
      </ElFormItem>

      <ElFormItem label="节点" prop="node">
        <ElInput
          v-model="formModel.node"
          placeholder="例如：合同签订后 7 个工作日内"
          maxlength="100"
          show-word-limit
          clearable
        />
      </ElFormItem>

      <ElFormItem label="备注" prop="remark">
        <ElInput
          v-model="formModel.remark"
          type="textarea"
          placeholder="补充说明（选填）"
          :rows="3"
          maxlength="200"
          show-word-limit
          :autosize="{ minRows: 3, maxRows: 6 }"
        />
      </ElFormItem>

      <ElFormItem label="状态" prop="status">
        <ElRadioGroup v-model="formModel.status">
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
