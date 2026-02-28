import { api } from './api.client';
import type { Pagination } from '../config/api';

export type ClientApi = {
  id: number;
  name: string;
  phone: string;
  document_type?: string | null;
  document_number?: string | null;
  address?: string | null;
  city_id: number;
  birth_date: string;
  client_type: string;
  source: string;
  status: string;
  create_type?: string;
  create_mode?: string;
  score: number;
  notes?: string | null;
  created_at: string;
  updated_at: string;
  city?: { id: number; name: string };
  assigned_advisor?: { id: number; name: string; email: string };
};

export type ClientsListResponse = {
  clients: ClientApi[];
  pagination: Pagination;
};

export type ClientCreatePayload = {
  name: string;
  phone: string;
  document_type?: string;
  document_number?: string;
  address?: string | null;
  city_id: number;
  birth_date: string;
  client_type: string;
  source: string;
  status: string;
  score: number;
  notes?: string | null;
  create_mode?: string;
};

export async function getClients(params?: {
  page?: number;
  per_page?: number;
  search?: string;
  status?: string;
  type?: string;
  create_type?: string;
}): Promise<ClientsListResponse> {
  const q = new URLSearchParams();
  if (params?.page) q.set('page', String(params.page));
  if (params?.per_page) q.set('per_page', String(params.per_page));
  if (params?.search) q.set('search', params.search);
  if (params?.status) q.set('status', params.status);
  if (params?.type) q.set('type', params.type);
  if (params?.create_type) q.set('create_type', params.create_type);
  const path = `/clients${q.toString() ? `?${q.toString()}` : ''}`;
  const res = await api.get<ClientsListResponse>(path);
  if (!res.success || !res.data) return { clients: [], pagination: { current_page: 1, per_page: 15, total: 0, last_page: 1, from: 0, to: 0, links: { first: '', last: '', prev: null, next: null } } };
  return res.data;
}

export async function createClient(payload: ClientCreatePayload): Promise<ClientApi> {
  const res = await api.post<{ client: ClientApi }>('/clients', payload);
  if (!res.success || !res.data?.client) throw new Error(res.message || 'Error al crear cliente');
  return res.data.client;
}
