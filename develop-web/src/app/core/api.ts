import { HttpErrorResponse } from '@angular/common/http';
import { environment } from '../../environments/environment';

/** URL base de la API, siempre terminada en "/". */
export const API = environment.apiBaseUrl.endsWith('/')
  ? environment.apiBaseUrl
  : environment.apiBaseUrl + '/';

/** Convierte un nombre de fichero devuelto por la API en una URL de imagen. */
export function imageUrl(path: string | null | undefined): string {
  if (!path) return 'assets/img/no-cover.svg';
  if (path.startsWith('http')) return path;
  return `${API}download/${encodeURIComponent(path)}`;
}

/** Empaqueta un objeto como parte JSON de un multipart/form-data (@RequestPart en Spring). */
export function jsonPart(name: string, value: unknown, form = new FormData()): FormData {
  form.append(name, new Blob([JSON.stringify(value)], { type: 'application/json' }));
  return form;
}

/** Extrae un mensaje legible de los dos formatos de error que devuelve la API. */
export function errorMessage(err: unknown): string {
  if (err instanceof HttpErrorResponse) {
    if (err.status === 0) return 'No se puede conectar con el servidor';
    const body = err.error ?? {};
    const sub: { mensaje?: string }[] = body.subErrores ?? [];
    if (sub.length) return sub.map((s) => s.mensaje).join('. ');
    return body.mensaje ?? body.message ?? `Error ${err.status}`;
  }
  return 'Ha ocurrido un error inesperado';
}
