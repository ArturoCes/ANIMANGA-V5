import { Component, Inject, OnInit, inject } from '@angular/core';
import { FormBuilder, Validators } from '@angular/forms';
import { MAT_DIALOG_DATA, MatDialogRef } from '@angular/material/dialog';
import { Observable, of, switchMap } from 'rxjs';
import { UI } from '../../shared/material';
import { ImagePickerComponent } from '../../shared/image-picker.component';
import { CatalogService } from '../../core/catalog.service';
import { NotifyService } from '../../core/notify.service';
import { imageUrl } from '../../core/api';
import { Manga, Volumen, VolumenPayload } from '../../core/models';

export interface VolumenDialogData {
  manga: Manga;
  volumen: Volumen | null;
}

@Component({
  standalone: true,
  imports: [...UI, ImagePickerComponent],
  template: `
    <h2 mat-dialog-title>{{ data.volumen ? 'Editar volumen' : 'Nuevo volumen de ' + data.manga.name }}</h2>
    <form [formGroup]="form" (ngSubmit)="save()">
      <mat-dialog-content class="form-grid">
        <app-image-picker class="full" label="Portada" [required]="!data.volumen"
                          [current]="data.volumen ? cover(data.volumen.posterPath) : null" (picked)="file = $event" />

        <mat-form-field appearance="outline" class="full">
          <mat-label>Nombre</mat-label>
          <input matInput formControlName="nombre" placeholder="Ej. {{ data.manga.name }} 4" />
          <mat-error>El nombre es obligatorio</mat-error>
        </mat-form-field>

        <mat-form-field appearance="outline">
          <mat-label>Precio</mat-label>
          <input matInput type="number" min="0" step="0.01" formControlName="precio" />
          <span matTextSuffix>€</span>
          <mat-error>Introduce un precio válido</mat-error>
        </mat-form-field>

        <mat-form-field appearance="outline">
          <mat-label>Stock</mat-label>
          <input matInput type="number" min="0" step="1" formControlName="cantidad" />
          <span matTextSuffix>uds.</span>
          <mat-error>Introduce un stock válido</mat-error>
        </mat-form-field>

        <mat-form-field appearance="outline" class="full">
          <mat-label>ISBN</mat-label>
          <input matInput formControlName="isbn" maxlength="17" />
          <mat-error>El ISBN debe tener 10 o 13 dígitos</mat-error>
        </mat-form-field>
      </mat-dialog-content>

      <mat-dialog-actions align="end">
        <button mat-button type="button" mat-dialog-close>Cancelar</button>
        <button mat-flat-button color="primary" [disabled]="saving">{{ saving ? 'Guardando…' : 'Guardar' }}</button>
      </mat-dialog-actions>
    </form>
  `,
})
export class VolumenFormDialog implements OnInit {
  private readonly catalog = inject(CatalogService);
  private readonly notify = inject(NotifyService);
  private readonly ref = inject(MatDialogRef<VolumenFormDialog>);

  readonly form = inject(FormBuilder).nonNullable.group({
    nombre: ['', Validators.required],
    precio: [8.5, [Validators.required, Validators.min(0)]],
    cantidad: [10, [Validators.required, Validators.min(0)]],
    isbn: ['', Validators.pattern(/^(\d[- ]?){9}[\dXx]$|^(\d[- ]?){12}\d$/)],
  });

  file: File | null = null;
  saving = false;
  readonly cover = imageUrl;

  constructor(@Inject(MAT_DIALOG_DATA) public data: VolumenDialogData) {}

  ngOnInit(): void {
    const v = this.data.volumen;
    if (v) {
      this.form.patchValue({ nombre: v.nombre, precio: v.precio, cantidad: v.cantidad, isbn: v.isbn ?? '' });
    } else {
      this.form.patchValue({ nombre: `${this.data.manga.name} ${this.data.manga.volumenes.length + 1}` });
    }
  }

  save(): void {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }
    if (!this.data.volumen && !this.file) {
      this.notify.error('Elige una portada para el volumen');
      return;
    }
    const v = this.form.getRawValue();
    const payload: VolumenPayload = {
      idManga: this.data.manga.id,
      nombre: v.nombre.trim(),
      precio: Number(v.precio),
      cantidad: Math.trunc(Number(v.cantidad)),
      isbn: v.isbn.replace(/[- ]/g, ''),
    };

    this.saving = true;
    const current = this.data.volumen;
    const request: Observable<Volumen> = current
      ? this.catalog.updateVolumen(current.id, payload).pipe(
          switchMap((saved) => (this.file ? this.catalog.updateVolumenCover(saved.id, this.file) : of(saved)))
        )
      : this.catalog.createVolumen(this.data.manga.id, payload, this.file!);

    request.subscribe({
      next: () => {
        this.notify.success(current ? 'Cambios guardados' : 'Volumen creado');
        this.ref.close(true);
      },
      error: (err) => {
        this.saving = false;
        this.notify.error(err);
      },
    });
  }
}
