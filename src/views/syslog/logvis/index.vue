<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue';
import { ElMessage } from 'element-plus';
import { getSysVislogPage } from '@/service/api';

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
interface VisLogRecord {
  id: number;
  userId: number;
  userName: string;
  userType: string;
  browser: string;
  os: string;
  device: string;
  browserLang: string;
  requestUrl: string;
  requestMethod: string;
  requestParam: string;
  responseResult: string;
  ip: string;
  location: string;
  visitTime: string;
  visitTimestamp: number;
}

const visLogList = ref<{
  records: VisLogRecord[];
  totalRows: number;
}>();

// 计算属性 - 用户类型标签颜色
const userTypeTag = computed(() => (type: string) => {
  const map: Record<string, string> = {
    'SuperAdmin': 'danger',
    'Admin': 'warning',
    'User': 'primary',
    'Visitor': 'info'
  };
  return map[type] || 'info';
});

// 获取访问日志列表
const fetchVisLogList = async () => {
  loading.value = true;
  try {
    const response = await getSysVislogPage(searchParams);
    visLogList.value = response;
  } catch (error) {
    console.error('获取访问日志列表失败:', error);
    ElMessage.error('获取访问日志列表失败');
  } finally {
    loading.value = false;
  }
};

// 搜索功能
const search = () => {
  searchParams.pageNo = 1;
  fetchVisLogList();
};

// 重置搜索
const resetSearch = () => {
  searchParams.keyword = '';
  searchParams.pageNo = 1;
  fetchVisLogList();
};

// 监听页码变化
const handleCurrentChange = (val: number) => {
  searchParams.pageNo = val;
  fetchVisLogList();
};

// 监听页面大小变化
const handleSizeChange = (val: number) => {
  searchParams.pageSize = val;
  searchParams.pageNo = 1;
  fetchVisLogList();
};

// 查看详情
const showDetail = (row: VisLogRecord) => {
  console.log('查看访问详情:', row);
};

// 初始化数据
onMounted(() => {
  fetchVisLogList();
});
</script>

<template>
  <div class="min-h-500px flex-col-stretch gap-16px overflow-hidden lt-sm:overflow-auto">
    <ElSpace style="display: flex;flex-direction:column;align-items: stretch;" :size="16" class="page-container">
      <!-- 搜索区域 -->
      <ElCard class="card-wrapper">
        <ElCollapse>
          <ElCollapseItem title="搜索" name="vislog-search">
            <ElForm :model="searchParams" label-position="right" :label-width="80">
              <ElRow :gutter="24">
                <ElCol :lg="6" :md="8" :sm="12">
                  <ElFormItem label="关键字" prop="keyword">
                    <ElInput v-model="searchParams.keyword" placeholder="请输入用户名或访问地址" clearable />
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

      <!-- 访问日志列表 -->
      <ElCard header="访问日志列表" class="card-wrapper sm:flex-1-hidden" style="margin-top: 12px;">
        <template #header>
          <div class="flex items-center justify-between">
            <p>访问日志</p>
            <ElButton type="primary" @click="fetchVisLogList">
              <template #icon>
                <icon-ic-round-refresh class="text-icon" />
              </template>
              {{ $t('common.refresh') }}
            </ElButton>
          </div>
        </template>

        <ElTable v-loading="loading" border class="sm:h-full" :data="visLogList?.records" row-key="id">
          <ElTableColumn prop="id" label="ID" width="70" align="center" fixed />
          <ElTableColumn prop="userName" label="访问用户" width="90" show-overflow-tooltip>
            <template #default="{ row }">
              {{ row.userName || '游客' }}
            </template>
          </ElTableColumn>
          <ElTableColumn prop="userType" label="用户类型" width="90" align="center">
            <template #default="{ row }">
              <ElTag :type="userTypeTag(row.userType)" size="small" round>
                {{ row.userType || '未知' }}
              </ElTag>
            </template>
          </ElTableColumn>
          <ElTableColumn prop="browser" label="浏览器" width="100" show-overflow-tooltip />
          <ElTableColumn prop="os" label="操作系统" width="90" show-overflow-tooltip />
          <ElTableColumn prop="device" label="设备" width="70" align="center">
            <template #default="{ row }">
              <ElTag size="small">{{ row.device || '-' }}</ElTag>
            </template>
          </ElTableColumn>
          <ElTableColumn prop="browserLang" label="语言" width="70" align="center">
            <template #default="{ row }">
              <ElTag size="small" type="info">{{ row.browserLang || '-' }}</ElTag>
            </template>
          </ElTableColumn>
          <ElTableColumn prop="requestMethod" label="请求方式" width="90" align="center">
            <template #default="{ row }">
              <ElTag :type="row.requestMethod === 'GET' ? 'success' : 'warning'" size="small">
                {{ row.requestMethod || '-' }}
              </ElTag>
            </template>
          </ElTableColumn>
          <ElTableColumn prop="requestUrl" label="访问地址" min-width="150" show-overflow-tooltip />
          <ElTableColumn prop="ip" label="IP地址" width="120" align="center" show-overflow-tooltip />
          <ElTableColumn prop="location" label="访问地点" width="100" align="center" show-overflow-tooltip />
          <ElTableColumn prop="visitTime" label="访问时间" width="160" align="center" sortable />
          <ElTableColumn label="操作" width="80" fixed="right" align="center">
            <template #default="{ row }">
              <ElButton size="small" type="primary" @click="showDetail(row)">
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
          :total="visLogList?.totalRows"
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
:deep(.el-card) {
  .ht50 {
    height: calc(100% - 50px);
  }
}
</style>
