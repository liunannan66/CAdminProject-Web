<script setup lang="ts">
import { computed, nextTick, onMounted, reactive, ref } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { ElMessage, ElMessageBox } from 'element-plus';
import {
  PROJECT_INIT_AUTH,
  PROJECT_INIT_STATUS_LABEL,
  PROJECT_INIT_STATUS_OPTIONS,
  PROJECT_INIT_STATUS_TAG_TYPE,
  PROJECT_INIT_TYPE_LABEL,
  PROJECT_INIT_TYPE_OPTIONS,
  type ProjectInitStatus,
  type ProjectInitType
} from '@/constants/project-init';
import { useAuth } from '@/hooks/business/auth';
import { useAuthStore } from '@/store/modules/auth';
import { deleteProjectInit, generateProjectInitSow, getProjectInitDetail, getProjectInitPage } from '@/service/api/project-init';
import { mapProjectInitDtoToRecord, withFreshLineIds } from '@/utils/project-init-map';
import type { ProjectInitRecord } from '@/utils/project-init';
import ProjectInitDetailDrawer from './modules/project-init-detail-drawer.vue';
import ProjectInitOperateDrawer from './modules/project-init-operate-drawer.vue';

defineOptions({ name: 'ContractProjectInit' });

interface SearchParams {
  pageNo: number;
  pageSize: number;
  keyword: string;
  projectType: ProjectInitType | '';
  status: ProjectInitStatus | '';
}

const route = useRoute();
const router = useRouter();
const { hasAuth } = useAuth();
const authStore = useAuthStore();

function checkProjectInitAuth(code: string) {
  const configured = authStore.userInfo.buttons.some(item => item.startsWith('api:ProjectInit:'));
  if (!configured) return true;
  return hasAuth(code);
}

const canAdd = computed(() => checkProjectInitAuth(PROJECT_INIT_AUTH.add));
const canUpdate = computed(() => checkProjectInitAuth(PROJECT_INIT_AUTH.update));
const canDelete = computed(() => checkProjectInitAuth(PROJECT_INIT_AUTH.delete));
const canGenerateSow = computed(() => checkProjectInitAuth(PROJECT_INIT_AUTH.generateSow));

const sowGeneratingId = ref<number | null>(null);

const searchParams = reactive<SearchParams>({
  pageNo: 1,
  pageSize: 10,
  keyword: '',
  projectType: '',
  status: ''
});

const loading = ref(false);
const totalRows = ref(0);
const tableData = ref<ProjectInitRecord[]>([]);

const showDrawer = ref(false);
const showDetailDrawer = ref(false);
const drawerTitle = ref('新增项目立项');
const editingRecord = ref<ProjectInitRecord | null>(null);
const detailRecord = ref<ProjectInitRecord | null>(null);

async function fetchProjectList() {
  loading.value = true;
  try {
    const result = await getProjectInitPage({
      pageNo: searchParams.pageNo,
      pageSize: searchParams.pageSize,
      keyWord: searchParams.keyword.trim() || undefined,
      projectType: searchParams.projectType || undefined,
      status: searchParams.status || undefined
    });
    tableData.value = (result?.records ?? []).map(mapProjectInitDtoToRecord);
    totalRows.value = result?.totalRows ?? 0;
  } catch {
    tableData.value = [];
    totalRows.value = 0;
  } finally {
    loading.value = false;
  }
}

function resetSearch() {
  searchParams.keyword = '';
  searchParams.projectType = '';
  searchParams.status = '';
  searchParams.pageNo = 1;
  fetchProjectList();
}

function search() {
  searchParams.pageNo = 1;
  fetchProjectList();
}

function openAddDrawer() {
  drawerTitle.value = '新增项目立项';
  editingRecord.value = null;
  showDrawer.value = true;
}

function openEditDrawer(row: ProjectInitRecord) {
  drawerTitle.value = '编辑项目立项';
  editingRecord.value = JSON.parse(JSON.stringify(row)) as ProjectInitRecord;
  showDrawer.value = true;
}

