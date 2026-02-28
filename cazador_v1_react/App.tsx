import React, { useState, useEffect, useCallback } from 'react';
import { View, StyleSheet } from 'react-native';
import { SafeAreaProvider, SafeAreaView } from 'react-native-safe-area-context';
import { StatusBar } from 'expo-status-bar';
import type { AppState, Client, Project, Subordinate, Reservation } from './src/types';
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
import { restoreToken, login as apiLogin, logout as apiLogout, getMe, type User } from './src/services/auth.service';
import { getClients, createClient } from './src/services/clients.service';
import { getCities } from './src/services/cities.service';
import { getProjects, getProjectUnits } from './src/services/projects.service';
import { getDateros, createDatero } from './src/services/dateros.service';
import { getReservations, createReservation } from './src/services/reservations.service';
import { clientApiToUi, projectApiToUi, dateroApiToUi, reservationApiToUi } from './src/lib/apiMappers';
import { ApiError } from './src/services/api.client';

const DEFAULT_CLIENT_PAYLOAD = {
  birth_date: '1990-01-01',
  client_type: 'comprador' as const,
  source: 'referidos' as const,
  status: 'nuevo' as const,
  score: 0,
};

export default function App() {
  const [appState, setAppState] = useState<AppState>('login');
  const [email, setEmail] = useState('');
  const [pin, setPin] = useState<string[]>(['', '', '', '', '', '']);
  const [isLoggingIn, setIsLoggingIn] = useState(false);
  const [loginError, setLoginError] = useState('');
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const [user, setUser] = useState<User | null>(null);
  const [authReady, setAuthReady] = useState(false);

  const [clients, setClients] = useState<Client[]>([]);
  const [projects, setProjects] = useState<Project[]>([]);
  const [subordinates, setSubordinates] = useState<Subordinate[]>([]);
  const [reservations, setReservations] = useState<Reservation[]>([]);
  const [cities, setCities] = useState<{ id: number; name: string }[]>([]);
  const [loading, setLoading] = useState(false);
  const [loadError, setLoadError] = useState<string | null>(null);

  const [clientSearch, setClientSearch] = useState('');
  const [clientTypeFilter, setClientTypeFilter] = useState<'all' | 'propio' | 'dateado'>('all');
  const [clientCityFilter, setClientCityFilter] = useState('all');
  const [userSearch, setUserSearch] = useState('');
  const [userCityFilter, setUserCityFilter] = useState('all');
  const [activeClientMenu, setActiveClientMenu] = useState<string | null>(null);

  const cityNames = cities.map((c) => c.name);
  const citiesForFilter = Array.from(new Set([...clients.map((c) => c.city), ...subordinates.map((s) => s.city)]));

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

  const loadData = useCallback(async () => {
    setLoading(true);
    setLoadError(null);
    try {
      const [clientsRes, projectsList, daterosList, reservationsList, citiesList] = await Promise.all([
        getClients({ per_page: 100 }),
        getProjects({ per_page: 50 }),
        getDateros({ per_page: 100 }),
        getReservations({ per_page: 100 }),
        getCities({ per_page: 200 }),
      ]);
      setClients((clientsRes.clients || []).map(clientApiToUi));
      setProjects(projectsList.map(projectApiToUi));
      setSubordinates(daterosList.map(dateroApiToUi));
      setReservations(reservationsList.map(reservationApiToUi));
      setCities(citiesList);
    } catch (e) {
      setLoadError(e instanceof Error ? e.message : 'Error al cargar datos');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    let cancelled = false;
    (async () => {
      const token = await restoreToken();
      if (cancelled) return;
      setAuthReady(true);
      if (token) {
        try {
          const me = await getMe();
          if (cancelled) return;
          setUser(me);
          setAppState('dashboard');
          await loadData();
        } catch {
          setAppState('login');
        }
      }
    })();
    return () => {
      cancelled = true;
    };
  }, [loadData]);

  const handlePinChange = (index: number, value: string) => {
    if (value.length > 1) return;
    if (!/^\d*$/.test(value)) return;
    const newPin = [...pin];
    newPin[index] = value;
    setPin(newPin);
  };

  const handleLogin = async () => {
    const password = pin.join('');
    if (!email.trim() || password.length !== 6) return;
    setIsLoggingIn(true);
    setLoginError('');
    try {
      const data = await apiLogin({ email: email.trim(), password });
      setUser(data.user);
      setAppState('dashboard');
      await loadData();
    } catch (e) {
      setLoginError(e instanceof ApiError ? e.message : 'Correo o PIN incorrectos');
      setPin(['', '', '', '', '', '']);
    } finally {
      setIsLoggingIn(false);
    }
  };

  const navigateTo = (state: AppState) => {
    setAppState(state);
    setIsMenuOpen(false);
  };

  const handleLogout = async () => {
    await apiLogout();
    setUser(null);
    setClients([]);
    setProjects([]);
    setSubordinates([]);
    setReservations([]);
    setAppState('login');
  };

  const handleAddClient = async (data: { name: string; email: string; phone: string; city: string; type: 'propio' | 'dateado' }) => {
    const cityId = cities.find((c) => c.name === data.city)?.id ?? cities[0]?.id ?? 1;
    try {
      const created = await createClient({
        name: data.name,
        phone: data.phone.replace(/\D/g, '').slice(-9) || data.phone,
        city_id: cityId,
        ...DEFAULT_CLIENT_PAYLOAD,
        create_mode: 'phone',
      });
      setClients((prev) => [clientApiToUi(created), ...prev]);
      setAppState('clients');
    } catch (e) {
      setLoadError(e instanceof Error ? e.message : 'Error al crear cliente');
    }
  };

  const handleAddUser = async (data: { name: string; role: string; city: string; email?: string; phone?: string; dni?: string; pin?: string }) => {
    const emailVal = data.email ?? `${data.name.toLowerCase().replace(/\s/g, '')}@datero.local`;
    const phoneVal = data.phone ?? '900000000';
    const dniVal = data.dni ?? '00000000';
    const pinVal = data.pin ?? '123456';
    try {
      const created = await createDatero({
        name: data.name,
        email: emailVal,
        phone: phoneVal,
        dni: dniVal,
        pin: pinVal,
        ocupacion: data.role,
      });
      setSubordinates((prev) => [dateroApiToUi(created), ...prev]);
      setAppState('subordinates');
    } catch (e) {
      setLoadError(e instanceof Error ? e.message : 'Error al crear datero');
    }
  };

  const handleAddReservation = async (data: {
    clientId: string;
    projectId: string;
    unitId?: number;
    unit?: string;
    date: string;
    amount: number;
  }) => {
    const unitId = data.unitId ?? 0;
    if (!unitId) {
      setLoadError('Selecciona una unidad del proyecto');
      return;
    }
    try {
      const created = await createReservation({
        client_id: Number(data.clientId),
        project_id: Number(data.projectId),
        unit_id: unitId,
        reservation_amount: data.amount,
      });
      setReservations((prev) => [reservationApiToUi(created), ...prev]);
      setAppState('reservations');
    } catch (e) {
      setLoadError(e instanceof Error ? e.message : 'Error al crear reserva');
    }
  };

  if (!authReady) {
    return null;
  }

  if (appState === 'login') {
    return (
      <SafeAreaProvider>
        <SafeAreaView style={styles.safe}>
          <LoginScreen
            email={email}
            setEmail={setEmail}
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
              <DashboardScreen
                clientsCount={loading ? 0 : clients.length}
                projects={loading ? [] : projects}
              />
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
                cities={citiesForFilter}
                activeMenuId={activeClientMenu}
                setActiveMenuId={setActiveClientMenu}
                onAddClient={() => setAppState('add-client')}
              />
            )}
            {appState === 'projects' && <ProjectsScreen projects={projects} />}
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
                cities={citiesForFilter}
                onAddUser={() => setAppState('add-user')}
              />
            )}
            {appState === 'add-client' && (
              <AddClientForm
                cities={cities}
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
                projects={projects}
                loadUnits={getProjectUnits}
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
          onLogout={handleLogout}
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
