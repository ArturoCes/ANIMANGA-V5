import { HttpClient } from '@angular/common/http';
import { Injectable, computed, signal } from '@angular/core';
import { Router } from '@angular/router';
import { Observable, finalize, map, shareReplay, tap } from 'rxjs';
import { API } from './api';
import { AuthResponse, User } from './models';

const ACCESS_KEY = 'animanga.access';
const REFRESH_KEY = 'animanga.refresh';
const USER_KEY = 'animanga.user';

@Injectable({ providedIn: 'root' })
export class AuthService {
  private readonly _user = signal<User | null>(this.readUser());
  private refreshing$: Observable<string> | null = null;

  readonly user = this._user.asReadonly();
  readonly isAdmin = computed(() => this._user()?.role === 'ADMIN');

  constructor(private http: HttpClient, private router: Router) {}

  get accessToken(): string | null {
    return localStorage.getItem(ACCESS_KEY);
  }

  login(username: string, password: string): Observable<User> {
    return this.http
      .post<AuthResponse>(`${API}auth/login`, { username, password })
      .pipe(tap((res) => this.store(res)), map((res) => res.user));
  }

  /**
   * Renueva la sesión con el refresh token. Si varias peticiones caducan a la vez,
   * todas esperan a la misma renovación.
   */
  refresh(): Observable<string> {
    if (!this.refreshing$) {
      const refreshToken = localStorage.getItem(REFRESH_KEY) ?? '';
      this.refreshing$ = this.http.post<AuthResponse>(`${API}auth/refresh`, { refreshToken }).pipe(
        tap((res) => this.store(res)),
        map((res) => res.accessToken),
        finalize(() => (this.refreshing$ = null)),
        shareReplay(1)
      );
    }
    return this.refreshing$;
  }

  setUser(user: User): void {
    localStorage.setItem(USER_KEY, JSON.stringify(user));
    this._user.set(user);
  }

  logout(redirect = true): void {
    const refreshToken = localStorage.getItem(REFRESH_KEY);
    if (refreshToken) this.http.post(`${API}auth/logout`, { refreshToken }).subscribe({ error: () => {} });
    localStorage.removeItem(ACCESS_KEY);
    localStorage.removeItem(REFRESH_KEY);
    localStorage.removeItem(USER_KEY);
    this._user.set(null);
    if (redirect) this.router.navigate(['/login']);
  }

  private store(res: AuthResponse): void {
    localStorage.setItem(ACCESS_KEY, res.accessToken);
    localStorage.setItem(REFRESH_KEY, res.refreshToken);
    this.setUser(res.user);
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
