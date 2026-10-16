import { HttpErrorResponse, HttpInterceptorFn, HttpRequest } from '@angular/common/http';
import { inject } from '@angular/core';
import { catchError, switchMap, throwError } from 'rxjs';
import { API } from './api';
import { AuthService } from './auth.service';
import { NotifyService } from './notify.service';

function withToken(req: HttpRequest<unknown>, token: string | null): HttpRequest<unknown> {
  return token ? req.clone({ setHeaders: { Authorization: `Bearer ${token}` } }) : req;
}

/**
 * Añade el token a las peticiones a la API. Si el servidor responde 401 (token caducado),
 * renueva la sesión con el refresh token y repite la petición una vez.
 */
export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const auth = inject(AuthService);
  const notify = inject(NotifyService);
  const isApi = req.url.startsWith(API);
  const isAuthCall = req.url.startsWith(`${API}auth/`);

  if (!isApi || isAuthCall) return next(req);

  return next(withToken(req, auth.accessToken)).pipe(
    catchError((err: HttpErrorResponse) => {
      if (err.status !== 401 || !auth.user()) return throwError(() => err);
      return auth.refresh().pipe(
        switchMap((token) => next(withToken(req, token))),
        catchError((refreshError) => {
          auth.logout();
          notify.error('Tu sesión ha caducado. Vuelve a iniciar sesión.');
          return throwError(() => refreshError);
        })
      );
    })
  );
};
