<script setup lang="ts">
import { computed, ref, shallowRef, watch } from 'vue';
import { ElMessage } from 'element-plus';
import { addUserButtonPermiss, getRoleButen, getSysRoleAllPermission } from '@/service/api';
import type { ResRolePermission } from '@/typings/response/ResRolePermission';

defineOptions({
  name: 'ButtonAuthModal'
});

interface Props {
  /** the roleId */
  currentrole: Api.SystemManage.RoleInfo;
}

const props = defineProps<Props>();

const visible = defineModel<boolean>('visible', {
  default: false
});

const emit = defineEmits<{
  (e: 'confirm'): void;
}>();

function closeModal() {
  visible.value = false;
}

const title = computed(() => '编辑按钮权限');

const tree = shallowRef<ResRolePermission[]>([]);
const checks = shallowRef<string[]>([]);

// 加载状态
const loading = ref(false);
const submitLoading = ref(false);

async function getAllButtons() {
  try {
    loading.value = true;
    const res = await getSysRoleAllPermission();
    // 转换数据结构，确保ElTree能够正确显示
    tree.value = res.map(item => ({
      ...item,
      id: item.permissionId,
      label: item.permissionName
    }));
    console.log('所有按钮权限:', tree.value);
  } catch (error) {
    console.error('获取所有按钮权限失败:', error);
    ElMessage.error('请求失败');
  } finally {
    loading.value = false;
  }
}

async function getuseButtons() {
  try {
    loading.value = true;
    const res = await getRoleButen({ RoleId: props.currentrole.id });
    checks.value = res !== null ? res.map(x => x.userPermiss) : [];
  } catch (error) {
    console.error('获取角色按钮权限失败:', error);
    ElMessage.error('请求失败');
  } finally {
    loading.value = false;
  }
}

async function handleSubmit() {
  try {
    submitLoading.value = true;
    const res = await addUserButtonPermiss({ roleId: props.currentrole.id, permissionId: checks.value });
    if (res) {
      ElMessage.success('修改成功');
      emit('confirm');
      closeModal();
    }
  } catch (error) {
    console.error('设置角色按钮权限失败:', error);
    ElMessage.error('请求失败');
  } finally {
    submitLoading.value = false;
  }
}

async function init() {
  await Promise.all([getAllButtons(), getuseButtons()]);
}

// 是否全选
const checkallactive = ref<boolean>(false);
const checkallactivehandle = (value: boolean) => {
  checkallactive.value = value;
  if (value) {
    checks.value = tree.value?.map(item => item.id) || [];
  } else {
    checks.value = [];
  }
};

watch(visible, val => {
  if (val) {
    init();
  }
});
</script>

<template>
  <ElDialog v-model="visible" :title="title" preset="card" class="w-480px">
    <div class="flex items-center gap-16px pb-12px">
      <div>全选/全不选</div>
      <ElSwitch v-model="checkallactive" @change="checkallactivehandle" />
    </div>
    <ElTree
      v-model:checked-keys="checks"
      :data="tree"
      node-key="id"
      show-checkbox
      class="h-280px overflow-y-auto"
      :default-checked-keys="checks"
      :loading="loading"
    >
      <template #default="{ node }">
        {{ node.label }}
      </template>
    </ElTree>
    <template #footer>
      <ElSpace class="w-full justify-end">
        <ElButton size="small" class="mt-16px" :disabled="submitLoading" @click="closeModal">取消</ElButton>
        <ElButton type="primary" size="small" class="mt-16px" :loading="submitLoading" @click="handleSubmit">
          确定
        </ElButton>
      </ElSpace>
    </template>
  </ElDialog>
</template>

<style scoped></style>
