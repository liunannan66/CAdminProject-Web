<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';
import { addSysRole, delSysRole, getSysRolePage, updateSysRole } from '@/service/api';
import ButtonAuthModal from './modules/button-auth-modal.vue';
import MenuPermissionDialog from './modules/menu-permission-dialog.vue';

// 类型定义
interface RoleFormData {
  id: number;
  name: string;
  desc: string;
  status: number;
}

interface SearchParams {
  pageNo: number;
  pageSize: number;
  keyword: string;
}

// 响应式数据
const roleList = ref<Api.SystemManage.RolePageList>();
const loading = ref(false);
const showRoleDialog = ref(false);
const dialogTitle = ref('');
const isEdit = ref(false);
const submitting = ref(false);

// 搜索参数
const searchParams = reactive<SearchParams>({
  pageNo: 1,
  pageSize: 10,
  keyword: ''
});

// 角色表单数据
const roleForm = reactive<RoleFormData>({
  id: 0,
  name: '',
  desc: '',
  status: 1
});

// 表单验证规则
const formRules = reactive({
  name: [
    { required: true, message: '请输入角色名称', trigger: 'blur' },
    { min: 1, max: 50, message: '长度在 1 到 50 个字符', trigger: 'blur' }
  ],
  desc: [{ max: 200, message: '长度不能超过 200 个字符', trigger: 'blur' }]
});

// 计算属性 - 角色状态标签类型
const roleStatusType = computed(() => (status: number) => (status === 1 ? 'success' : 'danger'));

// 计算属性 - 角色状态文本
const roleStatusText = computed(() => (status: number) => (status === 1 ? '启用' : '禁用'));

// 重置表单
const resetRoleForm = () => {
  Object.assign(roleForm, {
    id: 0,
    name: '',
    desc: '',
    status: 1
  });
};

// 显示新增角色对话框
const addRole = () => {
  resetRoleForm();
  dialogTitle.value = '新增角色';
  isEdit.value = false;
  showRoleDialog.value = true;
};

// 显示编辑角色对话框
const editRole = (row: Api.SystemManage.RoleInfo) => {
  Object.assign(roleForm, {
    id: row.id,
    name: row.name,
    desc: row.desc,
    status: row.status
  });
  dialogTitle.value = '编辑角色';
  isEdit.value = true;
  showRoleDialog.value = true;
};

// 弹窗相关响应式数据
const dialogShow = ref(false); // 控制弹窗显隐
const currentEditRole = ref({}); // 当前编辑的角色数据
const buttondialogShow = ref(false); // 当前按钮权限开关

// 显示角色权限设置对话框
const editRoleMenu = (row: Api.SystemManage.RoleInfo) => {
  Object.assign(roleForm, {
    id: row.id,
    name: row.name,
    desc: row.desc,
    status: row.status
  });
  // 赋值当前编辑的角色（深拷贝，避免直接修改原数据）
  currentEditRole.value = JSON.parse(JSON.stringify(row));
  // 打开弹窗
  dialogShow.value = true;
};

// 2. 监听弹窗的确认事件：处理权限提交逻辑（如接口请求）
const handlePermissionConfirm = async (submitData: { roleId: number; menuIds: number[] }) => {
  console.log('提交的角色权限数据：', submitData);
  // 此处可编写接口请求逻辑，将submitData（roleId + menuIds）提交到后端
  // 示例：await api.updateRolePermission(submitData)
  // alert(`角色${submitData.roleId}的菜单权限已提交，共选择${submitData.menuIds.length}个菜单`);
};

// 3. 监听弹窗的关闭事件：重置相关状态
const handleDialogClose = () => {
  dialogShow.value = false;
  buttondialogShow.value = false;
  currentEditRole.value = {};
};

const editRoleButton = (row: Api.SystemManage.RoleInfo) => {
  Object.assign(roleForm, {
    id: row.id,
    name: row.name,
    desc: row.desc,
    status: row.status
  });
  // 赋值当前编辑的角色（深拷贝，避免直接修改原数据）
  currentEditRole.value = JSON.parse(JSON.stringify(row));
  // 打开弹窗
  buttondialogShow.value = true;
};

