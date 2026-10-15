import { HttpErrorResponse } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { MatSnackBar } from '@angular/material/snack-bar';
import { Observable, map } from 'rxjs';
import { errorMessage } from './api';
import { ConfirmDialogComponent, ConfirmData } from '../shared/confirm-dialog.component';

@Injectable({ providedIn: 'root' })
export class NotifyService {
  constructor(private snack: MatSnackBar, private dialog: MatDialog) {}

  success(message: string): void {
    this.snack.open(message, 'OK', { duration: 3000, panelClass: 'snack-success' });
  }

  error(messageOrError: unknown): void {
    // Las sesiones caducadas ya las gestiona el interceptor con su propio aviso
    if (messageOrError instanceof HttpErrorResponse && messageOrError.status === 401) return;
    const message = typeof messageOrError === 'string' ? messageOrError : errorMessage(messageOrError);
    this.snack.open(message, 'Cerrar', { duration: 6000, panelClass: 'snack-error' });
  }

  confirm(data: ConfirmData): Observable<boolean> {
    return this.dialog
      .open(ConfirmDialogComponent, { data, width: '420px', autoFocus: false })
      .afterClosed()
      .pipe(map((r) => r === true));
  }
}
