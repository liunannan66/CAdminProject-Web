import { computed, effectScope, onScopeDispose, reactive, shallowRef, watch } from 'vue';
import type { Ref } from 'vue';
import type { PaginationEmits, PaginationProps } from 'element-plus';
import { useBoolean, useTable } from '@sa/hooks';
import type { PaginationData, TableColumnCheck, UseTableOptions } from '@sa/hooks';
import type { FlatResponseData } from '@sa/axios';
import { jsonClone } from '@sa/utils';
import { useAppStore } from '@/store/modules/app';
import { $t } from '@/locales';

type RemoveReadonly<T> = {
  -readonly [key in keyof T]: T[key];
};

export type UseUITableOptions<ResponseData, ApiData, Pagination extends boolean> = Omit<
  UseTableOptions<ResponseData, ApiData, UI.TableColumn<ApiData>, Pagination>,
  'pagination' | 'getColumnChecks' | 'getColumns'
> & {
  /**
   * get column visible
   *
   * @default true
   *
   * @param column
   * @returns true if the column is visible, false otherwise
   */
  getColumnVisible?: (column: UI.TableColumn<ApiData>) => boolean;
};

const SELECTION_KEY = '__selection__';

const EXPAND_KEY = '__expand__';

const INDEX_KEY = '__index__';

export function useUITable<ResponseData, ApiData>(options: UseUITableOptions<ResponseData, ApiData, false>) {
  const scope = effectScope();
  const appStore = useAppStore();

  const result = useTable<ResponseData, ApiData, UI.TableColumn<ApiData>, false>({
    ...options,
    getColumnChecks: cols => getColumnChecks(cols, options.getColumnVisible),
    getColumns
  });

  // calculate the total width of the table this is used for horizontal scrolling
  const scrollX = computed(() => {
    return result.columns.value.reduce((acc, column) => {
      return acc + Number(column.width ?? column.minWidth ?? 120);
    }, 0);
  });

  scope.run(() => {
    watch(
      () => appStore.locale,
      () => {
        result.reloadColumns();
      }
    );
  });

  onScopeDispose(() => {
    scope.stop();
  });

  return {
    ...result,
    scrollX
  };
}

type PaginationParams = Pick<PaginationProps, 'currentPage' | 'pageSize'>;

type UseUIPaginatedTableOptions<ResponseData, ApiData> = UseUITableOptions<ResponseData, ApiData, true> & {
  paginationProps?: Partial<Omit<PaginationProps, 'total'>>;
  /**
   * whether to show the total count of the table
   *
   * @default true
   */
  showTotal?: boolean;
  onPaginationParamsChange?: (params: PaginationParams) => void | Promise<void>;
};

export function useUIPaginatedTable<ResponseData, ApiData>(options: UseUIPaginatedTableOptions<ResponseData, ApiData>) {
  const scope = effectScope();
  const appStore = useAppStore();

  const isMobile = computed(() => appStore.isMobile);

  const pagination: Partial<RemoveReadonly<PaginationProps & PaginationEmits>> = reactive({
    currentPage: 1,
    pageSize: 10,
    total: 0,
    pageSizes: [10, 15, 20, 25, 30],
    'current-change': (page: number) => {
      pagination.currentPage = page;

      return true;
    },
    'size-change': (pageSize: number) => {
      pagination.currentPage = 1;
      pagination.pageSize = pageSize;

      return true;
    },
    ...options.paginationProps
  }) as PaginationProps;

  // this is for mobile, if the system does not support mobile, you can use `pagination` directly
  const mobilePagination = computed(() => {
    const p: Partial<RemoveReadonly<PaginationProps & PaginationEmits>> = {
      ...pagination,
      pagerCount: isMobile.value ? 3 : 9
    };

    return p;
  });

  const paginationParams = computed(() => {
    const { currentPage, pageSize } = pagination;

    return {
      currentPage,
      pageSize
    };
  });

  const result = useTable<ResponseData, ApiData, UI.TableColumn<ApiData>, true>({
    ...options,
    pagination: true,
    getColumnChecks: cols => getColumnChecks(cols, options.getColumnVisible),
    getColumns,
    onFetched: data => {
      pagination.total = data.total;
    }
  });

  async function getDataByPage(page: number = 1) {
    if (page !== pagination.currentPage) {
      pagination.currentPage = page;

      return;
    }

    await result.getData();
  }

  scope.run(() => {
    watch(
      () => appStore.locale,
      () => {
        result.reloadColumns();
      }
    );

    watch(paginationParams, async newVal => {
      await options.onPaginationParamsChange?.(newVal);

      await result.getData();
    });
  });

  onScopeDispose(() => {
    scope.stop();
  });

  return {
    ...result,
    getDataByPage,
    pagination,
    mobilePagination
  };
}

