<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';
import {
  addSysUser,
  deleteSysUser,
  getRolesList,
  getSysUserPage,
  resetUserPassword,
  updateSysUser
} from '@/service/api';
import ResetPasswordDialog from './modules/reset-password-dialog.vue';

// 类型定义
interface UserFormData {
  id: number;
  account: string;
  name: string;
  passWord: string;
  userRolesId: number[];
  status: number;
  avatar?: string;
  tel: string;
  email: string;
  remark?: string;
  isSuperAdmin: boolean;
}

// 响应式数据
// 加载状态
const loading = ref(false);
const submitting = ref(false); // 新增提交加载状态，对齐role.vue

// 数据列表
const userList = ref<Api.SystemManage.UserPageList>();
const roleList = ref<Api.SystemManage.RoleList>();

// 对话框相关
const showUserDialog = ref(false);
const showResetPasswordDialog = ref(false);
const dialogTitle = ref('');
const isEdit = ref(false);

// 搜索相关
const activeNames = ref(['user-search']); // 搜索折叠面板状态
const searchParams = reactive<Api.Common.SearchParams>({
  pageNo: 1,
  pageSize: 10,
  keywords: ''
});

// 表单数据
const userForm = reactive<UserFormData>({
  id: 0,
  account: '',
  name: '',
  passWord: '',
  userRolesId: [],
  status: 1,
  tel: '',
  email: '',
  isSuperAdmin: false
});

// 重置密码相关
const currentUserId = ref<number | null>(null);
const currentUserName = ref('');

