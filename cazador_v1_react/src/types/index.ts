export type AppState =
  | 'login'
  | 'dashboard'
  | 'clients'
  | 'projects'
  | 'subordinates'
  | 'reservations'
  | 'add-client'
  | 'add-user'
  | 'add-reservation';

export interface Client {
  id: string;
  name: string;
  email: string;
  phone: string;
  city: string;
  status: 'active' | 'pending' | 'inactive';
  type: 'propio' | 'dateado';
}

export interface Project {
  id: string;
  title: string;
  location: string;
  units: number;
  progress: number;
  status: 'ongoing' | 'completed' | 'on-hold';
}

export interface Subordinate {
  id: string;
  name: string;
  role: string;
  city: string;
  status: 'online' | 'offline';
}

export interface Reservation {
  id: string;
  clientId: string;
  clientName: string;
  projectId: string;
  projectName: string;
  unit: string;
  date: string;
  amount: number;
  status: 'confirmed' | 'pending' | 'cancelled';
}
