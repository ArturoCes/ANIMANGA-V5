import { Component, Inject, OnInit, inject } from '@angular/core';
import { FormControl } from '@angular/forms';
import { MAT_DIALOG_DATA, MatDialog, MatDialogRef } from '@angular/material/dialog';
import { PageEvent } from '@angular/material/paginator';
import { debounceTime, distinctUntilChanged, merge } from 'rxjs';
import { UI } from '../../shared/material';
import { StatusBadgeComponent } from '../../shared/status-badge.component';
import { UsersService } from '../../core/users.service';
import { NotifyService } from '../../core/notify.service';
import { ORDER_STATUS_LABEL, Order, OrderStatus } from '../../core/models';

/** Siguientes estados posibles según el flujo del backend. */
const NEXT: Record<OrderStatus, OrderStatus[]> = {
  PAID: ['SHIPPED', 'CANCELLED'],
  SHIPPED: ['DELIVERED'],
  DELIVERED: [],
  CANCELLED: [],
};

@Component({
  standalone: true,
  imports: [...UI, StatusBadgeComponent],
  template: `
    <div mat-dialog-title class="dialog-head">
      <div>
        <span class="number">Pedido {{ order.number }}</span>
        <span class="date">{{ order.createdAt | date: "d 'de' MMMM 'de' y, HH:mm" }}</span>
      </div>
      <app-status-badge [status]="order.status" />
    </div>
    <mat-dialog-content>
      <div class="columns">
        <div>
          <h3>Cliente</h3>
          <p>{{ order.customer.fullName }}<br /><span class="muted">&#64;{{ order.customer.username }} · {{ order.customer.email }}</span></p>
        </div>
        <div>
          <h3>Envío</h3>
          <p>
            {{ order.shipping.fullName }}<br />
            {{ order.shipping.address }}<br />
            {{ order.shipping.postalCode }} {{ order.shipping.city }}<br />
            <span class="muted">Tel. {{ order.shipping.phone }}</span>
          </p>
        </div>
      </div>
      <h3>Productos</h3>
      <div class="line" *ngFor="let l of order.items">
        <img class="thumb" [src]="l.coverImage | imageUrl" alt="" />
        <div class="line-main"><strong>{{ l.volumeTitle }}</strong><span class="muted">{{ l.quantity }} × {{ l.unitPrice | currency: 'EUR' }}</span></div>
        <strong>{{ l.subtotal | currency: 'EUR' }}</strong>
      </div>
      <div class="total">
        <span class="muted">Pagado con tarjeta ···· {{ order.cardLast4 }}</span>
        <strong>Total {{ order.total | currency: 'EUR' }}</strong>
      </div>
    </mat-dialog-content>
    <mat-dialog-actions align="end">
      <button mat-button mat-dialog-close>Cerrar</button>
      <button mat-stroked-button color="warn" *ngIf="next.includes('CANCELLED')" [disabled]="saving"
              (click)="change('CANCELLED')">Cancelar pedido</button>
      <button mat-flat-button color="primary" *ngIf="next.includes('SHIPPED')" [disabled]="saving"
              (click)="change('SHIPPED')"><mat-icon>local_shipping</mat-icon> Marcar como enviado</button>
      <button mat-flat-button color="primary" *ngIf="next.includes('DELIVERED')" [disabled]="saving"
              (click)="change('DELIVERED')"><mat-icon>done_all</mat-icon> Marcar como entregado</button>
    </mat-dialog-actions>
  `,
  styles: [
    `.dialog-head::before { display: none !important; }
     .dialog-head { padding-top: 22px !important; padding-bottom: 6px !important; display: flex !important; justify-content: space-between; align-items: center; gap: 16px; }
     .dialog-head > div { display: flex; flex-direction: column; line-height: 1.3; }
     .number { font-size: 20px; font-weight: 700; font-family: ui-monospace, monospace; }
     .date { font-size: 13px; font-weight: 400; color: var(--muted); }
     h3 { font-size: 12px; font-weight: 600; text-transform: uppercase; letter-spacing: .06em; color: var(--muted); margin: 16px 0 8px; }
     .columns { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; padding: 14px 16px; border-radius: 12px; background: var(--surface-2); }
     .columns h3 { margin-top: 0; }
     .columns p { margin: 0; line-height: 1.5; }
     .line { display: flex; align-items: center; gap: 12px; padding: 8px 0; border-top: 1px solid var(--border); }
     .line-main { flex: 1; display: flex; flex-direction: column; }
     .total { display: flex; justify-content: space-between; align-items: center; padding-top: 14px; margin-top: 4px; border-top: 1px solid var(--border); font-size: 16px; }
     .total strong { font-size: 18px; }
     .line strong { white-space: nowrap; }
     @media (max-width: 600px) { .columns { grid-template-columns: 1fr; } }`,
  ],
})
export class OrderDetailDialog {
  private readonly service = inject(UsersService);
  private readonly notify = inject(NotifyService);
  private readonly ref = inject(MatDialogRef<OrderDetailDialog>);
  saving = false;

