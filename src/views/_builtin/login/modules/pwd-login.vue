<script setup lang="ts">
import { computed, ref } from 'vue';
import { loginModuleRecord } from '@/constants/app';
import { useAuthStore } from '@/store/modules/auth';
import { useRouterPush } from '@/hooks/common/router';
import { useForm, useFormRules } from '@/hooks/common/form';
import { $t } from '@/locales';
import { localStg } from '@/utils/storage';

defineOptions({ name: 'PwdLogin' });

const authStore = useAuthStore();
const { toggleLoginModule } = useRouterPush();
const { formRef, validate } = useForm();

interface FormModel {
  userName: string;
  password: string;
}

function loadRememberedForm(): FormModel {
  if (localStg.get('rememberMe') !== 'Y') {
    return { userName: '', password: '' };
  }

  return {
    userName: localStg.get('loginAccount') || '',
    password: localStg.get('loginPassword') || ''
  };
}

const rememberMe = ref(localStg.get('rememberMe') === 'Y');
const model = ref<FormModel>(loadRememberedForm());

function persistRememberMe() {
  if (rememberMe.value) {
    localStg.set('rememberMe', 'Y');
    localStg.set('loginAccount', model.value.userName.trim());
    localStg.set('loginPassword', model.value.password);
    return;
  }

  localStg.remove('rememberMe');
  localStg.remove('loginAccount');
  localStg.remove('loginPassword');
}

const rules = computed<Record<keyof FormModel, App.Global.FormRule[]>>(() => {
  // inside computed to make locale ref, if not apply i18n, you can define it without computed
  const { formRules } = useFormRules();

  return {
    userName: formRules.userName,
    password: formRules.pwd
  };
});

async function handleSubmit() {
  await validate();
  await authStore.login(model.value.userName, model.value.password);

  if (authStore.isLogin) {
    persistRememberMe();
  }
}

type AccountKey = 'super' | 'admin' | 'user';

interface Account {
  key: AccountKey;
  label: string;
  userName: string;
  password: string;
}

const accounts = computed<Account[]>(() => [
  {
    key: 'super',
    label: $t('page.login.pwdLogin.superAdmin'),
    userName: 'Super',
    password: '123456'
  },
  {
    key: 'admin',
    label: $t('page.login.pwdLogin.admin'),
    userName: 'Admin',
    password: '123456'
  },
  {
    key: 'user',
    label: $t('page.login.pwdLogin.user'),
    userName: 'User',
    password: '123456'
  }
]);

async function handleAccountLogin(account: Account) {
  await authStore.login(account.userName, account.password);
}
</script>

<template>
  <ElForm ref="formRef" :model="model" :rules="rules" size="large" :show-label="false" @keyup.enter="handleSubmit">
    <ElFormItem prop="userName">
      <ElInput v-model="model.userName" :placeholder="$t('page.login.common.userNamePlaceholder')" />
    </ElFormItem>
    <ElFormItem prop="password">
      <ElInput
        v-model="model.password"
        type="password"
        show-password-on="click"
        :placeholder="$t('page.login.common.passwordPlaceholder')"
      />
    </ElFormItem>
    <ElSpace direction="vertical" :size="24" class="w-full" fill>
      <div class="flex-y-center justify-between">
        <ElCheckbox v-model="rememberMe">{{ $t('page.login.pwdLogin.rememberMe') }}</ElCheckbox>
        <ElButton text @click="toggleLoginModule('reset-pwd')">

        </ElButton>
      </div>
      <ElButton type="primary" size="large" round block :loading="authStore.loginLoading" @click="handleSubmit">
        {{ $t('common.confirm') }}
      </ElButton>
      <!-- <div class="flex-y-center justify-between gap-12px">
        <ElButton class="flex-1" size="default" @click="toggleLoginModule('code-login')">
          {{ $t(loginModuleRecord['code-login']) }}
        </ElButton>
        <ElButton class="flex-1" size="default" @click="toggleLoginModule('register')">
          {{ $t(loginModuleRecord.register) }}
        </ElButton>
      </div> -->
      <ElDivider class="text-14px text-#666 !m-0" style="display: none;">{{ $t('page.login.pwdLogin.otherAccountLogin') }}</ElDivider>
      <div class="flex-center gap-12px" style="display: none;">
        <ElButton
          v-for="item in accounts"
          :key="item.key"
          size="default"
          type="primary"
          :disabled="authStore.loginLoading"
          @click="handleAccountLogin(item)"
        >
          {{ item.label }}
        </ElButton>
      </div>
    </ElSpace>
  </ElForm>
</template>

<style scoped></style>
