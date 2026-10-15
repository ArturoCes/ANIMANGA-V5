export interface Page<T> {
  content: T[];
  totalElements: number;
  totalPages: number;
  number: number;
  size: number;
  empty: boolean;
}

export interface Category {
  id: string;
  name: string;
  description: string;
}

export interface Volumen {
  id: string;
  nombre: string;
  precio: number;
  isbn: string;
  cantidad: number;
  posterPath: string;
  idManga: string;
  nameManga: string;
}

export interface Manga {
  id: string;
  name: string;
  description: string;
  releaseDate: string | null;
  posterPath: string;
  author: string;
  publisher: string;
  categories: Category[];
  volumenes: Volumen[];
}

export type Role = 'ADMIN' | 'USER';

export interface User {
  id: string;
  username: string;
  fullName: string;
  email: string;
  image: string;
  role: Role;
  idCart: string;
  createdAt: string;
}

export interface LoginResponse extends User {
  token: string;
  refreshToken: string;
}

export interface Purchase {
  idPurchase: string;
  numCreditCard: string;
  idUser: string;
  username: string;
  fullName: string;
  idVolumen: string;
  nombreVolumen: string;
  nameManga: string;
  posterPath: string;
  quantity: number;
  precio: number;
  total: number;
  purchaseDate: string;
}

export interface MangaPayload {
  name: string;
  description: string;
  author: string;
  publisher: string;
  releaseDate: string | null;
  categories: { id: string }[];
}

export interface VolumenPayload {
  idManga: string;
  nombre: string;
  precio: number;
  isbn: string;
  cantidad: number;
}

export interface CategoryPayload {
  name: string;
  description: string;
}

export interface UserSearch {
  username?: string;
  fullName?: string;
  email?: string;
  role?: Role | null;
}
