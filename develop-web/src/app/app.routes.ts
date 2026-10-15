import { Routes } from '@angular/router';
import { adminGuard, guestGuard } from './core/admin.guard';
import { ShellComponent } from './layout/shell.component';
import { LoginComponent } from './pages/login/login.component';

export const routes: Routes = [
  { path: 'login', component: LoginComponent, canActivate: [guestGuard], title: 'Iniciar sesión · Animanga' },
  {
    path: '',
    component: ShellComponent,
    canActivate: [adminGuard],
    children: [
      {
        path: '',
        title: 'Resumen · Animanga',
        loadComponent: () => import('./pages/dashboard/dashboard.component').then((m) => m.DashboardComponent),
      },
      {
        path: 'mangas',
        title: 'Mangas · Animanga',
        loadComponent: () => import('./pages/mangas/mangas.component').then((m) => m.MangasComponent),
      },
      {
        path: 'mangas/:id',
        title: 'Manga · Animanga',
        loadComponent: () =>
          import('./pages/manga-detail/manga-detail.component').then((m) => m.MangaDetailComponent),
      },
      {
        path: 'categorias',
        title: 'Categorías · Animanga',
        loadComponent: () => import('./pages/categories/categories.component').then((m) => m.CategoriesComponent),
      },
      {
        path: 'usuarios',
        title: 'Usuarios · Animanga',
        loadComponent: () => import('./pages/users/users.component').then((m) => m.UsersComponent),
      },
      {
        path: 'compras',
        title: 'Compras · Animanga',
        loadComponent: () => import('./pages/purchases/purchases.component').then((m) => m.PurchasesComponent),
      },
      {
        path: 'perfil',
        title: 'Mi perfil · Animanga',
        loadComponent: () => import('./pages/profile/profile.component').then((m) => m.ProfileComponent),
      },
    ],
  },
  { path: '**', redirectTo: '' },
];
