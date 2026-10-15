import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { API, jsonPart } from './api';
import { Page, Purchase, User, UserSearch } from './models';

@Injectable({ providedIn: 'root' })
export class UsersService {
  constructor(private http: HttpClient) {}

  users(page = 0, size = 10): Observable<Page<User>> {
    const params = new HttpParams().set('page', page).set('size', size);
    return this.http.get<Page<User>>(`${API}all`, { params });
  }

  search(search: UserSearch, page = 0, size = 10): Observable<Page<User>> {
    const params = new HttpParams().set('page', page).set('size', size);
    return this.http.post<Page<User>>(`${API}find/`, jsonPart('search', search), { params });
  }

  me(): Observable<User> {
    return this.http.get<User>(`${API}me`);
  }

  update(user: User, changes: { fullName: string; email: string }): Observable<User> {
    return this.http.put<User>(
      `${API}user/${user.id}`,
      jsonPart('user', { ...changes, username: user.username })
    );
  }

  updateAvatar(id: string, image: File): Observable<User> {
    const form = new FormData();
    form.append('image', image);
    return this.http.put<User>(`${API}image/${id}`, form);
  }

  changePassword(password: string, passwordNew: string, passwordNewVerify: string): Observable<User> {
    return this.http.put<User>(
      `${API}change`,
      jsonPart('user', { password, passwordNew, passwordNewVerify })
    );
  }

  setAdmin(id: string, admin: boolean): Observable<User> {
    return this.http.put<User>(`${API}${admin ? 'give' : 'remove'}/admin/${id}`, null);
  }

  delete(id: string): Observable<void> {
    return this.http.delete<void>(`${API}${id}`);
  }

  purchases(page = 0, size = 10): Observable<Page<Purchase>> {
    const params = new HttpParams().set('page', page).set('size', size);
    return this.http.get<Page<Purchase>>(`${API}purchase/all`, { params });
  }
}
