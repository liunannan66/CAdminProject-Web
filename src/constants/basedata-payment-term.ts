/** 付款条件按钮权限码（与后端 Permission 配置一致，见 doc/sql） */
export const PAYMENT_TERM_AUTH = {
  page: 'api:PaymentTerm:PageList',
  listEnabled: 'api:PaymentTerm:ListEnabled',
  add: 'api:PaymentTerm:Add',
  update: 'api:PaymentTerm:Update',
  delete: 'api:PaymentTerm:Delete'
} as const;

/** 结算方式选项 */
export const PAYMENT_TERM_SETTLEMENT_OPTIONS = [
  { label: '预付款', value: 'prepay' },
  { label: '进度款', value: 'progress' },
  { label: '到货款', value: 'delivery' },
  { label: '验收款', value: 'acceptance' },
  { label: '质保金', value: 'warranty' },
  { label: '月结', value: 'monthly' }
] as const;

export type PaymentSettlementMethod = (typeof PAYMENT_TERM_SETTLEMENT_OPTIONS)[number]['value'];

export const SETTLEMENT_METHOD_LABEL: Record<PaymentSettlementMethod, string> = {
  prepay: '预付款',
  progress: '进度款',
  delivery: '到货款',
  acceptance: '验收款',
  warranty: '质保金',
  monthly: '月结'
};
