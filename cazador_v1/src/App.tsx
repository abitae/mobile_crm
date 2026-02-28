/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import React, { useState } from 'react';
import { 
  User, 
  Lock, 
  ChevronRight, 
  ShieldCheck,
  Sparkles,
  MessageSquare,
  Image as ImageIcon,
  Menu,
  X,
  Users,
  LayoutDashboard,
  Bell,
  Search,
  MoreVertical,
  ArrowUpRight,
  LogOut,
  Briefcase,
  UserPlus,
  Plus,
  ArrowLeft,
  CheckCircle2,
  Clock,
  AlertCircle,
  Calendar,
  Edit2,
  Trash2,
  Phone,
  Key
} from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';

// --- Types ---
type AppState = 'login' | 'dashboard' | 'clients' | 'projects' | 'subordinates' | 'reservations' | 'add-client' | 'add-user' | 'add-reservation';

interface Client {
  id: string;
  name: string;
  email: string;
  phone: string;
  city: string;
  status: 'active' | 'pending' | 'inactive';
  type: 'propio' | 'dateado';
}

interface Project {
  id: string;
  title: string;
  location: string;
  units: number;
  progress: number;
  status: 'ongoing' | 'completed' | 'on-hold';
}

interface Subordinate {
  id: string;
  name: string;
  role: string;
  city: string;
  status: 'online' | 'offline';
}

