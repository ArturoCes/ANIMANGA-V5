import { Component, Inject } from '@angular/core';
import { MAT_DIALOG_DATA, MatDialogModule } from '@angular/material/dialog';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';

export interface ConfirmData {
  title: string;
  message: string;
  confirmText?: string;
  danger?: boolean;
}

@Component({
  standalone: true,
  imports: [MatDialogModule, MatButtonModule, MatIconModule],
  template: `
    <h2 mat-dialog-title class="confirm-title">
      <mat-icon [class.danger]="data.danger">{{ data.danger ? 'warning' : 'help_outline' }}</mat-icon>
      {{ data.title }}
    </h2>
    <mat-dialog-content>{{ data.message }}</mat-dialog-content>
    <mat-dialog-actions align="end">
      <button mat-button [mat-dialog-close]="false">Cancelar</button>
      <button mat-flat-button [color]="data.danger ? 'warn' : 'primary'" [mat-dialog-close]="true">
        {{ data.confirmText ?? 'Aceptar' }}
      </button>
    </mat-dialog-actions>
  `,
  styles: [
    `.confirm-title { display: flex; align-items: center; gap: 8px; }
     mat-icon.danger { color: var(--danger); }`,
  ],
})
export class ConfirmDialogComponent {
  constructor(@Inject(MAT_DIALOG_DATA) public data: ConfirmData) {}
}
