import { api } from './api.client';
import type { Pagination } from '../config/api';

export type DateroApi = {
  id: number;
  name: string;
  email: string;
  phone: string;
  dni?: string;
  is_active?: boolean;
  ocupacion?: string | null;
  city?: string | null;
  [key: string]: unknown;
};

export type DaterosListResponse = {
  dateros?: DateroApi[];
  users?: DateroApi[];
  pagination?: Pagination;
};

export type DateroCreatePayload = {
  name: string;
  email: string;
  phone: string;
  dni: string;
  pin: string;
  ocupacion?: string;
  banco?: string;
  cuenta_bancaria?: string;
  cci_bancaria?: string;
};

export async function getDateros(params?: {
  page?: number;
  per_page?: number;
  search?: string;
  is_active?: boolean;
}): Promise<DateroApi[]> {
  const q = new URLSearchParams();
  if (params?.page) q.set('page', String(params.page));
  if (params?.per_page) q.set('per_page', String(params.per_page ?? 50));
  if (params?.search) q.set('search', params.search);
  if (params?.is_active !== undefined) q.set('is_active', params.is_active ? '1' : '0');
  const path = `/dateros${q.toString() ? `?${q.toString()}` : ''}`;
  const res = await api.get<DaterosListResponse>(path);
  if (!res.success || !res.data) return [];
  const list = (res.data as { dateros?: DateroApi[] }).dateros ?? (res.data as { users?: DateroApi[] }).users ?? [];
  return Array.isArray(list) ? list : [];
}

export async function createDatero(payload: DateroCreatePayload): Promise<DateroApi> {
  const res = await api.post<{ datero: DateroApi; user?: DateroApi }>('/dateros', payload);
  if (!res.success || !res.data) throw new Error(res.message || 'Error al crear datero');
  const data = res.data as { datero?: DateroApi; user?: DateroApi };
  return data.datero ?? data.user ?? (res.data as DateroApi);
}
