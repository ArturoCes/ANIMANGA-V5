import { Component, Inject, OnInit, inject } from '@angular/core';
import { FormBuilder, Validators } from '@angular/forms';
import { MAT_DIALOG_DATA, MatDialogRef } from '@angular/material/dialog';
import { Observable, of, switchMap } from 'rxjs';
import { UI } from '../../shared/material';
import { ImagePickerComponent } from '../../shared/image-picker.component';
import { CatalogService } from '../../core/catalog.service';
import { NotifyService } from '../../core/notify.service';
import { imageUrl } from '../../core/api';
import { MangaDetail, Volume, VolumePayload } from '../../core/models';

export interface VolumeDialogData {
  manga: MangaDetail;
  volume: Volume | null;
}

@Component({
  standalone: true,
  imports: [...UI, ImagePickerComponent],
  template: `
    <h2 mat-dialog-title>{{ data.volume ? 'Editar volumen' : 'Nuevo volumen de ' + data.manga.title }}</h2>
    <form [formGroup]="form" (ngSubmit)="save()">
      <mat-dialog-content class="form-grid">
        <app-image-picker class="full" label="Portada" [required]="!data.volume"
                          [current]="data.volume ? cover(data.volume.coverImage) : null" (picked)="file = $event" />

        <mat-form-field appearance="outline">
          <mat-label>Número de tomo</mat-label>
          <input matInput type="number" min="0" formControlName="number" />
          <mat-error>Indica un número de tomo</mat-error>
        </mat-form-field>

        <mat-form-field appearance="outline">
          <mat-label>Título</mat-label>
          <input matInput formControlName="title" [placeholder]="data.manga.title + ' ' + form.value.number" />
          <mat-hint>Vacío = «{{ data.manga.title }} {{ form.value.number }}»</mat-hint>
        </mat-form-field>

        <mat-form-field appearance="outline">
          <mat-label>Precio</mat-label>
          <input matInput type="number" min="0" step="0.01" formControlName="price" />
          <span matTextSuffix>€</span>
          <mat-error>Introduce un precio válido</mat-error>
        </mat-form-field>

        <mat-form-field appearance="outline">
          <mat-label>Stock</mat-label>
          <input matInput type="number" min="0" step="1" formControlName="stock" />
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
export class VolumeFormDialog implements OnInit {
  private readonly catalog = inject(CatalogService);
  private readonly notify = inject(NotifyService);
  private readonly ref = inject(MatDialogRef<VolumeFormDialog>);

  readonly form = inject(FormBuilder).nonNullable.group({
    number: [1, [Validators.required, Validators.min(0)]],
    title: [''],
    price: [8.5, [Validators.required, Validators.min(0)]],
    stock: [10, [Validators.required, Validators.min(0)]],
    isbn: ['', Validators.pattern(/^(\d[- ]?){9}[\dXx]$|^(\d[- ]?){12}\d$/)],
  });

  file: File | null = null;
  saving = false;
  readonly cover = imageUrl;

  constructor(@Inject(MAT_DIALOG_DATA) public data: VolumeDialogData) {}

  ngOnInit(): void {
    const v = this.data.volume;
    if (v) {
      this.form.patchValue({ number: v.number, title: v.title, price: v.price, stock: v.stock, isbn: v.isbn ?? '' });
    } else {
      const next = Math.max(0, ...this.data.manga.volumes.map((x) => x.number)) + 1;
      this.form.patchValue({ number: next });
    }
  }

  save(): void {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }
    if (!this.data.volume && !this.file) {
      this.notify.error('Elige una portada para el volumen');
      return;
    }
    const v = this.form.getRawValue();
    const payload: VolumePayload = {
      number: Math.trunc(Number(v.number)),
      title: v.title.trim(),
      price: Number(v.price),
      stock: Math.trunc(Number(v.stock)),
      isbn: v.isbn.replace(/[- ]/g, ''),
    };

    this.saving = true;
    const current = this.data.volume;
    const request: Observable<Volume> = current
      ? this.catalog.updateVolume(current.id, payload).pipe(
          switchMap((saved) => (this.file ? this.catalog.updateVolumeCover(saved.id, this.file) : of(saved)))
        )
      : this.catalog.createVolume(this.data.manga.id, payload, this.file!);

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
