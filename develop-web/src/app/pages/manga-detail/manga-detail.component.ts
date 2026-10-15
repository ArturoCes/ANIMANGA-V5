import { Component, OnInit, inject } from '@angular/core';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { MatDialog } from '@angular/material/dialog';
import { UI } from '../../shared/material';
import { CatalogService } from '../../core/catalog.service';
import { NotifyService } from '../../core/notify.service';
import { Manga, Volumen } from '../../core/models';
import { MangaFormDialog } from '../mangas/manga-form.dialog';
import { VolumenFormDialog } from './volumen-form.dialog';

@Component({
  standalone: true,
  imports: [...UI, RouterLink],
  template: `
    <a mat-button routerLink="/mangas" class="back"><mat-icon>arrow_back</mat-icon> Mangas</a>

    <mat-progress-bar *ngIf="!manga" mode="indeterminate" />

    <ng-container *ngIf="manga">
      <section class="card hero">
        <img class="cover" [src]="manga.posterPath | imageUrl" [alt]="'Portada de ' + manga.name" />
        <div class="info">
          <div class="info-head">
            <div>
              <h1>{{ manga.name }}</h1>
              <p class="muted">
                {{ manga.author }}<span *ngIf="manga.publisher"> · {{ manga.publisher }}</span>
                <span *ngIf="manga.releaseDate"> · {{ manga.releaseDate | date: 'longDate' }}</span>
              </p>
            </div>
            <button mat-stroked-button (click)="edit()"><mat-icon>edit</mat-icon> Editar</button>
          </div>
          <div class="tags">
            <span class="tag" *ngFor="let c of manga.categories">{{ c.name }}</span>
          </div>
          <p class="description">{{ manga.description }}</p>
          <div class="facts">
            <div><span class="fact-value">{{ manga.volumenes.length }}</span><span class="muted">volúmenes</span></div>
            <div><span class="fact-value">{{ stock }}</span><span class="muted">uds. en stock</span></div>
            <div><span class="fact-value">{{ minPrice | currency: 'EUR' }}</span><span class="muted">desde</span></div>
          </div>
        </div>
      </section>

      <div class="page-header section-header">
        <h2>Volúmenes</h2>
        <button mat-flat-button color="primary" (click)="openVolumen()">
          <mat-icon>add</mat-icon> Nuevo volumen
        </button>
      </div>

      <div class="card table-card">
        <div class="table-scroll">
          <table mat-table [dataSource]="volumes">
            <ng-container matColumnDef="cover">
              <th mat-header-cell *matHeaderCellDef></th>
              <td mat-cell *matCellDef="let v"><img class="thumb" [src]="v.posterPath | imageUrl" alt="" /></td>
            </ng-container>
            <ng-container matColumnDef="nombre">
              <th mat-header-cell *matHeaderCellDef>Nombre</th>
              <td mat-cell *matCellDef="let v"><strong>{{ v.nombre }}</strong></td>
            </ng-container>
            <ng-container matColumnDef="isbn">
              <th mat-header-cell *matHeaderCellDef>ISBN</th>
              <td mat-cell *matCellDef="let v" class="mono">{{ v.isbn || '—' }}</td>
            </ng-container>
            <ng-container matColumnDef="precio">
              <th mat-header-cell *matHeaderCellDef>Precio</th>
              <td mat-cell *matCellDef="let v">{{ v.precio | currency: 'EUR' }}</td>
            </ng-container>
            <ng-container matColumnDef="cantidad">
              <th mat-header-cell *matHeaderCellDef>Stock</th>
              <td mat-cell *matCellDef="let v">
                <span class="badge" [class.badge-danger]="v.cantidad === 0" [class.badge-warn]="v.cantidad > 0 && v.cantidad <= 5"
                      [class.badge-ok]="v.cantidad > 5">
                  {{ v.cantidad === 0 ? 'Agotado' : v.cantidad + ' uds.' }}
                </span>
              </td>
            </ng-container>
            <ng-container matColumnDef="actions">
              <th mat-header-cell *matHeaderCellDef></th>
              <td mat-cell *matCellDef="let v" class="actions">
                <button mat-icon-button (click)="openVolumen(v)" matTooltip="Editar"><mat-icon>edit</mat-icon></button>
                <button mat-icon-button (click)="removeVolumen(v)" matTooltip="Eliminar"><mat-icon>delete</mat-icon></button>
              </td>
            </ng-container>
            <tr mat-header-row *matHeaderRowDef="columns"></tr>
            <tr mat-row *matRowDef="let row; columns: columns"></tr>
            <tr class="mat-row" *matNoDataRow>
              <td class="empty-cell" [attr.colspan]="columns.length">Este manga todavía no tiene volúmenes</td>
            </tr>
          </table>
        </div>
      </div>
    </ng-container>
  `,
  styles: [
    `.back { margin: -8px 0 12px -8px; }
     .hero { display: flex; gap: 28px; }
     .cover { width: 200px; aspect-ratio: 2 / 3; object-fit: cover; border-radius: 12px; box-shadow: var(--shadow-lg); flex-shrink: 0; }
     .info { flex: 1; min-width: 0; }
     .info-head { display: flex; justify-content: space-between; gap: 16px; align-items: flex-start; }
     h1 { margin: 0 0 4px; font-size: 28px; }
     .tags { margin: 8px 0 12px; }
     .description { line-height: 1.6; max-width: 70ch; }
     .facts { display: flex; gap: 32px; margin-top: 20px; flex-wrap: wrap; }
     .facts div { display: flex; flex-direction: column; }
     .fact-value { font-size: 22px; font-weight: 700; }
     .section-header { margin-top: 28px; }
     .section-header h2 { margin: 0; }
     .mono { font-family: ui-monospace, monospace; font-size: 13px; }
     @media (max-width: 700px) {
       .hero { flex-direction: column; align-items: center; }
       .cover { width: 160px; }
       .info-head { flex-direction: column; }
     }`,
  ],
})
export class MangaDetailComponent implements OnInit {
  private readonly route = inject(ActivatedRoute);
  private readonly catalog = inject(CatalogService);
  private readonly dialog = inject(MatDialog);
  private readonly notify = inject(NotifyService);

