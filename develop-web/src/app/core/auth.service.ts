import { HttpClient } from '@angular/common/http';
import { Injectable, computed, signal } from '@angular/core';
import { Router } from '@angular/router';
import { Observable, tap } from 'rxjs';
import { API } from './api';
import { LoginResponse, User } from './models';

const TOKEN_KEY = 'animanga.token';
const USER_KEY = 'animanga.user';

@Injectable({ providedIn: 'root' })
export class AuthService {
  private readonly _user = signal<User | null>(this.readUser());

  readonly user = this._user.asReadonly();
  readonly isAdmin = computed(() => this._user()?.role === 'ADMIN');

  constructor(private http: HttpClient, private router: Router) {}

  get token(): string | null {
    return localStorage.getItem(TOKEN_KEY);
  }

  login(username: string, password: string): Observable<LoginResponse> {
    return this.http
      .post<LoginResponse>(`${API}auth/login`, { username, password })
      .pipe(
        tap((res) => {
          localStorage.setItem(TOKEN_KEY, res.token);
          this.setUser(res);
        })
      );
  }

  /** Actualiza los datos del usuario en sesión (p. ej. tras editar el perfil). */
  setUser(user: User): void {
    const { id, username, fullName, email, image, role, idCart, createdAt } = user;
    const clean: User = { id, username, fullName, email, image, role, idCart, createdAt };
    localStorage.setItem(USER_KEY, JSON.stringify(clean));
    this._user.set(clean);
  }

  logout(redirect = true): void {
    localStorage.removeItem(TOKEN_KEY);
    localStorage.removeItem(USER_KEY);
    this._user.set(null);
    if (redirect) this.router.navigate(['/login']);
  }

  private readUser(): User | null {
    try {
      const raw = localStorage.getItem(USER_KEY);
      return raw ? (JSON.parse(raw) as User) : null;
    } catch {
      return null;
    }
  }
}
