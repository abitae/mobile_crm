import type { Client, Project, Subordinate, Reservation } from '../types';

export const DEMO_USER = {
  username: 'demo',
  pin: '123456',
};

export const INITIAL_CLIENTS: Client[] = [
  { id: '1', name: 'Alex Rivera', email: 'alex@example.com', phone: '+51 987 654 321', city: 'Lima', status: 'active', type: 'propio' },
  { id: '2', name: 'Sofia Mendez', email: 'sofia@example.com', phone: '+51 912 345 678', city: 'Arequipa', status: 'pending', type: 'dateado' },
  { id: '3', name: 'Julian Castro', email: 'julian@example.com', phone: '+51 955 443 322', city: 'Lima', status: 'active', type: 'propio' },
  { id: '4', name: 'Elena Torres', email: 'elena@example.com', phone: '+51 900 111 222', city: 'Trujillo', status: 'inactive', type: 'dateado' },
  { id: '5', name: 'Roberto Sanz', email: 'roberto@example.com', phone: '+51 988 777 666', city: 'Lima', status: 'active', type: 'propio' },
];

export const PROJECTS: Project[] = [
  { id: '1', title: 'Torre Esmeralda', location: 'Zona Norte', units: 45, progress: 75, status: 'ongoing' },
  { id: '2', title: 'Residencial Azul', location: 'Costa Este', units: 120, progress: 30, status: 'ongoing' },
  { id: '3', title: 'Condominio Verde', location: 'Centro Histórico', units: 24, progress: 100, status: 'completed' },
];

export const SUBORDINATES: Subordinate[] = [
  { id: '1', name: 'Carlos Ruiz', role: 'Asesor Senior', city: 'Lima', status: 'online' },
  { id: '2', name: 'Ana Belén', role: 'Arquitecta', city: 'Arequipa', status: 'offline' },
  { id: '3', name: 'Luis Paez', role: 'Gestor de Ventas', city: 'Lima', status: 'online' },
];

export const INITIAL_RESERVATIONS: Reservation[] = [
  { id: '1', clientId: '1', clientName: 'Alex Rivera', projectId: '1', projectName: 'Torre Esmeralda', unit: 'A-402', date: '2024-03-20', amount: 5000, status: 'confirmed' },
  { id: '2', clientId: '2', clientName: 'Sofia Mendez', projectId: '2', projectName: 'Residencial Azul', unit: 'B-105', date: '2024-03-22', amount: 3500, status: 'pending' },
];
