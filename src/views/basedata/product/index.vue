<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';
import { PRODUCT_AUTH } from '@/constants/basedata-product';
import { useAuth } from '@/hooks/business/auth';
import { useAuthStore } from '@/store/modules/auth';
import { addProduct, deleteProduct, getProductPage, updateProduct } from '@/service/api/basedata';
import ProductOperateDialog from './modules/product-operate-dialog.vue';

defineOptions({ name: 'BasedataProduct' });

type ProductCategory = Api.Basedata.ProductCategory;
type ProductRecord = Api.Basedata.ProductRecord;

interface SearchParams {
  pageNo: number;
  pageSize: number;
  keyword: string;
  category: ProductCategory | '';
  status: 0 | 1 | '';
}

const CATEGORY_MAP: Record<ProductCategory, string> = {
  main: '主产品',
  third: '第三方产品'
};

const { hasAuth } = useAuth();
const authStore = useAuthStore();

function checkProductAuth(code: string) {
  const configured = authStore.userInfo.buttons.some(item => item.startsWith('api:Product:'));
  if (!configured) return true;
  return hasAuth(code);
}

const canAdd = computed(() => checkProductAuth(PRODUCT_AUTH.add));
const canUpdate = computed(() => checkProductAuth(PRODUCT_AUTH.update));
const canDelete = computed(() => checkProductAuth(PRODUCT_AUTH.delete));

const loading = ref(false);
const productList = ref<Api.Common.PaginatingQueryRecord<ProductRecord>>();

const searchParams = reactive<SearchParams>({
  pageNo: 1,
  pageSize: 10,
  keyword: '',
  category: '',
  status: ''
});

const showDialog = ref(false);
const dialogTitle = ref('新增产品');
const editingProduct = ref<ProductRecord | null>(null);

const categoryTagType = computed(() => (category: ProductCategory) => (category === 'main' ? 'primary' : 'warning'));
const statusTagType = computed(() => (status: 0 | 1) => (status === 1 ? 'success' : 'danger'));
const statusText = computed(() => (status: 0 | 1) => (status === 1 ? '启用' : '禁用'));

const tableData = computed(() => productList.value?.records ?? []);
const totalRows = computed(() => productList.value?.totalRows ?? 0);

async function fetchProductList() {
  if (loading.value) return;
  loading.value = true;
  try {
    const response = await getProductPage({
      pageNo: searchParams.pageNo,
      pageSize: searchParams.pageSize,
      keyWord: searchParams.keyword.trim() || undefined,
      category: searchParams.category || undefined,
      status: searchParams.status === '' ? undefined : searchParams.status
    });
    productList.value = response;
  } catch {
    ElMessage.error('获取产品列表失败');
  } finally {
    loading.value = false;
  }
}

function resetSearch() {
  searchParams.keyword = '';
  searchParams.category = '';
  searchParams.status = '';
  searchParams.pageNo = 1;
  fetchProductList();
}

function search() {
  searchParams.pageNo = 1;
  fetchProductList();
}

function handleSizeChange(val: number) {
  searchParams.pageSize = val;
  searchParams.pageNo = 1;
  fetchProductList();
}

function handleCurrentChange(val: number) {
  searchParams.pageNo = val;
  fetchProductList();
}

function openAddDialog() {
  if (!canAdd.value) {
    ElMessage.warning('暂无新增权限');
    return;
  }
  dialogTitle.value = '新增产品';
  editingProduct.value = null;
  showDialog.value = true;
}

function openEditDialog(row: ProductRecord) {
  if (!canUpdate.value) {
    ElMessage.warning('暂无编辑权限');
    return;
  }
  dialogTitle.value = '编辑产品';
  editingProduct.value = { ...row };
  showDialog.value = true;
}

async function deleteRecord(row: ProductRecord) {
  if (!canDelete.value) {
    ElMessage.warning('暂无删除权限');
    return;
  }
  try {
    await ElMessageBox.confirm(`确定删除产品「${row.name} ${row.version}」吗？`, '警告', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    });
    await deleteProduct(row.id);
    ElMessage.success('删除成功');
    await fetchProductList();
  } catch {
    // 用户取消或接口失败
  }
}

async function handleSubmitted(form: Omit<ProductRecord, 'id'>) {
  try {
    if (editingProduct.value) {
      await updateProduct({
        ...editingProduct.value,
        ...form
      });
      ElMessage.success('更新成功');
    } else {
      await addProduct(form);
      ElMessage.success('新增成功');
    }
    await fetchProductList();
  } catch {
    // request 层已提示
  }
}

onMounted(() => {
  fetchProductList();
});
</script>

<template>
  <div class="min-h-500px flex-col-stretch gap-16px overflow-hidden lt-sm:overflow-auto">
    <ElSpace style="display: flex; flex-direction: column; align-items: stretch" :size="16" class="page-container">
      <ElCard class="card-wrapper">
        <ElCollapse>
          <ElCollapseItem title="搜索" name="product-search">
            <ElForm :model="searchParams" label-position="right" :label-width="80">
              <ElRow :gutter="24">
                <ElCol :lg="6" :md="8" :sm="12">
                  <ElFormItem label="关键字" prop="keyword">
                    <ElInput v-model="searchParams.keyword" placeholder="产品名称 / 版本 / 描述" clearable />
                  </ElFormItem>
                </ElCol>
                <ElCol :lg="6" :md="8" :sm="12">
                  <ElFormItem label="产品类别" prop="category">
                    <ElSelect v-model="searchParams.category" placeholder="全部类别" clearable class="w-full">
                      <ElOption label="主产品" value="main" />
                      <ElOption label="第三方产品" value="third" />
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
            <p>产品</p>
            <ElSpace>
              <ElButton v-if="canAdd" type="primary" @click="openAddDialog">
                <template #icon>
                  <icon-ic-round-plus class="text-icon" />
                </template>
                {{ $t('common.add') }}
              </ElButton>
              <ElButton type="primary" @click="fetchProductList">
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
          <ElTableColumn prop="category" label="产品类别" width="110" align="center">
            <template #default="{ row }">
              <ElTag :type="categoryTagType(row.category)" size="small" round>
                {{ CATEGORY_MAP[row.category] }}
              </ElTag>
            </template>
          </ElTableColumn>
          <ElTableColumn prop="name" label="产品名称" min-width="140" show-overflow-tooltip />
          <ElTableColumn prop="version" label="产品版本" width="110" show-overflow-tooltip />
          <ElTableColumn prop="description" label="描述" min-width="200" show-overflow-tooltip />
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

    <ProductOperateDialog
      v-model:visible="showDialog"
      :title="dialogTitle"
      :product="editingProduct"
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