export function useTableOperate<TableData>(
  data: Ref<TableData[]>,
  idKey: keyof TableData,
  getData: () => Promise<void>
) {
  const { bool: drawerVisible, setTrue: openDrawer, setFalse: closeDrawer } = useBoolean();

  const operateType = shallowRef<UI.TableOperateType>('add');

  function handleAdd() {
    operateType.value = 'add';
    openDrawer();
  }

  /** the editing row data */
  const editingData = shallowRef<TableData | null>(null);

  function handleEdit(id: TableData[keyof TableData]) {
    operateType.value = 'edit';
    const findItem = data.value.find(item => item[idKey] === id) || null;
    editingData.value = jsonClone(findItem);

    openDrawer();
  }

  /** the checked row keys of table */
  const checkedRowKeys = shallowRef<string[]>([]);

  /** the hook after the batch delete operation is completed */
  async function onBatchDeleted() {
    window.$message?.success($t('common.deleteSuccess'));

    checkedRowKeys.value = [];

    await getData();
  }

  /** the hook after the delete operation is completed */
  async function onDeleted() {
    window.$message?.success($t('common.deleteSuccess'));

    await getData();
  }

  return {
    drawerVisible,
    openDrawer,
    closeDrawer,
    operateType,
    handleAdd,
    editingData,
    handleEdit,
    checkedRowKeys,
    onBatchDeleted,
    onDeleted
  };
}

export function defaultTransform<ApiData>(
  response: FlatResponseData<any, Api.Common.PaginatingQueryRecord<ApiData>>
): PaginationData<ApiData> {
  const { data, error } = response;

  if (!error) {
    const { records, current, size, total } = data;

    return {
      data: records,
      pageNum: current,
      pageSize: size,
      total
    };
  }

  return {
    data: [],
    pageNum: 1,
    pageSize: 10,
    total: 0
  };
}

function getColumnChecks<Column extends UI.TableColumn<any>>(
  cols: Column[],
  getColumnVisible?: (column: Column) => boolean
) {
  const checks: TableColumnCheck[] = [];

  cols.forEach(column => {
    if (column.type === 'selection') {
      checks.push({
        prop: SELECTION_KEY,
        label: $t('common.check'),
        checked: true,
        visible: getColumnVisible?.(column) ?? false
      });
    } else if (column.type === 'expand') {
      checks.push({
        prop: EXPAND_KEY,
        label: $t('common.expandColumn'),
        checked: true,
        visible: getColumnVisible?.(column) ?? false
      });
    } else if (column.type === 'index') {
      checks.push({
        prop: INDEX_KEY,
        label: $t('common.index'),
        checked: true,
        visible: getColumnVisible?.(column) ?? false
      });
    } else {
      checks.push({
        prop: column.prop as string,
        label: column.label as string,
        checked: true,
        visible: getColumnVisible?.(column) ?? true
      });
    }
  });

  return checks;
}

