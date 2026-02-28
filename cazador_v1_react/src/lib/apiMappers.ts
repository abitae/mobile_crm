import type { Client, Project, Subordinate, Reservation } from '../types';
import type { ClientApi } from '../services/clients.service';
import type { ProjectApi } from '../services/projects.service';
import type { DateroApi } from '../services/dateros.service';
import type { ReservationApi } from '../services/reservations.service';

export function clientApiToUi(c: ClientApi): Client {
  return {
    id: String(c.id),
    name: c.name,
    email: c.assigned_advisor?.email ?? '',
    phone: c.phone,
    city: c.city?.name ?? '',
    status: mapClientStatus(c.status),
    type: (c.create_type === 'datero' ? 'dateado' : 'propio') as 'propio' | 'dateado',
  };
}

function mapClientStatus(s: string): 'active' | 'pending' | 'inactive' {
  if (s === 'perdido') return 'inactive';
  if (s === 'nuevo' || s === 'contacto_inicial') return 'pending';
  return 'active';
}

export function projectApiToUi(p: ProjectApi): Project {
  return {
    id: String(p.id),
    title: p.title ?? p.name ?? 'Proyecto',
    location: ([p.district, p.province, p.region].filter(Boolean).join(', ') || p.location) ?? '',
    units: p.units_count ?? 0,
    progress: p.progress ?? 0,
    status: p.status === 'completed' || p.stage === 'completado' ? 'completed' : 'ongoing',
  };
}

export function dateroApiToUi(d: DateroApi): Subordinate {
  return {
    id: String(d.id),
    name: d.name,
    role: d.ocupacion ?? 'Datero',
    city: d.city ?? '',
    status: d.is_active !== false ? 'online' : 'offline',
  };
}

export function reservationApiToUi(r: ReservationApi): Reservation {
  return {
    id: String(r.id),
    clientId: String(r.client_id),
    clientName: r.client?.name ?? '',
    projectId: String(r.project_id),
    projectName: r.project?.name ?? r.project?.title ?? '',
    unit: r.unit?.code ?? r.unit?.name ?? String(r.unit_id),
    date: r.reservation_date ?? '',
    amount: r.reservation_amount ?? 0,
    status: mapReservationStatus(r.status),
  };
}

function mapReservationStatus(s?: string): 'confirmed' | 'pending' | 'cancelled' {
  if (s === 'cancelada' || s === 'cancelled') return 'cancelled';
  if (s === 'confirmada' || s === 'confirmed') return 'confirmed';
  return 'pending';
}
