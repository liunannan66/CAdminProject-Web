/** 合同管理按钮权限码（与后端 Permission / doc/sql 一致） */
export const CONTRACT_AUTH = {
  page: 'api:Contract:PageList',
  add: 'api:Contract:Add',
  update: 'api:Contract:Update',
  delete: 'api:Contract:Delete',
  projectInit: 'api:Contract:ProjectInit',
  submitApproval: 'api:Contract:SubmitApproval'
} as const;

/** 合同类型 */
export type ContractType = 'self' | 'outsource';

export const CONTRACT_TYPE_OPTIONS: { label: string; value: ContractType }[] = [
  { label: '自建', value: 'self' },
  { label: '外包', value: 'outsource' }
];

export const CONTRACT_TYPE_LABEL: Record<ContractType, string> = {
  self: '自建',
  outsource: '外包'
};

/** 合同状态（详情页演示） */
export type ContractStatus = 'draft' | 'approving' | 'approved' | 'rejected';

export const CONTRACT_STATUS_LABEL: Record<ContractStatus, string> = {
  draft: '草稿',
  approving: '审批中',
  approved: '已审批',
  rejected: '已驳回'
};

export const CONTRACT_STATUS_TAG_TYPE: Record<ContractStatus, 'info' | 'primary' | 'success' | 'danger'> = {
  draft: 'info',
  approving: 'primary',
  approved: 'success',
  rejected: 'danger'
};

/** 审批流程（前端演示） */
export const CONTRACT_APPROVAL_FLOW_OPTIONS = [
  { label: '标准合同审批流程', value: 'standard' },
  { label: '大额合同审批流程', value: 'large_amount' },
  { label: '外包合同专项流程', value: 'outsource_special' }
] as const;

/** 销售负责人（演示） */
export const CONTRACT_SALES_OWNER_OPTIONS = ['张三', '李四', '王五', '赵六'] as const;

/** 可选产品（与产品管理 mock 对齐，供合同子表选择） */
export const MOCK_CONTRACT_PRODUCTS = [
  { id: 1001, name: '金蝶云·星空', category: 'main', categoryLabel: '主产品', version: '旗舰版' },
  { id: 1002, name: '金蝶云·星空', category: 'main', categoryLabel: '主产品', version: '生鲜版' },
  { id: 1003, name: '金蝶 KIS', category: 'main', categoryLabel: '主产品', version: '专业版' },
  { id: 1004, name: '第三方 BI 报表', category: 'third', categoryLabel: '第三方产品', version: 'V3.2' },
  { id: 1006, name: '金蝶云·星瀚', category: 'main', categoryLabel: '主产品', version: '企业版' }
] as const;
