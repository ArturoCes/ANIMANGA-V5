import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { API, jsonPart } from './api';
import {
  Category,
  CategoryPayload,
  CharacterPayload,
  MangaCharacter,
  MangaDetail,
  MangaPayload,
  MangaSummary,
  Page,
  Review,
  Volume,
  VolumePayload,
} from './models';

export interface MangaQuery {
  q?: string;
  category?: string;
  sort?: string;
  page?: number;
  size?: number;
}

function params(values: Record<string, string | number | undefined | null>): HttpParams {
  let p = new HttpParams();
  Object.entries(values).forEach(([k, v]) => {
    if (v !== undefined && v !== null && v !== '') p = p.set(k, v);
  });
  return p;
}

function filePart(name: string, file: File, form = new FormData()): FormData {
  form.append(name, file);
  return form;
}

@Injectable({ providedIn: 'root' })
export class CatalogService {
  constructor(private http: HttpClient) {}

  // ---------- Mangas
  mangas(query: MangaQuery = {}): Observable<Page<MangaSummary>> {
    return this.http.get<Page<MangaSummary>>(`${API}mangas`, { params: params({ size: 10, ...query }) });
  }

  manga(id: string): Observable<MangaDetail> {
    return this.http.get<MangaDetail>(`${API}mangas/${id}`);
  }

  publishers(): Observable<string[]> {
    return this.http.get<string[]>(`${API}mangas/publishers`);
  }

  createManga(manga: MangaPayload, cover: File): Observable<MangaDetail> {
    return this.http.post<MangaDetail>(`${API}mangas`, filePart('cover', cover, jsonPart('manga', manga)));
  }

  updateManga(id: string, manga: MangaPayload): Observable<MangaDetail> {
    return this.http.put<MangaDetail>(`${API}mangas/${id}`, manga);
  }

  updateMangaCover(id: string, cover: File): Observable<MangaDetail> {
    return this.http.put<MangaDetail>(`${API}mangas/${id}/cover`, filePart('cover', cover));
  }

  deleteManga(id: string): Observable<void> {
    return this.http.delete<void>(`${API}mangas/${id}`);
  }

  // ---------- Volúmenes
  createVolume(mangaId: string, volume: VolumePayload, cover: File): Observable<Volume> {
    return this.http.post<Volume>(`${API}mangas/${mangaId}/volumes`, filePart('cover', cover, jsonPart('volume', volume)));
  }

  updateVolume(id: string, volume: VolumePayload): Observable<Volume> {
    return this.http.put<Volume>(`${API}volumes/${id}`, volume);
  }

  updateVolumeCover(id: string, cover: File): Observable<Volume> {
    return this.http.put<Volume>(`${API}volumes/${id}/cover`, filePart('cover', cover));
  }

  deleteVolume(id: string): Observable<void> {
    return this.http.delete<void>(`${API}volumes/${id}`);
  }

  // ---------- Personajes
  createCharacter(mangaId: string, character: CharacterPayload, image: File | null): Observable<MangaCharacter> {
    const form = jsonPart('character', character);
    if (image) form.append('image', image);
    return this.http.post<MangaCharacter>(`${API}mangas/${mangaId}/characters`, form);
  }

  updateCharacter(id: string, character: CharacterPayload): Observable<MangaCharacter> {
    return this.http.put<MangaCharacter>(`${API}characters/${id}`, character);
  }

  updateCharacterImage(id: string, image: File): Observable<MangaCharacter> {
    return this.http.put<MangaCharacter>(`${API}characters/${id}/image`, filePart('image', image));
  }

  deleteCharacter(id: string): Observable<void> {
    return this.http.delete<void>(`${API}characters/${id}`);
  }

  // ---------- Reseñas
  reviews(mangaId: string, page = 0, size = 5): Observable<Page<Review>> {
    return this.http.get<Page<Review>>(`${API}mangas/${mangaId}/reviews`, { params: params({ page, size }) });
  }

  deleteReview(id: string): Observable<void> {
    return this.http.delete<void>(`${API}reviews/${id}`);
  }

  // ---------- Categorías
  categories(): Observable<Category[]> {
    return this.http.get<Category[]>(`${API}categories`);
  }

  createCategory(category: CategoryPayload): Observable<Category> {
    return this.http.post<Category>(`${API}categories`, category);
  }

  updateCategory(id: string, category: CategoryPayload): Observable<Category> {
    return this.http.put<Category>(`${API}categories/${id}`, category);
  }

  deleteCategory(id: string): Observable<void> {
    return this.http.delete<void>(`${API}categories/${id}`);
  }
}
