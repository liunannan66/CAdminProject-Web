<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';
import {
  PAYMENT_TERM_AUTH,
  PAYMENT_TERM_SETTLEMENT_OPTIONS,
  SETTLEMENT_METHOD_LABEL,
  type PaymentSettlementMethod
} from '@/constants/basedata-payment-term';
import { useAuth } from '@/hooks/business/auth';
import { useAuthStore } from '@/store/modules/auth';
import {
  addPaymentTerm,
  deletePaymentTerm,
  getPaymentTermPage,
  updatePaymentTerm
} from '@/service/api/basedata';
import PaymentTermOperateDialog, {
  type PaymentTermRecord
} from './modules/payment-term-operate-dialog.vue';

defineOptions({ name: 'BasedataPaymentTerm' });

interface SearchParams {
  pageNo: number;
  pageSize: number;
  keyword: string;
  settlementMethod: PaymentSettlementMethod | '';
  status: 0 | 1 | '';
}

const { hasAuth } = useAuth();
const authStore = useAuthStore();

function checkPaymentAuth(code: string) {
  const configured = authStore.userInfo.buttons.some(item => item.startsWith('api:PaymentTerm:'));
  if (!configured) return true;
  return hasAuth(code);
}

const canAdd = computed(() => checkPaymentAuth(PAYMENT_TERM_AUTH.add));
const canUpdate = computed(() => checkPaymentAuth(PAYMENT_TERM_AUTH.update));
const canDelete = computed(() => checkPaymentAuth(PAYMENT_TERM_AUTH.delete));

const loading = ref(false);
const paymentTermList = ref<Api.Common.PaginatingQueryRecord<PaymentTermRecord>>();

const searchParams = reactive<SearchParams>({
  pageNo: 1,
  pageSize: 10,
  keyword: '',
  settlementMethod: '',
  status: ''
});

const showDialog = ref(false);
const dialogTitle = ref('新增付款条件');
const editingRecord = ref<PaymentTermRecord | null>(null);

const statusTagType = computed(() => (status: 0 | 1) => (status === 1 ? 'success' : 'danger'));
const statusText = computed(() => (status: 0 | 1) => (status === 1 ? '启用' : '禁用'));

const tableData = computed(() => paymentTermList.value?.records ?? []);
const totalRows = computed(() => paymentTermList.value?.totalRows ?? 0);

async function fetchPaymentTermList() {
  if (loading.value) return;
  loading.value = true;
  try {
    const response = await getPaymentTermPage({
      pageNo: searchParams.pageNo,
      pageSize: searchParams.pageSize,
      keyWord: searchParams.keyword.trim() || undefined,
      settlementMethod: searchParams.settlementMethod || undefined,
      status: searchParams.status === '' ? undefined : searchParams.status
    });
    paymentTermList.value = response;
  } catch {
    ElMessage.error('获取付款条件列表失败');
  } finally {
    loading.value = false;
  }
}

function resetSearch() {
  searchParams.keyword = '';
  searchParams.settlementMethod = '';
  searchParams.status = '';
  searchParams.pageNo = 1;
  fetchPaymentTermList();
}

function search() {
  searchParams.pageNo = 1;
  fetchPaymentTermList();
}

function handleSizeChange(val: number) {
  searchParams.pageSize = val;
  searchParams.pageNo = 1;
  fetchPaymentTermList();
}

function handleCurrentChange(val: number) {
  searchParams.pageNo = val;
  fetchPaymentTermList();
}

function openAddDialog() {
  if (!canAdd.value) {
    ElMessage.warning('暂无新增权限');
    return;
  }
  dialogTitle.value = '新增付款条件';
  editingRecord.value = null;
  showDialog.value = true;
}

function openEditDialog(row: PaymentTermRecord) {
  if (!canUpdate.value) {
    ElMessage.warning('暂无编辑权限');
    return;
  }
  dialogTitle.value = '编辑付款条件';
  editingRecord.value = { ...row };
  showDialog.value = true;
}

