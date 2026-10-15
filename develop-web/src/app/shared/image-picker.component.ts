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
      <img [src]="preview ?? current" [alt]="label" />
      <div class="picker-info">
        <span class="label">{{ label }}</span>
        <span class="hint" *ngIf="required && !preview && !current">Obligatoria</span>
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
     img { width: 84px; height: 120px; object-fit: cover; border-radius: 8px; background: var(--surface-2); border: 1px solid var(--border); }
     .round img { width: 88px; height: 88px; border-radius: 50%; }
     .picker-info { display: flex; flex-direction: column; gap: 6px; align-items: flex-start; }
     .label { font-weight: 600; }
     .hint { font-size: 12px; color: var(--muted); }`,
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
