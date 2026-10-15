import { Component, OnInit, inject } from '@angular/core';
import { PageEvent } from '@angular/material/paginator';
import { UI } from '../../shared/material';
import { UsersService } from '../../core/users.service';
import { NotifyService } from '../../core/notify.service';
import { Purchase } from '../../core/models';

@Component({
  standalone: true,
  imports: [...UI],
  template: `
    <div class="page-header">
      <div>
        <h1>Compras</h1>
        <p class="muted">{{ total }} líneas de venta registradas</p>
      </div>
    </div>

    <div class="card table-card">
      <mat-progress-bar *ngIf="loading" mode="indeterminate" />
      <div class="table-scroll">
        <table mat-table [dataSource]="purchases">
          <ng-container matColumnDef="date">
            <th mat-header-cell *matHeaderCellDef>Fecha</th>
            <td mat-cell *matCellDef="let p">{{ p.purchaseDate | date: 'dd/MM/yyyy HH:mm' }}</td>
          </ng-container>
          <ng-container matColumnDef="volume">
            <th mat-header-cell *matHeaderCellDef>Producto</th>
            <td mat-cell *matCellDef="let p">
              <div class="product">
                <img class="thumb" [src]="p.posterPath | imageUrl" alt="" />
                <div>
                  <strong>{{ p.nombreVolumen }}</strong>
                  <div class="muted small">{{ p.nameManga }}</div>
                </div>
              </div>
            </td>
          </ng-container>
          <ng-container matColumnDef="customer">
            <th mat-header-cell *matHeaderCellDef>Cliente</th>
            <td mat-cell *matCellDef="let p">
              {{ p.fullName }}
              <div class="muted small">&#64;{{ p.username }}</div>
            </td>
          </ng-container>
          <ng-container matColumnDef="quantity">
            <th mat-header-cell *matHeaderCellDef>Uds.</th>
            <td mat-cell *matCellDef="let p">{{ p.quantity }} × {{ p.precio | currency: 'EUR' }}</td>
          </ng-container>
          <ng-container matColumnDef="card">
            <th mat-header-cell *matHeaderCellDef>Tarjeta</th>
            <td mat-cell *matCellDef="let p" class="mono">{{ p.numCreditCard }}</td>
          </ng-container>
          <ng-container matColumnDef="total">
            <th mat-header-cell *matHeaderCellDef class="right">Total</th>
            <td mat-cell *matCellDef="let p" class="right"><strong>{{ p.total | currency: 'EUR' }}</strong></td>
          </ng-container>
          <tr mat-header-row *matHeaderRowDef="columns"></tr>
          <tr mat-row *matRowDef="let row; columns: columns"></tr>
          <tr class="mat-row" *matNoDataRow>
            <td class="empty-cell" [attr.colspan]="columns.length">{{ loading ? 'Cargando…' : 'Todavía no hay compras' }}</td>
          </tr>
        </table>
      </div>
      <mat-paginator [length]="total" [pageIndex]="page" [pageSize]="size" [pageSizeOptions]="[10, 20, 50]"
                     (page)="onPage($event)" showFirstLastButtons />
    </div>
  `,
  styles: [
    `.product { display: flex; align-items: center; gap: 12px; }
     .small { font-size: 13px; }
     .mono { font-family: ui-monospace, monospace; font-size: 13px; white-space: nowrap; }
     .right { text-align: right; }`,
  ],
})
export class PurchasesComponent implements OnInit {
  private readonly service = inject(UsersService);
  private readonly notify = inject(NotifyService);

  readonly columns = ['date', 'volume', 'customer', 'quantity', 'card', 'total'];
  purchases: Purchase[] = [];
  total = 0;
  page = 0;
  size = 10;
  loading = false;

  ngOnInit(): void {
    this.load();
  }

  load(): void {
    this.loading = true;
    this.service.purchases(this.page, this.size).subscribe({
      next: (res) => {
        this.purchases = res.content;
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
}
