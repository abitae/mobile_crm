/**
 * Configuración de la API Cazador.
 * Base URL: prueba o producción según env / build.
 */
export const API_CONFIG = {
  /** Base URL de la API (sin trailing slash). Prueba por defecto. */
  baseUrl: 'https://v1.lotesenremate.pe/api/cazador',
  /** Timeout de peticiones en ms */
  timeout: 30000,
} as const;

export type ApiResponse<T> = {
  success: boolean;
  message: string;
  data?: T;
  errors?: Record<string, string[]>;
};

export type Pagination = {
  current_page: number;
  per_page: number;
  total: number;
  last_page: number;
  from: number;
  to: number;
  links: { first: string; last: string; prev: string | null; next: string | null };
};
