import { Component, Inject, OnInit, inject } from '@angular/core';
import { FormBuilder, Validators } from '@angular/forms';
import { MAT_DIALOG_DATA, MatDialog, MatDialogRef } from '@angular/material/dialog';
import { UI } from '../../shared/material';
import { CatalogService } from '../../core/catalog.service';
import { NotifyService } from '../../core/notify.service';
import { Category } from '../../core/models';

@Component({
  standalone: true,
  imports: [...UI],
  template: `
    <h2 mat-dialog-title>{{ category ? 'Editar categoría' : 'Nueva categoría' }}</h2>
    <form [formGroup]="form" (ngSubmit)="save()">
      <mat-dialog-content class="form-grid">
        <mat-form-field appearance="outline" class="full">
          <mat-label>Nombre</mat-label>
          <input matInput formControlName="name" />
          <mat-error>El nombre es obligatorio</mat-error>
        </mat-form-field>
        <mat-form-field appearance="outline" class="full">
          <mat-label>Descripción</mat-label>
          <textarea matInput rows="3" formControlName="description"></textarea>
        </mat-form-field>
      </mat-dialog-content>
      <mat-dialog-actions align="end">
        <button mat-button type="button" mat-dialog-close>Cancelar</button>
        <button mat-flat-button color="primary" [disabled]="saving">{{ saving ? 'Guardando…' : 'Guardar' }}</button>
      </mat-dialog-actions>
    </form>
  `,
})
export class CategoryFormDialog {
  private readonly catalog = inject(CatalogService);
  private readonly notify = inject(NotifyService);
  private readonly ref = inject(MatDialogRef<CategoryFormDialog>);
  saving = false;

  readonly form = inject(FormBuilder).nonNullable.group({
    name: ['', Validators.required],
    description: [''],
  });

  constructor(@Inject(MAT_DIALOG_DATA) public category: Category | null) {
    if (category) this.form.patchValue({ name: category.name, description: category.description ?? "" });
  }

  save(): void {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }
    const payload = { name: this.form.value.name!.trim(), description: this.form.value.description!.trim() };
    this.saving = true;
    const request = this.category
      ? this.catalog.updateCategory(this.category.id, payload)
      : this.catalog.createCategory(payload);
    request.subscribe({
      next: () => {
        this.notify.success(this.category ? 'Categoría actualizada' : 'Categoría creada');
        this.ref.close(true);
      },
      error: (err) => {
        this.saving = false;
        this.notify.error(err);
      },
    });
  }
}

@Component({
  standalone: true,
  imports: [...UI],
  template: `
    <div class="page-header">
      <div>
        <h1>Categorías</h1>
        <p class="muted">Géneros con los que se clasifican los mangas</p>
      </div>
      <button mat-flat-button color="primary" (click)="open()"><mat-icon>add</mat-icon> Nueva categoría</button>
    </div>

    <div class="card table-card">
      <mat-progress-bar *ngIf="loading" mode="indeterminate" />
      <div class="table-scroll">
        <table mat-table [dataSource]="categories">
          <ng-container matColumnDef="name">
            <th mat-header-cell *matHeaderCellDef>Nombre</th>
            <td mat-cell *matCellDef="let c"><span class="tag">{{ c.name }}</span></td>
          </ng-container>
          <ng-container matColumnDef="description">
            <th mat-header-cell *matHeaderCellDef>Descripción</th>
            <td mat-cell *matCellDef="let c" class="muted">{{ c.description || '—' }}</td>
          </ng-container>
          <ng-container matColumnDef="actions">
            <th mat-header-cell *matHeaderCellDef></th>
            <td mat-cell *matCellDef="let c" class="actions">
              <button mat-icon-button (click)="open(c)" matTooltip="Editar"><mat-icon>edit</mat-icon></button>
              <button mat-icon-button (click)="remove(c)" matTooltip="Eliminar"><mat-icon>delete</mat-icon></button>
            </td>
          </ng-container>
          <tr mat-header-row *matHeaderRowDef="columns"></tr>
          <tr mat-row *matRowDef="let row; columns: columns"></tr>
          <tr class="mat-row" *matNoDataRow>
            <td class="empty-cell" [attr.colspan]="columns.length">{{ loading ? 'Cargando…' : 'No hay categorías' }}</td>
          </tr>
        </table>
      </div>
    </div>
  `,
})
export class CategoriesComponent implements OnInit {
  private readonly catalog = inject(CatalogService);
  private readonly dialog = inject(MatDialog);
  private readonly notify = inject(NotifyService);

  readonly columns = ['name', 'description', 'actions'];
  categories: Category[] = [];
  loading = false;

  ngOnInit(): void {
    this.load();
  }

  load(): void {
    this.loading = true;
    this.catalog.categories().subscribe({
      next: (res) => {
        this.categories = res;
        this.loading = false;
      },
      error: (err) => {
        this.loading = false;
        this.notify.error(err);
      },
    });
  }

  open(category?: Category): void {
    this.dialog
      .open(CategoryFormDialog, { data: category ?? null, width: '480px', maxWidth: '95vw' })
      .afterClosed()
      .subscribe((saved) => saved && this.load());
  }

  remove(category: Category): void {
    this.notify
      .confirm({
        title: 'Eliminar categoría',
        message: `Se eliminará "${category.name}" y se quitará de los mangas que la tengan asignada.`,
        confirmText: 'Eliminar',
        danger: true,
      })
      .subscribe((ok) => {
        if (!ok) return;
        this.catalog.deleteCategory(category.id).subscribe({
          next: () => {
            this.notify.success('Categoría eliminada');
            this.load();
          },
          error: (err) => this.notify.error(err),
        });
      });
  }
}