// 表单验证规则
const formRules = reactive({
  account: [
    { required: true, message: '请输入账号', trigger: ['blur', 'change'] },
    { min: 3, max: 20, message: '账号长度在 3 到 20 个字符', trigger: ['blur', 'change'] },
    { pattern: /^[a-zA-Z0-9_]+$/, message: '账号只能包含字母、数字和下划线', trigger: ['blur', 'change'] }
  ],
  name: [
    { required: true, message: '请输入姓名', trigger: ['blur', 'change'] },
    { max: 20, message: '姓名长度不超过 20 个字符', trigger: ['blur', 'change'] }
  ],
  passWord: [
    { required: true, message: '请输入密码', trigger: ['blur', 'change'] },
    { min: 6, max: 20, message: '密码长度在 6 到 20 个字符', trigger: ['blur', 'change'] }
  ],
  userRolesId: [{ required: true, message: '请至少选择一个角色', trigger: 'change' }],
  tel: [{ pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号码', trigger: ['blur', 'change'] }],
  email: [{ pattern: /^[^\s@]+@[^\s@]+\.[^\s@]+$/, message: '请输入正确的邮箱地址', trigger: ['blur', 'change'] }]
});

// 计算属性
// 用户状态相关
const userStatusType = computed(() => (status: number) => (status === 1 ? 'success' : 'danger'));
const userStatusText = computed(() => (status: number) => (status === 1 ? '启用' : '禁用'));

// 超级管理员相关
const superAdminType = computed(() => (isSuper: boolean) => (isSuper ? 'warning' : 'info'));
const superAdminText = computed(() => (isSuper: boolean) => (isSuper ? '是' : '否'));

// 获取角色名称
const getRoleNameById = (roleId: number) => {
  const role = roleList.value?.find(r => r.id === roleId);
  return role ? role.name : '未分配角色';
};

// 重置用户表单（提取公共方法，对齐role.vue）
const resetUserForm = () => {
  Object.assign(userForm, {
    id: 0,
    account: '',
    name: '',
    passWord: '',
    userRolesId: [],
    status: 1,
    tel: '',
    email: '',
    isSuperAdmin: false
  });
};

// 获取用户列表
const fetchUserList = async () => {
  if (loading.value) return; // 防止重复请求
  loading.value = true;
  try {
    const response = await getSysUserPage(searchParams);
    userList.value = response;
  } catch (error) {
    console.error('获取用户列表失败:', error);
    ElMessage.error('获取用户列表失败');
  } finally {
    loading.value = false;
  }
};

// 获取角色列表
const fetchRoleList = async () => {
  if (roleList.value?.length) return; // 防止重复请求
  try {
    const response = await getRolesList();
    if (response) {
      roleList.value = response;
    } else {
      throw new Error('获取角色列表接口返回异常');
    }
  } catch (error) {
    console.error('获取角色列表失败:', error);
    ElMessage.error('获取角色列表失败');
  }
};

// 搜索功能（对齐role.vue）
const search = () => {
  searchParams.pageNo = 1;
  fetchUserList();
};

// 重置搜索（对齐role.vue）
const resetSearch = () => {
  searchParams.keywords = '';
  searchParams.pageNo = 1;
  fetchUserList();
};

// 处理页面大小变化（对齐role.vue）
const handleSizeChange = (val: number) => {
  searchParams.pageSize = val;
  searchParams.pageNo = 1; // 改变每页数量时回到第一页
  fetchUserList();
};

// 处理当前页变化（对齐role.vue）
const handleCurrentChange = (val: number) => {
  searchParams.pageNo = val;
  fetchUserList();
};

// 显示新增用户对话框（对齐role.vue）
const addUser = () => {
  resetUserForm();
  dialogTitle.value = '新增用户';
  isEdit.value = false;
  showUserDialog.value = true;
};

// 显示编辑用户对话框（对齐role.vue）
const editUser = (row: Api.SystemManage.UserInfo) => {
  Object.assign(userForm, {
    id: row.id,
    account: row.account,
    name: row.name,
    passWord: row.passWord || '',
    userRolesId: Array.isArray(row.userRolesId) ? row.userRolesId : [],
    status: row.status,
    tel: row.tel || '',
    email: row.email || '',
    isSuperAdmin: row.isSuperAdmin || false
  });
  dialogTitle.value = '编辑用户';
  isEdit.value = true;
  showUserDialog.value = true;
};

// 确认新增/更新用户（优化逻辑，增加提交加载，对齐role.vue）
const confirmUser = async () => {
  if (submitting.value) return; // 防止重复提交

  // 简单前置验证（配合表单规则双重保障）
  if (!userForm.account.trim()) {
    ElMessage.warning('请输入账号');
    return;
  }
  if (!userForm.name.trim()) {
    ElMessage.warning('请输入姓名');
    return;
  }
  if (!isEdit.value && !userForm.passWord.trim()) {
    ElMessage.warning('请输入密码');
    return;
  }
  if (!userForm.userRolesId || userForm.userRolesId.length === 0) {
    ElMessage.warning('请至少选择一个角色');
    return;
  }

  submitting.value = true;
  try {
    const apiCall = isEdit.value ? updateSysUser : addSysUser;
    const result = await apiCall(userForm);

    if (result) {
      const successMsg = isEdit.value ? '更新用户成功' : '新增用户成功';
      ElMessage.success(successMsg);
      showUserDialog.value = false;
      await fetchUserList(); // 重新获取列表
    } else {
      throw new Error(isEdit.value ? '更新用户接口返回异常' : '新增用户接口返回异常');
    }
  } catch (error: any) {
    console.error(isEdit.value ? '更新用户失败:' : '新增用户失败:', error);
    const errorMsg = error?.message || (isEdit.value ? '更新用户失败' : '新增用户失败');
    ElMessage.error(errorMsg);
  } finally {
    submitting.value = false;
  }
};

// 删除用户（优化提示文案，对齐role.vue逻辑）
const deleteUser = async (id: number, userName: string) => {
  try {
    if (!id) {
      ElMessage.warning('无效的用户ID');
      return;
    }

    await ElMessageBox.confirm(`确定要删除用户 "${userName}" 吗？此操作不可撤销`, '警告', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    });

    const result = await deleteSysUser(id);
    if (result) {
      ElMessage.success('删除成功');
      await fetchUserList(); // 重新获取列表
    } else {
      throw new Error('删除用户接口返回异常');
    }
  } catch (error: any) {
    if (error !== 'cancel') {
      // 用户取消操作时不显示错误消息
      console.error('删除用户失败:', error);
      const errorMsg = error?.message || '删除用户失败';
      ElMessage.error(errorMsg);
    }
  }
};

// 显示重置密码对话框
const showResetPassword = (row: Api.SystemManage.UserInfo) => {
  if (!row || !row.id) {
    ElMessage.warning('无效的用户数据');
    return;
  }
  currentUserId.value = row.id;
  currentUserName.value = row.name;
  showResetPasswordDialog.value = true;
};

// 重置密码确认回调
const handleResetPasswordConfirm = async (data: { userId: number; Password: string }) => {
  try {
    if (!data || !data.userId) {
      ElMessage.warning('无效的用户ID');
      return;
    }

    const result = await resetUserPassword(data);
    if (result) {
      ElMessage.success('密码重置成功');
      showResetPasswordDialog.value = false;
    } else {
      throw new Error('重置密码接口返回异常');
    }
  } catch (error: any) {
    console.error('重置密码失败:', error);
    const errorMsg = error?.message || '重置密码失败';
    ElMessage.error(errorMsg);
  }
};

// 初始化数据（对齐role.vue，使用Promise.all优化并行请求）
onMounted(async () => {
  await Promise.all([fetchUserList(), fetchRoleList()]);
});
</script>

<template>
  <div class="min-h-500px flex-col-stretch gap-16px overflow-hidden lt-sm:overflow-auto">
    <ElSpace style="display: flex;flex-direction:column;align-items: stretch;" :size="16" class="page-container">
      <!-- 搜索区域（完全对齐role.vue的折叠面板+卡片布局） -->
      <ElCard class="card-wrapper">
        <ElCollapse v-model="activeNames">
          <ElCollapseItem title="搜索" name="user-search" class="search-collapse-item">
            <ElForm :model="searchParams" label-position="right" :label-width="80">
              <ElRow :gutter="24" class="w-full">
                <ElCol :lg="6" :md="8" :sm="12">
                  <ElFormItem label="关键字" prop="keywords">
                    <ElInput v-model="searchParams.keywords" placeholder="请输入账号或姓名" clearable />
                  </ElFormItem>
                </ElCol>
              </ElRow>
              <ElRow :gutter="24" class="w-full">
                <ElCol :lg="24" :md="24" :sm="24" class="search-button-col">
                  <ElSpace class="w-full justify-end" alignment="end">
                    <ElButton @click="resetSearch">
                      <template #icon>
                        <icon-ic-round-refresh class="text-icon" />
                      </template>
                      {{ $t('common.reset') }}
                    </ElButton>
                    <ElButton type="primary" plain @click="search">
                      <template #icon>
                        <icon-ic-round-search class="text-icon" />
                      </template>
                      {{ $t('common.search') }}
                    </ElButton>
                  </ElSpace>
                </ElCol>
              </ElRow>
            </ElForm>
          </ElCollapseItem>
        </ElCollapse>
      </ElCard>

      <!-- 用户列表（对齐role.vue的卡片+表格布局） -->
      <ElCard header="用户列表" class="card-wrapper sm:flex-1-hidden" body-class="ht50" style="margin-top: 12px;">
        <template #header>
          <div class="flex items-center justify-between">
            <p>用户管理</p>
            <TableHeaderOperation @add="addUser" @refresh="fetchRoleList" />
          </div>
        </template>

        <ElTable
          v-loading="loading"
          height="100%"
          border
          class="sm:h-full"
          :data="userList?.records"
          row-key="id"
          stripe
          highlight-current-row
        >
          <ElTableColumn prop="id" label="ID" width="80" align="center" fixed="left" />
          <ElTableColumn prop="account" label="账号" min-width="120" show-overflow-tooltip sortable />
          <ElTableColumn prop="name" label="姓名" min-width="100" show-overflow-tooltip sortable />
          <ElTableColumn prop="userRolesId" label="角色" min-width="180" show-overflow-tooltip>
            <template #default="{ row }">
              <div class="role-tags flex flex-wrap gap-4px">
                <ElTag v-for="roleId in row.userRolesId" :key="roleId" size="small">
                  {{ getRoleNameById(roleId) }}
                </ElTag>
              </div>
            </template>
          </ElTableColumn>
          <ElTableColumn prop="status" label="状态" width="100" align="center">
            <template #default="{ row }">
              <ElTag :type="userStatusType(row.status)" size="small" round>
                {{ userStatusText(row.status) }}
              </ElTag>
            </template>
          </ElTableColumn>
          <ElTableColumn prop="isSuperAdmin" label="超级管理员" width="120" align="center">
            <template #default="{ row }">
              <ElTag :type="superAdminType(row.isSuperAdmin)" size="small" round>
                {{ superAdminText(row.isSuperAdmin) }}
              </ElTag>
            </template>
          </ElTableColumn>
          <ElTableColumn
            prop="sysCreateTime"
            label="创建时间"
            min-width="160"
            align="center"
            show-overflow-tooltip
            sortable
          />
          <ElTableColumn label="操作" width="300" fixed="right" align="center">
            <template #default="{ row }">
              <div class="operation-buttons">
                <ElButton size="small" type="primary" :disabled="row.isSuperAdmin" @click="editUser(row)">
                  <i class="el-icon-edit"></i>
                  编辑
                </ElButton>
                <ElButton size="small" type="warning" :disabled="row.isSuperAdmin" @click="showResetPassword(row)">
                  <i class="el-icon-refresh-left"></i>
                  重置密码
                </ElButton>
                <ElButton size="small" type="danger" :disabled="row.isSuperAdmin" @click="deleteUser(row.id, row.name)">
                  <i class="el-icon-delete"></i>
                  删除
                </ElButton>
              </div>
            </template>
          </ElTableColumn>
        </ElTable>

        <!-- 分页组件（对齐role.vue的布局和绑定方式） -->
      </ElCard>

      <div class="h-[calc(100%-50px)]" style="margin-top: 12px;">
        <div class="mt-20px flex justify-end">
          <ElPagination
            v-model:current-page="searchParams.pageNo"
            v-model:page-size="searchParams.pageSize"
            :page-sizes="[10, 20, 30, 50, 100]"
            :total="userList?.totalRows"
            :disabled="loading"
            layout="total, sizes, prev, pager, next, jumper"
            @current-change="handleCurrentChange"
            @size-change="handleSizeChange"
          />
        </div>
      </div>

      <!-- 新增/编辑用户对话框（对齐role.vue的对话框配置） -->
      <ElDialog
        v-model="showUserDialog"
        :title="dialogTitle"
        width="520px"
        :close-on-click-modal="false"
        :destroy-on-close="true"
        @closed="resetUserForm"
      >
        <ElForm :model="userForm" :rules="formRules" label-width="100px" class="user-form">
          <ElFormItem label="账号" prop="account">
            <ElInput
              v-model="userForm.account"
              placeholder="请输入账号"
              maxlength="20"
              show-word-limit
              clearable
              size="default"
            />
          </ElFormItem>
          <ElFormItem label="姓名" prop="name">
            <ElInput
              v-model="userForm.name"
              placeholder="请输入姓名"
              maxlength="20"
              show-word-limit
              clearable
              size="default"
            />
          </ElFormItem>
          <ElFormItem v-if="!isEdit" label="密码" prop="passWord">
            <ElInput
              v-model="userForm.passWord"
              type="password"
              placeholder="请输入密码（6-20位）"
              maxlength="20"
              show-password
              clearable
              size="default"
            />
          </ElFormItem>
          <ElFormItem label="角色" prop="userRolesId">
            <ElSelect
              v-model="userForm.userRolesId"
              multiple
              filterable
              placeholder="请选择角色（可多选）"
              style="width: 100%"
              clearable
              size="default"
            >
              <ElOption v-for="role in roleList" :key="role.id" :label="role.name" :value="role.id" />
            </ElSelect>
          </ElFormItem>
          <ElFormItem label="电话" prop="tel">
            <ElInput v-model="userForm.tel" placeholder="请输入电话" clearable size="default" />
          </ElFormItem>
          <ElFormItem label="邮箱" prop="email">
            <ElInput v-model="userForm.email" placeholder="请输入邮箱" clearable size="default" />
          </ElFormItem>
          <ElFormItem label="状态" prop="status">
            <ElRadioGroup v-model="userForm.status" size="default">
              <ElRadioButton :label="1">启用</ElRadioButton>
              <ElRadioButton :label="2">禁用</ElRadioButton>
            </ElRadioGroup>
          </ElFormItem>
          <ElFormItem label="超级管理员" prop="isSuperAdmin">
            <ElRadioGroup v-model="userForm.isSuperAdmin" size="default">
              <ElRadioButton :label="true">是</ElRadioButton>
              <ElRadioButton :label="false">否</ElRadioButton>
            </ElRadioGroup>
          </ElFormItem>
        </ElForm>
        <template #footer>
          <div class="dialog-footer">
            <ElButton @click="showUserDialog = false">取消</ElButton>
            <ElButton type="primary" :loading="submitting" @click="confirmUser">
              <i v-if="!submitting" :class="isEdit ? 'el-icon-refresh-right' : 'el-icon-check'"></i>
              {{ isEdit ? '更新' : '确定' }}
            </ElButton>
          </div>
        </template>
      </ElDialog>
    </ElSpace>

    <!-- 重置密码对话框组件 -->
    <ResetPasswordDialog
      v-model="showResetPasswordDialog"
      :user-id="currentUserId ?? undefined"
      :user-name="currentUserName"
      @confirm="handleResetPasswordConfirm"
      @close="() => {}"
    />
  </div>
</template>

<style lang="scss" scoped>
:deep(.el-card) {
  .ht50 {
    height: calc(100% - 50px);
  }
}
</style>
