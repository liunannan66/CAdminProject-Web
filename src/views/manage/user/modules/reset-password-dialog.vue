<script setup lang="ts">
import { nextTick, reactive, ref, watch } from 'vue';
import { ElForm, ElMessage } from 'element-plus';

defineOptions({
  name: 'ResetPasswordDialog'
});

// 定义props和emit
interface Props {
  modelValue: boolean;
  userId?: number;
  userName?: string;
}

interface Emits {
  (e: 'update:modelValue', value: boolean): void;
  (e: 'confirm', data: { userId: number; Password: string }): void;
  (e: 'close'): void;
}

const props = withDefaults(defineProps<Props>(), {
  modelValue: false,
  userId: 0,
  userName: ''
});

const emit = defineEmits<Emits>();

// 响应式数据
const showDialog = ref(props.modelValue);
const submitting = ref(false);
const passwordFormRef = ref<InstanceType<typeof ElForm>>();

// 密码表单数据
const passwordForm = reactive({
  newPassword: '',
  confirmPassword: ''
});

// 密码验证规则
const passwordRules = reactive({
  newPassword: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { min: 6, max: 20, message: '密码长度在 6 到 20 个字符', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请再次输入密码', trigger: 'blur' },
    {
      validator: (_rule: any, value: string, callback: (msg?: string) => void) => {
        if (value !== passwordForm.newPassword) {
          callback('两次输入的密码不一致');
        } else {
          callback();
        }
      },
      trigger: 'blur'
    }
  ]
});

// 监听props变化
watch(
  () => props.modelValue,
  newValue => {
    showDialog.value = newValue;
    if (newValue) {
      // 打开对话框时清空表单
      console.log('打开重置密码对话框', props);
    }
  }
);

// 重置表单
const resetForm = () => {
  passwordForm.newPassword = '';
  passwordForm.confirmPassword = '';
  nextTick(() => {
    if (passwordFormRef.value) {
      passwordFormRef.value.clearValidate();
    }
  });
};

// 确认重置密码
const confirmResetPassword = async () => {
  if (passwordFormRef.value) {
    // 验证表单
    const valid = await passwordFormRef.value.validate().catch(() => false);
    if (!valid) return;

    if (!props.userId) {
      ElMessage.error('用户ID不能为空');
      return;
    }

    submitting.value = true;
    try {
      emit('confirm', {
        userId: props.userId,
        Password: passwordForm.newPassword
      });
    } catch (error) {
      console.error('重置密码失败:', error);
    } finally {
      submitting.value = false;
    }
  }
};

// 关闭对话框
const closeDialog = () => {
  emit('update:modelValue', false);
  emit('close');
};

// 对话框关闭后的处理
const handleClosed = () => {
  resetForm();
};
</script>

<template>
  <ElDialog
    v-model="showDialog"
    title="重置密码"
    width="500px"
    :close-on-click-modal="false"
    :destroy-on-close="true"
    @closed="handleClosed"
  >
    <ElForm ref="passwordFormRef" :model="passwordForm" :rules="passwordRules" label-width="100px">
      <ElFormItem label="新密码" prop="newPassword">
        <ElInput
          v-model="passwordForm.newPassword"
          type="password"
          placeholder="请输入新密码"
          show-password
          maxlength="20"
          show-word-limit
        />
      </ElFormItem>
      <ElFormItem label="确认密码" prop="confirmPassword">
        <ElInput
          v-model="passwordForm.confirmPassword"
          type="password"
          placeholder="请再次输入新密码"
          show-password
          maxlength="20"
          show-word-limit
        />
      </ElFormItem>
      <ElAlert title="注意：重置后用户需使用新密码登录" type="warning" :closable="false" show-icon />
    </ElForm>
    <template #footer>
      <div class="dialog-footer">
        <ElButton @click="closeDialog">取消</ElButton>
        <ElButton type="primary" :loading="submitting" @click="confirmResetPassword">
          <i v-if="!submitting" class="el-icon-refresh-left"></i>
          确定重置
        </ElButton>
      </div>
    </template>
  </ElDialog>
</template>

<style scoped>
.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 16px;
}
</style>