function getColumns<Column extends UI.TableColumn<any>>(cols: Column[], checks: TableColumnCheck[]) {
  const columnMap = new Map<string, Column>();

  cols.forEach(column => {
    if (column.type === 'selection') {
      columnMap.set(SELECTION_KEY, column);
    } else if (column.type === 'expand') {
      columnMap.set(EXPAND_KEY, column);
    } else if (column.type === 'index') {
      columnMap.set(INDEX_KEY, column);
    } else {
      columnMap.set(column.prop as string, column);
    }
  });

  const filteredColumns = checks.filter(item => item.checked).map(check => columnMap.get(check.prop) as Column);

  return filteredColumns;
}

export function usemyTable<A extends NaiveUI.TableApiFn>(config: NaiveUI.NaiveTableConfig<A>) {
  const scope = effectScope();
  const appStore = useAppStore();

  const { apiFn, apiParams, immediate } = config;

  const SELECTION_KEY = '__selection__';

  const {
    loading,
    empty,
    data,
    columns,
    columnChecks,
    reloadColumns,
    getData,
    searchParams,
    updateSearchParams,
    resetSearchParams
  } = useHookTable<A, GetTableData<A>, TableColumn<NaiveUI.TableDataWithIndex<GetTableData<A>>>>({
    apiFn,
    apiParams,
    columns: config.columns,
    transformer: res => {
      return {
        data: res.records,
        pageNum: res.pageNo,
        pageSize: res.pageSize,
        total: res.totalRows
      };
    },
    getColumnChecks: cols => {
      const checks: NaiveUI.TableColumnCheck[] = [];

      cols.forEach(column => {
        if (isTableColumnHasKey(column)) {
          checks.push({
            key: column.key as string,
            title: column.title as string,
            checked: true
          });
        } else if (column.type === 'selection') {
          checks.push({
            key: SELECTION_KEY,
            title: $t('common.check'),
            checked: true
          });
        }
      });

      return checks;
    },
    getColumns: (cols, checks) => {
      const columnMap = new Map<string, TableColumn<GetTableData<A>>>();

      cols.forEach(column => {
        if (isTableColumnHasKey(column)) {
          columnMap.set(column.key as string, column);
        } else if (column.type === 'selection') {
          columnMap.set(SELECTION_KEY, column);
        }
      });

      const filteredColumns = checks
        .filter(item => item.checked)
        .map(check => columnMap.get(check.key) as TableColumn<GetTableData<A>>);

      return filteredColumns;
    },
    onFetched: async transformed => {
      const { pageNum, pageSize, total } = transformed;

      updatePagination({
        page: pageNum,
        pageSize,
        itemCount: total
      });
    },
    immediate
  });

  const pagination: PaginationProps = reactive({
    page: 1,
    pageSize: 10,
    showSizePicker: true,
    pageSizes: [10, 15, 20, 25, 30],
    onUpdatePage: async (page: number) => {
      pagination.page = page;

      updateSearchParams({
        pageNo: page,
        pageSize: pagination.pageSize!
      });

      getData();
    },
    onUpdatePageSize: async (pageSize: number) => {
      pagination.pageSize = pageSize;
      pagination.page = 1;

      updateSearchParams({
        pageNo: pagination.page,
        pageSize
      });

      getData();
    }
  });

  // this is for mobile, if the system does not support mobile, you can use `pagination` directly
  const mobilePagination = computed(() => {
    const p: PaginationProps = {
      ...pagination,
      pageSlot: appStore.isMobile ? 3 : 9
    };

    return p;
  });

  function updatePagination(update: Partial<PaginationProps>) {
    Object.assign(pagination, update);
  }

  scope.run(() => {
    watch(
      () => appStore.locale,
      () => {
        reloadColumns();
      }
    );
  });

  onScopeDispose(() => {
    scope.stop();
  });

  return {
    loading,
    empty,
    data,
    columns,
    columnChecks,
    reloadColumns,
    pagination,
    mobilePagination,
    updatePagination,
    getData,
    searchParams,
    updateSearchParams,
    resetSearchParams
  };
}
