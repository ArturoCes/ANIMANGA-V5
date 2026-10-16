import { Component, EventEmitter, Input, OnDestroy, Output } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';

/** Selector de imagen con vista previa. */
@Component({
  selector: 'app-image-picker',
  standalone: true,
  imports: [CommonModule, MatButtonModule, MatIconModule],
  template: `
    <div class="picker" [class.round]="round">
      <button type="button" class="frame" (click)="input.click()" [attr.aria-label]="'Elegir ' + label.toLowerCase()">
        <img *ngIf="preview ?? current as src; else empty" [src]="src" alt="" />
        <ng-template #empty>
          <mat-icon>{{ round ? 'person' : 'add_photo_alternate' }}</mat-icon>
        </ng-template>
      </button>
      <div class="picker-info">
        <span class="label">{{ label }} <span class="required" *ngIf="required && !preview && !current">· obligatoria</span></span>
        <button mat-stroked-button type="button" (click)="input.click()">
          <mat-icon>upload</mat-icon> {{ preview || current ? 'Cambiar' : 'Elegir' }} imagen
        </button>
        <span class="hint">JPG, PNG o WEBP · máx. 5 MB</span>
      </div>
      <input #input type="file" accept="image/*" hidden (change)="onChange($event)" />
    </div>
  `,
  styles: [
    `.picker { display: flex; gap: 16px; align-items: center; }
     .frame { width: 84px; height: 120px; flex-shrink: 0; padding: 0; border-radius: 10px; overflow: hidden; cursor: pointer;
              display: grid; place-items: center; background: var(--surface-2); border: 1px dashed var(--border); color: var(--muted); }
     .frame:hover { border-color: var(--brand); color: var(--brand); }
     .frame img { width: 100%; height: 100%; object-fit: cover; display: block; }
     .frame mat-icon { font-size: 30px; width: 30px; height: 30px; }
     .round .frame { width: 88px; height: 88px; border-radius: 50%; }
     .picker-info { display: flex; flex-direction: column; gap: 8px; align-items: flex-start; }
     .label { font-weight: 600; color: var(--text); }
     .required { font-weight: 400; color: var(--warn); font-size: 13px; }
     .hint { font-size: 12px; color: var(--muted); white-space: nowrap; }`,
  ],
})
export class ImagePickerComponent implements OnDestroy {
  @Input() label = 'Imagen';
  @Input() current: string | null = null;
  @Input() required = false;
  @Input() round = false;
  @Output() picked = new EventEmitter<File>();

  preview: string | null = null;

  onChange(event: Event): void {
    const file = (event.target as HTMLInputElement).files?.[0];
    if (!file) return;
    if (this.preview) URL.revokeObjectURL(this.preview);
    this.preview = URL.createObjectURL(file);
    this.picked.emit(file);
  }

  ngOnDestroy(): void {
    if (this.preview) URL.revokeObjectURL(this.preview);
  }
}