function openDetailDrawer(row: ProjectInitRecord) {
  detailRecord.value = JSON.parse(JSON.stringify(row)) as ProjectInitRecord;
  showDetailDrawer.value = true;
}

function openTaskList(row: ProjectInitRecord) {
  if (row.status !== 'approved') {
    ElMessage.warning('仅已立项项目可进入任务清单');
    return;
  }
  router.push({ name: 'contract_project-task', query: { projectId: String(row.id) } });
}

function onSubmitted() {
  showDrawer.value = false;
  fetchProjectList();
}

async function handleDelete(row: ProjectInitRecord) {
  if (!canDelete.value) {
    ElMessage.warning('暂无删除权限');
    return;
  }
  try {
    await ElMessageBox.confirm(`确定删除立项「${row.projectNo}」吗？`, '提示', { type: 'warning' });
    await deleteProjectInit(row.id);
    ElMessage.success('删除成功');
    fetchProjectList();
  } catch {
    /* 用户取消或请求失败 */
  }
}

function buildSowFileName(row: ProjectInitRecord) {
  const customerName = (row.customerName || row.partyA || row.projectName || String(row.id)).replace(
    /[\\/:*?"<>|]/g,
    '_'
  );
  return `实施工作说明书（SOW）_${customerName}_V2.1.docx`;
}

async function handleGenerateSow(row: ProjectInitRecord) {
  if (!canGenerateSow.value) {
    ElMessage.warning('暂无生成 SOW 权限');
    return;
  }
  if (sowGeneratingId.value != null) return;

  sowGeneratingId.value = row.id;
  try {
    await generateProjectInitSow(row.id, buildSowFileName(row));
    ElMessage.success('SOW 已生成并开始下载');
  } catch (error) {
    ElMessage.error(error instanceof Error ? error.message : '生成 SOW 失败');
  } finally {
    sowGeneratingId.value = null;
  }
}

async function tryOpenByQuery() {
  const openId = route.query.openId;
  if (!openId) return;

  const id = Number(openId);
  if (!Number.isFinite(id) || id <= 0) return;

  try {
    const detail = await getProjectInitDetail(id);
    await nextTick();
    openEditDrawer(withFreshLineIds(mapProjectInitDtoToRecord(detail)));
    router.replace({ name: 'contract_project-init', query: {} });
  } catch {
    ElMessage.warning('加载立项详情失败');
  }
}

onMounted(async () => {
  await fetchProjectList();
  await tryOpenByQuery();
});
</script>

<template>
  <div class="min-h-500px flex-col-stretch gap-16px overflow-hidden lt-sm:overflow-auto">
    <ElSpace style="display: flex; flex-direction: column; align-items: stretch" :size="16" class="page-container">
      <ElCard class="card-wrapper">
        <ElCollapse>
          <ElCollapseItem title="搜索" name="project-init-search">
            <ElForm :model="searchParams" label-position="right" :label-width="88">
              <ElRow :gutter="24">
                <ElCol :lg="6" :md="8" :sm="12">
                  <ElFormItem label="关键字">
                    <ElInput
                      v-model="searchParams.keyword"
                      placeholder="项目编号 / 名称 / 合同 / 客户 / 项目经理"
                      clearable
                    />
                  </ElFormItem>
                </ElCol>
                <ElCol :lg="6" :md="8" :sm="12">
                  <ElFormItem label="项目类型">
                    <ElSelect v-model="searchParams.projectType" placeholder="全部类型" clearable class="w-full">
                      <ElOption
                        v-for="item in PROJECT_INIT_TYPE_OPTIONS"
                        :key="item.value"
                        :label="item.label"
                        :value="item.value"
                      />
                    </ElSelect>
                  </ElFormItem>
                </ElCol>
                <ElCol :lg="6" :md="8" :sm="12">
                  <ElFormItem label="立项状态">
                    <ElSelect v-model="searchParams.status" placeholder="全部状态" clearable class="w-full">
                      <ElOption
                        v-for="item in PROJECT_INIT_STATUS_OPTIONS"
                        :key="item.value"
                        :label="item.label"
                        :value="item.value"
                      />
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

      <ElCard v-loading="loading" class="card-wrapper sm:flex-1-hidden" style="margin-top: 12px">
        <template #header>
          <div class="flex items-center justify-between">
            <p>{{ $t('contract.projectInit') }}</p>
            <ElSpace>
              <ElButton v-if="canAdd" type="primary" @click="openAddDrawer" style="display: none;">
                <template #icon>
                  <icon-ic-round-plus class="text-icon" />
                </template>
                {{ $t('common.add') }}
              </ElButton>
              <ElButton type="primary" @click="fetchProjectList">
                <template #icon>
                  <icon-ic-round-refresh class="text-icon" />
                </template>
                {{ $t('common.refresh') }}
              </ElButton>
            </ElSpace>
          </div>
        </template>

        <ElTable border class="sm:h-full" :data="tableData" row-key="id">
          <ElTableColumn prop="id" label="ID" width="72" align="center" fixed />
          <ElTableColumn prop="projectNo" label="项目编号" width="160" show-overflow-tooltip fixed />
          <ElTableColumn prop="projectName" label="项目名称" min-width="180" show-overflow-tooltip fixed>
            <template #default="{ row }">
              <ElButton type="primary" link class="project-name-link" @click="openDetailDrawer(row)">
                {{ row.projectName }}
              </ElButton>
            </template>
          </ElTableColumn>
          <ElTableColumn prop="projectType" label="项目类型" width="90" align="center">
            <template #default="{ row }">
              <ElTag :type="row.projectType === 'self' ? 'primary' : 'warning'" size="small" round>
                {{ PROJECT_INIT_TYPE_LABEL[row.projectType as ProjectInitType] }}
              </ElTag>
            </template>
          </ElTableColumn>
          <ElTableColumn prop="status" label="立项状态" width="100" align="center">
            <template #default="{ row }">
              <ElTag :type="PROJECT_INIT_STATUS_TAG_TYPE[row.status as ProjectInitStatus]" size="small" round>
                {{ PROJECT_INIT_STATUS_LABEL[row.status as ProjectInitStatus] }}
              </ElTag>
            </template>
          </ElTableColumn>
          <ElTableColumn prop="contractNo" label="合同编号" width="130" show-overflow-tooltip />
          <ElTableColumn prop="customerName" label="客户名称" min-width="150" show-overflow-tooltip />
          <ElTableColumn prop="planStartDate" label="预计开始" width="110" align="center" />
          <ElTableColumn prop="planEndDate" label="预计完工" width="110" align="center" />
          <ElTableColumn prop="projectManager" label="项目经理" width="100" align="center" />
          <ElTableColumn prop="createTime" label="创建时间" width="160" align="center" show-overflow-tooltip />
          <ElTableColumn label="操作" width="320" fixed="right" align="center">
            <template #default="{ row }">
              <ElButton
                v-if="row.status === 'approved'"
                size="small"
                type="warning"
                @click="openTaskList(row)"
              >
                任务清单
              </ElButton>
              <ElButton v-if="canUpdate" size="small" type="primary" @click="openEditDrawer(row)">编辑</ElButton>
              <ElButton
                v-if="canGenerateSow"
                size="small"
                type="success"
                :loading="sowGeneratingId === row.id"
                @click="handleGenerateSow(row)"
              >
                生成SOW
              </ElButton>
              <ElButton v-if="canDelete" size="small" type="danger" @click="handleDelete(row)">删除</ElButton>
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
          @current-change="fetchProjectList"
          @size-change="search"
        />
      </div>
    </ElSpace>

    <ProjectInitOperateDrawer
      v-model:visible="showDrawer"
      :title="drawerTitle"
      :record="editingRecord"
      @submitted="onSubmitted"
    />

    <ProjectInitDetailDrawer v-model:visible="showDetailDrawer" :record="detailRecord" />
  </div>
</template>

<style lang="scss" scoped>
:deep(.el-card) {
  .ht50 {
    height: calc(100% - 50px);
  }
}

.project-name-link {
  max-width: 100%;
  height: auto;
  padding: 0;
  font-weight: 400;
  white-space: normal;
  text-align: left;
}
</style>
