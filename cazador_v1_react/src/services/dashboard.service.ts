import { api } from './api.client';

export type DashboardStats = {
  clients_count?: number;
  projects_count?: number;
  dateros_count?: number;
  reservations_count?: number;
  [key: string]: number | undefined;
};

export async function getDashboardStats(): Promise<DashboardStats> {
  const res = await api.get<DashboardStats>('/dashboard/stats');
  if (!res.success || !res.data) return {};
  return res.data;
}
