<script setup lang="ts">
import { computed, nextTick, ref, shallowRef, watch } from 'vue';
import { ElTree } from 'element-plus';
import { getMenuTreeList, getRoleUserMenu, setRoleUserMenu } from '@/service/api';
import { $t } from '@/locales';

defineOptions({
  name: 'MenuPermissionDialog'
});

interface Props {
  currentrole: Api.SystemManage.RoleInfo;
}

const props = defineProps<Props>();

const visible = defineModel<boolean>('visible', {
  default: false
});

const treeRef = ref();

function closeModal() {
  visible.value = false;
}

const title = computed(() => `编辑【${props.currentrole.name}】的菜单权限`);

const tree = shallowRef<Api.SystemManage.Menu[]>([]);

async function getTree() {
  await getMenuTreeList().then(res => {
    if (res?.records) {
      tree.value = res.records;
    }
  });
}

const checks = shallowRef<number[]>([]);

async function getChecks() {
  await getRoleUserMenu({ roleId: props.currentrole.id }).then(res => {
    if (res) {
      checks.value = res;
    }
  });
  console.log('当前用户的菜单权限：', checks.value);
}

function handleSubmit() {
  setRoleUserMenu({ roleId: props.currentrole.id, menuId: checks.value }).then(res => {
    if (res) {
      window.$message?.success?.($t('common.modifySuccess'));
      closeModal();
    }
  });
}

const cascadeactive = ref<boolean>(true);
const expandallactive = ref<boolean>(false);
const checkallactive = ref<boolean>(false);

// 处理展开/折叠切换
function handleExpandToggle(expanded: boolean) {
  if (treeRef.value) {
    // 使用 Element Plus 的 API 展开或收起所有节点
    const nodes = getTreeNodes(tree.value);
    nodes.forEach((nodeId: number) => {
      if (treeRef.value) {
        treeRef.value.store.nodesMap[nodeId].expanded = expanded;
      }
    });
  }
}

// 获取所有节点ID
function getTreeNodes(nodes: Api.SystemManage.Menu[], result: number[] = []): number[] {
  nodes.forEach(node => {
    result.push(node.id);
    if (node.children && node.children.length > 0) {
      getTreeNodes(node.children, result);
    }
  });
  return result;
}

// 处理全选/全不选
async function handleCheckAllChange(checked: boolean) {
  await nextTick();
  if (checked) {
    // 全选：根据父子联动设置选择所有节点或仅叶子节点
    if (cascadeactive.value) {
      // 如果父子联动开启，则选择所有节点
      const allKeys = getTreeNodes(tree.value);
      checks.value = allKeys;
      treeRef.value?.setCheckedKeys(allKeys);
    } else {
      // 如果父子联动关闭，则只选择叶子节点
      const leafKeys = getAllLeafKeys(tree.value);
      checks.value = leafKeys;
      treeRef.value?.setCheckedKeys(leafKeys);
    }
  } else {
    // 全不选
    checks.value = [];
    treeRef.value?.setCheckedKeys([]);
  }
}

// 处理父子联动切换
async function handleCascadeChange(cascade: boolean) {
  await nextTick();
  // 切换父子联动时，需要重新设置选中状态
  if (!cascade) {
    // 关闭父子联动时，只保留叶子节点的选中状态
    const checkedKeys = treeRef.value?.getCheckedKeys() || [];
    const halfCheckedKeys = treeRef.value?.getHalfCheckedKeys() || [];
    const allCheckedKeys = [...checkedKeys, ...halfCheckedKeys];

    // 只保留叶子节点的选中状态
    const leafKeys = getAllLeafKeys(tree.value).filter(key => allCheckedKeys.includes(key));
    checks.value = leafKeys;
    treeRef.value?.setCheckedKeys(leafKeys);
  } else {
    // 开启父子联动时，保持当前选中状态
    checks.value = treeRef.value?.getCheckedKeys(true) || [];
  }
}

// 获取所有叶子节点的key
function getAllLeafKeys(nodes: Api.SystemManage.Menu[]): number[] {
  const keys: number[] = [];

  function traverse(nodeList: Api.SystemManage.Menu[]) {
    nodeList.forEach(node => {
      if (node.children && node.children.length > 0) {
        traverse(node.children);
      } else {
        keys.push(node.id);
      }
    });
  }

  traverse(nodes);
  return keys;
}

function init() {
  getTree();
  getChecks();
}

watch(
  visible,
  val => {
    if (val) {
      init();
    }
  },
  { immediate: true }
);

// 监听树数据变化，重新设置选中状态
watch(
  tree,
  async newTree => {
    if (newTree.length > 0) {
      await nextTick();
      // 确保树组件已经渲染完成后再设置选中状态
      treeRef.value?.setCheckedKeys(checks.value);
    }
  },
  { deep: true }
);

// 监听选中状态变化，更新本地状态
watch(
  () => treeRef.value?.getCheckedKeys(),
  newKeys => {
    if (newKeys) {
      checks.value = newKeys;
    }
  },
  { deep: true }
);
</script>

<template>
  <ElDialog v-model="visible" :title="title" width="480px" class="menu-permission-dialog">
    <div class="flex-y-center gap-16px pb-12px">
      <div>展开/折叠</div>
      <ElSwitch v-model="expandallactive" @change="handleExpandToggle" />

      <div>全选/全不选</div>
      <ElSwitch v-model="checkallactive" @change="handleCheckAllChange" />

      <div>父子连动</div>
      <ElSwitch v-model="cascadeactive" @change="handleCascadeChange" />
    </div>

    <!-- 添加外层容器处理滚动 -->
    <div class="tree-container">
      <ElTree
        ref="treeRef"
        :default-checked-keys="checks"
        :data="tree"
        :props="{ children: 'children', label: 'menuName' }"
        node-key="id"
        show-checkbox
        :default-expand-all="expandallactive"
        :check-strictly="!cascadeactive"
        class="tree-with-scrollbar"
      />
    </div>

    <template #footer>
      <div class="dialog-footer">
        <ElButton @click="closeModal">取消</ElButton>
        <ElButton type="primary" @click="handleSubmit">提交</ElButton>
      </div>
    </template>
  </ElDialog>
</template>

<style scoped>
.flex-y-center {
  display: flex;
  align-items: center;
}

.gap-16px {
  gap: 16px;
}

.pb-12px {
  padding-bottom: 12px;
}

.tree-container {
  height: 280px;
  overflow-y: auto; /* 添加垂直滚动条 */
  border: 1px solid #dcdfe6;
  border-radius: 4px;
  padding: 8px;
}

.tree-with-scrollbar {
  max-height: none; /* 移除固定高度，让容器控制高度 */
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}

.menu-permission-dialog :deep(.el-dialog__body) {
  padding: 12px;
}
</style>
