import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';

import { EMPTY, Observable, of } from 'rxjs';

import { catchError, map, switchMap } from 'rxjs/operators';
import Swal from 'sweetalert2';
import { environment } from '../environments/environment.prod';
import { Manga, MangaResponse } from '../models/interfaces/mangaResponse';
import { CreateMangaDto } from '../models/dto/createMangaDto';

const TOKEN = 'token';

@Injectable({
  providedIn: 'root',
})
export class MangaService {
  constructor(private http: HttpClient) {}

  mangaBaseUrl = `${environment.API_BASE_URL}manga`;

  findAllMangas(page: String, size: String): Observable<MangaResponse> {
    let encabezados = new HttpHeaders({
      'Content-Type': 'application/json',
      Authorization: `Bearer ${localStorage.getItem(TOKEN)}`,
    });
    return this.http.get<MangaResponse>(
      `${this.mangaBaseUrl}/all?size=${size}&page=${page}`,
      { headers: encabezados }
    );
  }

  create(manga: CreateMangaDto, file: File) {
    let encabezados = new HttpHeaders({
      Authorization: `Bearer ${localStorage.getItem(TOKEN)}`,
    });
    let formData = new FormData();
    formData.append(
      'manga',
      new Blob([JSON.stringify(manga)], {
        type: 'application/json',
      })
    );
    formData.append('file', file);
    return this.http.post<Manga>(`${this.mangaBaseUrl}/new`, formData, {
      headers: encabezados,
    });
  }

  findById(idManga: string) {
    let encabezados = new HttpHeaders({
      Authorization: `Bearer ${localStorage.getItem(TOKEN)}`,
    });
    return this.http.get<Manga>(`${this.mangaBaseUrl}/${idManga}`, {
      headers: encabezados,
    });
  }

  update(manga: any, idManga: number) {
    let encabezados = new HttpHeaders({
      Authorization: `Bearer ${localStorage.getItem(TOKEN)}`,
    });
    return this.http.put<Manga>(`${this.mangaBaseUrl}/${idManga}`, manga, {
      headers: encabezados,
    });
  }

  delete(idManga: String) {
    let encabezados = new HttpHeaders({
      Authorization: `Bearer ${localStorage.getItem(TOKEN)}`,
    });
    return this.http.delete(`${this.mangaBaseUrl}/${idManga}`, {
      headers: encabezados,
    });
  }

  updateCover(file: File, idManga: String) {
    let encabezados = new HttpHeaders({
      Authorization: `Bearer ${localStorage.getItem(TOKEN)}`,
    });

    let formData = new FormData();
    formData.append('file', file);
    return this.http.put<Manga>(
      `${this.mangaBaseUrl}/cover/${idManga}`,
      formData,
      { headers: encabezados }
    );
  }

  getCover(cover: String) {
    let encabezados = new HttpHeaders({
      Authorization: `Bearer ${localStorage.getItem(TOKEN)}`,
    });
    return this.http.get(`${cover}`, { headers: encabezados });
  }

  buscar(name: String) {
    let encabezados = new HttpHeaders({
      Authorization: `Bearer ${localStorage.getItem(TOKEN)}`,
    });
    let formData = new FormData();
    formData.append(
      'search',
      new Blob([JSON.stringify(name)], {
        type: 'application/json',
      })
    );
    return this.http.post<MangaResponse>(
      `${this.mangaBaseUrl}/search/all`,
      formData,
      { headers: encabezados }
    );
  }

  editarManga(createMangaDto: any, idManga: string, file: File) {
    let encabezados = new HttpHeaders({
      Authorization: `Bearer ${localStorage.getItem(TOKEN)}`,
    });

    let formData2 = new FormData();
    formData2.append(
      'manga',
      new Blob([JSON.stringify(createMangaDto)], {
        type: 'application/json',
      })
    );

    let formData = new FormData();
    formData.append('file', file);

    return this.http
      .put<Manga>(`${this.mangaBaseUrl}/${idManga}`, formData2, {
        headers: encabezados,
      })
      .pipe(
        switchMap((manga) =>
          file != undefined
            ? this.http
                .put<Manga>(
                  `${this.mangaBaseUrl}/poster/${idManga}`,
                  formData,
                  {
                    headers: encabezados,
                  }
                )
                .pipe(map((manga2) => ({ manga, manga2 })))
            : of({ manga2: manga })
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
        next: (manga2) =>
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
