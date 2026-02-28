import { api } from './api.client';
import type { Pagination } from '../config/api';

export type City = { id: number; name: string };

export type CitiesResponse = {
  cities: City[];
  pagination: Pagination;
};

export async function getCities(params?: { search?: string; per_page?: number }): Promise<City[]> {
  const q = new URLSearchParams();
  if (params?.search) q.set('search', params.search);
  if (params?.per_page) q.set('per_page', String(params.per_page));
  const path = `/cities${q.toString() ? `?${q.toString()}` : ''}`;
  const res = await api.get<CitiesResponse>(path);
  if (!res.success || !res.data) return [];
  return res.data.cities || [];
}
