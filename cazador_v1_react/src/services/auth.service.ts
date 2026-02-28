import AsyncStorage from '@react-native-async-storage/async-storage';
import { api, setAuthToken, getAuthToken, ApiError } from './api.client';

const TOKEN_KEY = '@cazador_token';

export type User = {
  id: number;
  name: string;
  email: string;
  phone: string;
  role: string;
  is_active: boolean;
};

export type LoginPayload = { email: string; password: string };
export type LoginResponse = {
  token: string;
  token_type: string;
  expires_in: number;
  user: User;
};

export async function login(payload: LoginPayload): Promise<LoginResponse> {
  const res = await api.post<{ token: string; token_type: string; expires_in: number; user: User }>(
    '/auth/login',
    payload
  );
  if (!res.success || !res.data) throw new ApiError(res.message || 'Login fallido', 401, res);
  const data = res.data as LoginResponse;
  setAuthToken(data.token);
  await AsyncStorage.setItem(TOKEN_KEY, data.token);
  return data;
}

export async function getMe(): Promise<User> {
  const res = await api.get<User>('/auth/me');
  if (!res.success || !res.data) throw new ApiError(res.message || 'No autorizado', 401, res);
  return res.data;
}

export async function logout(): Promise<void> {
  try {
    await api.post('/auth/logout');
  } finally {
    setAuthToken(null);
    await AsyncStorage.removeItem(TOKEN_KEY);
  }
}

export function getStoredToken(): string | null {
  return getAuthToken();
}

export function setStoredToken(t: string | null): void {
  setAuthToken(t);
}

/** Restaura el token desde AsyncStorage (llamar al iniciar la app). */
export async function restoreToken(): Promise<string | null> {
  const t = await AsyncStorage.getItem(TOKEN_KEY);
  if (t) setAuthToken(t);
  return t;
}
