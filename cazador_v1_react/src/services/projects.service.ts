import { api } from './api.client';
import type { Pagination } from '../config/api';

export type ProjectApi = {
  id: number;
  name?: string;
  title?: string;
  location?: string;
  district?: string;
  province?: string;
  region?: string;
  units_count?: number;
  progress?: number;
  status?: string;
  stage?: string;
  [key: string]: unknown;
};

export type ProjectsListResponse = {
  projects: ProjectApi[];
  pagination?: Pagination;
};

export async function getProjects(params?: {
  page?: number;
  per_page?: number;
  search?: string;
  status?: string;
}): Promise<ProjectApi[]> {
  const q = new URLSearchParams();
  if (params?.page) q.set('page', String(params.page));
  if (params?.per_page) q.set('per_page', String(params.per_page ?? 50));
  if (params?.search) q.set('search', params.search);
  if (params?.status) q.set('status', params.status);
  const path = `/projects${q.toString() ? `?${q.toString()}` : ''}`;
  const res = await api.get<ProjectsListResponse>(path);
  if (!res.success || !res.data) return [];
  return res.data.projects || [];
}

export type ProjectUnit = { id: number; name?: string; code?: string; [key: string]: unknown };

export async function getProjectUnits(projectId: number, params?: { per_page?: number }): Promise<ProjectUnit[]> {
  const q = params?.per_page ? `?per_page=${params.per_page}` : '';
  const res = await api.get<{ units: ProjectUnit[] }>(`/projects/${projectId}/units${q}`);
  if (!res.success || !res.data) return [];
  return (res.data as { units?: ProjectUnit[] }).units || [];
}
