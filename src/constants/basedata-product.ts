/** 产品管理按钮权限码（与后端 api:Product:{Action} 一致） */
export const PRODUCT_AUTH = {
  page: 'api:Product:PageList',
  listEnabled: 'api:Product:ListEnabled',
  add: 'api:Product:Add',
  update: 'api:Product:Update',
  delete: 'api:Product:Delete'
} as const;
