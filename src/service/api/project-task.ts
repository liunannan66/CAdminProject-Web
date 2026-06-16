import { request } from '../request';

export interface ProjectTaskDto {
  id: number;
  projectId: number;
  projectNo: string;
  projectName: string;
  sortNo: number;
  taskName: string;
  description?: string;
  startDate: string;
  endDate: string;
  assigneeUserId: number;
  assigneeName: string;
  priority: string;
  progress: number;
  status: string;
  remark?: string;
  delayDays: number;
}

export interface ProjectTaskPageParams {
  pageNo: number;
  pageSize: number;
  projectId: number;
  keyWord?: string;
  status?: string;
}

export interface ProjectTaskMyPageParams {
  pageNo: number;
  pageSize: number;
  keyWord?: string;
  status?: string;
}

export interface ProjectTaskPageResult {
  pageNo: number;
  pageSize: number;
  totalPage: number;
  totalRows: number;
  records: ProjectTaskDto[];
}

export interface ProjectTaskSaveDto {
  id?: number;
  projectId: number;
  sortNo: number;
  taskName: string;
  description?: string;
  startDate: string;
  endDate: string;
  assigneeUserId: number;
  priority: string;
  progress: number;
  status: string;
  remark?: string;
}

export interface ProjectTaskProgressDto {
  id: number;
  progress: number;
  status: string;
  remark?: string;
}

export function getProjectTaskPage(params: ProjectTaskPageParams) {
  return request<ProjectTaskPageResult>({
    url: '/ProjectTask/PageList',
    method: 'get',
    params
  });
}

export function getMyProjectTaskPage(params: ProjectTaskMyPageParams) {
  return request<ProjectTaskPageResult>({
    url: '/ProjectTask/MyPageList',
    method: 'get',
    params
  });
}

export function getProjectTaskDetail(id: number) {
  return request<ProjectTaskDto>({
    url: `/ProjectTask/Detail/${id}`,
    method: 'get'
  });
}

export function addProjectTask(data: ProjectTaskSaveDto) {
  return request<boolean>({
    url: '/ProjectTask/Add',
    method: 'post',
    data
  });
}

export function updateProjectTask(data: ProjectTaskSaveDto) {
  return request<boolean>({
    url: '/ProjectTask/Update',
    method: 'post',
    data
  });
}

export function updateProjectTaskProgress(data: ProjectTaskProgressDto) {
  return request<boolean>({
    url: '/ProjectTask/UpdateProgress',
    method: 'post',
    data
  });
}

export function deleteProjectTask(id: number) {
  return request<boolean>({
    url: `/ProjectTask/Delete/${id}`,
    method: 'get'
  });
}
