import { API_CONFIG, type ApiResponse } from '../config/api';

let token: string | null = null;

export function setAuthToken(t: string | null) {
  token = t;
}

export function getAuthToken(): string | null {
  return token;
}

export class ApiError extends Error {
  constructor(
    message: string,
    public status: number,
    public data?: ApiResponse<unknown>
  ) {
    super(message);
    this.name = 'ApiError';
  }
}

async function request<T>(
  path: string,
  options: RequestInit & { timeout?: number } = {}
): Promise<ApiResponse<T>> {
  const { timeout = API_CONFIG.timeout, ...fetchOptions } = options;
  const url = path.startsWith('http') ? path : `${API_CONFIG.baseUrl}${path.startsWith('/') ? '' : '/'}${path}`;
  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
    Accept: 'application/json',
    ...((fetchOptions.headers as Record<string, string>) || {}),
  };
  if (token) headers['Authorization'] = `Bearer ${token}`;

  const controller = new AbortController();
  const id = setTimeout(() => controller.abort(), timeout);

  try {
    const res = await fetch(url, {
      ...fetchOptions,
      headers,
      signal: controller.signal,
    });
    clearTimeout(id);
    const json = (await res.json().catch(() => ({}))) as ApiResponse<T>;
    if (!res.ok) {
      throw new ApiError(
        json.message || `HTTP ${res.status}`,
        res.status,
        json
      );
    }
    return json;
  } catch (e) {
    clearTimeout(id);
    if (e instanceof ApiError) throw e;
    if (e instanceof Error) throw new ApiError(e.message, 0);
    throw new ApiError('Error de red', 0);
  }
}

export const api = {
  get: <T>(path: string) => request<T>(path, { method: 'GET' }),
  post: <T>(path: string, body?: object) =>
    request<T>(path, { method: 'POST', body: body ? JSON.stringify(body) : undefined }),
  put: <T>(path: string, body?: object) =>
    request<T>(path, { method: 'PUT', body: body ? JSON.stringify(body) : undefined }),
  patch: <T>(path: string, body?: object) =>
    request<T>(path, { method: 'PATCH', body: body ? JSON.stringify(body) : undefined }),
  delete: <T>(path: string) => request<T>(path, { method: 'DELETE' }),
};
