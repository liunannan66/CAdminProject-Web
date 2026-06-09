<script setup lang="tsx">
import { computed, onMounted, reactive, ref } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';
import { views } from '@/router/elegant/imports';
import { deleteMenu, getMenuAllTreeList } from '@/service/api';
import SvgIcon from '@/components/custom/svg-icon.vue';
import type { OperateType } from './modules/menu-operate-modal.vue';
import MenuOperateModal from './modules/menu-operate-modal.vue';
import { getMenuSvgIconProps, normalizeMenuIconType } from './modules/shared';

interface MenuFormData {
  id: number;
  menuName: string;
  i18nKey: string;
  menuType: Api.SystemManage.MenuType;
  icon: string;
  iconType: '1' | '2';
  routeName: string;
  routePath: string;
  status: Api.Common.EnableStatus;
  hideInMenu: boolean;
  parentId: number;
  order: number;
}

// 响应式数据 - 页面核心数据
const menuList = ref<Api.SystemManage.MenuPage>();
const loading = ref(false);
const showMenuDialog = ref(false);
const dialogTitle = ref('');
const isEdit = ref(false);
const allPages = ref<string[]>([]);

// 响应式数据 - 操作相关
const operateType = ref<OperateType>('add');
const editingData = ref<Api.SystemManage.Menu | null>(null);

// 响应式数据 - 菜单表单数据
const menuForm = reactive<MenuFormData>({
  id: 0,
  menuName: '',
  i18nKey: '',
  menuType: '1',
  icon: '',
  iconType: '1',
  routeName: '',
  routePath: '',
  status: '1' as Api.Common.EnableStatus,
  hideInMenu: false,
  parentId: 0,
  order: 0
});

// 重置菜单表单数据
const resetMenuForm = () => {
  menuForm.id = 0;
  menuForm.menuName = '';
  menuForm.i18nKey = '';
  menuForm.menuType = '1';
  menuForm.icon = '';
  menuForm.iconType = '1';
  menuForm.routeName = '';
  menuForm.routePath = '';
  menuForm.status = '1' as Api.Common.EnableStatus;
  menuForm.hideInMenu = false;
  menuForm.parentId = 0;
  menuForm.order = 0;
};

// 计算属性 - 菜单类型标签类型（对齐角色页面计算属性风格）
const menuTypeTagType = computed(() => (type: Api.SystemManage.MenuType) => {
  const tagMap: Record<string, string> = {
    '1': 'info',
    '2': 'primary'
  };
  return tagMap[type] || 'default';
});

// 计算属性 - 菜单状态标签类型
const menuStatusTagType = computed(() => (status: Api.Common.EnableStatus) => {
  const tagMap: Record<string, string> = {
    '1': 'success',
    '2': 'warning'
  };
  return tagMap[status] || 'default';
});

// 计算属性 - 隐藏菜单标签类型
const hideInMenuTagType = computed(() => (hide: boolean) => {
  const tagMap: Record<string, string> = {
    true: 'danger',
    false: 'info'
  };
  return tagMap[String(hide)];
});

// 计算属性 - 菜单类型文本
const menuTypeText = computed(() => (type: Api.SystemManage.MenuType) => {
  const textMap: Record<string, string> = {
    '1': '目录',
    '2': '菜单'
  };
  return textMap[type] || '';
});

// 计算属性 - 菜单状态文本
const menuStatusText = computed(() => (status: Api.Common.EnableStatus) => {
  const textMap: Record<string, string> = {
    '1': '启用',
    '2': '禁用'
  };
  return textMap[status] || '';
});

// 计算属性 - 隐藏菜单文本
const hideInMenuText = computed(() => (hide: boolean) => {
  const yesOrNo: CommonType.YesOrNo = hide ? 'Y' : 'N';
  const textMap: Record<CommonType.YesOrNo, string> = {
    Y: '是',
    N: '否'
  };
  return textMap[yesOrNo];
});

// 显示新增菜单对话框（对齐角色页面addRole）
const addMenuAction = () => {
  resetMenuForm();
  dialogTitle.value = '新增菜单';
  isEdit.value = false;
  operateType.value = 'add';
  editingData.value = null;
  showMenuDialog.value = true;
};

// 显示新增子菜单对话框
const addChildMenu = (row: Api.SystemManage.Menu) => {
  resetMenuForm();
  dialogTitle.value = '新增子菜单';
  isEdit.value = false;
  operateType.value = 'addChild';
  editingData.value = { ...row };
  menuForm.parentId = row.id || 0;
  showMenuDialog.value = true;
};

// 显示编辑菜单对话框（对齐角色页面editRole）
const editMenu = (row: Api.SystemManage.Menu) => {
  resetMenuForm();
  Object.assign(menuForm, {
    id: row.id || 0,
    menuName: row.menuName || '',
    i18nKey: row.i18nKey || '',
    menuType: row.menuType || '1',
    icon: row.icon || '',
    iconType: normalizeMenuIconType(row.iconType),
    routeName: row.routeName || '',
    routePath: row.routePath || '',
    status: row.status || 1,
    hideInMenu: row.hideInMenu || false,
    parentId: row.parentId || 0,
    order: row.order || 0
  });
  editingData.value = { ...row };
  dialogTitle.value = '编辑菜单';
  isEdit.value = true;
  operateType.value = 'edit';
  showMenuDialog.value = true;
};