  constructor(@Inject(MAT_DIALOG_DATA) public order: Order) {}

  get next(): OrderStatus[] {
    return NEXT[this.order.status];
  }

  change(status: OrderStatus): void {
    const run = () => {
      this.saving = true;
      this.service.setOrderStatus(this.order.id, status).subscribe({
        next: (o) => {
          this.notify.success(`Pedido ${o.number}: ${ORDER_STATUS_LABEL[o.status].toLowerCase()}`);
          this.ref.close(true);
        },
        error: (err) => {
          this.saving = false;
          this.notify.error(err);
        },
      });
    };
    if (status !== 'CANCELLED') return run();
    this.notify
      .confirm({ title: 'Cancelar pedido', message: 'Se devolverán las unidades al stock. ¿Continuar?',
                 confirmText: 'Cancelar pedido', danger: true })
      .subscribe((ok) => ok && run());
  }
}

@Component({
  standalone: true,
  imports: [...UI, StatusBadgeComponent],
  template: `
    <div class="page-header">
      <div>
        <h1>Pedidos</h1>
        <p class="muted">{{ total }} pedidos{{ status.value ? ' ' + label[status.value].toLowerCase() + 's' : '' }}</p>
      </div>
    </div>

    <div class="card table-card">
      <div class="toolbar">
        <mat-form-field appearance="outline" class="search" subscriptSizing="dynamic">
          <mat-icon matPrefix>search</mat-icon>
          <input matInput [formControl]="search" placeholder="Número de pedido, cliente o email" />
        </mat-form-field>
        <mat-button-toggle-group [formControl]="status" aria-label="Filtrar por estado">
          <mat-button-toggle [value]="null">Todos</mat-button-toggle>
          <mat-button-toggle *ngFor="let s of statuses" [value]="s">{{ label[s] }}</mat-button-toggle>
        </mat-button-toggle-group>
      </div>
      <mat-progress-bar *ngIf="loading" mode="indeterminate" />
      <div class="table-scroll">
        <table mat-table [dataSource]="orders">
          <ng-container matColumnDef="number">
            <th mat-header-cell *matHeaderCellDef>Pedido</th>
            <td mat-cell *matCellDef="let o"><strong class="mono nowrap">{{ o.number }}</strong>
              <div class="show-sm">{{ o.customer.fullName }}</div>
              <div class="muted small">{{ o.createdAt | date: 'dd/MM/yyyy HH:mm' }}</div></td>
          </ng-container>
          <ng-container matColumnDef="customer">
            <th mat-header-cell *matHeaderCellDef class="hide-sm">Cliente</th>
            <td mat-cell *matCellDef="let o" class="hide-sm">{{ o.customer.fullName }}<div class="muted small">{{ o.shipping.city }}</div></td>
          </ng-container>
          <ng-container matColumnDef="items">
            <th mat-header-cell *matHeaderCellDef class="hide-md">Productos</th>
            <td mat-cell *matCellDef="let o" class="hide-md">
              <div class="covers">
                <img class="thumb" *ngFor="let l of o.items.slice(0, 3)" [src]="l.coverImage | imageUrl" [matTooltip]="l.volumeTitle" alt="" />
              </div>
              <span class="muted small">{{ o.totalUnits }} uds.</span>
            </td>
          </ng-container>
          <ng-container matColumnDef="status">
            <th mat-header-cell *matHeaderCellDef>Estado</th>
            <td mat-cell *matCellDef="let o"><app-status-badge [status]="o.status" /></td>
          </ng-container>
          <ng-container matColumnDef="total">
            <th mat-header-cell *matHeaderCellDef class="right">Total</th>
            <td mat-cell *matCellDef="let o" class="right nowrap"><strong>{{ o.total | currency: 'EUR' }}</strong></td>
          </ng-container>
          <ng-container matColumnDef="actions">
            <th mat-header-cell *matHeaderCellDef class="hide-sm"></th>
            <td mat-cell *matCellDef="let o" class="actions hide-sm">
              <button mat-icon-button (click)="open(o)" matTooltip="Ver y gestionar"><mat-icon>open_in_new</mat-icon></button>
            </td>
          </ng-container>
          <tr mat-header-row *matHeaderRowDef="columns"></tr>
          <tr mat-row *matRowDef="let row; columns: columns" class="clickable" (click)="open(row)"></tr>
          <tr class="mat-row" *matNoDataRow>
            <td class="empty-cell" [attr.colspan]="columns.length">{{ loading ? 'Cargando…' : 'No hay pedidos que coincidan' }}</td>
          </tr>
        </table>
      </div>
      <mat-paginator [length]="total" [pageIndex]="page" [pageSize]="size" [pageSizeOptions]="[10, 20, 50]"
                     (page)="onPage($event)" showFirstLastButtons />
    </div>
  `,
  styles: [
    `.small { font-size: 13px; }
     .mono { font-family: ui-monospace, monospace; }
     .nowrap { white-space: nowrap; }
     .right { text-align: right; }
     .covers { display: flex; gap: 4px; margin-bottom: 2px; }
     .covers .thumb { width: 28px; height: 40px; }
     .clickable { cursor: pointer; }`,
  ],
})
export class OrdersComponent implements OnInit {
  private readonly service = inject(UsersService);
  private readonly dialog = inject(MatDialog);
  private readonly notify = inject(NotifyService);

