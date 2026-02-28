import React, { useState } from 'react';
import { View, StyleSheet } from 'react-native';
import { SafeAreaProvider, SafeAreaView } from 'react-native-safe-area-context';
import { StatusBar } from 'expo-status-bar';
import type { AppState, Client, Subordinate, Reservation } from './src/types';
import { DEMO_USER, INITIAL_CLIENTS, PROJECTS, SUBORDINATES, INITIAL_RESERVATIONS } from './src/data/demo';
import { Header } from './src/components/Header';
import { BottomNav } from './src/components/BottomNav';
import { SideMenu } from './src/components/SideMenu';
import { LoginScreen } from './src/screens/LoginScreen';
import { DashboardScreen } from './src/screens/DashboardScreen';
import { ClientsScreen } from './src/screens/ClientsScreen';
import { ProjectsScreen } from './src/screens/ProjectsScreen';
import { ReservationsScreen } from './src/screens/ReservationsScreen';
import { SubordinatesScreen } from './src/screens/SubordinatesScreen';
import { AddClientForm } from './src/screens/forms/AddClientForm';
import { AddUserForm } from './src/screens/forms/AddUserForm';
import { AddReservationForm } from './src/screens/forms/AddReservationForm';
import { colors } from './src/theme';

export default function App() {
  const [appState, setAppState] = useState<AppState>('login');
  const [username, setUsername] = useState('');
  const [pin, setPin] = useState<string[]>(['', '', '', '', '', '']);
  const [isLoggingIn, setIsLoggingIn] = useState(false);
  const [loginError, setLoginError] = useState('');
  const [isMenuOpen, setIsMenuOpen] = useState(false);

  const [clients, setClients] = useState<Client[]>(INITIAL_CLIENTS);
  const [subordinates, setSubordinates] = useState<Subordinate[]>(SUBORDINATES);
  const [reservations, setReservations] = useState<Reservation[]>(INITIAL_RESERVATIONS);

  const [clientSearch, setClientSearch] = useState('');
  const [clientTypeFilter, setClientTypeFilter] = useState<'all' | 'propio' | 'dateado'>('all');
  const [clientCityFilter, setClientCityFilter] = useState('all');
  const [userSearch, setUserSearch] = useState('');
  const [userCityFilter, setUserCityFilter] = useState('all');
  const [activeClientMenu, setActiveClientMenu] = useState<string | null>(null);

  const cities = Array.from(new Set([...clients.map((c) => c.city), ...subordinates.map((s) => s.city)]));

  const filteredClients = clients.filter((c) => {
    const matchesSearch =
      c.name.toLowerCase().includes(clientSearch.toLowerCase()) || c.phone.includes(clientSearch);
    const matchesType = clientTypeFilter === 'all' || c.type === clientTypeFilter;
    const matchesCity = clientCityFilter === 'all' || c.city === clientCityFilter;
    return matchesSearch && matchesType && matchesCity;
  });

  const filteredUsers = subordinates.filter((u) => {
    const matchesSearch =
      u.name.toLowerCase().includes(userSearch.toLowerCase()) ||
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
  };

  const handleLogin = () => {
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
    }
  };

  const navigateTo = (state: AppState) => {
    setAppState(state);
    setIsMenuOpen(false);
  };

  const handleAddClient = (data: { name: string; email: string; phone: string; city: string; type: 'propio' | 'dateado' }) => {
    const newClient: Client = {
      id: Math.random().toString(36).substring(2, 11),
      name: data.name,
      email: data.email,
      phone: data.phone,
      city: data.city,
      status: 'active',
      type: data.type,
    };
    setClients([newClient, ...clients]);
    setAppState('clients');
  };

  const handleAddUser = (data: { name: string; role: string; city: string }) => {
    const newUser: Subordinate = {
      id: Math.random().toString(36).substring(2, 11),
      name: data.name,
      role: data.role,
      city: data.city,
      status: 'offline',
    };
    setSubordinates([newUser, ...subordinates]);
    setAppState('subordinates');
  };

  const handleAddReservation = (data: {
    clientId: string;
    projectId: string;
    unit: string;
    date: string;
    amount: number;
  }) => {
    const client = clients.find((c) => c.id === data.clientId);
    const project = PROJECTS.find((p) => p.id === data.projectId);
    const newReservation: Reservation = {
      id: Math.random().toString(36).substring(2, 11),
      clientId: data.clientId,
      clientName: client?.name ?? 'Cliente Desconocido',
      projectId: data.projectId,
      projectName: project?.title ?? 'Proyecto Desconocido',
      unit: data.unit,
      date: data.date,
      amount: data.amount,
      status: 'pending',
    };
    setReservations([newReservation, ...reservations]);
    setAppState('reservations');
  };

  if (appState === 'login') {
    return (
      <SafeAreaProvider>
        <SafeAreaView style={styles.safe}>
          <LoginScreen
            username={username}
            setUsername={setUsername}
            pin={pin}
            isLoggingIn={isLoggingIn}
            loginError={loginError}
            onPinChange={handlePinChange}
            onLogin={handleLogin}
          />
        </SafeAreaView>
        <StatusBar style="dark" />
      </SafeAreaProvider>
    );
  }

  return (
    <SafeAreaProvider>
      <SafeAreaView style={styles.safe} edges={['top']}>
        <View style={styles.main}>
          <Header onMenuPress={() => setIsMenuOpen(true)} />
          <View style={styles.content}>
            {appState === 'dashboard' && (
              <DashboardScreen clientsCount={clients.length} projects={PROJECTS} />
            )}
            {appState === 'clients' && (
              <ClientsScreen
                clients={clients}
                filteredClients={filteredClients}
                search={clientSearch}
                setSearch={setClientSearch}
                typeFilter={clientTypeFilter}
                setTypeFilter={setClientTypeFilter}
                cityFilter={clientCityFilter}
                setCityFilter={setClientCityFilter}
                cities={cities}
                activeMenuId={activeClientMenu}
                setActiveMenuId={setActiveClientMenu}
                onAddClient={() => setAppState('add-client')}
              />
            )}
            {appState === 'projects' && <ProjectsScreen projects={PROJECTS} />}
            {appState === 'reservations' && (
              <ReservationsScreen
                reservations={reservations}
                onAddReservation={() => setAppState('add-reservation')}
              />
            )}
            {appState === 'subordinates' && (
              <SubordinatesScreen
                filteredUsers={filteredUsers}
                search={userSearch}
                setSearch={setUserSearch}
                cityFilter={userCityFilter}
                setCityFilter={setUserCityFilter}
                cities={cities}
                onAddUser={() => setAppState('add-user')}
              />
            )}
            {appState === 'add-client' && (
              <AddClientForm
                onBack={() => setAppState('clients')}
                onSubmit={handleAddClient}
              />
            )}
            {appState === 'add-user' && (
              <AddUserForm
                onBack={() => setAppState('subordinates')}
                onSubmit={handleAddUser}
              />
            )}
            {appState === 'add-reservation' && (
              <AddReservationForm
                clients={clients}
                projects={PROJECTS}
                onBack={() => setAppState('reservations')}
                onSubmit={handleAddReservation}
              />
            )}
          </View>
          <BottomNav currentState={appState} onNavigate={setAppState} />
        </View>
        <SideMenu
          visible={isMenuOpen}
          currentState={appState}
          onClose={() => setIsMenuOpen(false)}
          onNavigate={navigateTo}
          onLogout={() => setAppState('login')}
        />
      </SafeAreaView>
      <StatusBar style="dark" />
    </SafeAreaProvider>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: colors.zinc[50] },
  main: { flex: 1 },
  content: { flex: 1 },
});