/** 从菜单树收集路由名称（供「页面」下拉使用，须为 routeName 而非 routePath） */
function collectMenuRouteNames(menus: Api.SystemManage.Menu[] | undefined, names = new Set<string>()) {
  menus?.forEach(menu => {
    if (menu.routeName) names.add(menu.routeName);
    if (menu.children?.length) collectMenuRouteNames(menu.children, names);
  });
  return names;
}

/** 统计树形菜单总条数（含子级） */
function countMenuNodes(menus: Api.SystemManage.Menu[] | undefined): number {
  if (!menus?.length) return 0;
  return menus.reduce((sum, menu) => sum + 1 + countMenuNodes(menu.children ?? []), 0);
}

// 获取菜单列表（对齐角色页面fetchRoleList，完整的加载/异常处理）
const fetchMenuList = async () => {
  loading.value = true;
  try {
    // 此处可扩展支持搜索参数，保持与角色页面接口调用风格一致
    const response = await getMenuAllTreeList();
    menuList.value = response;
    const fromMenus = collectMenuRouteNames(response?.records);
    const fromCatalog = Object.keys(views);
    allPages.value = [...new Set([...fromMenus, ...fromCatalog])];
  } catch (error) {
    console.error('获取菜单列表失败:', error);
    ElMessage.error('获取菜单列表失败');
  } finally {
    loading.value = false;
  }
};

// 删除菜单（对齐角色页面deleteRole，包含确认弹窗）
const deleteMenuAction = async (id: number, menuName: string) => {
  try {
    await ElMessageBox.confirm(`确定删除菜单 "${menuName}" 吗？`, '警告', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    });

    await deleteMenu({ id });
    ElMessage.success('菜单删除成功');
    await fetchMenuList(); // 重新获取列表
  } catch (error) {
    if (error !== 'cancel') {
      // 用户取消操作时不显示错误消息
      console.error('删除菜单失败:', error);
      ElMessage.error('删除菜单失败 ');
    }
  }
};

// 初始化数据（对齐角色页面onMounted）
onMounted(() => {
  fetchMenuList();
});
</script>

<template>
  <div class="page-container">
    <!-- 菜单列表 -->
    <ElCard class="card-wrapper">
      <template #header>
        <div class="flex items-center justify-between">
          <p>菜单管理</p>
          <ElButton type="primary" plain @click="addMenuAction">
            <i class="el-icon-plus"></i>
            新增
          </ElButton>
        </div>
      </template>

      <ElTable
        v-loading="loading"
        border
        :data="menuList?.records"
        row-key="id"
        default-expand-all
        :tree-props="{ children: 'children' }"
      >
        <ElTableColumn prop="id" label="ID" width="90" align="center" fixed="left" />
        <ElTableColumn prop="menuType" label="菜单类型" width="90" align="center">
          <template #default="{ row }">
            <ElTag v-if="row.menuType" :type="menuTypeTagType(row.menuType)" size="small" round>
              {{ menuTypeText(row.menuType) }}
            </ElTag>
          </template>
        </ElTableColumn>
        <ElTableColumn prop="menuName" label="菜单名称" min-width="120" show-overflow-tooltip />
        <ElTableColumn prop="icon" label="图标" width="100" align="center">
          <template #default="{ row }">
            <div class="flex-center">
              <SvgIcon v-bind="getMenuSvgIconProps(row)" class="text-icon" />
            </div>
          </template>
        </ElTableColumn>
        <ElTableColumn prop="routeName" label="路由名称" min-width="120" show-overflow-tooltip />
        <ElTableColumn prop="routePath" label="路由路径" min-width="120" show-overflow-tooltip />
        <ElTableColumn prop="status" label="菜单状态" width="80" align="center">
          <template #default="{ row }">
            <ElTag v-if="row.status" :type="menuStatusTagType(row.status)" size="small" round>
              {{ menuStatusText(row.status) }}
            </ElTag>
          </template>
        </ElTableColumn>
        <ElTableColumn prop="hideInMenu" label="隐藏菜单" width="80" align="center">
          <template #default="{ row }">
            <ElTag v-if="row.hideInMenu !== undefined" :type="hideInMenuTagType(row.hideInMenu)" size="small" round>
              {{ hideInMenuText(row.hideInMenu) }}
            </ElTag>
          </template>
        </ElTableColumn>
        <ElTableColumn prop="parentId" label="父级ID" width="90" align="center" />
        <ElTableColumn prop="order" label="排序" width="60" align="center" />
        <ElTableColumn label="操作" width="270" fixed="right" align="center">
          <template #default="{ row }">
            <div class="flex-center justify-end pr-10px">
              <ElButton v-if="row.menuType == '1'" type="primary" plain size="small" @click="addChildMenu(row)">
                新增子菜单
              </ElButton>
              <ElButton type="primary" plain size="small" @click="editMenu(row)">编辑</ElButton>
              <ElButton type="danger" plain size="small" @click="deleteMenuAction(row.id, row.menuName)">删除</ElButton>
            </div>
          </template>
        </ElTableColumn>
      </ElTable>
    </ElCard>

    <!-- 分页信息 -->
    <div class="mt-20px flex justify-end">共 {{ countMenuNodes(menuList?.records) || menuList?.totalRows || 0 }} 条</div>

    <!-- 菜单操作模态框 -->
    <MenuOperateModal
      v-model:visible="showMenuDialog"
      :operate-type="operateType"
      :row-data="editingData"
      :all-pages="allPages"
      @submitted="fetchMenuList"
    />
  </div>
</template>

<style lang="scss" scoped></style>
