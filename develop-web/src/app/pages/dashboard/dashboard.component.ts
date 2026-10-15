import { Component, OnInit, inject } from '@angular/core';
import { RouterLink } from '@angular/router';
import { forkJoin } from 'rxjs';
import { UI } from '../../shared/material';
import { CatalogService } from '../../core/catalog.service';
import { UsersService } from '../../core/users.service';
import { NotifyService } from '../../core/notify.service';
import { AuthService } from '../../core/auth.service';
import { Purchase, Volumen } from '../../core/models';

interface Stat {
  label: string;
  value: string;
  icon: string;
  link: string;
}

@Component({
  standalone: true,
  imports: [...UI, RouterLink],
  template: `
    <div class="page-header">
      <div>
        <h1>Hola, {{ auth.user()?.fullName }}</h1>
        <p class="muted">Este es el estado actual de la tienda.</p>
      </div>
    </div>

    <mat-progress-bar *ngIf="loading" mode="indeterminate" />

    <div class="stats" *ngIf="!loading">
      <a class="card stat" *ngFor="let s of stats" [routerLink]="s.link">
        <mat-icon>{{ s.icon }}</mat-icon>
        <div>
          <span class="stat-value">{{ s.value }}</span>
          <span class="stat-label">{{ s.label }}</span>
        </div>
      </a>
    </div>

    <div class="grid" *ngIf="!loading">
      <section class="card">
        <div class="card-title">
          <h2>Últimas compras</h2>
          <a mat-button color="primary" routerLink="/compras">Ver todas</a>
        </div>
        <div class="empty" *ngIf="!recent.length">Todavía no hay compras.</div>
        <div class="row" *ngFor="let p of recent">
          <img class="thumb" [src]="p.posterPath | imageUrl" alt="" />
          <div class="row-main">
            <strong>{{ p.nombreVolumen }}</strong>
            <span class="muted">{{ p.fullName }} · {{ p.purchaseDate | date: 'd MMM y, HH:mm' }}</span>
          </div>
          <span class="amount">{{ p.total | currency: 'EUR' }}</span>
        </div>
      </section>

      <section class="card">
        <div class="card-title">
          <h2>Stock bajo</h2>
          <a mat-button color="primary" routerLink="/mangas">Ir al catálogo</a>
        </div>
        <div class="empty" *ngIf="!lowStock.length">Todos los volúmenes tienen stock suficiente.</div>
        <a class="row link" *ngFor="let v of lowStock" [routerLink]="['/mangas', v.idManga]">
          <img class="thumb" [src]="v.posterPath | imageUrl" alt="" />
          <div class="row-main">
            <strong>{{ v.nombre }}</strong>
            <span class="muted">{{ v.nameManga }}</span>
          </div>
          <span class="badge" [class.badge-danger]="v.cantidad === 0" [class.badge-warn]="v.cantidad > 0">
            {{ v.cantidad === 0 ? 'Agotado' : v.cantidad + ' uds.' }}
          </span>
        </a>
      </section>
    </div>
  `,
  styles: [
    `.stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px; margin-bottom: 24px; }
     .stat { display: flex; gap: 16px; align-items: center; text-decoration: none; color: inherit; transition: transform .15s, box-shadow .15s; }
     .stat:hover { transform: translateY(-2px); box-shadow: var(--shadow-lg); }
     .stat mat-icon { width: 48px; height: 48px; font-size: 26px; display: grid; place-items: center; border-radius: 12px; background: var(--brand-soft); color: var(--brand); }
     .stat div { display: flex; flex-direction: column; }
     .stat-value { font-size: 24px; font-weight: 700; }
     .stat-label { color: var(--muted); font-size: 14px; }
     .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(340px, 1fr)); gap: 16px; }
     .card-title { display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px; }
     .card-title h2 { margin: 0; font-size: 18px; }
     .row { display: flex; align-items: center; gap: 12px; padding: 10px 0; border-top: 1px solid var(--border); color: inherit; text-decoration: none; }
     .row.link:hover strong { color: var(--brand); }
     .row-main { flex: 1; display: flex; flex-direction: column; min-width: 0; }
     .row-main strong { white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
     .amount { font-weight: 600; }
     .empty { color: var(--muted); padding: 16px 0; }`,
  ],
})
export class DashboardComponent implements OnInit {
  readonly auth = inject(AuthService);
  private readonly catalog = inject(CatalogService);
  private readonly users = inject(UsersService);
  private readonly notify = inject(NotifyService);

  loading = true;
  stats: Stat[] = [];
  recent: Purchase[] = [];
  lowStock: Volumen[] = [];

  ngOnInit(): void {
    forkJoin({
      mangas: this.catalog.mangas(0, 1),
      volumenes: this.catalog.volumenes(0, 500),
      users: this.users.users(0, 1),
      purchases: this.users.purchases(0, 500),
    }).subscribe({
      next: ({ mangas, volumenes, users, purchases }) => {
        const revenue = purchases.content.reduce((sum, p) => sum + (p.total ?? p.precio), 0);
        const units = volumenes.content.reduce((sum, v) => sum + v.cantidad, 0);
        const eur = new Intl.NumberFormat('es-ES', { style: 'currency', currency: 'EUR' });
        this.stats = [
          { label: 'Mangas', value: String(mangas.totalElements), icon: 'auto_stories', link: '/mangas' },
          { label: `Volúmenes · ${units} uds. en stock`, value: String(volumenes.totalElements), icon: 'inventory_2', link: '/mangas' },
          { label: 'Usuarios', value: String(users.totalElements), icon: 'group', link: '/usuarios' },
          { label: `Ingresos · ${purchases.totalElements} ventas`, value: eur.format(revenue), icon: 'payments', link: '/compras' },
        ];
        this.recent = purchases.content.slice(0, 5);
        this.lowStock = volumenes.content
          .filter((v) => v.cantidad <= 5)
          .sort((a, b) => a.cantidad - b.cantidad)
          .slice(0, 5);
        this.loading = false;
      },
      error: (err) => {
        this.loading = false;
        this.notify.error(err);
      },
    });
  }
}
