import { Component, OnInit, inject } from '@angular/core';
import { RouterLink } from '@angular/router';
import { UI } from '../../shared/material';
import { BarChartComponent, BarDatum } from '../../shared/bar-chart.component';
import { StatusBadgeComponent } from '../../shared/status-badge.component';
import { UsersService } from '../../core/users.service';
import { NotifyService } from '../../core/notify.service';
import { AuthService } from '../../core/auth.service';
import { ORDER_STATUS_LABEL, OrderStatus, Stats } from '../../core/models';

const eur = new Intl.NumberFormat('es-ES', { style: 'currency', currency: 'EUR' });
const monthName = new Intl.DateTimeFormat('es-ES', { month: 'short' });

@Component({
  standalone: true,
  imports: [...UI, RouterLink, BarChartComponent, StatusBadgeComponent],
  template: `
    <div class="page-header">
      <div>
        <h1>Hola, {{ auth.user()?.fullName }}</h1>
        <p class="muted">Así va la tienda.</p>
      </div>
      <mat-button-toggle-group [value]="months" (change)="load($event.value)" aria-label="Periodo">
        <mat-button-toggle [value]="6">6 meses</mat-button-toggle>
        <mat-button-toggle [value]="12">12 meses</mat-button-toggle>
      </mat-button-toggle-group>
    </div>

    <mat-progress-bar *ngIf="!stats" mode="indeterminate" />

    <ng-container *ngIf="stats as s">
      <div class="stats">
        <div class="card stat">
          <mat-icon>payments</mat-icon>
          <div><span class="stat-value">{{ money(s.totals.revenue) }}</span><span class="stat-label">Ingresos totales</span></div>
        </div>
        <a class="card stat" routerLink="/pedidos">
          <mat-icon>local_shipping</mat-icon>
          <div><span class="stat-value">{{ s.totals.orders }}</span><span class="stat-label">Pedidos · media {{ money(s.totals.averageOrder) }}</span></div>
        </a>
        <a class="card stat" routerLink="/mangas">
          <mat-icon>inventory_2</mat-icon>
          <div><span class="stat-value">{{ s.totals.unitsInStock }}</span><span class="stat-label">Uds. en stock · {{ s.totals.volumes }} volúmenes</span></div>
        </a>
        <a class="card stat" routerLink="/usuarios">
          <mat-icon>group</mat-icon>
          <div><span class="stat-value">{{ s.totals.customers }}</span><span class="stat-label">Clientes</span></div>
        </a>
      </div>

      <div class="grid">
        <section class="card wide">
          <div class="card-title">
            <h2>Ingresos por mes</h2>
            <span class="muted">{{ money(periodRevenue) }} en el periodo</span>
          </div>
          <app-bar-chart [values]="revenueBars" [format]="money" ariaLabel="Ingresos por mes" />
        </section>

        <section class="card">
          <div class="card-title"><h2>Pedidos por estado</h2></div>
          <div class="status-bar">
            <span *ngFor="let st of statuses" class="segment seg-{{ st }}"
                  [style.flex]="s.ordersByStatus[st] || 0" [matTooltip]="statusLabel[st] + ': ' + s.ordersByStatus[st]"></span>
          </div>
          <div class="legend">
            <div *ngFor="let st of statuses" class="legend-row">
              <app-status-badge [status]="st" /><strong>{{ s.ordersByStatus[st] }}</strong>
            </div>
          </div>
        </section>

        <section class="card">
          <div class="card-title"><h2>Más vendidos</h2></div>
          <div class="empty" *ngIf="!s.topVolumes.length">Todavía no hay ventas.</div>
          <div class="row" *ngFor="let v of s.topVolumes; let i = index">
            <span class="rank">{{ i + 1 }}</span>
            <img class="thumb" [src]="v.coverImage | imageUrl" alt="" />
            <div class="row-main"><strong>{{ v.title }}</strong><span class="muted">{{ money(v.revenue) }}</span></div>
            <span class="badge badge-brand">{{ v.units }} uds.</span>
          </div>
        </section>

        <section class="card">
          <div class="card-title">
            <h2>Últimos pedidos</h2>
            <a mat-button color="primary" routerLink="/pedidos">Ver todos</a>
          </div>
          <div class="row" *ngFor="let o of s.recentOrders">
            <div class="row-main">
              <strong>{{ o.number }}</strong>
              <span class="muted">{{ o.customer.fullName }} · {{ o.createdAt | date: 'd MMM, HH:mm' }}</span>
            </div>
            <app-status-badge [status]="o.status" />
            <span class="amount">{{ money(o.total) }}</span>
          </div>
        </section>

        <section class="card">
          <div class="card-title">
            <h2>Stock bajo</h2>
            <a mat-button color="primary" routerLink="/mangas">Catálogo</a>
          </div>
          <div class="empty" *ngIf="!s.lowStock.length">Todos los volúmenes tienen stock.</div>
          <a class="row link" *ngFor="let v of s.lowStock" [routerLink]="['/mangas', v.mangaId]">
            <img class="thumb" [src]="v.coverImage | imageUrl" alt="" />
            <div class="row-main"><strong>{{ v.title }}</strong><span class="muted">{{ money(v.price) }}</span></div>
            <span class="badge" [class.badge-danger]="v.stock === 0" [class.badge-warn]="v.stock > 0">
              {{ v.stock === 0 ? 'Agotado' : v.stock + ' uds.' }}
            </span>
          </a>
        </section>
      </div>
    </ng-container>
  `,
  styles: [
    `.stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(210px, 1fr)); gap: 16px; margin-bottom: 16px; }
     .stat { display: flex; gap: 16px; align-items: center; text-decoration: none; color: inherit; transition: transform .15s, box-shadow .15s; }
     a.stat:hover { transform: translateY(-2px); box-shadow: var(--shadow-lg); }
     .stat mat-icon { width: 48px; height: 48px; font-size: 26px; display: grid; place-items: center; border-radius: 12px; background: var(--brand-soft); color: var(--brand); flex-shrink: 0; }
     .stat div { display: flex; flex-direction: column; min-width: 0; }
     .stat-value { font-size: 24px; font-weight: 700; }
     .stat-label { color: var(--muted); font-size: 13px; }
     .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(340px, 1fr)); gap: 16px; }
     .wide { grid-column: 1 / -1; }
     .card-title { display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px; gap: 8px; }
     .card-title h2 { margin: 0; font-size: 17px; }
     .row { display: flex; align-items: center; gap: 12px; padding: 10px 0; border-top: 1px solid var(--border); color: inherit; text-decoration: none; }
     .row.link:hover strong { color: var(--brand); }
     .row-main { flex: 1; display: flex; flex-direction: column; min-width: 0; }
     .row-main strong { white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
     .rank { width: 22px; font-weight: 700; color: var(--muted); }
     .amount { font-weight: 600; min-width: 70px; text-align: right; }
     .empty { color: var(--muted); padding: 16px 0; }
     .status-bar { display: flex; height: 14px; border-radius: 99px; overflow: hidden; gap: 2px; margin: 12px 0 16px; background: var(--surface-2); }
     .segment { min-width: 0; }
     .seg-PAID { background: var(--brand); } .seg-SHIPPED { background: #42a5f5; }
     .seg-DELIVERED { background: #66bb6a; } .seg-CANCELLED { background: #ef5350; }
     .legend { display: grid; grid-template-columns: 1fr 1fr; gap: 10px 16px; }
     .legend-row { display: flex; justify-content: space-between; align-items: center; }`,
  ],
})
export class DashboardComponent implements OnInit {
  readonly auth = inject(AuthService);
  private readonly users = inject(UsersService);
  private readonly notify = inject(NotifyService);

  readonly statuses: OrderStatus[] = ['PAID', 'SHIPPED', 'DELIVERED', 'CANCELLED'];
  readonly statusLabel = ORDER_STATUS_LABEL;
  readonly money = (v: number) => eur.format(v);

  months = 6;
  stats: Stats | null = null;
  revenueBars: BarDatum[] = [];
  periodRevenue = 0;

  ngOnInit(): void {
    this.load(6);
  }

  load(months: number): void {
    this.months = months;
    this.users.stats(months).subscribe({
      next: (s) => {
        this.stats = s;
        this.revenueBars = s.revenueByMonth.map((p) => {
          const [y, m] = p.month.split('-').map(Number);
          return { label: monthName.format(new Date(y, m - 1, 1)).replace('.', ''), value: p.revenue,
                   hint: `${p.orders} pedidos` };
        });
        this.periodRevenue = s.revenueByMonth.reduce((sum, p) => sum + p.revenue, 0);
      },
      error: (err) => this.notify.error(err),
    });
  }
}