// 获取角色列表
const fetchRoleList = async () => {
  loading.value = true;
  try {
    const response = await getSysRolePage(searchParams);
    roleList.value = response;
  } catch (error) {
    console.error('获取角色列表失败:', error);
    ElMessage.error('获取角色列表失败');
  } finally {
    loading.value = false;
  }
};

// 确认新增/更新角色
const confirmRole = async () => {
  if (!roleForm.name.trim()) {
    ElMessage.warning('请输入角色名称');
    return;
  }

  submitting.value = true;
  try {
    const apiCall = isEdit.value ? updateSysRole : addSysRole;
    const result = await apiCall(roleForm);

    if (result) {
      const successMsg = isEdit.value ? '更新角色成功' : '新增角色成功';
      ElMessage.success(successMsg);
      showRoleDialog.value = false;
      await fetchRoleList(); // 重新获取列表
    } else {
      throw new Error(isEdit.value ? '更新角色接口返回异常' : '新增角色接口返回异常');
    }
  } catch (error) {
    console.error(isEdit.value ? '更新角色失败:' : '新增角色失败:', error);
    ElMessage.error(isEdit.value ? '更新角色失败' : '新增角色失败');
  } finally {
    submitting.value = false;
  }
};

// 删除角色
const deleteRole = async (id: number, roleName: string) => {
  try {
    await ElMessageBox.confirm(`确定要删除角色 "${roleName}" 吗？此操作不可撤销`, '警告', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    });

    const result = await delSysRole(id);
    if (result) {
      ElMessage.success('删除成功');
      await fetchRoleList(); // 重新获取列表
    } else {
      throw new Error('删除角色接口返回异常');
    }
  } catch (error) {
    if (error !== 'cancel') {
      // 用户取消操作时不显示错误消息
      console.error('删除角色失败:', error);
      ElMessage.error('删除角色失败');
    }
  }
};

// 搜索功能
const search = () => {
  searchParams.pageNo = 1;
  fetchRoleList();
};

// 重置搜索
const resetSearch = () => {
  searchParams.keyword = '';
  searchParams.pageNo = 1;
  fetchRoleList();
};

// 监听页码变化
const handleCurrentChange = (val: number) => {
  searchParams.pageNo = val;
  fetchRoleList();
};

// 监听页面大小变化
const handleSizeChange = (val: number) => {
  searchParams.pageSize = val;
  searchParams.pageNo = 1; // 改变每页数量时回到第一页
  fetchRoleList();
};

// 初始化数据
onMounted(() => {
  fetchRoleList();
});
</script>

