<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue';
import { useRouter } from 'vue-router';
import { ElMessage, ElMessageBox } from 'element-plus';
import {
  CONTRACT_APPROVAL_FLOW_OPTIONS,
  CONTRACT_AUTH,
  CONTRACT_TYPE_LABEL,
  CONTRACT_TYPE_OPTIONS,
  type ContractType
} from '@/constants/contract';
import { SETTLEMENT_METHOD_LABEL, type PaymentSettlementMethod } from '@/constants/basedata-payment-term';
import { useAuth } from '@/hooks/business/auth';
import { useAuthStore } from '@/store/modules/auth';
import { deleteContract, getContractPage, initContractProject } from '@/service/api/contract';
import { mapContractDtoToRecord } from '@/utils/contract-map';
import ContractDetailDrawer from './modules/contract-detail-drawer.vue';
import ContractOperateDrawer, { type ContractRecord } from './modules/contract-operate-drawer.vue';

defineOptions({ name: 'ContractManage' });

interface SearchParams {
  pageNo: number;
  pageSize: number;
  keyword: string;
  contractType: ContractType | '';
}

const router = useRouter();
const { hasAuth } = useAuth();
const authStore = useAuthStore();

function checkContractAuth(code: string) {
  const configured = authStore.userInfo.buttons.some(item => item.startsWith('api:Contract:'));
  if (!configured) return true;
  return hasAuth(code);
}

const canAdd = computed(() => checkContractAuth(CONTRACT_AUTH.add));
const canUpdate = computed(() => checkContractAuth(CONTRACT_AUTH.update));
const canDelete = computed(() => checkContractAuth(CONTRACT_AUTH.delete));
const canProjectInit = computed(() => checkContractAuth(CONTRACT_AUTH.projectInit));

const searchParams = reactive<SearchParams>({
  pageNo: 1,
  pageSize: 10,
  keyword: '',
  contractType: ''
});

const loading = ref(false);
const contractList = ref<ContractRecord[]>([]);
const totalRows = ref(0);

const showDrawer = ref(false);
const showDetailDrawer = ref(false);
const drawerTitle = ref('新增合同');
const editingContract = ref<ContractRecord | null>(null);
const detailContract = ref<ContractRecord | null>(null);

const contractTypeTagType = computed(() => (type: ContractType) => (type === 'self' ? 'primary' : 'warning'));

const approvalFlowLabel = (flow: string) =>
  CONTRACT_APPROVAL_FLOW_OPTIONS.find(item => item.value === flow)?.label ?? '—';

const tableData = computed(() => contractList.value);

async function fetchContractList() {
  if (loading.value) return;
  loading.value = true;
  try {
    const response = await getContractPage({
      pageNo: searchParams.pageNo,
      pageSize: searchParams.pageSize,
      keyWord: searchParams.keyword.trim() || undefined,
      contractType: searchParams.contractType || undefined
    });
    contractList.value = (response?.records ?? []).map(mapContractDtoToRecord);
    totalRows.value = response?.totalRows ?? 0;
  } catch {
    ElMessage.error('获取合同列表失败');
  } finally {
    loading.value = false;
  }
}

onMounted(() => {
  fetchContractList();
});