interface Reservation {
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

const DEMO_USER = {
  username: 'demo',
  pin: '123456'
};

const INITIAL_CLIENTS: Client[] = [
  { id: '1', name: 'Alex Rivera', email: 'alex@example.com', phone: '+51 987 654 321', city: 'Lima', status: 'active', type: 'propio' },
  { id: '2', name: 'Sofia Mendez', email: 'sofia@example.com', phone: '+51 912 345 678', city: 'Arequipa', status: 'pending', type: 'dateado' },
  { id: '3', name: 'Julian Castro', email: 'julian@example.com', phone: '+51 955 443 322', city: 'Lima', status: 'active', type: 'propio' },
  { id: '4', name: 'Elena Torres', email: 'elena@example.com', phone: '+51 900 111 222', city: 'Trujillo', status: 'inactive', type: 'dateado' },
  { id: '5', name: 'Roberto Sanz', email: 'roberto@example.com', phone: '+51 988 777 666', city: 'Lima', status: 'active', type: 'propio' },
];

const PROJECTS: Project[] = [
  { id: '1', title: 'Torre Esmeralda', location: 'Zona Norte', units: 45, progress: 75, status: 'ongoing' },
  { id: '2', title: 'Residencial Azul', location: 'Costa Este', units: 120, progress: 30, status: 'ongoing' },
  { id: '3', title: 'Condominio Verde', location: 'Centro Histórico', units: 24, progress: 100, status: 'completed' },
];

const SUBORDINATES: Subordinate[] = [
  { id: '1', name: 'Carlos Ruiz', role: 'Asesor Senior', city: 'Lima', status: 'online' },
  { id: '2', name: 'Ana Belén', role: 'Arquitecta', city: 'Arequipa', status: 'offline' },
  { id: '3', name: 'Luis Paez', role: 'Gestor de Ventas', city: 'Lima', status: 'online' },
];

const INITIAL_RESERVATIONS: Reservation[] = [
  { id: '1', clientId: '1', clientName: 'Alex Rivera', projectId: '1', projectName: 'Torre Esmeralda', unit: 'A-402', date: '2024-03-20', amount: 5000, status: 'confirmed' },
  { id: '2', clientId: '2', clientName: 'Sofia Mendez', projectId: '2', projectName: 'Residencial Azul', unit: 'B-105', date: '2024-03-22', amount: 3500, status: 'pending' },
];

export default function App() {
  const [appState, setAppState] = useState<AppState>('login');
  const [username, setUsername] = useState('');
  const [pin, setPin] = useState(['', '', '', '', '', '']);
  const [isLoggingIn, setIsLoggingIn] = useState(false);
  const [loginError, setLoginError] = useState('');
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  
  // Data State
  const [clients, setClients] = useState<Client[]>(INITIAL_CLIENTS);
  const [subordinates, setSubordinates] = useState<Subordinate[]>(SUBORDINATES);
  const [reservations, setReservations] = useState<Reservation[]>(INITIAL_RESERVATIONS);

  // Filter States
  const [clientSearch, setClientSearch] = useState('');
  const [clientTypeFilter, setClientTypeFilter] = useState<'all' | 'propio' | 'dateado'>('all');
  const [clientCityFilter, setClientCityFilter] = useState('all');
  const [userSearch, setUserSearch] = useState('');
  const [userCityFilter, setUserCityFilter] = useState('all');
  const [activeClientMenu, setActiveClientMenu] = useState<string | null>(null);

  const cities = Array.from(new Set([...clients.map(c => c.city), ...subordinates.map(s => s.city)]));

  const filteredClients = clients.filter(c => {
    const matchesSearch = c.name.toLowerCase().includes(clientSearch.toLowerCase()) || 
                         c.phone.includes(clientSearch);
    const matchesType = clientTypeFilter === 'all' || c.type === clientTypeFilter;
    const matchesCity = clientCityFilter === 'all' || c.city === clientCityFilter;
    return matchesSearch && matchesType && matchesCity;
  });

  const filteredUsers = subordinates.filter(u => {
    const matchesSearch = u.name.toLowerCase().includes(userSearch.toLowerCase()) || 
                         u.role.toLowerCase().includes(userSearch.toLowerCase());
    const matchesCity = userCityFilter === 'all' || u.city === userCityFilter;
    return matchesSearch && matchesCity;
  });

  const handlePinChange = (index: number, value: string) => {
    if (value.length > 1) return;
    if (!/^\d*$/.test(value)) return;

    const newPin = [...pin];
    newPin[index] = value;
    setPin(newPin);

    if (value && index < 5) {
      const nextInput = document.getElementById(`pin-${index + 1}`);
      nextInput?.focus();
    }
  };

  const handleKeyDown = (index: number, e: React.KeyboardEvent) => {
    if (e.key === 'Backspace' && !pin[index] && index > 0) {
      const prevInput = document.getElementById(`pin-${index - 1}`);
      prevInput?.focus();
    }
  };

  const handleLogin = (e: React.FormEvent) => {
    e.preventDefault();
    const enteredPin = pin.join('');
    
    if (username === DEMO_USER.username && enteredPin === DEMO_USER.pin) {
      setIsLoggingIn(true);
      setLoginError('');
      setTimeout(() => {
        setAppState('dashboard');
        setIsLoggingIn(false);
      }, 1000);
    } else {
      setLoginError('Usuario o PIN incorrectos (demo/123456)');
      setPin(['', '', '', '', '', '']);
      document.getElementById('pin-0')?.focus();
    }
  };

  const toggleMenu = () => setIsMenuOpen(!isMenuOpen);

  const navigateTo = (state: AppState) => {
    setAppState(state);
    setIsMenuOpen(false);
  };

  const handleAddClient = (e: React.FormEvent) => {
    e.preventDefault();
    const formData = new FormData(e.currentTarget as HTMLFormElement);
    const newClient: Client = {
      id: Math.random().toString(36).substr(2, 9),
      name: formData.get('name') as string,
      email: formData.get('email') as string,
      phone: formData.get('phone') as string,
      city: formData.get('city') as string,
      status: 'active',
      type: formData.get('type') as 'propio' | 'dateado'
    };
    setClients([newClient, ...clients]);
    setAppState('clients');
  };

  const handleAddUser = (e: React.FormEvent) => {
    e.preventDefault();
    const formData = new FormData(e.currentTarget as HTMLFormElement);
    const newUser: Subordinate = {
      id: Math.random().toString(36).substr(2, 9),
      name: formData.get('name') as string,
      role: formData.get('role') as string,
      city: formData.get('city') as string,
      status: 'offline'
    };
    setSubordinates([newUser, ...subordinates]);
    setAppState('subordinates');
  };

  const handleAddReservation = (e: React.FormEvent) => {
    e.preventDefault();
    const formData = new FormData(e.currentTarget as HTMLFormElement);
    const client = clients.find(c => c.id === formData.get('clientId'));
    const project = PROJECTS.find(p => p.id === formData.get('projectId'));
    
    const newReservation: Reservation = {
      id: Math.random().toString(36).substr(2, 9),
      clientId: formData.get('clientId') as string,
      clientName: client?.name || 'Cliente Desconocido',
      projectId: formData.get('projectId') as string,
      projectName: project?.title || 'Proyecto Desconocido',
      unit: formData.get('unit') as string,
      date: formData.get('date') as string,
      amount: Number(formData.get('amount')),
      status: 'pending'
    };
    setReservations([newReservation, ...reservations]);
    setAppState('reservations');
  };

  return (
    <div className="min-h-screen bg-zinc-50 text-zinc-900 font-sans selection:bg-emerald-100 overflow-hidden">
      <AnimatePresence mode="wait">
        {appState === 'login' ? (
          <motion.div
            key="login-screen"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0, y: -20 }}
            className="relative h-screen flex flex-col items-center justify-center p-6 bg-white"
          >
            <div className="absolute top-[-10%] left-[-10%] w-72 h-72 bg-emerald-100/50 blur-[100px] rounded-full" />
            <div className="absolute bottom-[-10%] right-[-10%] w-80 h-80 bg-blue-100/50 blur-[100px] rounded-full" />

            <div className="w-full max-w-sm space-y-10 relative z-10">
              <div className="text-center space-y-3">
                <motion.div 
                  initial={{ scale: 0.8, opacity: 0 }}
                  animate={{ scale: 1, opacity: 1 }}
                  className="w-16 h-16 bg-gradient-to-br from-emerald-500 to-blue-500 rounded-2xl mx-auto flex items-center justify-center shadow-lg shadow-emerald-200"
                >
                  <ShieldCheck size={32} className="text-white" />
                </motion.div>
                <h1 className="text-2xl font-bold tracking-tight text-zinc-900">Veridian Mobile</h1>
                <p className="text-zinc-500 text-sm">Ingresa tus credenciales para continuar</p>
              </div>

              <form onSubmit={handleLogin} className="space-y-6">
                <div className="space-y-4">
                  <div className="relative">
                    <User className="absolute left-4 top-1/2 -translate-y-1/2 text-zinc-400" size={18} />
                    <input
                      type="text"
                      placeholder="Usuario"
                      value={username}
                      onChange={(e) => setUsername(e.target.value)}
                      className="w-full bg-zinc-50 border border-zinc-200 rounded-xl py-3.5 pl-12 pr-4 focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500/50 transition-all"
                    />
                  </div>

                  <div className="space-y-2">
                    <label className="text-[10px] font-bold uppercase tracking-widest text-zinc-400 ml-1">PIN de 6 dígitos</label>
                    <div className="flex justify-between gap-2">
                      {pin.map((digit, i) => (
                        <input
                          key={i}
                          id={`pin-${i}`}
                          type="password"
                          inputMode="numeric"
                          maxLength={1}
                          value={digit}
                          onChange={(e) => handlePinChange(i, e.target.value)}
                          onKeyDown={(e) => handleKeyDown(i, e)}
                          className="w-full aspect-square bg-zinc-50 border border-zinc-200 rounded-xl text-center text-lg font-bold focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500/50 transition-all"
                        />
                      ))}
                    </div>
                  </div>
                </div>

                {loginError && (
                  <p className="text-center text-red-500 text-xs font-medium">{loginError}</p>
                )}

                <div className="space-y-3 pt-2">
                  <button
                    type="submit"
                    disabled={isLoggingIn || !username || pin.some(d => !d)}
                    className="w-full bg-zinc-900 text-white py-4 rounded-xl font-bold flex items-center justify-center gap-2 hover:bg-zinc-800 active:scale-[0.98] transition-all disabled:opacity-30"
                  >
                    {isLoggingIn ? (
                      <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                    ) : (
                      <>
                        <span>Iniciar Sesión</span>
                        <ChevronRight size={18} />
                      </>
                    )}
                  </button>
                  <p className="text-center text-[10px] text-zinc-400">Pista: demo / 123456</p>
                </div>
              </form>
            </div>
          </motion.div>
        ) : (
          <div className="h-screen flex flex-col bg-zinc-50">
            {/* Header */}
            <header className="bg-white px-6 py-4 flex items-center justify-between border-b border-zinc-100 sticky top-0 z-30">
              <div className="flex items-center gap-3">
                <button 
                  onClick={toggleMenu}
                  className="p-2 -ml-2 hover:bg-zinc-50 rounded-lg transition-colors"
                >
                  <Menu size={24} className="text-zinc-600" />
                </button>
                <div className="flex items-center gap-2">
                  <div className="w-8 h-8 bg-emerald-500 rounded-lg flex items-center justify-center text-white">
                    <Sparkles size={16} />
                  </div>
                  <span className="font-bold text-sm tracking-tight">Veridian</span>
                </div>
              </div>
              <div className="flex items-center gap-3">
                <button className="p-2 text-zinc-400 hover:text-zinc-900"><Bell size={20} /></button>
                <div className="w-8 h-8 rounded-full bg-blue-100 border border-blue-200 flex items-center justify-center text-blue-600 font-bold text-xs">
                  JD
                </div>
              </div>
            </header>

            {/* Main Content Area */}
            <main className="flex-1 overflow-y-auto p-4 space-y-4">
              <AnimatePresence mode="wait">
                {appState === 'dashboard' && (
                  <motion.div
                    key="dashboard-view"
                    initial={{ opacity: 0, x: 20 }}
                    animate={{ opacity: 1, x: 0 }}
                    exit={{ opacity: 0, x: -20 }}
                    className="space-y-4"
                  >
                    <div className="bg-gradient-to-br from-emerald-500 to-emerald-600 p-5 rounded-2xl text-white shadow-lg shadow-emerald-100 relative overflow-hidden">
                      <div className="absolute top-0 right-0 w-24 h-24 bg-white/10 blur-2xl rounded-full -mr-8 -mt-8" />
                      <div className="relative z-10 space-y-1">
                        <h2 className="text-lg font-bold">¡Hola, Demo User!</h2>
                        <p className="text-emerald-50/80 text-xs">Panel Inmobiliario Veridian</p>
                      </div>
                    </div>

                    <div className="grid grid-cols-2 gap-3">
                      <div className="bg-white p-4 rounded-2xl border border-zinc-100 shadow-sm space-y-2">
                        <div className="w-8 h-8 bg-blue-50 rounded-xl flex items-center justify-center text-blue-500">
                          <Users size={16} />
                        </div>
                        <div>
                          <p className="text-zinc-400 text-[9px] font-bold uppercase tracking-wider">Clientes</p>
                          <p className="text-lg font-bold">{clients.length}</p>
                        </div>
                      </div>
                      <div className="bg-white p-4 rounded-2xl border border-zinc-100 shadow-sm space-y-2">
                        <div className="w-8 h-8 bg-emerald-50 rounded-xl flex items-center justify-center text-emerald-500">
                          <Briefcase size={16} />
                        </div>
                        <div>
                          <p className="text-zinc-400 text-[9px] font-bold uppercase tracking-wider">Proyectos</p>
                          <p className="text-lg font-bold">{PROJECTS.length}</p>
                        </div>
                      </div>
                    </div>

                    <div className="space-y-3">
                      <h3 className="font-bold text-zinc-900 text-sm">Proyectos Destacados</h3>
                      <div className="space-y-2">
                        {PROJECTS.slice(0, 2).map(project => (
                          <div key={project.id} className="bg-white p-3 rounded-xl border border-zinc-100 shadow-sm flex items-center justify-between">
                            <div className="flex items-center gap-3">
                              <div className="w-8 h-8 bg-zinc-50 rounded-lg flex items-center justify-center text-zinc-400">
                                <Briefcase size={16} />
                              </div>
                              <div>
                                <p className="font-bold text-xs">{project.title}</p>
                                <p className="text-[9px] text-zinc-400">{project.location}</p>
                              </div>
                            </div>
                            <div className="text-right">
                              <p className="text-xs font-bold text-emerald-600">{project.progress}%</p>
                              <p className="text-[8px] text-zinc-400 uppercase font-bold tracking-tighter">{project.units} UNIDADES</p>
                            </div>
                          </div>
                        ))}
                      </div>
                    </div>
                  </motion.div>
                )}

                {appState === 'clients' && (
                  <motion.div
                    key="clients-view"
                    initial={{ opacity: 0, x: 20 }}
                    animate={{ opacity: 1, x: 0 }}
                    exit={{ opacity: 0, x: -20 }}
                    className="space-y-4"
                  >
                    <div className="flex items-center justify-between">
                      <h2 className="text-xl font-bold">Clientes</h2>
                      <button 
                        onClick={() => setAppState('add-client')}
                        className="p-2 bg-emerald-500 text-white rounded-xl shadow-lg shadow-emerald-100"
                      >
                        <Plus size={18} />
                      </button>
                    </div>

                    {/* Filters */}
                    <div className="space-y-2">
                      <div className="relative">
                        <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-zinc-400" size={14} />
                        <input 
                          type="text" 
                          placeholder="Buscar por nombre o teléfono..." 
                          value={clientSearch}
                          onChange={(e) => setClientSearch(e.target.value)}
                          className="w-full bg-white border border-zinc-200 rounded-xl py-2 pl-9 pr-4 text-xs focus:outline-none focus:ring-2 focus:ring-emerald-500/10"
                        />
                      </div>
                      <div className="flex gap-2">
                        <div className="flex-1 flex gap-1 overflow-x-auto pb-1 no-scrollbar">
                          {(['all', 'propio', 'dateado'] as const).map(type => (
                            <button
                              key={type}
                              onClick={() => setClientTypeFilter(type)}
                              className={`px-3 py-1.5 rounded-lg text-[10px] font-bold uppercase tracking-wider transition-all border whitespace-nowrap ${
                                clientTypeFilter === type 
                                  ? 'bg-zinc-900 border-zinc-900 text-white' 
                                  : 'bg-white border-zinc-200 text-zinc-500'
                              }`}
                            >
                              {type === 'all' ? 'Todos' : type}
                            </button>
                          ))}
                        </div>
                        <select 
                          value={clientCityFilter}
                          onChange={(e) => setClientCityFilter(e.target.value)}
                          className="bg-white border border-zinc-200 rounded-lg px-2 py-1 text-[10px] font-bold text-zinc-500 focus:outline-none"
                        >
                          <option value="all">Ciudad: Todas</option>
                          {cities.map(city => (
                            <option key={city} value={city}>{city}</option>
                          ))}
                        </select>
                      </div>
                    </div>

                    <div className="space-y-2">
                      {filteredClients.map(client => (
                        <div key={client.id} className="relative">
                          <div className="bg-white p-2.5 rounded-xl border border-zinc-100 shadow-sm flex items-center justify-between">
                            <div className="flex flex-col gap-0.5">
                              <div className="flex items-center gap-2">
                                <p className="font-bold text-xs">{client.name}</p>
                                <span className={`text-[7px] font-bold uppercase tracking-wider px-1 py-0.5 rounded ${
                                  client.type === 'propio' ? 'bg-emerald-100 text-emerald-700' : 'bg-blue-100 text-blue-700'
                                }`}>
                                  {client.type}
                                </span>
                                <span className="text-[7px] font-bold text-zinc-400 uppercase">{client.city}</span>
                              </div>
                              <div className="flex items-center gap-2 text-[9px] text-zinc-400">
                                <span className="flex items-center gap-1">
                                  <Phone size={10} />
                                  {client.phone}
                                </span>
                              </div>
                            </div>
                            <button 
                              onClick={() => setActiveClientMenu(activeClientMenu === client.id ? null : client.id)}
                              className={`p-1.5 rounded-lg transition-colors ${activeClientMenu === client.id ? 'bg-zinc-100 text-zinc-900' : 'text-zinc-300 hover:text-zinc-600'}`}
                            >
                              <MoreVertical size={14} />
                            </button>
                          </div>

                          {/* Action Menu */}
                          <AnimatePresence>
                            {activeClientMenu === client.id && (
                              <>
                                <div 
                                  className="fixed inset-0 z-40" 
                                  onClick={() => setActiveClientMenu(null)} 
                                />
                                <motion.div
                                  initial={{ opacity: 0, scale: 0.95, y: -10 }}
                                  animate={{ opacity: 1, scale: 1, y: 0 }}
                                  exit={{ opacity: 0, scale: 0.95, y: -10 }}
                                  className="absolute right-0 top-full mt-1 w-44 bg-white border border-zinc-100 rounded-xl shadow-xl z-50 overflow-hidden"
                                >
                                  <div className="p-1">
                                    <button className="w-full flex items-center gap-2.5 px-3 py-2 text-[10px] font-bold text-zinc-600 hover:bg-emerald-50 hover:text-emerald-700 rounded-lg transition-colors">
                                      <Key size={14} />
                                      <span>Reservar (Unidades)</span>
                                    </button>
                                    <button className="w-full flex items-center gap-2.5 px-3 py-2 text-[10px] font-bold text-zinc-600 hover:bg-blue-50 hover:text-blue-700 rounded-lg transition-colors">
                                      <Calendar size={14} />
                                      <span>Agendar</span>
                                    </button>
                                    <button className="w-full flex items-center gap-2.5 px-3 py-2 text-[10px] font-bold text-zinc-600 hover:bg-zinc-50 rounded-lg transition-colors">
                                      <Edit2 size={14} />
                                      <span>Editar</span>
                                    </button>
                                    <div className="h-px bg-zinc-50 my-1" />
                                    <button className="w-full flex items-center gap-2.5 px-3 py-2 text-[10px] font-bold text-red-500 hover:bg-red-50 rounded-lg transition-colors">
                                      <Trash2 size={14} />
                                      <span>Eliminar</span>
                                    </button>
                                  </div>
                                </motion.div>
                              </>
                            )}
                          </AnimatePresence>
                        </div>
                      ))}
                      {filteredClients.length === 0 && (
                        <div className="text-center py-8 text-zinc-400 text-xs">No se encontraron clientes.</div>
                      )}
                    </div>
                  </motion.div>
                )}

                {appState === 'projects' && (
                  <motion.div
                    key="projects-view"
                    initial={{ opacity: 0, x: 20 }}
                    animate={{ opacity: 1, x: 0 }}
                    exit={{ opacity: 0, x: -20 }}
                    className="space-y-4"
                  >
                    <h2 className="text-xl font-bold">Proyectos Inmobiliarios</h2>
                    <div className="space-y-3">
                      {PROJECTS.map(project => (
                        <div key={project.id} className="bg-white p-4 rounded-2xl border border-zinc-100 shadow-sm space-y-3">
                          <div className="flex justify-between items-center">
                            <div className="flex items-center gap-3">
                              <div className="w-9 h-9 bg-zinc-50 rounded-xl flex items-center justify-center text-zinc-400">
                                <Briefcase size={18} />
                              </div>
                              <div>
                                <h3 className="font-bold text-xs">{project.title}</h3>
                                <p className="text-[10px] text-zinc-400">{project.location}</p>
                              </div>
                            </div>
                            {project.status === 'completed' ? (
                              <CheckCircle2 size={18} className="text-emerald-500" />
                            ) : (
                              <Clock size={18} className="text-blue-500" />
                            )}
                          </div>
                          <div className="grid grid-cols-2 gap-2">
                            <div className="bg-zinc-50 p-2 rounded-lg">
                              <p className="text-[8px] font-bold text-zinc-400 uppercase">Unidades</p>
                              <p className="text-xs font-bold">{project.units}</p>
                            </div>
                            <div className="bg-zinc-50 p-2 rounded-lg">
                              <p className="text-[8px] font-bold text-zinc-400 uppercase">Progreso</p>
                              <p className="text-xs font-bold">{project.progress}%</p>
                            </div>
                          </div>
                          <div className="w-full h-1.5 bg-zinc-50 rounded-full overflow-hidden">
                            <div 
                              className={`h-full rounded-full ${project.status === 'completed' ? 'bg-emerald-500' : 'bg-blue-500'}`}
                              style={{ width: `${project.progress}%` }}
                            />
                          </div>
                        </div>
                      ))}
                    </div>
                  </motion.div>
                )}

                {appState === 'subordinates' && (
                  <motion.div
                    key="subordinates-view"
                    initial={{ opacity: 0, x: 20 }}
                    animate={{ opacity: 1, x: 0 }}
                    exit={{ opacity: 0, x: -20 }}
                    className="space-y-4"
                  >
                    <div className="flex items-center justify-between">
                      <h2 className="text-xl font-bold">Dateros</h2>
                      <button 
                        onClick={() => setAppState('add-user')}
                        className="p-2 bg-blue-500 text-white rounded-xl shadow-lg shadow-blue-100"
                      >
                        <UserPlus size={18} />
                      </button>
                    </div>

                    <div className="flex gap-2">
                      <div className="relative flex-1">
                        <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-zinc-400" size={14} />
                        <input 
                          type="text" 
                          placeholder="Buscar por nombre o cargo..." 
                          value={userSearch}
                          onChange={(e) => setUserSearch(e.target.value)}
                          className="w-full bg-white border border-zinc-200 rounded-xl py-2 pl-9 pr-4 text-xs focus:outline-none focus:ring-2 focus:ring-blue-500/10"
                        />
                      </div>
                      <select 
                        value={userCityFilter}
                        onChange={(e) => setUserCityFilter(e.target.value)}
                        className="bg-white border border-zinc-200 rounded-lg px-2 py-1 text-[10px] font-bold text-zinc-500 focus:outline-none"
                      >
                        <option value="all">Ciudad</option>
                        {cities.map(city => (
                          <option key={city} value={city}>{city}</option>
                        ))}
                      </select>
                    </div>

                    <div className="space-y-2">
                      {filteredUsers.map(user => (
                        <div key={user.id} className="bg-white p-3 rounded-xl border border-zinc-100 shadow-sm flex items-center justify-between">
                          <div className="flex items-center gap-3">
                            <div className="relative">
                              <div className="w-9 h-9 bg-zinc-50 rounded-lg flex items-center justify-center text-zinc-400">
                                <User size={20} />
                              </div>
                              <div className={`absolute -bottom-0.5 -right-0.5 w-2.5 h-2.5 rounded-full border-2 border-white ${
                                user.status === 'online' ? 'bg-emerald-500' : 'bg-zinc-300'
                              }`} />
                            </div>
                            <div>
                              <p className="font-bold text-xs">{user.name}</p>
                              <div className="flex items-center gap-2">
                                <p className="text-[10px] text-zinc-400">{user.role}</p>
                                <span className="w-0.5 h-0.5 bg-zinc-200 rounded-full" />
                                <p className="text-[10px] text-zinc-400 uppercase font-bold">{user.city}</p>
                              </div>
                            </div>
                          </div>
                          <button className="p-1.5 text-zinc-300 hover:text-zinc-900">
                            <MessageSquare size={16} />
                          </button>
                        </div>
                      ))}
                      {filteredUsers.length === 0 && (
                        <div className="text-center py-8 text-zinc-400 text-xs">No se encontraron dateros.</div>
                      )}
                    </div>
                  </motion.div>
                )}

                {appState === 'reservations' && (
                  <motion.div
                    key="reservations-view"
                    initial={{ opacity: 0, x: 20 }}
                    animate={{ opacity: 1, x: 0 }}
                    exit={{ opacity: 0, x: -20 }}
                    className="space-y-4"
                  >
                    <div className="flex items-center justify-between">
                      <h2 className="text-xl font-bold">Reservas</h2>
                      <button 
                        onClick={() => setAppState('add-reservation')}
                        className="p-2 bg-blue-600 text-white rounded-xl shadow-lg shadow-blue-100"
                      >
                        <Plus size={18} />
                      </button>
                    </div>

                    <div className="space-y-2">
                      {reservations.map(res => (
                        <div key={res.id} className="bg-white p-3 rounded-xl border border-zinc-100 shadow-sm space-y-2">
                          <div className="flex justify-between items-start">
                            <div>
                              <p className="font-bold text-xs">{res.projectName}</p>
                              <p className="text-[10px] text-zinc-500">Unidad: {res.unit}</p>
                            </div>
                            <span className={`text-[8px] font-bold uppercase tracking-wider px-1.5 py-0.5 rounded-full ${
                              res.status === 'confirmed' ? 'bg-emerald-100 text-emerald-700' : 
                              res.status === 'pending' ? 'bg-amber-100 text-amber-700' : 'bg-red-100 text-red-700'
                            }`}>
                              {res.status === 'confirmed' ? 'Confirmada' : res.status === 'pending' ? 'Pendiente' : 'Cancelada'}
                            </span>
                          </div>
                          <div className="flex justify-between items-center pt-1 border-t border-zinc-50">
                            <div className="flex items-center gap-2">
                              <div className="w-6 h-6 bg-zinc-50 rounded-full flex items-center justify-center text-zinc-400">
                                <User size={12} />
                              </div>
                              <p className="text-[10px] font-medium text-zinc-600">{res.clientName}</p>
                            </div>
                            <p className="text-xs font-bold text-zinc-900">${res.amount.toLocaleString()}</p>
                          </div>
                        </div>
                      ))}
                    </div>
                  </motion.div>
                )}

                {(appState === 'add-client' || appState === 'add-user' || appState === 'add-reservation') && (
                  <motion.div
                    key="form-view"
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    exit={{ opacity: 0, y: 20 }}
                    className="space-y-4"
                  >
                    <div className="flex items-center gap-4">
                      <button 
                        onClick={() => setAppState(
                          appState === 'add-client' ? 'clients' : 
                          appState === 'add-user' ? 'subordinates' : 'reservations'
                        )}
                        className="p-1.5 bg-white border border-zinc-100 rounded-lg"
                      >
                        <ArrowLeft size={18} />
                      </button>
                      <h2 className="text-lg font-bold">
                        {appState === 'add-client' ? 'Nuevo Cliente' : 
                         appState === 'add-user' ? 'Nuevo Datero' : 'Nueva Reserva'}
                      </h2>
                    </div>

                    <form 
                      onSubmit={
                        appState === 'add-client' ? handleAddClient : 
                        appState === 'add-user' ? handleAddUser : handleAddReservation
                      }
                      className="bg-white p-4 rounded-2xl border border-zinc-100 shadow-sm space-y-4"
                    >
                      <div className="grid grid-cols-1 gap-3">
                        {appState === 'add-reservation' ? (
                          <>
                            <div className="space-y-1">
                              <label className="text-[9px] font-bold uppercase tracking-widest text-zinc-400 ml-1">Cliente</label>
                              <select name="clientId" required className="w-full bg-zinc-50 border border-zinc-200 rounded-lg py-2 px-3 text-xs focus:outline-none focus:ring-2 focus:ring-blue-500/10">
                                <option value="">Seleccionar Cliente</option>
                                {clients.map(c => <option key={c.id} value={c.id}>{c.name}</option>)}
                              </select>
                            </div>
                            <div className="space-y-1">
                              <label className="text-[9px] font-bold uppercase tracking-widest text-zinc-400 ml-1">Proyecto</label>
                              <select name="projectId" required className="w-full bg-zinc-50 border border-zinc-200 rounded-lg py-2 px-3 text-xs focus:outline-none focus:ring-2 focus:ring-blue-500/10">
                                <option value="">Seleccionar Proyecto</option>
                                {PROJECTS.map(p => <option key={p.id} value={p.id}>{p.title}</option>)}
                              </select>
                            </div>
                            <div className="grid grid-cols-2 gap-3">
                              <div className="space-y-1">
                                <label className="text-[9px] font-bold uppercase tracking-widest text-zinc-400 ml-1">Unidad</label>
                                <input name="unit" required placeholder="Ej. A-101" className="w-full bg-zinc-50 border border-zinc-200 rounded-lg py-2 px-3 text-xs focus:outline-none focus:ring-2 focus:ring-blue-500/10" />
                              </div>
                              <div className="space-y-1">
                                <label className="text-[9px] font-bold uppercase tracking-widest text-zinc-400 ml-1">Monto ($)</label>
                                <input name="amount" type="number" required placeholder="0.00" className="w-full bg-zinc-50 border border-zinc-200 rounded-lg py-2 px-3 text-xs focus:outline-none focus:ring-2 focus:ring-blue-500/10" />
                              </div>
                            </div>
                            <div className="space-y-1">
                              <label className="text-[9px] font-bold uppercase tracking-widest text-zinc-400 ml-1">Fecha</label>
                              <input name="date" type="date" required className="w-full bg-zinc-50 border border-zinc-200 rounded-lg py-2 px-3 text-xs focus:outline-none focus:ring-2 focus:ring-blue-500/10" />
                            </div>
                          </>
                        ) : (
                          <>
                            <div className="space-y-1">
                              <label className="text-[9px] font-bold uppercase tracking-widest text-zinc-400 ml-1">Nombre Completo</label>
                              <input name="name" required placeholder="Ej. Juan Pérez" className="w-full bg-zinc-50 border border-zinc-200 rounded-lg py-2 px-3 text-xs focus:outline-none focus:ring-2 focus:ring-emerald-500/10" />
                            </div>
                            
                            {appState === 'add-client' ? (
                              <>
                                <div className="grid grid-cols-2 gap-3">
                                  <div className="space-y-1">
                                    <label className="text-[9px] font-bold uppercase tracking-widest text-zinc-400 ml-1">Teléfono</label>
                                    <input name="phone" type="tel" required placeholder="+51..." className="w-full bg-zinc-50 border border-zinc-200 rounded-lg py-2 px-3 text-xs focus:outline-none focus:ring-2 focus:ring-emerald-500/10" />
                                  </div>
                                  <div className="space-y-1">
                                    <label className="text-[9px] font-bold uppercase tracking-widest text-zinc-400 ml-1">Ciudad</label>
                                    <input name="city" required placeholder="Ej. Lima" className="w-full bg-zinc-50 border border-zinc-200 rounded-lg py-2 px-3 text-xs focus:outline-none focus:ring-2 focus:ring-emerald-500/10" />
                                  </div>
                                </div>
                                <div className="grid grid-cols-2 gap-3">
                                  <div className="space-y-1">
                                    <label className="text-[9px] font-bold uppercase tracking-widest text-zinc-400 ml-1">Email (Opcional)</label>
                                    <input name="email" type="email" placeholder="juan@mail.com" className="w-full bg-zinc-50 border border-zinc-200 rounded-lg py-2 px-3 text-xs focus:outline-none focus:ring-2 focus:ring-emerald-500/10" />
                                  </div>
                                  <div className="space-y-1">
                                    <label className="text-[9px] font-bold uppercase tracking-widest text-zinc-400 ml-1">Tipo</label>
                                    <select name="type" className="w-full bg-zinc-50 border border-zinc-200 rounded-lg py-2 px-3 text-xs focus:outline-none focus:ring-2 focus:ring-emerald-500/10">
                                      <option value="propio">Propio</option>
                                      <option value="dateado">Dateado</option>
                                    </select>
                                  </div>
                                </div>
                              </>
                            ) : (
                              <div className="grid grid-cols-2 gap-3">
                                <div className="space-y-1">
                                  <label className="text-[9px] font-bold uppercase tracking-widest text-zinc-400 ml-1">Cargo</label>
                                  <input name="role" required placeholder="Ej. Asesor" className="w-full bg-zinc-50 border border-zinc-200 rounded-lg py-2 px-3 text-xs focus:outline-none focus:ring-2 focus:ring-blue-500/10" />
                                </div>
                                <div className="space-y-1">
                                  <label className="text-[9px] font-bold uppercase tracking-widest text-zinc-400 ml-1">Ciudad</label>
                                  <input name="city" required placeholder="Ej. Lima" className="w-full bg-zinc-50 border border-zinc-200 rounded-lg py-2 px-3 text-xs focus:outline-none focus:ring-2 focus:ring-blue-500/10" />
                                </div>
                              </div>
                            )}
                          </>
                        )}
                      </div>

                      <button 
                        type="submit"
                        className={`w-full py-3 rounded-xl text-white font-bold shadow-lg transition-all active:scale-[0.98] text-sm ${
                          appState === 'add-client' ? 'bg-emerald-500 shadow-emerald-100' : 
                          appState === 'add-user' ? 'bg-blue-500 shadow-blue-100' : 'bg-blue-600 shadow-blue-100'
                        }`}
                      >
                        Guardar Registro
                      </button>
                    </form>
                  </motion.div>
                )}
              </AnimatePresence>
            </main>

            {/* Bottom Nav */}
            <nav className="bg-white border-t border-zinc-100 px-6 py-3 flex justify-around items-center sticky bottom-0 z-30">
              <button 
                onClick={() => navigateTo('dashboard')}
                className={`p-2 transition-colors ${appState === 'dashboard' ? 'text-emerald-500' : 'text-zinc-400'}`}
              >
                <LayoutDashboard size={24} />
              </button>
              <button 
                onClick={() => navigateTo('clients')}
                className={`p-2 transition-colors ${appState === 'clients' ? 'text-emerald-500' : 'text-zinc-400'}`}
              >
                <Users size={24} />
              </button>
              <button 
                onClick={() => navigateTo('projects')}
                className={`p-2 transition-colors ${appState === 'projects' ? 'text-emerald-500' : 'text-zinc-400'}`}
              >
                <Briefcase size={24} />
              </button>
              <button 
                onClick={() => navigateTo('reservations')}
                className={`p-2 transition-colors ${appState === 'reservations' ? 'text-emerald-500' : 'text-zinc-400'}`}
              >
                <Key size={24} />
              </button>
              <button 
                onClick={() => navigateTo('subordinates')}
                className={`p-2 transition-colors ${appState === 'subordinates' ? 'text-emerald-500' : 'text-zinc-400'}`}
              >
                <User size={24} />
              </button>
            </nav>

            {/* Sidebar Menu Overlay */}
            <AnimatePresence>
              {isMenuOpen && (
                <>
                  <motion.div 
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    exit={{ opacity: 0 }}
                    onClick={toggleMenu}
                    className="fixed inset-0 bg-zinc-900/20 backdrop-blur-sm z-40"
                  />
                  <motion.div 
                    initial={{ x: '-100%' }}
                    animate={{ x: 0 }}
                    exit={{ x: '-100%' }}
                    transition={{ type: 'spring', damping: 25, stiffness: 200 }}
                    className="fixed inset-y-0 left-0 w-72 bg-white shadow-2xl z-50 p-6 flex flex-col"
                  >
                    <div className="flex items-center justify-between mb-10">
                      <div className="flex items-center gap-2">
                        <div className="w-8 h-8 bg-zinc-900 rounded-lg flex items-center justify-center text-white">
                          <ShieldCheck size={18} />
                        </div>
                        <span className="font-bold text-lg">Veridian</span>
                      </div>
                      <button onClick={toggleMenu} className="p-2 hover:bg-zinc-50 rounded-lg">
                        <X size={20} className="text-zinc-400" />
                      </button>
                    </div>

                    <div className="flex-1 space-y-2">
                      <button 
                        onClick={() => navigateTo('clients')}
                        className={`w-full flex items-center gap-4 p-4 rounded-2xl transition-all ${
                          appState === 'clients' ? 'bg-emerald-50 text-emerald-600 font-bold' : 'text-zinc-500 hover:bg-zinc-50'
                        }`}
                      >
                        <Users size={20} />
                        <span>Lista de Clientes</span>
                      </button>
                      <button 
                        onClick={() => navigateTo('projects')}
                        className={`w-full flex items-center gap-4 p-4 rounded-2xl transition-all ${
                          appState === 'projects' ? 'bg-emerald-50 text-emerald-600 font-bold' : 'text-zinc-500 hover:bg-zinc-50'
                        }`}
                      >
                        <Briefcase size={20} />
                        <span>Proyectos</span>
                      </button>
                      <button 
                        onClick={() => navigateTo('reservations')}
                        className={`w-full flex items-center gap-4 p-4 rounded-2xl transition-all ${
                          appState === 'reservations' ? 'bg-emerald-50 text-emerald-600 font-bold' : 'text-zinc-500 hover:bg-zinc-50'
                        }`}
                      >
                        <Key size={20} />
                        <span>Reservas</span>
                      </button>
                      <button 
                        onClick={() => navigateTo('subordinates')}
                        className={`w-full flex items-center gap-4 p-4 rounded-2xl transition-all ${
                          appState === 'subordinates' ? 'bg-emerald-50 text-emerald-600 font-bold' : 'text-zinc-500 hover:bg-zinc-50'
                        }`}
                      >
                        <User size={20} />
                        <span>Dateros</span>
                      </button>
                      <div className="h-px bg-zinc-100 my-4" />
                      <button className="w-full flex items-center gap-4 p-4 rounded-2xl text-zinc-500 hover:bg-zinc-50 font-medium transition-all">
                        <Bell size={20} />
                        <span>Notificaciones</span>
                      </button>
                    </div>

                    <div className="pt-6 border-t border-zinc-100">
                      <button 
                        onClick={() => navigateTo('login')}
                        className="w-full flex items-center gap-4 p-4 rounded-2xl text-red-500 hover:bg-red-50 font-bold transition-all"
                      >
                        <LogOut size={20} />
                        <span>Cerrar Sesión</span>
                      </button>
                    </div>
                  </motion.div>
                </>
              )}
            </AnimatePresence>
          </div>
        )}
      </AnimatePresence>
    </div>
  );
}
