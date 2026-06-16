export const PROJECT_TASK_AUTH = {
  page: 'api:ProjectTask:PageList',
  myPage: 'api:ProjectTask:MyPageList',
  detail: 'api:ProjectTask:Detail',
  add: 'api:ProjectTask:Add',
  update: 'api:ProjectTask:Update',
  updateProgress: 'api:ProjectTask:UpdateProgress',
  delete: 'api:ProjectTask:Delete'
} as const;

export type ProjectTaskStatus = 'pending' | 'in_progress' | 'completed' | 'overdue';

export type ProjectTaskPriority = 'low' | 'normal' | 'high';

export const PROJECT_TASK_STATUS_LABEL: Record<ProjectTaskStatus, string> = {
  pending: '待开始',
  in_progress: '进行中',
  completed: '已完成',
  overdue: '逾期'
};

export const PROJECT_TASK_STATUS_TAG_TYPE: Record<
  ProjectTaskStatus,
  'info' | 'primary' | 'success' | 'danger' | 'warning'
> = {
  pending: 'info',
  in_progress: 'primary',
  completed: 'success',
  overdue: 'danger'
};

export const PROJECT_TASK_STATUS_OPTIONS: { label: string; value: ProjectTaskStatus }[] = [
  { label: PROJECT_TASK_STATUS_LABEL.pending, value: 'pending' },
  { label: PROJECT_TASK_STATUS_LABEL.in_progress, value: 'in_progress' },
  { label: PROJECT_TASK_STATUS_LABEL.completed, value: 'completed' },
  { label: PROJECT_TASK_STATUS_LABEL.overdue, value: 'overdue' }
];

export const PROJECT_TASK_PRIORITY_LABEL: Record<ProjectTaskPriority, string> = {
  low: '低',
  normal: '中',
  high: '高'
};

export const PROJECT_TASK_PRIORITY_OPTIONS: { label: string; value: ProjectTaskPriority }[] = [
  { label: PROJECT_TASK_PRIORITY_LABEL.low, value: 'low' },
  { label: PROJECT_TASK_PRIORITY_LABEL.normal, value: 'normal' },
  { label: PROJECT_TASK_PRIORITY_LABEL.high, value: 'high' }
];
