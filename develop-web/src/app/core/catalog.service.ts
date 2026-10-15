import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { API, jsonPart } from './api';
import {
  Category,
  CategoryPayload,
  Manga,
  MangaPayload,
  Page,
  Volumen,
  VolumenPayload,
} from './models';

function pageParams(page: number, size: number): HttpParams {
  return new HttpParams().set('page', page).set('size', size);
}

@Injectable({ providedIn: 'root' })
export class CatalogService {
  constructor(private http: HttpClient) {}

  // ---------- Mangas
  mangas(page = 0, size = 10): Observable<Page<Manga>> {
    return this.http.get<Page<Manga>>(`${API}manga/all`, { params: pageParams(page, size) });
  }

  searchMangas(name: string, page = 0, size = 10): Observable<Page<Manga>> {
    return this.http.post<Page<Manga>>(`${API}manga/search/all`, jsonPart('search', { name }), {
      params: pageParams(page, size),
    });
  }

  manga(id: string): Observable<Manga> {
    return this.http.get<Manga>(`${API}manga/${id}`);
  }

  createManga(manga: MangaPayload, cover: File): Observable<Manga> {
    const form = jsonPart('manga', manga);
    form.append('file', cover);
    return this.http.post<Manga>(`${API}manga/new`, form);
  }

  updateManga(id: string, manga: MangaPayload): Observable<Manga> {
    return this.http.put<Manga>(`${API}manga/${id}`, jsonPart('manga', manga));
  }

  updateMangaCover(id: string, cover: File): Observable<Manga> {
    const form = new FormData();
    form.append('file', cover);
    return this.http.put<Manga>(`${API}manga/poster/${id}`, form);
  }

  deleteManga(id: string): Observable<void> {
    return this.http.delete<void>(`${API}manga/${id}`);
  }

  // ---------- Volúmenes
  volumenes(page = 0, size = 100): Observable<Page<Volumen>> {
    return this.http.get<Page<Volumen>>(`${API}volumen/all`, { params: pageParams(page, size) });
  }

  createVolumen(idManga: string, volumen: VolumenPayload, cover: File): Observable<Volumen> {
    const form = jsonPart('volumen', volumen);
    form.append('file', cover);
    return this.http.post<Volumen>(`${API}volumen/new/${idManga}`, form);
  }

  updateVolumen(id: string, volumen: VolumenPayload): Observable<Volumen> {
    return this.http.put<Volumen>(`${API}volumen/${id}`, jsonPart('volumen', volumen));
  }

  updateVolumenCover(id: string, cover: File): Observable<Volumen> {
    const form = new FormData();
    form.append('file', cover);
    return this.http.put<Volumen>(`${API}volumen/poster/${id}`, form);
  }

  deleteVolumen(id: string): Observable<void> {
    return this.http.delete<void>(`${API}volumen/${id}`);
  }

  // ---------- Categorías
  categories(page = 0, size = 100): Observable<Page<Category>> {
    return this.http.get<Page<Category>>(`${API}category/all`, { params: pageParams(page, size) });
  }

  createCategory(category: CategoryPayload): Observable<Category> {
    return this.http.post<Category>(`${API}category/new`, jsonPart('category', category));
  }

  updateCategory(id: string, category: CategoryPayload): Observable<Category> {
    return this.http.put<Category>(`${API}category/${id}`, jsonPart('category', category));
  }

  deleteCategory(id: string): Observable<void> {
    return this.http.delete<void>(`${API}category/${id}`);
  }
}
