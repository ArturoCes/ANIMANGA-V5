import { HttpErrorResponse } from '@angular/common/http';
import { environment } from '../../environments/environment';

/** URL base de la API, siempre terminada en "/". */
export const API = environment.apiBaseUrl.endsWith('/')
  ? environment.apiBaseUrl
  : environment.apiBaseUrl + '/';

/** Convierte el nombre de una imagen devuelto por la API en una URL. */
export function imageUrl(name: string | null | undefined): string {
  if (!name) return 'assets/img/no-cover.svg';
  if (name.startsWith('http')) return name;
  return `${API}images/${encodeURIComponent(name)}`;
}

/** Avatar del usuario o uno generado con sus iniciales. */
export function avatarUrl(avatar: string | null | undefined, fullName: string): string {
  if (avatar) return imageUrl(avatar);
  return `https://ui-avatars.com/api/?background=673ab7&color=fff&name=${encodeURIComponent(fullName)}`;
}

/** Empaqueta un objeto como parte JSON de un multipart/form-data (@RequestPart en Spring). */
export function jsonPart(name: string, value: unknown, form = new FormData()): FormData {
  form.append(name, new Blob([JSON.stringify(value)], { type: 'application/json' }));
  return form;
}

/** Extrae un mensaje legible del error de la API. */
export function errorMessage(err: unknown): string {
  if (err instanceof HttpErrorResponse) {
    if (err.status === 0) return 'No se puede conectar con el servidor';
    const body = err.error ?? {};
    if (typeof body.message === 'string' && body.message) return body.message;
    return `Error ${err.status}`;
  }
  return 'Ha ocurrido un error inesperado';
}
