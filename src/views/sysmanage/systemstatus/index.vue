<script setup lang="ts">
import { computed, onMounted, ref } from 'vue';
import { getSystemInfo } from '@/service/api';
import { useAppStore } from '@/store/modules/app';
import type { SystemInfo } from '@/typings/response/systemInfo';

const appStore = useAppStore();

const column = computed(() => (appStore.isMobile ? 1 : 2));

const sysdata = ref<SystemInfo | undefined>();
const isLoading = ref(true);

onMounted(async () => {
  try {
    const response = await getSystemInfo();
    console.log('response', response);
    if (response) {
      sysdata.value = response as SystemInfo;
    } else {
      console.warn('No system data received');
    }
    console.log('sysdata', sysdata.value);
  } catch (error) {
    console.error('Failed to fetch system data:', error);
  } finally {
    isLoading.value = false;
  }
});

// 根据磁盘使用百分比获取对应的颜色
const getDiskColor = (percent: number) => {
  if (percent > 90) return '#f56c6c'; // 红色 - 危险
  if (percent > 80) return '#e6a23c'; // 橙色 - 警告
  if (percent > 60) return '#f7ba2a'; // 黄色 - 注意
  return '#67c23a'; // 绿色 - 正常
};

// 根据内存使用率获取颜色
const getMemoryColor = (percent: number) => {
  if (percent > 90) return '#f56c6c';
  if (percent > 80) return '#e6a23c';
  if (percent > 60) return '#f7ba2a';
  return '#67c23a';
};
</script>

<template>
  <div class="system-status-page">
    <div class="page-section">
      <ElCard header="服务器信息" class="info-card">
        <ElDescriptions :column="column" border>
          <ElDescriptionsItem label="服务器名称">
            <ElSkeleton v-if="isLoading" :rows="1" animated />
            <span v-else class="text-primary">{{ sysdata?.machineName }}</span>
          </ElDescriptionsItem>
          <ElDescriptionsItem label="服务器IP">
            <ElSkeleton v-if="isLoading" :rows="1" animated />
            <span v-else class="text-primary">{{ sysdata?.ip }}</span>
          </ElDescriptionsItem>
          <ElDescriptionsItem label="系统名称">
            <ElSkeleton v-if="isLoading" :rows="1" animated />
            <span v-else class="text-primary">{{ sysdata?.osName }}</span>
          </ElDescriptionsItem>
          <ElDescriptionsItem label="系统架构">
            <ElSkeleton v-if="isLoading" :rows="1" animated />
            <span v-else class="text-primary">{{ sysdata?.osArchitecture }}</span>
          </ElDescriptionsItem>
          <ElDescriptionsItem label=".NET版本">
            <ElSkeleton v-if="isLoading" :rows="1" animated />
            <span v-else class="text-primary">{{ sysdata?.doNetName }}</span>
          </ElDescriptionsItem>
          <ElDescriptionsItem label="CPU核心数">
            <ElSkeleton v-if="isLoading" :rows="1" animated />
            <span v-else class="text-primary">{{ sysdata?.cpuCount }}</span>
          </ElDescriptionsItem>
          <ElDescriptionsItem label="启动时间">
            <ElSkeleton v-if="isLoading" :rows="1" animated />
            <span v-else class="text-primary">{{ sysdata?.startTime }}</span>
          </ElDescriptionsItem>
          <ElDescriptionsItem label="运行时间">
            <ElSkeleton v-if="isLoading" :rows="1" animated />
            <span v-else class="text-primary">{{ sysdata?.runTime }}</span>
          </ElDescriptionsItem>
        </ElDescriptions>
      </ElCard>
    </div>

    <div class="page-section">
      <ElCard header="CPU/内存信息" class="info-card">
        <ElRow :gutter="20" class="progress-container">
          <ElCol :xs="24" :sm="12" :md="8" class="progress-item">
            <ElCard shadow="hover" class="metric-card">
              <div class="metric-header">
                <div class="metric-title">CPU使用率</div>
                <div class="metric-value">{{ sysdata?.memoryInfo.cpuRate || 0 }}%</div>
              </div>
              <ElProgress
                type="dashboard"
                :percentage="sysdata?.memoryInfo.cpuRate || 0"
                :color="getMemoryColor(sysdata?.memoryInfo.cpuRate || 0)"
                :width="120"
              />
            </ElCard>
          </ElCol>

          <ElCol :xs="24" :sm="12" :md="8" class="progress-item">
            <ElCard shadow="hover" class="metric-card">
              <div class="metric-header">
                <div class="metric-title">总内存使用率</div>
                <div class="metric-value">{{ sysdata?.memoryInfo.ramRate || 0 }}%</div>
              </div>
              <ElProgress
                type="dashboard"
                :percentage="sysdata?.memoryInfo.ramRate || 0"
                :color="getMemoryColor(sysdata?.memoryInfo.ramRate || 0)"
                :width="120"
              />
            </ElCard>
          </ElCol>

          <ElCol :xs="24" :sm="12" :md="8" class="progress-item">
            <ElCard shadow="hover" class="metric-card">
              <div class="metric-header">
                <div class="metric-title">应用内存使用率</div>
                <div class="metric-value">{{ sysdata?.memoryInfo.appRAMRate || 0 }}%</div>
              </div>
              <ElProgress
                type="dashboard"
                :percentage="sysdata?.memoryInfo.appRAMRate || 0"
                :color="getMemoryColor(sysdata?.memoryInfo.appRAMRate || 0)"
                :width="120"
              />
            </ElCard>
          </ElCol>
        </ElRow>

        <!-- 内存详细信息 -->
        <ElRow :gutter="20" class="detail-container">
          <ElCol :xs="24" :sm="12" :md="6">
            <div class="detail-item">
              <div class="detail-label">总内存</div>
              <div class="detail-value">{{ sysdata?.memoryInfo.totalRAM.toFixed(2) }} GB</div>
            </div>
          </ElCol>
          <ElCol :xs="24" :sm="12" :md="6">
            <div class="detail-item">
              <div class="detail-label">已用内存</div>
              <div class="detail-value">{{ sysdata?.memoryInfo.usedRam }}</div>
            </div>
          </ElCol>
          <ElCol :xs="24" :sm="12" :md="6">
            <div class="detail-item">
              <div class="detail-label">可用内存</div>
              <div class="detail-value">{{ sysdata?.memoryInfo.freeRam }}</div>
            </div>
          </ElCol>
          <ElCol :xs="24" :sm="12" :md="6">
            <div class="detail-item">
              <div class="detail-label">已用容量</div>
              <div class="detail-value">{{ sysdata?.useRam }}</div>
            </div>
          </ElCol>
        </ElRow>
      </ElCard>
    </div>

    <div class="page-section">
      <ElCard header="磁盘信息" class="info-card">
        <ElSkeleton v-if="isLoading" :rows="3" animated />
        <ElRow v-else :gutter="20" class="disk-container">
          <ElCol
            v-for="(item, index) in sysdata?.diskInfo"
            :key="index"
            :xs="24"
            :sm="12"
            :md="8"
            :lg="6"
            class="disk-item"
          >
            <ElCard shadow="hover" class="disk-card">
              <div class="disk-header">
                <div class="disk-name">{{ item.diskName }}</div>
                <div class="disk-type">{{ item.typeName }}</div>
              </div>

              <div class="disk-progress">
                <ElProgress
                  type="dashboard"
                  :percentage="item.availablePercent || 0"
                  :color="getDiskColor(item.availablePercent || 0)"
                  :width="80"
                />
              </div>

              <div class="disk-details">
                <div class="disk-space">已用: {{ item.used }} GB</div>
                <div class="disk-space">总量: {{ item.totalSize }} GB</div>
                <div class="disk-free">剩余: {{ item.availableFreeSpace }} GB</div>
              </div>
            </ElCard>
          </ElCol>
        </ElRow>
      </ElCard>
    </div>
  </div>
