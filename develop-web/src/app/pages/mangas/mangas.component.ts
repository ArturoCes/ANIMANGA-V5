import { Component, OnInit, inject } from '@angular/core';
import { FormControl } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { MatDialog } from '@angular/material/dialog';
import { PageEvent } from '@angular/material/paginator';
import { debounceTime, distinctUntilChanged } from 'rxjs';
import { UI } from '../../shared/material';
import { CatalogService } from '../../core/catalog.service';
import { NotifyService } from '../../core/notify.service';
import { Manga } from '../../core/models';
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
          <input matInput [formControl]="search" placeholder="Buscar por título" />
        </mat-form-field>
      </div>
      <mat-progress-bar *ngIf="loading" mode="indeterminate" />

      <div class="table-scroll">
        <table mat-table [dataSource]="mangas">
          <ng-container matColumnDef="cover">
            <th mat-header-cell *matHeaderCellDef></th>
            <td mat-cell *matCellDef="let m"><img class="thumb" [src]="m.posterPath | imageUrl" alt="" /></td>
          </ng-container>
          <ng-container matColumnDef="name">
            <th mat-header-cell *matHeaderCellDef>Título</th>
            <td mat-cell *matCellDef="let m">
              <a class="title-link" [routerLink]="['/mangas', m.id]">{{ m.name }}</a>
              <div class="muted small">{{ m.author }}<span *ngIf="m.publisher"> · {{ m.publisher }}</span></div>
            </td>
          </ng-container>
          <ng-container matColumnDef="categories">
            <th mat-header-cell *matHeaderCellDef>Categorías</th>
            <td mat-cell *matCellDef="let m">
              <span class="tag" *ngFor="let c of m.categories">{{ c.name }}</span>
            </td>
          </ng-container>
          <ng-container matColumnDef="volumes">
            <th mat-header-cell *matHeaderCellDef>Volúmenes</th>
            <td mat-cell *matCellDef="let m">{{ m.volumenes.length }}</td>
          </ng-container>
          <ng-container matColumnDef="date">
            <th mat-header-cell *matHeaderCellDef>Publicación</th>
            <td mat-cell *matCellDef="let m">{{ m.releaseDate ? (m.releaseDate | date: 'yyyy') : '—' }}</td>
          </ng-container>
          <ng-container matColumnDef="actions">
            <th mat-header-cell *matHeaderCellDef></th>
            <td mat-cell *matCellDef="let m" class="actions">
              <a mat-icon-button [routerLink]="['/mangas', m.id]" matTooltip="Ver volúmenes"><mat-icon>visibility</mat-icon></a>
              <button mat-icon-button (click)="openForm(m)" matTooltip="Editar"><mat-icon>edit</mat-icon></button>
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
    `.mat-column-name { min-width: 220px; }
     .mat-column-categories { min-width: 160px; }
     .title-link { font-weight: 600; color: var(--text); text-decoration: none; }
     .title-link:hover { color: var(--brand); }
     .small { font-size: 13px; }`,
  ],
})
export class MangasComponent implements OnInit {
  private readonly catalog = inject(CatalogService);
  private readonly dialog = inject(MatDialog);
  private readonly notify = inject(NotifyService);

  readonly columns = ['cover', 'name', 'categories', 'volumes', 'date', 'actions'];
  readonly search = new FormControl('', { nonNullable: true });

  mangas: Manga[] = [];
  total = 0;
  page = 0;
  size = 10;
  loading = false;

  ngOnInit(): void {
    this.load();
    this.search.valueChanges.pipe(debounceTime(300), distinctUntilChanged()).subscribe(() => {
      this.page = 0;
      this.load();
    });
  }

  load(): void {
    this.loading = true;
    const term = this.search.value.trim();
    const request = term
      ? this.catalog.searchMangas(term, this.page, this.size)
      : this.catalog.mangas(this.page, this.size);
    request.subscribe({
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

  openForm(manga?: Manga): void {
    this.dialog
      .open(MangaFormDialog, { data: manga ?? null, width: '640px', maxWidth: '95vw' })
      .afterClosed()
      .subscribe((saved) => saved && this.load());
  }

  remove(manga: Manga): void {
    this.notify
      .confirm({
        title: 'Eliminar manga',
        message: `Se eliminará "${manga.name}" junto con sus ${manga.volumenes.length} volúmenes. Esta acción no se puede deshacer.`,
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
