import axios from 'axios';
import { request } from '../request';
import { localStg } from '@/utils/storage';
import { resolveServiceUrl } from '@/utils/service';
import type { FileBizType } from '@/constants/file';

export interface FileUploadResult {
  id: number;
  fileName: string;
  fileSize: number;
  contentType?: string;
}

/** 上传文件 */
export function uploadFile(file: File, bizType: FileBizType) {
  const formData = new FormData();
  formData.append('file', file);
  formData.append('bizType', bizType);
  return request<FileUploadResult>({
    url: '/File/Upload',
    method: 'post',
    data: formData,
    timeout: 120000
  });
}

/** 删除未绑定附件 */
export function deleteFile(id: number) {
  return request<boolean>({
    url: `/File/Delete/${id}`,
    method: 'get'
  });
}

async function parseBlobErrorMessage(blob: Blob) {
  try {
    const text = await blob.text();
    const json = JSON.parse(text) as { message?: string; body?: unknown };
    if (typeof json.body === 'string' && json.body) return json.body;
    if (json.message) return json.message;
  } catch {
    /* ignore */
  }
  return '下载失败';
}

function triggerBrowserDownload(blob: Blob, fileName: string) {
  const url = URL.createObjectURL(blob);
  const anchor = document.createElement('a');
  anchor.href = url;
  anchor.download = fileName;
  anchor.click();
  URL.revokeObjectURL(url);
}

/** 下载附件（带鉴权，不走 JSON 包装） */
export async function downloadFile(id: number, fileName: string) {
  const token = localStg.get('token');
  const url = resolveServiceUrl(import.meta.env, `/File/Download/${id}`);
  const response = await axios.get<Blob>(url, {
    responseType: 'blob',
    headers: token ? { Authorization: `Bearer ${token}` } : {},
    validateStatus: () => true
  });

  const blob = response.data;
  const contentType = String(response.headers['content-type'] ?? blob.type ?? '');

  if (contentType.includes('application/json')) {
    throw new Error(await parseBlobErrorMessage(blob));
  }

  if (response.status < 200 || response.status >= 300) {
    throw new Error(await parseBlobErrorMessage(blob));
  }

  triggerBrowserDownload(blob, fileName);
}

/** 通过 API 路径下载二进制文件（POST/GET，带鉴权） */
export async function downloadBlobFile(path: string, fileName: string, method: 'get' | 'post' = 'get') {
  const token = localStg.get('token');
  const url = resolveServiceUrl(import.meta.env, path);
  const response = await axios.request<Blob>({
    url,
    method,
    responseType: 'blob',
    headers: token ? { Authorization: `Bearer ${token}` } : {},
    validateStatus: () => true
  });

  const blob = response.data;
  const contentType = String(response.headers['content-type'] ?? blob.type ?? '');

  if (contentType.includes('application/json')) {
    throw new Error(await parseBlobErrorMessage(blob));
  }

  if (response.status < 200 || response.status >= 300) {
    throw new Error(await parseBlobErrorMessage(blob));
  }

  triggerBrowserDownload(blob, fileName);
}
