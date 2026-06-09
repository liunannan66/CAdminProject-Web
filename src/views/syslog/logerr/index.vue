<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue';
import { ElMessage } from 'element-plus';
import { getSysErrlogPage } from '@/service/api';

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

// 表格数据
interface ErrLogRecord {
  id: number;
  userId: number;
  userName: string;
  userType: string;
  exceptionName: string;
  exceptionMessage: string;
  stackTrace: string;
  requestMethod: string;
  requestUrl: string;
  requestParam: string;
  ip: string;
  location: string;
  errTime: string;
  errTimestamp: number;
}

const errLogList = ref<{
  records: ErrLogRecord[];
  totalRows: number;
}>();

// 获取异常日志列表
const fetchErrLogList = async () => {
  loading.value = true;
  try {
    const response = await getSysErrlogPage(searchParams);
    errLogList.value = response;
  } catch (error) {
    console.error('获取异常日志列表失败:', error);
    ElMessage.error('获取异常日志列表失败');
  } finally {
    loading.value = false;
  }
};

// 搜索功能
const search = () => {
  searchParams.pageNo = 1;
  fetchErrLogList();
};

// 重置搜索
const resetSearch = () => {
  searchParams.keyword = '';
  searchParams.pageNo = 1;
  fetchErrLogList();
};

// 监听页码变化
const handleCurrentChange = (val: number) => {
  searchParams.pageNo = val;
  fetchErrLogList();
};

// 监听页面大小变化
const handleSizeChange = (val: number) => {
  searchParams.pageSize = val;
  searchParams.pageNo = 1;
  fetchErrLogList();
};

// 查看堆栈详情
const showStackTrace = (stackTrace: string) => {
  console.log('异常堆栈:', stackTrace);
};

// 初始化数据
onMounted(() => {
  fetchErrLogList();
});
</script>

<template>
  <div class="min-h-500px flex-col-stretch gap-16px overflow-hidden lt-sm:overflow-auto">
    <ElSpace style="display: flex;flex-direction:column;align-items: stretch;" :size="16" class="page-container">
      <!-- 搜索区域 -->
      <ElCard class="card-wrapper">
        <ElCollapse>
          <ElCollapseItem title="搜索" name="errlog-search">
            <ElForm :model="searchParams" label-position="right" :label-width="80">
              <ElRow :gutter="24">
                <ElCol :lg="6" :md="8" :sm="12">
                  <ElFormItem label="关键字" prop="keyword">
                    <ElInput v-model="searchParams.keyword" placeholder="请输入用户名或异常信息" clearable />
                  </ElFormItem>
                </ElCol>

                <ElCol :lg="18" :md="16" :sm="12">
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

      <!-- 异常日志列表 -->
      <ElCard class="card-wrapper" style="flex: 1; min-height: 0;" >
        <template #header>
          <div class="flex items-center justify-between">
            <p>异常日志</p>
            <ElButton type="primary" @click="fetchErrLogList">
              <template #icon>
                <icon-ic-round-refresh class="text-icon" />
              </template>
              {{ $t('common.refresh') }}
            </ElButton>
          </div>
        </template>

        <ElTable v-loading="loading" border class="w-full" :data="errLogList?.records" row-key="id">
          <ElTableColumn prop="id" label="ID" width="70" align="center" fixed />
          <ElTableColumn prop="userName" label="操作用户" width="100" show-overflow-tooltip>
            <template #default="{ row }">
              {{ row.userName || '系统' }}
            </template>
          </ElTableColumn>
          <ElTableColumn prop="userType" label="用户类型" width="90" align="center">
            <template #default="{ row }">
              <ElTag :type="row.userType === 'SuperAdmin' ? 'danger' : row.userType === 'Admin' ? 'warning' : 'info'" size="small" round>
                {{ row.userType || '未知' }}
              </ElTag>
            </template>
          </ElTableColumn>
          <ElTableColumn prop="exceptionName" label="异常类型" width="150" show-overflow-tooltip>
            <template #default="{ row }">
              <ElTag type="danger" size="small">{{ row.exceptionName || '-' }}</ElTag>
            </template>
          </ElTableColumn>
          <ElTableColumn prop="exceptionMessage" label="异常信息" min-width="180" show-overflow-tooltip>
            <template #default="{ row }">
              <span class="text-danger">{{ row.exceptionMessage || '-' }}</span>
            </template>
          </ElTableColumn>
          <ElTableColumn prop="requestMethod" label="请求方式" width="90" align="center">
            <template #default="{ row }">
              <ElTag :type="row.requestMethod === 'GET' ? 'success' : 'warning'" size="small">
                {{ row.requestMethod || '-' }}
              </ElTag>
            </template>
          </ElTableColumn>
          <ElTableColumn prop="requestUrl" label="请求地址" min-width="160" show-overflow-tooltip />
          <ElTableColumn prop="ip" label="IP地址" width="120" align="center" show-overflow-tooltip />
          <ElTableColumn prop="location" label="操作地点" width="100" align="center" show-overflow-tooltip />
          <ElTableColumn prop="errTime" label="异常时间" width="160" align="center" sortable />
          <ElTableColumn label="操作" width="80" fixed="right" align="center">
            <template #default="{ row }">
              <ElButton size="small" type="danger" @click="showStackTrace(row.stackTrace)">
                详情
              </ElButton>
            </template>
          </ElTableColumn>
        </ElTable>
      </ElCard>

      <div class="flex justify-end" style="margin-top: 12px;">
        <ElPagination
          v-model:current-page="searchParams.pageNo"
          v-model:page-size="searchParams.pageSize"
          :page-sizes="[10, 20, 30, 50, 100]"
          :total="errLogList?.totalRows"
          :disabled="loading"
          layout="total, sizes, prev, pager, next, jumper"
          @current-change="handleCurrentChange"
          @size-change="handleSizeChange"
        />
      </div>
    </ElSpace>
  </div>
</template>

<style lang="scss" scoped>
.text-danger {
  color: var(--el-color-danger);
}
</style>
