import { Component, Inject, inject } from '@angular/core';
import { FormBuilder, Validators } from '@angular/forms';
import { MAT_DIALOG_DATA, MatDialogRef } from '@angular/material/dialog';
import { Observable, of, switchMap } from 'rxjs';
import { UI } from '../../shared/material';
import { ImagePickerComponent } from '../../shared/image-picker.component';
import { CatalogService } from '../../core/catalog.service';
import { NotifyService } from '../../core/notify.service';
import { imageUrl } from '../../core/api';
import { CharacterPayload, MangaCharacter } from '../../core/models';

export interface CharacterDialogData {
  mangaId: string;
  character: MangaCharacter | null;
}

@Component({
  standalone: true,
  imports: [...UI, ImagePickerComponent],
  template: `
    <h2 mat-dialog-title>{{ data.character ? 'Editar personaje' : 'Nuevo personaje' }}</h2>
    <form [formGroup]="form" (ngSubmit)="save()">
      <mat-dialog-content class="form-grid">
        <app-image-picker class="full" label="Imagen (opcional)" [round]="true"
                          [current]="data.character?.image ? cover(data.character!.image) : null" (picked)="file = $event" />
        <mat-form-field appearance="outline">
          <mat-label>Nombre</mat-label>
          <input matInput formControlName="name" />
          <mat-error>El nombre es obligatorio</mat-error>
        </mat-form-field>
        <mat-form-field appearance="outline">
          <mat-label>Edad</mat-label>
          <input matInput type="number" min="0" formControlName="age" />
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
export class CharacterFormDialog {
  private readonly catalog = inject(CatalogService);
  private readonly notify = inject(NotifyService);
  private readonly ref = inject(MatDialogRef<CharacterFormDialog>);

  readonly form = inject(FormBuilder).nonNullable.group({
    name: ['', Validators.required],
    age: [null as number | null],
    description: [''],
  });
  file: File | null = null;
  saving = false;
  readonly cover = imageUrl;

  constructor(@Inject(MAT_DIALOG_DATA) public data: CharacterDialogData) {
    const c = data.character;
    if (c) this.form.patchValue({ name: c.name, age: c.age, description: c.description ?? '' });
  }

  save(): void {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }
    const v = this.form.getRawValue();
    const payload: CharacterPayload = {
      name: v.name.trim(),
      age: v.age === null || (v.age as unknown) === '' ? null : Number(v.age),
      description: v.description.trim(),
    };
    this.saving = true;
    const current = this.data.character;
    const request: Observable<MangaCharacter> = current
      ? this.catalog.updateCharacter(current.id, payload).pipe(
          switchMap((c) => (this.file ? this.catalog.updateCharacterImage(c.id, this.file) : of(c)))
        )
      : this.catalog.createCharacter(this.data.mangaId, payload, this.file);

    request.subscribe({
      next: () => {
        this.notify.success(current ? 'Personaje actualizado' : 'Personaje añadido');
        this.ref.close(true);
      },
      error: (err) => {
        this.saving = false;
        this.notify.error(err);
      },
    });
  }
}
