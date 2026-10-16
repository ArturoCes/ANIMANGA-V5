import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { AuthService } from './auth.service';

/** Solo deja pasar a administradores con sesión iniciada. */
export const adminGuard: CanActivateFn = () => {
  const auth = inject(AuthService);
  if (auth.accessToken && auth.isAdmin()) return true;
  auth.logout(false);
  return inject(Router).createUrlTree(['/login']);
};

/** Si ya hay sesión de administrador, la pantalla de login redirige al panel. */
export const guestGuard: CanActivateFn = () => {
  const auth = inject(AuthService);
  return auth.accessToken && auth.isAdmin() ? inject(Router).createUrlTree(['/']) : true;
};
