import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { API } from './api';
import { Order, OrderStatus, Page, Role, Stats, User } from './models';

/** Administración (usuarios, pedidos, estadísticas) y la cuenta del propio administrador. */
@Injectable({ providedIn: 'root' })
export class UsersService {
  constructor(private http: HttpClient) {}

  // ---------- Usuarios
  users(query: { q?: string; role?: Role | null; page?: number; size?: number }): Observable<Page<User>> {
    let params = new HttpParams().set('page', query.page ?? 0).set('size', query.size ?? 10);
    if (query.q) params = params.set('q', query.q);
    if (query.role) params = params.set('role', query.role);
    return this.http.get<Page<User>>(`${API}admin/users`, { params });
  }

  update(id: string, changes: { fullName: string; email: string }): Observable<User> {
    return this.http.put<User>(`${API}admin/users/${id}`, changes);
  }

  setRole(id: string, role: Role): Observable<User> {
    return this.http.patch<User>(`${API}admin/users/${id}/role`, { role });
  }

  delete(id: string): Observable<void> {
    return this.http.delete<void>(`${API}admin/users/${id}`);
  }

  // ---------- Pedidos
  orders(query: { status?: OrderStatus | null; q?: string; page?: number; size?: number }): Observable<Page<Order>> {
    let params = new HttpParams().set('page', query.page ?? 0).set('size', query.size ?? 10);
    if (query.status) params = params.set('status', query.status);
    if (query.q) params = params.set('q', query.q);
    return this.http.get<Page<Order>>(`${API}admin/orders`, { params });
  }

  setOrderStatus(id: string, status: OrderStatus): Observable<Order> {
    return this.http.patch<Order>(`${API}admin/orders/${id}/status`, { status });
  }

  // ---------- Estadísticas
  stats(months = 6): Observable<Stats> {
    return this.http.get<Stats>(`${API}admin/stats`, { params: { months } });
  }

  // ---------- Mi cuenta
  me(): Observable<User> {
    return this.http.get<User>(`${API}users/me`);
  }

  updateMe(changes: { fullName: string; email: string }): Observable<User> {
    return this.http.put<User>(`${API}users/me`, changes);
  }

  updateAvatar(image: File): Observable<User> {
    const form = new FormData();
    form.append('image', image);
    return this.http.put<User>(`${API}users/me/avatar`, form);
  }

  changePassword(currentPassword: string, newPassword: string): Observable<void> {
    return this.http.put<void>(`${API}users/me/password`, { currentPassword, newPassword });
  }
}
