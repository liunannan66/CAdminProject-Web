<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';
import { QUOTER_AUTH } from '@/constants/basedata-quoter';
import { useAuth } from '@/hooks/business/auth';
import { useAuthStore } from '@/store/modules/auth';
import {
  addQuoter,
  deleteQuoter,
  getQuoterModuleNames,
  getQuoterPage,
  updateQuoter
} from '@/service/api/basedata';
import QuoterOperateDialog from './modules/quoter-operate-dialog.vue';

defineOptions({ name: 'BasedataQuoter' });

type QuoterRecord = Api.Basedata.QuoterRecord;

interface SearchParams {
  pageNo: number;
  pageSize: number;
  keyword: string;
  moduleName: string;
  status: 0 | 1 | '';
}

const { hasAuth } = useAuth();
const authStore = useAuthStore();

function checkQuoterAuth(code: string) {
  const configured = authStore.userInfo.buttons.some(item => item.startsWith('api:Quoter:'));
  if (!configured) return true;
  return hasAuth(code);
}

const canAdd = computed(() => checkQuoterAuth(QUOTER_AUTH.add));
const canUpdate = computed(() => checkQuoterAuth(QUOTER_AUTH.update));
const canDelete = computed(() => checkQuoterAuth(QUOTER_AUTH.delete));

const loading = ref(false);
const quoterList = ref<Api.Common.PaginatingQueryRecord<QuoterRecord>>();
const moduleOptions = ref<string[]>([]);

const searchParams = reactive<SearchParams>({
  pageNo: 1,
  pageSize: 10,
  keyword: '',
  moduleName: '',
  status: ''
});

const showDialog = ref(false);
const dialogTitle = ref('新增报价项');
const editingQuoter = ref<QuoterRecord | null>(null);

const statusTagType = computed(() => (status: 0 | 1) => (status === 1 ? 'success' : 'danger'));
const statusText = computed(() => (status: 0 | 1) => (status === 1 ? '启用' : '禁用'));

const formatPrice = (price: number | null) => {
  if (price === null || price === undefined) return '-';
  return price.toLocaleString('zh-CN', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
};

const tableData = computed(() => quoterList.value?.records ?? []);
const totalRows = computed(() => quoterList.value?.totalRows ?? 0);

async function fetchModuleOptions() {
  try {
    moduleOptions.value = await getQuoterModuleNames();
  } catch {
    moduleOptions.value = [];
  }
}

async function fetchQuoterList() {
  if (loading.value) return;
  loading.value = true;
  try {
    const response = await getQuoterPage({
      pageNo: searchParams.pageNo,
      pageSize: searchParams.pageSize,
      keyWord: searchParams.keyword.trim() || undefined,
      moduleName: searchParams.moduleName || undefined,
      status: searchParams.status === '' ? undefined : searchParams.status
    });
    quoterList.value = response;
  } catch {
    ElMessage.error('获取报价器列表失败');
  } finally {
    loading.value = false;
  }
}

function resetSearch() {
  searchParams.keyword = '';
  searchParams.moduleName = '';
  searchParams.status = '';
  searchParams.pageNo = 1;
  fetchQuoterList();
}

function search() {
  searchParams.pageNo = 1;
  fetchQuoterList();
}

function handleSizeChange(val: number) {
  searchParams.pageSize = val;
  searchParams.pageNo = 1;
  fetchQuoterList();
}

function handleCurrentChange(val: number) {
  searchParams.pageNo = val;
  fetchQuoterList();
}

function openAddDialog() {
  if (!canAdd.value) {
    ElMessage.warning('暂无新增权限');
    return;
  }
  dialogTitle.value = '新增报价项';
  editingQuoter.value = null;
  showDialog.value = true;
}

function openEditDialog(row: QuoterRecord) {
  if (!canUpdate.value) {
    ElMessage.warning('暂无编辑权限');
    return;
  }
  dialogTitle.value = '编辑报价项';
  editingQuoter.value = { ...row };
  showDialog.value = true;
}

async function deleteRecord(row: QuoterRecord) {
  if (!canDelete.value) {
    ElMessage.warning('暂无删除权限');
    return;
  }
  try {
    await ElMessageBox.confirm(`确定删除报价项「${row.moduleName} / ${row.subModuleName}」吗？`, '警告', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    });
    await deleteQuoter(row.id);
    ElMessage.success('删除成功');
    await fetchQuoterList();
    await fetchModuleOptions();
  } catch {
    // 用户取消或接口失败
  }
}

async function handleSubmitted(form: Omit<QuoterRecord, 'id'>) {
  try {
    if (editingQuoter.value) {
      await updateQuoter({
        ...editingQuoter.value,
        ...form
      });
      ElMessage.success('更新成功');
    } else {
      await addQuoter(form);
      ElMessage.success('新增成功');
    }
    await fetchQuoterList();
    await fetchModuleOptions();
  } catch {
    // request 层已提示
  }
}