<template>
  <div class="min-h-500px flex-col-stretch gap-16px overflow-hidden lt-sm:overflow-auto">
    <ElSpace direction="vertical" fill :size="16" class="page-container">
      <!-- 搜索区域 -->
      <ElCard class="card-wrapper">
        <ElCollapse>
          <ElCollapseItem title="搜索" name="role-search">
            <ElForm :model="searchParams" label-position="right" :label-width="80">
              <ElRow :gutter="24">
                <ElCol :lg="6" :md="8" :sm="12">
                  <ElFormItem label="关键字" prop="roleName">
                    <ElInput v-model="searchParams.keyword" :placeholder="$t('page.manage.role.form.roleName')" clearable />
                  </ElFormItem>
                </ElCol>

                <ElCol :lg="6" :md="24" :sm="24">
                  <ElSpace class="w-full justify-end" alignment="end">
                    <ElButton @click="resetSearch">
                      <template #icon>
                        <icon-ic-round-refresh class="text-icon" />
                        重置
                      </template>
                    </ElButton>
                    <ElButton type="primary" plain @click="search">
                      <template #icon>
                        <icon-ic-round-search class="text-icon" />
                      </template>
                      搜索
                    </ElButton>
                  </ElSpace>
                </ElCol>
              </ElRow>
            </ElForm>
          </ElCollapseItem>
        </ElCollapse>
      </ElCard>

      <!-- 角色列表 -->
      <ElCard header="角色列表" class="card-wrapper sm:flex-1-hidden" body-class="ht50">
        <template #header>
          <div class="flex items-center justify-between">
            <p>{{ $t('page.manage.role.title') }}</p>
            <TableHeaderOperation @add="addRole" @refresh="fetchRoleList" />
          </div>
        </template>

        <ElTable v-loading="loading" height="100%" border class="sm:h-full" :data="roleList?.records" row-key="id">
          <ElTableColumn prop="id" label="ID" width="50" align="center" fixed="left" />
          <ElTableColumn prop="name" label="角色名称" min-width="80" show-overflow-tooltip />
          <ElTableColumn prop="desc" label="描述" min-width="150" show-overflow-tooltip />
          <ElTableColumn prop="status" label="状态" min-width="50" align="center">
            <template #default="{ row }">
              <ElTag :type="roleStatusType(row.status)" size="small" round>
                {{ roleStatusText(row.status) }}
              </ElTag>
            </template>
          </ElTableColumn>
          <ElTableColumn label="操作" width="300" fixed="right" align="center">
            <template #default="{ row }">
              <div class="operation-buttons">
                <ElButton size="small" type="primary" @click="editRoleMenu(row)">
                  <i class="el-icon-edit"></i>
                  菜单
                </ElButton>
                <ElButton size="small" type="primary" @click="editRoleButton(row)">
                  <i class="el-icon-edit"></i>
                  按钮
                </ElButton>
                <ElButton size="small" type="primary" @click="editRole(row)">
                  <i class="el-icon-edit"></i>
                  编辑
                </ElButton>
                <ElButton size="small" type="danger" @click="deleteRole(row.id, row.name)">
                  <i class="el-icon-delete"></i>
                  删除
                </ElButton>
              </div>
            </template>
          </ElTableColumn>
        </ElTable>
      </ElCard>
      <div class="h-[calc(100%-50px)]">
        <div class="mt-20px flex justify-end">
          <ElPagination
            v-model:current-page="searchParams.pageNo"
            v-model:page-size="searchParams.pageSize"
            :page-sizes="[10, 20, 30, 50, 100]"
            :total="roleList?.totalRows"
            :disabled="loading"
            @current-change="handleCurrentChange"
            @size-change="handleSizeChange"
          />
        </div>
      </div>
      <!-- 新增/编辑角色对话框 -->
      <ElDialog
        v-model="showRoleDialog"
        :title="dialogTitle"
        width="520px"
        :close-on-click-modal="false"
        :destroy-on-close="true"
        @closed="resetRoleForm"
      >
        <ElForm :model="roleForm" :rules="formRules" label-width="100px" class="role-form">
          <ElFormItem label="角色名称" prop="name">
            <ElInput
              v-model="roleForm.name"
              placeholder="请输入角色名称"
              maxlength="50"
              show-word-limit
              clearable
              size="default"
            />
          </ElFormItem>
          <ElFormItem label="描述" prop="desc">
            <ElInput
              v-model="roleForm.desc"
              type="textarea"
              placeholder="请输入角色描述"
              :rows="4"
              maxlength="200"
              show-word-limit
              :autosize="{ minRows: 3, maxRows: 6 }"
              size="default"
            />
          </ElFormItem>
          <ElFormItem label="状态" prop="status">
            <ElRadioGroup v-model="roleForm.status" size="default">
              <ElRadioButton :label="1">启用</ElRadioButton>
              <ElRadioButton :label="2">禁用</ElRadioButton>
            </ElRadioGroup>
          </ElFormItem>
        </ElForm>
        <template #footer>
          <div class="dialog-footer">
            <ElButton @click="showRoleDialog = false">取消</ElButton>
            <ElButton type="primary" :loading="submitting" @click="confirmRole">
              <i v-if="!submitting" :class="isEdit ? 'el-icon-refresh-right' : 'el-icon-check'"></i>
              {{ isEdit ? '更新' : '确定' }}
            </ElButton>
          </div>
        </template>
      </ElDialog>

      <!-- 引入封装好的菜单权限弹窗组件 -->
      <MenuPermissionDialog
        :visible="dialogShow"
        :currentrole="currentEditRole"
        @confirm="handlePermissionConfirm"
        @close="handleDialogClose"
      />

      <!-- 引入封装好的按钮权限弹窗组件 -->

      <ButtonAuthModal
        :visible="buttondialogShow"
        :currentrole="currentEditRole"
        @confirm="handlePermissionConfirm"
        @close="handleDialogClose"
      />
    </ElSpace>
  </div>
</template>

<style lang="scss" scoped>
:deep(.el-card) {
  .ht50 {
    height: calc(100% - 50px);
  }
}
</style>
