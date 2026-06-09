<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue';
import { ElMessage } from 'element-plus';
import { getSysOplogPage } from '@/service/api';
import OpLogDetailDialog, { type OpLogRecord } from './modules/op-log-detail-dialog.vue';

// 类型定义
interface SearchParams {
  pageNo: number;
  pageSize: number;
  keyword: string;
}

// 响应式数据
const loading = ref(false);
const searchParams = reactive<SearchParams>({
  pageNo: 1,
  pageSize: 10,
  keyword: ''
});

const opLogList = ref<{
  records: OpLogRecord[];
  totalRows: number;
}>();

const detailVisible = ref(false);
const currentLog = ref<OpLogRecord | null>(null);

// 计算属性 - 操作用户类型
const userTypeTag = computed(() => (type: string) => {
  const map: Record<string, string> = {
    SuperAdmin: 'danger',
    Admin: 'warning',
    User: 'primary',
    Visitor: 'info'
  };
  return map[type] || 'info';
});

// 获取操作日志列表
const fetchOpLogList = async () => {
  loading.value = true;
  try {
    const response = await getSysOplogPage(searchParams);
    opLogList.value = response;
  } catch (error) {
    console.error('获取操作日志列表失败:', error);
    ElMessage.error('获取操作日志列表失败');
  } finally {
    loading.value = false;
  }
};

// 搜索功能
const search = () => {
  searchParams.pageNo = 1;
  fetchOpLogList();
};

// 重置搜索
const resetSearch = () => {
  searchParams.keyword = '';
  searchParams.pageNo = 1;
  fetchOpLogList();
};

// 监听页码变化
const handleCurrentChange = (val: number) => {
  searchParams.pageNo = val;
  fetchOpLogList();
};

// 监听页面大小变化
const handleSizeChange = (val: number) => {
  searchParams.pageSize = val;
  searchParams.pageNo = 1;
  fetchOpLogList();
};

// 查看详情
const showDetail = (row: OpLogRecord) => {
  currentLog.value = row;
  detailVisible.value = true;
};

// 初始化数据
onMounted(() => {
  fetchOpLogList();
});
</script>

<template>
  <div class="min-h-500px flex-col-stretch gap-16px overflow-auto lt-sm:overflow-auto">
    <ElSpace style="display: flex;flex-direction: column;align-items: stretch;" :size="16" class="page-container">
      <!-- 搜索区域 -->
      <ElCard class="card-wrapper">
        <ElCollapse>
          <ElCollapseItem title="搜索" name="oplog-search">
            <ElForm :model="searchParams" label-position="right" :label-width="80">
              <ElRow :gutter="24">
                <ElCol :lg="6" :md="8" :sm="12">
                  <ElFormItem label="关键字" prop="keyword">
                    <ElInput v-model="searchParams.keyword" placeholder="请输入用户名或操作描述" clearable />
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

      <!-- 操作日志列表 -->
      <ElCard class="card-wrapper" style="flex: 1; min-height: 0;margin-top: 16px;">
        <template #header>
          <div class="flex items-center justify-between">
            <p>操作日志</p>
            <ElButton type="primary" @click="fetchOpLogList">
              <template #icon>
                <icon-ic-round-refresh class="text-icon" />
              </template>
              {{ $t('common.refresh') }}
            </ElButton>
          </div>
        </template>

        <ElTable v-loading="loading" border class="w-full" :data="opLogList?.records" row-key="id">
          <ElTableColumn prop="id" label="ID" width="70" align="center" fixed />
          <ElTableColumn prop="userName" label="操作用户" width="100" show-overflow-tooltip />
          <ElTableColumn prop="userType" label="用户类型" width="90" align="center">
            <template #default="{ row }">
              <ElTag :type="userTypeTag(row.userType)" size="small" round>
                {{ row.userType || '未知' }}
              </ElTag>
            </template>
          </ElTableColumn>
          <ElTableColumn prop="opModule" label="操作模块" width="100" show-overflow-tooltip />
          <ElTableColumn prop="opType" label="操作类型" width="90" align="center">
            <template #default="{ row }">
              <ElTag type="primary" size="small">{{ row.opType || '-' }}</ElTag>
            </template>
          </ElTableColumn>
          <ElTableColumn prop="opDesc" label="操作描述" min-width="120" show-overflow-tooltip />
          <ElTableColumn prop="requestMethod" label="请求方式" width="90" align="center">
            <template #default="{ row }">
              <ElTag :type="row.requestMethod === 'GET' ? 'success' : 'warning'" size="small">
                {{ row.requestMethod || '-' }}
              </ElTag>
            </template>
          </ElTableColumn>
          <ElTableColumn prop="requestUrl" label="请求地址" min-width="180" show-overflow-tooltip />
          <ElTableColumn prop="ip" label="IP地址" width="120" align="center" show-overflow-tooltip />
          <ElTableColumn prop="location" label="操作地点" width="100" align="center" show-overflow-tooltip />
          <ElTableColumn prop="opTime" label="操作时间" width="160" align="center" sortable />
          <ElTableColumn label="操作" width="80" fixed="right" align="center">
            <template #default="{ row }">
              <ElButton size="small" type="primary" @click="showDetail(row)">
                详情
              </ElButton>
            </template>
          </ElTableColumn>
        </ElTable>
      </ElCard>

      <div class="flex justify-end" style="margin-top: 16px;">
        <ElPagination
          v-model:current-page="searchParams.pageNo"
          v-model:page-size="searchParams.pageSize"
          :page-sizes="[10, 20, 30, 50, 100]"
          :total="opLogList?.totalRows"
          :disabled="loading"
          layout="total, sizes, prev, pager, next, jumper"
          @current-change="handleCurrentChange"
          @size-change="handleSizeChange"
        />
      </div>
    </ElSpace>

    <OpLogDetailDialog v-model="detailVisible" :record="currentLog" />
  </div>
</template>

<style lang="scss" scoped>
  :deep(.el-card) {
  .ht50 {
    height: calc(100% - 50px);
  }
}
</style>
