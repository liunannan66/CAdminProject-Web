/** 文件服务按钮权限码 */
export const FILE_AUTH = {
  upload: 'api:File:Upload',
  download: 'api:File:Download',
  delete: 'api:File:Delete'
} as const;

/** 上传业务类型 */
export type FileBizType =
  | 'contract'
  | 'requirement'
  | 'project_init_sow_ref'
  | 'project_init_org_structure'
  | 'richtext';