async function deleteRecord(row: PaymentTermRecord) {
  if (!canDelete.value) {
    ElMessage.warning('暂无删除权限');
    return;
  }
  try {
    await ElMessageBox.confirm(`确定删除付款条件「${row.name}」吗？`, '警告', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    });
    await deletePaymentTerm(row.id);
    ElMessage.success('删除成功');
    await fetchPaymentTermList();
  } catch {
    // 用户取消或接口失败
  }
}

async function handleSubmitted(form: {
  name: string;
  settlementMethod: PaymentSettlementMethod | '';
  paymentRatio: number | undefined;
  node: string;
  remark: string;
  status: 0 | 1;
}) {
  const payload = {
    name: form.name.trim(),
    settlementMethod: form.settlementMethod as PaymentSettlementMethod,
    paymentRatio: form.paymentRatio ?? 0,
    node: form.node.trim(),
    remark: form.remark.trim(),
    status: form.status
  };
  try {
    if (editingRecord.value) {
      await updatePaymentTerm({
        ...editingRecord.value,
        ...payload
      });
      ElMessage.success('更新成功');
    } else {
      await addPaymentTerm(payload);
      ElMessage.success('新增成功');
    }
    await fetchPaymentTermList();
  } catch {
    // request 层已提示
  }
}

onMounted(() => {
  fetchPaymentTermList();
});
</script>

<template>
  <div class="min-h-500px flex-col-stretch gap-16px overflow-hidden lt-sm:overflow-auto">
    <ElSpace style="display: flex; flex-direction: column; align-items: stretch" :size="16" class="page-container">
      <ElCard class="card-wrapper">
        <ElCollapse>
          <ElCollapseItem title="搜索" name="payment-term-search">
            <ElForm :model="searchParams" label-position="right" :label-width="80">
              <ElRow :gutter="24">
                <ElCol :lg="6" :md="8" :sm="12">
                  <ElFormItem label="关键字" prop="keyword">
                    <ElInput v-model="searchParams.keyword" placeholder="名称 / 节点 / 备注" clearable />
                  </ElFormItem>
                </ElCol>
                <ElCol :lg="6" :md="8" :sm="12">
                  <ElFormItem label="结算方式" prop="settlementMethod">
                    <ElSelect
                      v-model="searchParams.settlementMethod"
                      placeholder="全部方式"
                      clearable
                      class="w-full"
                    >
                      <ElOption
                        v-for="item in PAYMENT_TERM_SETTLEMENT_OPTIONS"
                        :key="item.value"
                        :label="item.label"
                        :value="item.value"
                      />
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
            <p>付款条件</p>
            <ElSpace>
              <ElButton v-if="canAdd" type="primary" @click="openAddDialog">
                <template #icon>
                  <icon-ic-round-plus class="text-icon" />
                </template>
                {{ $t('common.add') }}
              </ElButton>
              <ElButton type="primary" @click="fetchPaymentTermList">
                <template #icon>
                  <icon-ic-round-refresh class="text-icon" />
                </template>
                {{ $t('common.refresh') }}
              </ElButton>
            </ElSpace>
          </div>
        </template>

        <ElTable v-loading="loading" border class="sm:h-full" :data="tableData" row-key="id" style="overflow-y: auto;">
          <ElTableColumn prop="id" label="ID" width="70" align="center" fixed />
          <ElTableColumn prop="name" label="名称" min-width="140" show-overflow-tooltip />
          <ElTableColumn prop="settlementMethod" label="结算方式" width="100" align="center">
            <template #default="{ row }">
              <ElTag size="small" round>
                {{ SETTLEMENT_METHOD_LABEL[row.settlementMethod as PaymentSettlementMethod] ?? row.settlementMethod }}
              </ElTag>
            </template>
          </ElTableColumn>
          <ElTableColumn prop="paymentRatio" label="支付比例" width="100" align="center">
            <template #default="{ row }">{{ row.paymentRatio }}%</template>
          </ElTableColumn>
          <ElTableColumn prop="node" label="节点" min-width="180" show-overflow-tooltip />
          <ElTableColumn prop="remark" label="备注" min-width="120" show-overflow-tooltip />
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

    <PaymentTermOperateDialog
      v-model:visible="showDialog"
      :title="dialogTitle"
      :payment-term="editingRecord"
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
</style>
