import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { EMPTY, Observable, of } from 'rxjs';
import { catchError, map, switchMap } from 'rxjs/operators';
import { tap } from 'rxjs/operators';
import Swal from 'sweetalert2';
import { environment } from '../environments/environment.prod';
import { Volumen } from '../models/interfaces/mangaResponse';
import { CreateVolumenDto } from '../models/dto/createVolumenDto';

const TOKEN = 'token';

@Injectable({
  providedIn: 'root',
})
export class VolumenService {
  constructor(private http: HttpClient) {}

  volumenBaseUrl = `${environment.API_BASE_URL}volumen`;

  findAllVolumenes(page: String, size: String): Observable<any> {
    let encabezados = new HttpHeaders({
      'Content-Type': 'application/json',
      Authorization: `Bearer ${localStorage.getItem(TOKEN)}`,
    });
    return this.http.get<any>(
      `${this.volumenBaseUrl}/all?size=${size}&page=${page}`,
      { headers: encabezados }
    );
  }

  create(volumen: any, idManga: String, file: File) {
    let encabezados = new HttpHeaders({
      Authorization: `Bearer ${localStorage.getItem(TOKEN)}`,
    });
    let formData = new FormData();
    formData.append(
      'volumen',
      new Blob([JSON.stringify(volumen)], {
        type: 'application/json',
      })
    );
    formData.append('file', file);
    return this.http.post<Volumen>(
      `${this.volumenBaseUrl}/new/${idManga}`,
      formData,
      { headers: encabezados }
    );
  }

  findById(idVolumen: number) {
    return this.http.get<Volumen>(`${this.volumenBaseUrl}/${idVolumen}`);
  }

  update(volumen: any, idVolumen: String) {
    let encabezados = new HttpHeaders({
      Authorization: `Bearer ${localStorage.getItem(TOKEN)}`,
    });
    return this.http.put<Volumen>(
      `${this.volumenBaseUrl}/${idVolumen}`,
      volumen,
      { headers: encabezados }
    );
  }

  delete(idVolumen: String) {
    let encabezados = new HttpHeaders({
      Authorization: `Bearer ${localStorage.getItem(TOKEN)}`,
    });
    return this.http.delete(`${this.volumenBaseUrl}/${idVolumen}`, {
      headers: encabezados,
    });
  }

  updateFile(file: File, idVolumen: String) {
    let encabezados = new HttpHeaders({
      Authorization: `Bearer ${localStorage.getItem(TOKEN)}`,
    });

    let formData = new FormData();
    formData.append('file', file);
    return this.http.put<Volumen>(
      `${this.volumenBaseUrl}/file/${idVolumen}`,
      formData,
      { headers: encabezados }
    );
  }

  /*   buscar(name: String){
    let encabezados= new HttpHeaders({
      'Authorization': `Bearer ${localStorage.getItem(TOKEN)}`
    });
    let formData = new FormData();
    formData.append('search', new Blob([JSON.stringify(name)], {
      type: 'application/json'
    }));
    return this.http.post<ChapterResponse>(`${this.chapterBaseUrl}/search/all`, formData, { headers: encabezados });
  } */

  editarVolumen(volumen: CreateVolumenDto, idVolumen: String, file: File) {
    let encabezados = new HttpHeaders({
      Authorization: `Bearer ${localStorage.getItem(TOKEN)}`,
    });

    let formData2 = new FormData();
    formData2.append(
      'volumen',
      new Blob([JSON.stringify(volumen)], {
        type: 'application/json',
      })
    );

    let formData = new FormData();
    formData.append('file', file);

    return this.http
      .put<Volumen>(`${this.volumenBaseUrl}/${idVolumen}`, formData2, {
        headers: encabezados,
      })
      .pipe(
        switchMap((volumen) =>
          file != undefined
            ? this.http
                .put<Volumen>(
                  `${this.volumenBaseUrl}/file/${idVolumen}`,
                  formData,
                  { headers: encabezados }
                )
                .pipe(map((volumen2) => ({ volumen, volumen2 })))
            : of({ volumen2: volumen })
        ),
        catchError((err) => {
          Swal.fire({
            icon: 'error',
            title: 'Oops...',
            text: err.error.mensaje,
          });
          return EMPTY;
        })
      )
      .subscribe({
        next: (volumenData) =>
          Swal.fire('Cambios Guardados', '', 'success').then((r) => {
            history.go(0);
          }),
        error: (err) =>
          Swal.fire({
            icon: 'error',
            title: 'Oops...',
            text: err.error.mensaje,
          }),
      });
  }
}
