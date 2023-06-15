import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { catchError, forkJoin, Observable, of, throwError } from 'rxjs';

import { map, switchMap, } from 'rxjs/operators';
import { environment } from '../environments/environment.prod';
import { User, UserResponse } from '../models/interfaces/userResponse';
import Swal from 'sweetalert2';
import { SearchUserDto } from '../models/dto/searchDto';
import { PurchaseResponse } from '../models/interfaces/purchaseResponse';

const TOKEN = 'token';

@Injectable({
  providedIn: 'root'
})
export class UserService {

  constructor(private http:HttpClient) { }

  userBaseUrl =  `${environment.API_BASE_URL}`;

  findAllUsers(page:String, size:String):Observable<UserResponse>{
    let encabezados= new HttpHeaders({
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${localStorage.getItem(TOKEN)}`
    })
    return this.http.get<UserResponse>(`${this.userBaseUrl}all?size=${size}&page=${page}`, { headers: encabezados });
  }

  create(user: User, file:File){
    let encabezados= new HttpHeaders({
      'Authorization': `Bearer ${localStorage.getItem(TOKEN)}`
    });
    let formData = new FormData();
    formData.append('user', new Blob([JSON.stringify(user)], {
      type: 'application/json'
    }));
    formData.append("file", file);
    return this.http.post<User>('/auth/register', formData, { headers: encabezados });
  }

  findById(idUser: number){
    return this.http.get<User>(`${this.userBaseUrl}${idUser}`);
  }

  update(user: any, idUser: String){
    let formData = new FormData();
    formData.append('user', new Blob([JSON.stringify(user)], {
      type: 'application/json'
    }));
    let encabezados= new HttpHeaders({
      'Authorization': `Bearer ${localStorage.getItem(TOKEN)}`
    });
    return this.http.put<User>(`${this.userBaseUrl}${idUser}`, formData, { headers: encabezados });
  }

  delete(idUser: String){
    let encabezados= new HttpHeaders({
      'Authorization': `Bearer ${localStorage.getItem(TOKEN)}`
    });
    return this.http.delete(`${this.userBaseUrl}${idUser}`, { headers: encabezados });
  }

  updateAvatar(file: File, idUser: String){
    let encabezados= new HttpHeaders({
      'Authorization': `Bearer ${localStorage.getItem(TOKEN)}`
    });

    let formData = new FormData();
    formData.append("image", file);
    return this.http.put<User>(`${this.userBaseUrl}image/${idUser}`, formData, { headers: encabezados });
  }

  changePassword(changePassword: any){
    let formData = new FormData();
    formData.append('user', new Blob([JSON.stringify(changePassword)], {
      type: 'application/json'
    }));
    let encabezados= new HttpHeaders({
      'Authorization': `Bearer ${localStorage.getItem(TOKEN)}`
    });
    return this.http.put<User>(`${this.userBaseUrl}change/`, formData, { headers: encabezados });
  }

  giveAdmin(idUser: String){
    let encabezados= new HttpHeaders({
      'Authorization': `Bearer ${localStorage.getItem(TOKEN)}`
    });
    return this.http.put<User>(`${this.userBaseUrl}give/admin/${idUser}`, null, { headers: encabezados });
  }

  removeAdmin(idUser: String){
    let encabezados= new HttpHeaders({
      'Authorization': `Bearer ${localStorage.getItem(TOKEN)}`
    });
    console.log(localStorage.getItem(TOKEN));
    return this.http.put<User>(`${this.userBaseUrl}remove/admin/${idUser}`, null, { headers: encabezados });
  }

  buscar(searchUserDto: SearchUserDto){
    let encabezados= new HttpHeaders({
      'Authorization': `Bearer ${localStorage.getItem(TOKEN)}`
    });
    let formData = new FormData();
    formData.append('search', new Blob([JSON.stringify(searchUserDto)], {
      type: 'application/json'
    }));
    return this.http.post<UserResponse>(`${this.userBaseUrl}find/`, formData, { headers: encabezados });
  }

  editarUsuario(user: any, file: File, idUser: String, changePassword?: any) {
    let encabezados = new HttpHeaders({
      'Authorization': `Bearer ${localStorage.getItem(TOKEN)}`
    });

    let formData = new FormData();
    formData.append('user', new Blob([JSON.stringify(user)], {
      type: 'application/json'
    }));

    return this.http.put<User>(`${this.userBaseUrl}user/${idUser}`, formData, { headers: encabezados }).pipe(
      switchMap(user => {
        if (file) {
          let formData2 = new FormData();
          formData2.append("image", file);
          return this.http.put<User>(`${this.userBaseUrl}image/${idUser}`, formData2, { headers: encabezados }).pipe(
            map(user2 => ({ user, user2 })),
            catchError(err => this.handleHttpError(err))
          );
        } else {
          return of({ user });
        }
      }),
      switchMap(userObj => {
        if (changePassword) {
          let formData3 = new FormData();
          formData3.append('user', new Blob([JSON.stringify(changePassword)], {
            type: 'application/json'
          }));
          return this.http.put<User>(`${this.userBaseUrl}change`, formData3, { headers: encabezados }).pipe(
            map(user2 => ({ ...userObj, user2 })),
            catchError(err => this.handleHttpError(err))
          );
        } else {
          return of(userObj);
        }
      }),
    ).subscribe({
      next: user2 => Swal.fire('Cambios Guardados', '', 'success').then(r => {
        history.go(0);
      }),
      error: err => this.handleHttpError(err),
    });
  }
  findAllPurchases(page: string, size: string): Observable<PurchaseResponse> {
    let headers = new HttpHeaders({
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${localStorage.getItem(TOKEN)}`
    });
    return this.http.get<PurchaseResponse>(`${environment.API_BASE_URL}purchase/all?size=${size}&page=${page}`, { headers: headers });
  }

  private handleHttpError(err: any) {
    Swal.fire({
      icon: 'error',
      title: 'Oops...',
      text: err.error.mensaje,
    });
    return throwError(err);
  }

}
