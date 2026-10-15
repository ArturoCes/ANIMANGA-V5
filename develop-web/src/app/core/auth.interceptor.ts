import { HttpErrorResponse, HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { catchError, throwError } from 'rxjs';
import { API } from './api';
import { AuthService } from './auth.service';
import { NotifyService } from './notify.service';

/** Añade el token JWT a las peticiones a la API y cierra la sesión si caduca. */
export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const auth = inject(AuthService);
  const notify = inject(NotifyService);
  const isApi = req.url.startsWith(API);
  const isLogin = req.url.endsWith('auth/login');
  const token = auth.token;

  const request =
    isApi && token && !isLogin
      ? req.clone({ setHeaders: { Authorization: `Bearer ${token}` } })
      : req;

  return next(request).pipe(
    catchError((err: HttpErrorResponse) => {
      const expired =
        err.status === 401 ||
        (err.status === 403 && /jwt|token/i.test(err.error?.message ?? ''));
      if (isApi && !isLogin && token && expired) {
        auth.logout();
        notify.error('Tu sesión ha caducado. Vuelve a iniciar sesión.');
      }
      return throwError(() => err);
    })
  );
};
