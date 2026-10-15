import { Component, Inject, OnInit, inject } from '@angular/core';
import { FormBuilder, Validators } from '@angular/forms';
import { MAT_DIALOG_DATA, MatDialogRef } from '@angular/material/dialog';
import { Observable, of, switchMap } from 'rxjs';
import { UI } from '../../shared/material';
import { ImagePickerComponent } from '../../shared/image-picker.component';
import { CatalogService } from '../../core/catalog.service';
import { NotifyService } from '../../core/notify.service';
import { imageUrl } from '../../core/api';
import { Category, Manga, MangaPayload } from '../../core/models';

@Component({
  standalone: true,
  imports: [...UI, ImagePickerComponent],
  template: `
    <h2 mat-dialog-title>{{ manga ? 'Editar manga' : 'Nuevo manga' }}</h2>
    <form [formGroup]="form" (ngSubmit)="save()">
      <mat-dialog-content class="form-grid">
        <app-image-picker class="full" label="Portada" [required]="!manga"
                          [current]="manga ? cover(manga.posterPath) : null" (picked)="file = $event" />

        <mat-form-field appearance="outline" class="full">
          <mat-label>Título</mat-label>
          <input matInput formControlName="name" />
          <mat-error>El título es obligatorio</mat-error>
        </mat-form-field>

        <mat-form-field appearance="outline">
          <mat-label>Autor</mat-label>
          <input matInput formControlName="author" />
        </mat-form-field>

        <mat-form-field appearance="outline">
          <mat-label>Editorial</mat-label>
          <input matInput formControlName="publisher" />
        </mat-form-field>

        <mat-form-field appearance="outline">
          <mat-label>Fecha de publicación</mat-label>
          <input matInput type="date" formControlName="releaseDate" />
        </mat-form-field>

        <mat-form-field appearance="outline">
          <mat-label>Categorías</mat-label>
          <mat-select formControlName="categories" multiple>
            <mat-option *ngFor="let c of categories" [value]="c.id">{{ c.name }}</mat-option>
          </mat-select>
          <mat-error>Elige al menos una categoría</mat-error>
        </mat-form-field>

        <mat-form-field appearance="outline" class="full">
          <mat-label>Sinopsis</mat-label>
          <textarea matInput rows="4" formControlName="description"></textarea>
          <mat-error>La sinopsis es obligatoria</mat-error>
        </mat-form-field>
      </mat-dialog-content>

      <mat-dialog-actions align="end">
        <button mat-button type="button" mat-dialog-close>Cancelar</button>
        <button mat-flat-button color="primary" [disabled]="saving">
          {{ saving ? 'Guardando…' : 'Guardar' }}
        </button>
      </mat-dialog-actions>
    </form>
  `,
})
export class MangaFormDialog implements OnInit {
  private readonly catalog = inject(CatalogService);
  private readonly notify = inject(NotifyService);
  private readonly ref = inject(MatDialogRef<MangaFormDialog>);

  readonly form = inject(FormBuilder).nonNullable.group({
    name: ['', Validators.required],
    author: [''],
    publisher: [''],
    releaseDate: [''],
    categories: [[] as string[], Validators.required],
    description: ['', Validators.required],
  });

  categories: Category[] = [];
  file: File | null = null;
  saving = false;
  readonly cover = imageUrl;

  constructor(@Inject(MAT_DIALOG_DATA) public manga: Manga | null) {}

  ngOnInit(): void {
    this.catalog.categories().subscribe({
      next: (res) => (this.categories = res.content),
      error: (err) => this.notify.error(err),
    });
    if (this.manga) {
      this.form.patchValue({
        name: this.manga.name,
        author: this.manga.author ?? '',
        publisher: this.manga.publisher ?? '',
        releaseDate: this.manga.releaseDate ?? '',
        categories: this.manga.categories.map((c) => c.id),
        description: this.manga.description,
      });
    }
  }

  save(): void {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }
    if (!this.manga && !this.file) {
      this.notify.error('Elige una portada para el manga');
      return;
    }
    const v = this.form.getRawValue();
    const payload: MangaPayload = {
      name: v.name.trim(),
      author: v.author.trim(),
      publisher: v.publisher.trim(),
      releaseDate: v.releaseDate || null,
      description: v.description.trim(),
      categories: v.categories.map((id) => ({ id })),
    };

    this.saving = true;
    const request: Observable<Manga> = this.manga
      ? this.catalog.updateManga(this.manga.id, payload).pipe(
          switchMap((m) => (this.file ? this.catalog.updateMangaCover(m.id, this.file) : of(m)))
        )
      : this.catalog.createManga(payload, this.file!);

    request.subscribe({
      next: () => {
        this.notify.success(this.manga ? 'Cambios guardados' : 'Manga creado');
        this.ref.close(true);
      },
      error: (err) => {
        this.saving = false;
        this.notify.error(err);
      },
    });
  }
}
