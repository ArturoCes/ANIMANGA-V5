import { Component, OnInit, inject } from '@angular/core';
import { FormControl } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { MatDialog } from '@angular/material/dialog';
import { PageEvent } from '@angular/material/paginator';
import { debounceTime, distinctUntilChanged, merge } from 'rxjs';
import { UI } from '../../shared/material';
import { CatalogService } from '../../core/catalog.service';
import { NotifyService } from '../../core/notify.service';
import { Category, MangaSummary } from '../../core/models';
import { MangaFormDialog } from './manga-form.dialog';

@Component({
  standalone: true,
  imports: [...UI, RouterLink],
  template: `
    <div class="page-header">
      <div>
        <h1>Mangas</h1>
        <p class="muted">{{ total }} series en el catálogo</p>
      </div>
      <button mat-flat-button color="primary" (click)="openForm()">
        <mat-icon>add</mat-icon> Nuevo manga
      </button>
    </div>

    <div class="card table-card">
      <div class="toolbar">
        <mat-form-field appearance="outline" class="search" subscriptSizing="dynamic">
          <mat-icon matPrefix>search</mat-icon>
          <input matInput [formControl]="search" placeholder="Buscar por título o autor" />
        </mat-form-field>
        <mat-form-field appearance="outline" subscriptSizing="dynamic" class="filter">
          <mat-label>Categoría</mat-label>
          <mat-select [formControl]="category">
            <mat-option [value]="''">Todas</mat-option>
            <mat-option *ngFor="let c of categories" [value]="c.name">{{ c.name }}</mat-option>
          </mat-select>
        </mat-form-field>
        <mat-form-field appearance="outline" subscriptSizing="dynamic" class="filter">
          <mat-label>Ordenar por</mat-label>
          <mat-select [formControl]="sort">
            <mat-option value="title">Título</mat-option>
            <mat-option value="newest">Más recientes</mat-option>
            <mat-option value="bestselling">Más vendidos</mat-option>
            <mat-option value="rating">Mejor valorados</mat-option>
            <mat-option value="price_asc">Precio: menor a mayor</mat-option>
          </mat-select>
        </mat-form-field>
      </div>
      <mat-progress-bar *ngIf="loading" mode="indeterminate" />

      <div class="table-scroll">
        <table mat-table [dataSource]="mangas">
          <ng-container matColumnDef="cover">
            <th mat-header-cell *matHeaderCellDef></th>
            <td mat-cell *matCellDef="let m"><img class="thumb" [src]="m.coverImage | imageUrl" alt="" /></td>
          </ng-container>
          <ng-container matColumnDef="title">
            <th mat-header-cell *matHeaderCellDef>Título</th>
            <td mat-cell *matCellDef="let m">
              <a class="title-link" [routerLink]="['/mangas', m.id]">{{ m.title }}</a>
              <div class="muted small ellipsis">{{ m.author }}<span *ngIf="m.publisher"> · {{ m.publisher }}</span></div>
            </td>
          </ng-container>
          <ng-container matColumnDef="categories">
            <th mat-header-cell *matHeaderCellDef class="hide-md">Categorías</th>
            <td mat-cell *matCellDef="let m" class="hide-md">
              <div class="tags">
                <span class="tag" *ngFor="let c of m.categories.slice(0, 1)">{{ c.name }}</span>
                <span class="tag more" *ngIf="m.categories.length > 1" [matTooltip]="restOf(m)">+{{ m.categories.length - 1 }}</span>
              </div>
            </td>
          </ng-container>
          <ng-container matColumnDef="rating">
            <th mat-header-cell *matHeaderCellDef class="hide-lg">Valoración</th>
            <td mat-cell *matCellDef="let m" class="hide-lg">
              <span *ngIf="m.ratingCount; else noRating" class="rating">
                <mat-icon>star</mat-icon>{{ m.ratingAverage | number: '1.1-1' }}
                <span class="muted small">({{ m.ratingCount }})</span>
              </span>
              <ng-template #noRating><span class="muted">—</span></ng-template>
            </td>
          </ng-container>
          <ng-container matColumnDef="volumes">
            <th mat-header-cell *matHeaderCellDef class="hide-sm">Volúmenes</th>
            <td mat-cell *matCellDef="let m" class="hide-sm">
              {{ m.volumeCount }}
              <span class="badge badge-danger" *ngIf="m.volumeCount && !m.inStock">Sin stock</span>
            </td>
          </ng-container>
          <ng-container matColumnDef="sold">
            <th mat-header-cell *matHeaderCellDef class="hide-lg">Vendidos</th>
            <td mat-cell *matCellDef="let m" class="hide-lg">{{ m.unitsSold }}</td>
          </ng-container>
          <ng-container matColumnDef="price">
            <th mat-header-cell *matHeaderCellDef class="hide-sm">Desde</th>
            <td mat-cell *matCellDef="let m" class="hide-sm nowrap">{{ m.minPrice != null ? (m.minPrice | currency: 'EUR') : '—' }}</td>
          </ng-container>
          <ng-container matColumnDef="actions">
            <th mat-header-cell *matHeaderCellDef></th>
            <td mat-cell *matCellDef="let m" class="actions">
              <a mat-icon-button [routerLink]="['/mangas', m.id]" matTooltip="Volúmenes, personajes y reseñas"><mat-icon>visibility</mat-icon></a>
              <button mat-icon-button (click)="edit(m)" matTooltip="Editar"><mat-icon>edit</mat-icon></button>
              <button mat-icon-button (click)="remove(m)" matTooltip="Eliminar"><mat-icon>delete</mat-icon></button>
            </td>
          </ng-container>
          <tr mat-header-row *matHeaderRowDef="columns"></tr>
          <tr mat-row *matRowDef="let row; columns: columns"></tr>
          <tr class="mat-row" *matNoDataRow>
            <td class="empty-cell" [attr.colspan]="columns.length">
              {{ loading ? 'Cargando…' : 'No se ha encontrado ningún manga' }}
            </td>
          </tr>
        </table>
      </div>
      <mat-paginator [length]="total" [pageIndex]="page" [pageSize]="size" [pageSizeOptions]="[5, 10, 20]"
                     (page)="onPage($event)" showFirstLastButtons />
    </div>
  `,
  styles: [
    `.title-link { font-weight: 600; color: var(--text); text-decoration: none; }
     .title-link:hover { color: var(--brand); }
     .small { font-size: 13px; }
     .mat-column-title { min-width: 140px; }
     .tags { display: flex; flex-wrap: nowrap; gap: 4px; }
     .ellipsis { max-width: 260px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
     @media (max-width: 760px) { .ellipsis { max-width: 150px; } }
     .filter { flex: 0 1 190px; min-width: 150px; }
     .tags .tag { margin: 0; }
     .tag.more { background: var(--surface-2); color: var(--muted); cursor: default; }
     .nowrap { white-space: nowrap; }
     .rating { display: inline-flex; align-items: center; gap: 2px; font-weight: 600; }
     .rating mat-icon { color: #f5a623; font-size: 18px; width: 18px; height: 18px; }`,
  ],
})
export class MangasComponent implements OnInit {
  private readonly catalog = inject(CatalogService);
  private readonly dialog = inject(MatDialog);
  private readonly notify = inject(NotifyService);