function formatAmount(amount: number) {
  return amount.toLocaleString('zh-CN', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
}

function resetSearch() {
  searchParams.keyword = '';
  searchParams.contractType = '';
  searchParams.pageNo = 1;
  fetchContractList();
}

function search() {
  searchParams.pageNo = 1;
  fetchContractList();
}

function handleSizeChange(val: number) {
  searchParams.pageSize = val;
  searchParams.pageNo = 1;
  fetchContractList();
}

function handleCurrentChange(val: number) {
  searchParams.pageNo = val;
  fetchContractList();
}

function openAddDrawer() {
  drawerTitle.value = '新增合同';
  editingContract.value = null;
  showDrawer.value = true;
}

function openEditDrawer(row: ContractRecord) {
  drawerTitle.value = '编辑合同';
  editingContract.value = JSON.parse(JSON.stringify(row)) as ContractRecord;
  showDrawer.value = true;
}

function openDetailDrawer(row: ContractRecord) {
  detailContract.value = JSON.parse(JSON.stringify(row)) as ContractRecord;
  showDetailDrawer.value = true;
}

function onSubmitted() {
  fetchContractList();
}

async function handleDelete(row: ContractRecord) {
  if (!canDelete.value) {
    ElMessage.warning('暂无删除权限');
    return;
  }
  try {
    await ElMessageBox.confirm(`确定删除合同「${row.contractNo}」吗？`, '提示', { type: 'warning' });
    await deleteContract(row.id);
    ElMessage.success('删除成功');
    fetchContractList();
  } catch {
    /* 用户取消或请求失败 */
  }
}

async function handleProjectInit(row: ContractRecord) {
  if (!canProjectInit.value) {
    ElMessage.warning('暂无项目立项权限');
    return;
  }
  try {
    const result = await initContractProject(row.id);
    const projectId = result?.id;
    if (!projectId) {
      ElMessage.error('立项创建失败');
      return;
    }
    router.push({ name: 'contract_project-init', query: { openId: String(projectId) } });
  } catch {
    /* 请求失败已由拦截器提示 */
  }
}

function summarizePayment(row: ContractRecord) {
  return row.paymentLines
    .map(line => {
      const method =
        line.settlementMethod && SETTLEMENT_METHOD_LABEL[line.settlementMethod as PaymentSettlementMethod]
          ? SETTLEMENT_METHOD_LABEL[line.settlementMethod as PaymentSettlementMethod]
          : '—';
      return `${line.termName || '未命名'}(${method} ${line.paymentRatio ?? 0}%)`;
    })
    .join('；');
}
</script>

<template>
  <div class="min-h-500px flex-col-stretch gap-16px overflow-auto lt-sm:overflow-auto">
    <ElSpace style="display: flex; flex-direction: column; align-items: stretch" :size="16" class="page-container">
      <ElCard class="card-wrapper">
        <ElCollapse>
          <ElCollapseItem title="搜索" name="contract-search">
            <ElForm :model="searchParams" label-position="right" :label-width="88">
              <ElRow :gutter="24">
                <ElCol :lg="6" :md="8" :sm="12">
                  <ElFormItem label="关键字">
                    <ElInput
                      v-model="searchParams.keyword"
                      placeholder="合同名称 / 编号 / 客户 / 销售负责人"
                      clearable
                    />
                  </ElFormItem>
                </ElCol>
                <ElCol :lg="6" :md="8" :sm="12">
                  <ElFormItem label="合同类型">
                    <ElSelect v-model="searchParams.contractType" placeholder="全部类型" clearable class="w-full">
                      <ElOption
                        v-for="item in CONTRACT_TYPE_OPTIONS"
                        :key="item.value"
                        :label="item.label"
                        :value="item.value"
                      />
                    </ElSelect>
                  </ElFormItem>
                </ElCol>
                <ElCol :lg="12" :md="8" :sm="24">
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
            <p>合同</p>
            <ElSpace>
              <ElButton v-if="canAdd" type="primary" @click="openAddDrawer">
                <template #icon>
                  <icon-ic-round-plus class="text-icon" />
                </template>
                {{ $t('common.add') }}
              </ElButton>
              <ElButton type="primary" @click="search">
                <template #icon>
                  <icon-ic-round-refresh class="text-icon" />
                </template>
                {{ $t('common.refresh') }}
              </ElButton>
            </ElSpace>
          </div>
        </template>

        <ElTable border class="sm:h-full" :data="tableData" row-key="id" v-loading="loading">
          <ElTableColumn prop="id" label="合同ID" width="80" align="center" fixed />
          <ElTableColumn prop="contractNo" label="合同编号" width="130" show-overflow-tooltip fixed />
          <ElTableColumn prop="contractName" label="合同名称" min-width="180" show-overflow-tooltip fixed>
            <template #default="{ row }">
              <ElButton type="primary" link class="contract-name-link" @click="openDetailDrawer(row)">
                {{ row.contractName }}
              </ElButton>
            </template>
          </ElTableColumn>
          <ElTableColumn prop="customerName" label="客户名称" min-width="160" show-overflow-tooltip />
          <ElTableColumn prop="contractType" label="合同类型" width="90" align="center">
            <template #default="{ row }">
              <ElTag :type="contractTypeTagType(row.contractType)" size="small" round>
                {{ CONTRACT_TYPE_LABEL[row.contractType as ContractType] }}
              </ElTag>
            </template>
          </ElTableColumn>
          <ElTableColumn prop="signDate" label="签约日期" width="110" align="center" />
          <ElTableColumn prop="deliveryDate" label="交付日期" width="110" align="center" />
          <ElTableColumn prop="salesOwner" label="销售负责人" width="100" align="center" />
          <ElTableColumn label="产品报价(元)" width="130" align="right">
            <template #default="{ row }">
              {{ formatAmount(row.quoteAmount) }}
            </template>
          </ElTableColumn>
          <ElTableColumn label="审批流程" width="140" show-overflow-tooltip>
            <template #default="{ row }">
              {{ approvalFlowLabel(row.approvalFlow) }}
            </template>
          </ElTableColumn>
          <ElTableColumn label="收款条件" min-width="180" show-overflow-tooltip>
            <template #default="{ row }">
              {{ summarizePayment(row) }}
            </template>
          </ElTableColumn>
          <ElTableColumn prop="milestone" label="里程碑" min-width="140" show-overflow-tooltip />
          <ElTableColumn label="操作" width="220" fixed="right" align="center">
            <template #default="{ row }">
              <ElButton v-if="canUpdate" size="small" type="primary" @click="openEditDrawer(row)">编辑</ElButton>
              <ElButton v-if="canDelete" size="small" type="danger" @click="handleDelete(row)">删除</ElButton>
              <ElButton v-if="canProjectInit" size="small" type="warning" plain @click="handleProjectInit(row)">
                项目立项
              </ElButton>
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

    <ContractOperateDrawer
      v-model:visible="showDrawer"
      :title="drawerTitle"
      :contract="editingContract"
      @submitted="onSubmitted"
    />

    <ContractDetailDrawer v-model:visible="showDetailDrawer" :contract="detailContract" />
  </div>
</template>

<style lang="scss" scoped>
:deep(.el-card) {
  .ht50 {
    height: calc(100% - 50px);
  }
}

.contract-name-link {
  max-width: 100%;
  height: auto;
  padding: 0;
  font-weight: 400;
  white-space: normal;
  text-align: left;
}
</style>
