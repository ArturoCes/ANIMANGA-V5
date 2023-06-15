import { Injectable } from '@angular/core';
import { environment } from '../environments/environment.prod';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs/internal/Observable';
import { LoginResponse } from '../models/interfaces/loginResponse';
import { Router } from '@angular/router';
import { UserNewDto } from '../models/dto/userNewDto';
import { LoginDto } from '../models/dto/loginDto';
import { User } from '../models/interfaces/userResponse';

const TOKEN = 'token';

const DEFAULT_HEADERS = {
  headers: new HttpHeaders({
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  })
};

@Injectable({
  providedIn: 'root'
})
export class AuthService {

  authBaseUrl = `${environment.API_BASE_URL}auth`;

  constructor(private http: HttpClient, private router: Router) { }

  login(loginDto: LoginDto): Observable<LoginResponse> {
    let requestUrl = `${this.authBaseUrl}/login`;
    return this.http.post<LoginResponse>(requestUrl, loginDto, DEFAULT_HEADERS);
  }

  register(userNewDto: UserNewDto): Observable<LoginResponse> {

    let requestUrl = `${this.authBaseUrl}/register`;
    return this.http.post<User>(requestUrl, userNewDto);
  }

  userLogged(): Observable<User> {
    let encabezados = new HttpHeaders({
      'Authorization': `Bearer ${localStorage.getItem(TOKEN)}`
    });
    let requestUrl = `${environment.API_BASE_URL}me`;
    return this.http.get<User>(requestUrl, { headers: encabezados });
  }

  logout() {
    localStorage.clear();
    this.router.navigate(['login']);
  }

  getToken() {
    return localStorage.getItem(TOKEN);
  }

  getRol() {
    return localStorage.getItem('rol');
  }
}