onMounted(async () => {
  await fetchModuleOptions();
  await fetchQuoterList();
});
</script>

<template>
  <div class="min-h-500px flex-col-stretch gap-16px overflow-auto lt-sm:overflow-auto">
    <ElSpace style="display: flex; flex-direction: column; align-items: stretch" :size="16" class="page-container">
      <ElCard class="card-wrapper">
        <ElCollapse>
          <ElCollapseItem title="搜索" name="quoter-search">
            <ElForm :model="searchParams" label-position="right" :label-width="80">
              <ElRow :gutter="24">
                <ElCol :lg="6" :md="8" :sm="12">
                  <ElFormItem label="关键字" prop="keyword">
                    <ElInput
                      v-model="searchParams.keyword"
                      placeholder="模块 / 子模块 / 功能说明"
                      clearable
                    />
                  </ElFormItem>
                </ElCol>
                <ElCol :lg="6" :md="8" :sm="12">
                  <ElFormItem label="模块名称" prop="moduleName">
                    <ElSelect v-model="searchParams.moduleName" placeholder="全部模块" clearable class="w-full">
                      <ElOption v-for="name in moduleOptions" :key="name" :label="name" :value="name" />
                    </ElSelect>
                  </ElFormItem>
                </ElCol>
                <ElCol :lg="6" :md="8" :sm="12">
                  <ElFormItem label="状态" prop="status">
                    <ElSelect v-model="searchParams.status" placeholder="全部状态" clearable class="w-full">
                      <ElOption label="启用" :value="1" />
                      <ElOption label="禁用" :value="0" />
                    </ElSelect>
                  </ElFormItem>
                </ElCol>
                <ElCol :lg="6" :md="24" :sm="24">
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

      <ElCard class="card-wrapper sm:flex-1-hidden" style="margin-top: 12px">
        <template #header>
          <div class="flex items-center justify-between">
            <p>报价器</p>
            <ElSpace>
              <ElButton v-if="canAdd" type="primary" @click="openAddDialog">
                <template #icon>
                  <icon-ic-round-plus class="text-icon" />
                </template>
                {{ $t('common.add') }}
              </ElButton>
              <ElButton type="primary" @click="fetchQuoterList">
                <template #icon>
                  <icon-ic-round-refresh class="text-icon" />
                </template>
                {{ $t('common.refresh') }}
              </ElButton>
            </ElSpace>
          </div>
        </template>

        <ElTable v-loading="loading" border class="sm:h-full" :data="tableData" row-key="id">
          <ElTableColumn prop="id" label="ID" width="70" align="center" fixed />
          <ElTableColumn prop="moduleName" label="模块名称" width="110" show-overflow-tooltip>
            <template #default="{ row }">
              <ElTag size="small" round>{{ row.moduleName }}</ElTag>
            </template>
          </ElTableColumn>
          <ElTableColumn prop="subModuleName" label="子模块名称" width="130" show-overflow-tooltip />
          <ElTableColumn prop="description" label="功能说明" min-width="200" show-overflow-tooltip />
          <ElTableColumn prop="unitPrice" label="单价（元）" width="110" align="center">
            <template #default="{ row }">
              <span :class="{ 'text-secondary': row.unitPrice === null }">{{ formatPrice(row.unitPrice) }}</span>
            </template>
          </ElTableColumn>
          <ElTableColumn prop="status" label="状态" width="90" align="center">
            <template #default="{ row }">
              <ElTag :type="statusTagType(row.status)" size="small" round>
                {{ statusText(row.status) }}
              </ElTag>
            </template>
          </ElTableColumn>
          <ElTableColumn label="操作" width="150" fixed="right" align="center">
            <template #default="{ row }">
              <ElButton v-if="canUpdate" size="small" type="primary" @click="openEditDialog(row)">编辑</ElButton>
              <ElButton v-if="canDelete" size="small" type="danger" @click="deleteRecord(row)">删除</ElButton>
            </template>
          </ElTableColumn>
        </ElTable>
      </ElCard>

      <div class="flex justify-end" style="margin-top: 12px">
        <ElPagination
          v-model:current-page="searchParams.pageNo"
          v-model:page-size="searchParams.pageSize"
          :page-sizes="[10, 20, 30, 50, 100]"
          :total="totalRows"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
        />
      </div>
    </ElSpace>

    <QuoterOperateDialog
      v-model:visible="showDialog"
      :title="dialogTitle"
      :quoter="editingQuoter"
      @submitted="handleSubmitted"
    />
  </div>
</template>

<style lang="scss" scoped>
:deep(.el-card) {
  .ht50 {
    height: calc(100% - 50px);
  }
}

.text-secondary {
  color: var(--el-text-color-secondary);
}
</style>
