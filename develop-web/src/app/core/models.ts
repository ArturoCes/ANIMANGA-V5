export interface Page<T> {
  content: T[];
  page: number;
  size: number;
  totalElements: number;
  totalPages: number;
  last: boolean;
}

export interface Category {
  id: string;
  name: string;
  description: string | null;
}

export interface CategoryRef {
  id: string;
  name: string;
}

export interface Volume {
  id: string;
  mangaId: string;
  mangaTitle: string;
  number: number;
  title: string;
  price: number;
  isbn: string | null;
  stock: number;
  coverImage: string;
}

export interface MangaCharacter {
  id: string;
  name: string;
  age: number | null;
  description: string | null;
  image: string | null;
}

export interface MangaSummary {
  id: string;
  title: string;
  author: string | null;
  publisher: string | null;
  releaseDate: string | null;
  coverImage: string;
  categories: CategoryRef[];
  minPrice: number | null;
  ratingAverage: number;
  ratingCount: number;
  volumeCount: number;
  inStock: boolean;
  unitsSold: number;
}

export interface MangaDetail extends Omit<MangaSummary, 'volumeCount'> {
  synopsis: string;
  volumes: Volume[];
  characters: MangaCharacter[];
}

export type Role = 'ADMIN' | 'USER';

export interface User {
  id: string;
  username: string;
  fullName: string;
  email: string;
  avatar: string | null;
  role: Role;
  emailVerified: boolean;
  createdAt: string;
}

export interface AuthResponse {
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
  user: User;
}

export type OrderStatus = 'PAID' | 'SHIPPED' | 'DELIVERED' | 'CANCELLED';

export interface OrderLine {
  volumeId: string | null;
  mangaId: string | null;
  volumeTitle: string;
  mangaTitle: string;
  coverImage: string | null;
  unitPrice: number;
  quantity: number;
  subtotal: number;
}

export interface Order {
  id: string;
  number: string;
  status: OrderStatus;
  createdAt: string;
  updatedAt: string;
  customer: { id: string; username: string; fullName: string; email: string };
  shipping: { fullName: string; address: string; city: string; postalCode: string; phone: string };
  cardLast4: string;
  total: number;
  totalUnits: number;
  items: OrderLine[];
}

export interface Review {
  id: string;
  rating: number;
  comment: string | null;
  createdAt: string;
  author: { username: string; fullName: string; avatar: string | null };
  verifiedPurchase: boolean;
}

export interface Stats {
  totals: {
    mangas: number;
    volumes: number;
    unitsInStock: number;
    customers: number;
    orders: number;
    revenue: number;
    averageOrder: number;
  };
  revenueByMonth: { month: string; revenue: number; orders: number; units: number }[];
  ordersByStatus: Record<OrderStatus, number>;
  topVolumes: { volumeId: string; title: string; coverImage: string; units: number; revenue: number }[];
  lowStock: Volume[];
  recentOrders: Order[];
}

export interface MangaPayload {
  title: string;
  author: string;
  publisher: string;
  releaseDate: string | null;
  synopsis: string;
  categoryIds: string[];
}

export interface VolumePayload {
  number: number;
  title: string;
  price: number;
  isbn: string;
  stock: number;
}

export interface CharacterPayload {
  name: string;
  age: number | null;
  description: string;
}

export interface CategoryPayload {
  name: string;
  description: string;
}

export const ORDER_STATUS_LABEL: Record<OrderStatus, string> = {
  PAID: 'Pagado',
  SHIPPED: 'Enviado',
  DELIVERED: 'Entregado',
  CANCELLED: 'Cancelado',
};