</template>

<style scoped>
.system-status-page {
  padding: 20px;
  background-color: #f5f7fa;
}

.page-section {
  margin-bottom: 20px;
}

.info-card {
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
  border: none;
  margin-bottom: 20px;
}

.info-card :deep(.el-card__header) {
  font-weight: bold;
  background-color: #fafafa;
  border-bottom: 1px solid #ebeef5;
  font-size: 16px;
}

.progress-container {
  padding: 20px 0;
}

.progress-item {
  margin-bottom: 20px;
}

.metric-card {
  text-align: center;
  padding: 20px;
  height: 100%;
}

.metric-header {
  margin-bottom: 15px;
}

.metric-title {
  font-size: 14px;
  color: #606266;
  margin-bottom: 5px;
}

.metric-value {
  font-size: 20px;
  font-weight: bold;
  color: #303133;
}

.detail-container {
  padding: 20px 0;
  border-top: 1px solid #ebeef5;
}

.detail-item {
  text-align: center;
  padding: 10px;
  background: #fafafa;
  border-radius: 4px;
  margin: 5px;
}

.detail-label {
  font-size: 12px;
  color: #909399;
  margin-bottom: 5px;
}

.detail-value {
  font-size: 14px;
  font-weight: bold;
  color: #303133;
}

.disk-container {
  padding: 20px 0;
}

.disk-item {
  margin-bottom: 20px;
}

.disk-card {
  text-align: center;
  padding: 15px;
  height: 100%;
}

.disk-header {
  margin-bottom: 10px;
}

.disk-name {
  font-weight: bold;
  font-size: 16px;
  color: #303133;
}

.disk-type {
  font-size: 12px;
  color: #909399;
}

.disk-progress {
  margin: 15px 0;
}

.disk-details {
  font-size: 12px;
  color: #606266;
}

.disk-space,
.disk-free {
  margin: 3px 0;
}

.text-primary {
  color: var(--el-color-primary);
}

/* 响应式调整 */
@media (max-width: 768px) {
  .system-status-page {
    padding: 10px;
  }

  .metric-card,
  .disk-card {
    padding: 10px;
  }

  .metric-value {
    font-size: 16px;
  }

  .disk-progress {
    margin: 10px 0;
  }
}
</style>