  readonly columns = ['number', 'customer', 'items', 'status', 'total', 'actions'];
  readonly statuses: OrderStatus[] = ['PAID', 'SHIPPED', 'DELIVERED', 'CANCELLED'];
  readonly label = ORDER_STATUS_LABEL;
  readonly search = new FormControl('', { nonNullable: true });
  readonly status = new FormControl<OrderStatus | null>(null);

  orders: Order[] = [];
  total = 0;
  page = 0;
  size = 10;
  loading = false;

  ngOnInit(): void {
    this.load();
    merge(this.search.valueChanges.pipe(debounceTime(300), distinctUntilChanged()), this.status.valueChanges)
      .subscribe(() => {
        this.page = 0;
        this.load();
      });
  }

  load(): void {
    this.loading = true;
    this.service
      .orders({ status: this.status.value, q: this.search.value.trim(), page: this.page, size: this.size })
      .subscribe({
        next: (res) => {
          this.orders = res.content;
          this.total = res.totalElements;
          this.loading = false;
        },
        error: (err) => {
          this.loading = false;
          this.notify.error(err);
        },
      });
  }

  onPage(e: PageEvent): void {
    this.page = e.pageIndex;
    this.size = e.pageSize;
    this.load();
  }

  open(order: Order): void {
    this.dialog
      .open(OrderDetailDialog, { data: order, width: '640px', maxWidth: '95vw', autoFocus: false })
      .afterClosed()
      .subscribe((changed) => changed && this.load());
  }
}
