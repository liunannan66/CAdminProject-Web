/** 项目立项按钮权限码（前端演示，待后端联调） */
export const PROJECT_INIT_AUTH = {
  page: 'api:ProjectInit:PageList',
  detail: 'api:ProjectInit:Detail',
  add: 'api:ProjectInit:Add',
  update: 'api:ProjectInit:Update',
  delete: 'api:ProjectInit:Delete',
  generateSow: 'api:ProjectInit:GenerateSow'
} as const;

/** 项目类型：自建 / 对接（由合同类型映射） */
export type ProjectInitType = 'self' | 'integration';

export const PROJECT_INIT_TYPE_OPTIONS: { label: string; value: ProjectInitType }[] = [
  { label: '自建', value: 'self' },
  { label: '对接', value: 'integration' }
];

export const PROJECT_INIT_TYPE_LABEL: Record<ProjectInitType, string> = {
  self: '自建',
  integration: '对接'
};

/** 立项状态 */
export type ProjectInitStatus = 'draft' | 'approving' | 'approved' | 'rejected';

export const PROJECT_INIT_STATUS_LABEL: Record<ProjectInitStatus, string> = {
  draft: '草稿',
  approving: '审批中',
  approved: '已立项',
  rejected: '已驳回'
};

export const PROJECT_INIT_STATUS_TAG_TYPE: Record<
  ProjectInitStatus,
  'info' | 'primary' | 'success' | 'danger'
> = {
  draft: 'info',
  approving: 'primary',
  approved: 'success',
  rejected: 'danger'
};

export const PROJECT_INIT_STATUS_OPTIONS: { label: string; value: ProjectInitStatus }[] = [
  { label: PROJECT_INIT_STATUS_LABEL.draft, value: 'draft' },
  { label: PROJECT_INIT_STATUS_LABEL.approving, value: 'approving' },
  { label: PROJECT_INIT_STATUS_LABEL.approved, value: 'approved' },
  { label: PROJECT_INIT_STATUS_LABEL.rejected, value: 'rejected' }
];

/** 合同立项来源 sessionStorage 键 */
export const PROJECT_INIT_SOURCE_KEY = 'contract_project_init_source';
