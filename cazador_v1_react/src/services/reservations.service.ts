import { api } from './api.client';
import type { Pagination } from '../config/api';

export type ReservationApi = {
  id: number;
  client_id: number;
  project_id: number;
  unit_id: number;
  reservation_amount: number;
  status?: string;
  reservation_date?: string;
  client?: { id: number; name: string };
  project?: { id: number; name?: string; title?: string };
  unit?: { id: number; name?: string; code?: string };
  [key: string]: unknown;
};

export type ReservationsListResponse = {
  reservations: ReservationApi[];
  pagination?: Pagination;
};

export type ReservationCreatePayload = {
  client_id: number;
  project_id: number;
  unit_id: number;
  reservation_amount: number;
  payment_method?: string;
  payment_reference?: string;
  notes?: string;
  terms_conditions?: boolean;
};

export async function getReservations(params?: {
  page?: number;
  per_page?: number;
  search?: string;
  status?: string;
}): Promise<ReservationApi[]> {
  const q = new URLSearchParams();
  if (params?.page) q.set('page', String(params.page));
  if (params?.per_page) q.set('per_page', String(params.per_page ?? 50));
  if (params?.search) q.set('search', params.search ?? '');
  if (params?.status) q.set('status', params.status);
  const path = `/reservations${q.toString() ? `?${q.toString()}` : ''}`;
  const res = await api.get<ReservationsListResponse>(path);
  if (!res.success || !res.data) return [];
  return res.data.reservations || [];
}

export async function createReservation(payload: ReservationCreatePayload): Promise<ReservationApi> {
  const res = await api.post<{ reservation: ReservationApi }>('/reservations', payload);
  if (!res.success || !res.data) throw new Error(res.message || 'Error al crear reserva');
  const data = res.data as { reservation?: ReservationApi };
  return data.reservation ?? (res.data as ReservationApi);
}