  readonly columns = ['cover', 'title', 'categories', 'rating', 'volumes', 'sold', 'price', 'actions'];
  readonly search = new FormControl('', { nonNullable: true });
  readonly category = new FormControl('', { nonNullable: true });
  readonly sort = new FormControl('title', { nonNullable: true });

  categories: Category[] = [];
  mangas: MangaSummary[] = [];
  total = 0;
  page = 0;
  size = 10;
  loading = false;

  restOf(m: MangaSummary): string {
    return m.categories.slice(1).map((c) => c.name).join(', ');
  }

  ngOnInit(): void {
    this.catalog.categories().subscribe((c) => (this.categories = c));
    this.load();
    merge(this.search.valueChanges.pipe(debounceTime(300), distinctUntilChanged()),
      this.category.valueChanges, this.sort.valueChanges)
      .subscribe(() => {
        this.page = 0;
        this.load();
      });
  }

  load(): void {
    this.loading = true;
    this.catalog
      .mangas({ q: this.search.value.trim(), category: this.category.value, sort: this.sort.value,
                page: this.page, size: this.size })
      .subscribe({
        next: (res) => {
          this.mangas = res.content;
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

  openForm(): void {
    this.dialog
      .open(MangaFormDialog, { data: null, width: '640px', maxWidth: '95vw' })
      .afterClosed()
      .subscribe((saved) => saved && this.load());
  }

  edit(summary: MangaSummary): void {
    // El formulario necesita la sinopsis, que solo viene en la ficha completa
    this.catalog.manga(summary.id).subscribe({
      next: (manga) =>
        this.dialog
          .open(MangaFormDialog, { data: manga, width: '640px', maxWidth: '95vw' })
          .afterClosed()
          .subscribe((saved) => saved && this.load()),
      error: (err) => this.notify.error(err),
    });
  }

  remove(manga: MangaSummary): void {
    this.notify
      .confirm({
        title: 'Eliminar manga',
        message: `Se eliminará "${manga.title}" con sus ${manga.volumeCount} volúmenes, personajes y reseñas. Los pedidos ya hechos se conservan.`,
        confirmText: 'Eliminar',
        danger: true,
      })
      .subscribe((ok) => {
        if (!ok) return;
        this.catalog.deleteManga(manga.id).subscribe({
          next: () => {
            this.notify.success('Manga eliminado');
            if (this.mangas.length === 1 && this.page > 0) this.page--;
            this.load();
          },
          error: (err) => this.notify.error(err),
        });
      });
  }
}