  readonly columns = ['cover', 'nombre', 'isbn', 'precio', 'cantidad', 'actions'];
  manga: Manga | null = null;
  volumes: Volumen[] = [];

  get stock(): number {
    return this.volumes.reduce((s, v) => s + v.cantidad, 0);
  }

  get minPrice(): number {
    return this.volumes.length ? Math.min(...this.volumes.map((v) => v.precio)) : 0;
  }

  ngOnInit(): void {
    this.route.paramMap.subscribe(() => this.load());
  }

  load(): void {
    const id = this.route.snapshot.paramMap.get('id')!;
    this.catalog.manga(id).subscribe({
      next: (m) => {
        this.manga = m;
        this.volumes = [...m.volumenes].sort((a, b) =>
          a.nombre.localeCompare(b.nombre, 'es', { numeric: true })
        );
      },
      error: (err) => this.notify.error(err),
    });
  }

  edit(): void {
    this.dialog
      .open(MangaFormDialog, { data: this.manga, width: '640px', maxWidth: '95vw' })
      .afterClosed()
      .subscribe((saved) => saved && this.load());
  }

  openVolumen(volumen?: Volumen): void {
    this.dialog
      .open(VolumenFormDialog, {
        data: { manga: this.manga!, volumen: volumen ?? null },
        width: '560px',
        maxWidth: '95vw',
      })
      .afterClosed()
      .subscribe((saved) => saved && this.load());
  }

  removeVolumen(v: Volumen): void {
    this.notify
      .confirm({ title: 'Eliminar volumen', message: `¿Eliminar "${v.nombre}"?`, confirmText: 'Eliminar', danger: true })
      .subscribe((ok) => {
        if (!ok) return;
        this.catalog.deleteVolumen(v.id).subscribe({
          next: () => {
            this.notify.success('Volumen eliminado');
            this.load();
          },
          error: (err) => this.notify.error(err),
        });
      });
  }
}
