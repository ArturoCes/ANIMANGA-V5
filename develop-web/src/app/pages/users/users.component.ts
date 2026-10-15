import { Component, Inject, OnInit, inject } from '@angular/core';
import { FormBuilder, FormControl, Validators } from '@angular/forms';
import { MAT_DIALOG_DATA, MatDialog, MatDialogRef } from '@angular/material/dialog';
import { PageEvent } from '@angular/material/paginator';
import { debounceTime, distinctUntilChanged, merge } from 'rxjs';
import { UI } from '../../shared/material';
import { UsersService } from '../../core/users.service';
import { NotifyService } from '../../core/notify.service';
import { AuthService } from '../../core/auth.service';
import { Role, User } from '../../core/models';

@Component({
  standalone: true,
  imports: [...UI],
  template: `
    <h2 mat-dialog-title>Editar usuario</h2>
    <form [formGroup]="form" (ngSubmit)="save()">
      <mat-dialog-content class="form-grid">
        <mat-form-field appearance="outline" class="full">
          <mat-label>Nombre completo</mat-label>
          <input matInput formControlName="fullName" />
          <mat-error>El nombre es obligatorio</mat-error>
        </mat-form-field>
        <mat-form-field appearance="outline" class="full">
          <mat-label>Email</mat-label>
          <input matInput type="email" formControlName="email" />
          <mat-error>Introduce un email válido</mat-error>
        </mat-form-field>
      </mat-dialog-content>
      <mat-dialog-actions align="end">
        <button mat-button type="button" mat-dialog-close>Cancelar</button>
        <button mat-flat-button color="primary" [disabled]="saving">{{ saving ? 'Guardando…' : 'Guardar' }}</button>
      </mat-dialog-actions>
    </form>
  `,
})
export class UserFormDialog {
  private readonly users = inject(UsersService);
  private readonly notify = inject(NotifyService);
  private readonly ref = inject(MatDialogRef<UserFormDialog>);
  saving = false;

  readonly form = inject(FormBuilder).nonNullable.group({
    fullName: ['', Validators.required],
    email: ['', [Validators.required, Validators.email]],
  });

  constructor(@Inject(MAT_DIALOG_DATA) public user: User) {
    this.form.patchValue(user);
  }

  save(): void {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }
    this.saving = true;
    this.users.update(this.user, this.form.getRawValue()).subscribe({
      next: (u) => {
        this.notify.success('Usuario actualizado');
        this.ref.close(u);
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
        <h1>Usuarios</h1>
        <p class="muted">{{ total }} cuentas registradas</p>
      </div>
    </div>

    <div class="card table-card">
      <div class="toolbar">
        <mat-form-field appearance="outline" class="search" subscriptSizing="dynamic">
          <mat-icon matPrefix>search</mat-icon>
          <input matInput [formControl]="search" placeholder="Buscar por usuario, nombre o email" />
        </mat-form-field>
        <mat-button-toggle-group [formControl]="role" aria-label="Filtrar por rol">
          <mat-button-toggle [value]="null">Todos</mat-button-toggle>
          <mat-button-toggle value="ADMIN">Admins</mat-button-toggle>
          <mat-button-toggle value="USER">Clientes</mat-button-toggle>
        </mat-button-toggle-group>
      </div>
      <mat-progress-bar *ngIf="loading" mode="indeterminate" />

      <div class="table-scroll">
        <table mat-table [dataSource]="users">
          <ng-container matColumnDef="user">
            <th mat-header-cell *matHeaderCellDef>Usuario</th>
            <td mat-cell *matCellDef="let u">
              <div class="user-cell">
                <img class="avatar" [src]="u.image" alt="" />
                <div>
                  <strong>{{ u.fullName }}</strong>
                  <div class="muted small">&#64;{{ u.username }}</div>
                </div>
              </div>
            </td>
          </ng-container>
          <ng-container matColumnDef="email">
            <th mat-header-cell *matHeaderCellDef>Email</th>
            <td mat-cell *matCellDef="let u">{{ u.email }}</td>
          </ng-container>
          <ng-container matColumnDef="role">
            <th mat-header-cell *matHeaderCellDef>Rol</th>
            <td mat-cell *matCellDef="let u">
              <span class="badge" [class.badge-brand]="u.role === 'ADMIN'">{{ u.role === 'ADMIN' ? 'Administrador' : 'Cliente' }}</span>
            </td>
          </ng-container>
          <ng-container matColumnDef="actions">
            <th mat-header-cell *matHeaderCellDef></th>
            <td mat-cell *matCellDef="let u" class="actions">
              <ng-container *ngIf="u.id !== me?.id; else itsMe">
                <button mat-icon-button (click)="toggleAdmin(u)"
                        [matTooltip]="u.role === 'ADMIN' ? 'Quitar administrador' : 'Hacer administrador'">
                  <mat-icon>{{ u.role === 'ADMIN' ? 'remove_moderator' : 'add_moderator' }}</mat-icon>
                </button>
                <button mat-icon-button (click)="edit(u)" matTooltip="Editar"><mat-icon>edit</mat-icon></button>
                <button mat-icon-button (click)="remove(u)" matTooltip="Eliminar"><mat-icon>delete</mat-icon></button>
              </ng-container>
              <ng-template #itsMe><span class="muted small">Tu cuenta</span></ng-template>
            </td>
          </ng-container>
          <tr mat-header-row *matHeaderRowDef="columns"></tr>
          <tr mat-row *matRowDef="let row; columns: columns"></tr>
          <tr class="mat-row" *matNoDataRow>
            <td class="empty-cell" [attr.colspan]="columns.length">{{ loading ? 'Cargando…' : 'No hay usuarios que coincidan' }}</td>
          </tr>
        </table>
      </div>
      <mat-paginator [length]="total" [pageIndex]="page" [pageSize]="size" [pageSizeOptions]="[5, 10, 20]"
                     (page)="onPage($event)" showFirstLastButtons />
    </div>
  `,
  styles: [
    `.user-cell { display: flex; align-items: center; gap: 12px; }
     .avatar { width: 40px; height: 40px; border-radius: 50%; object-fit: cover; }
     .small { font-size: 13px; }`,
  ],
})
export class UsersComponent implements OnInit {
  private readonly service = inject(UsersService);
  private readonly dialog = inject(MatDialog);
  private readonly notify = inject(NotifyService);
  readonly me = inject(AuthService).user();

  readonly columns = ['user', 'email', 'role', 'actions'];
  readonly search = new FormControl('', { nonNullable: true });
  readonly role = new FormControl<Role | null>(null);

  users: User[] = [];
  total = 0;
  page = 0;
  size = 10;
  loading = false;

  ngOnInit(): void {
    this.load();
    merge(this.search.valueChanges.pipe(debounceTime(300), distinctUntilChanged()), this.role.valueChanges)
      .subscribe(() => {
        this.page = 0;
        this.load();
      });
  }

  load(): void {
    this.loading = true;
    const term = this.search.value.trim();
    const role = this.role.value;
    const request =
      term || role
        ? this.service.search({ username: term, fullName: term, email: term, role }, this.page, this.size)
        : this.service.users(this.page, this.size);
    request.subscribe({
      next: (res) => {
        this.users = res.content;
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

  toggleAdmin(user: User): void {
    const makeAdmin = user.role !== 'ADMIN';
    this.notify
      .confirm({
        title: makeAdmin ? 'Dar permisos de administrador' : 'Quitar permisos de administrador',
        message: makeAdmin
          ? `${user.fullName} podrá gestionar el catálogo, los usuarios y las ventas.`
          : `${user.fullName} dejará de tener acceso al panel.`,
        confirmText: makeAdmin ? 'Hacer administrador' : 'Quitar permisos',
        danger: !makeAdmin,
      })
      .subscribe((ok) => {
        if (!ok) return;
        this.service.setAdmin(user.id, makeAdmin).subscribe({
          next: () => {
            this.notify.success('Rol actualizado');
            this.load();
          },
          error: (err) => this.notify.error(err),
        });
      });
  }

  edit(user: User): void {
    this.dialog
      .open(UserFormDialog, { data: user, width: '460px', maxWidth: '95vw' })
      .afterClosed()
      .subscribe((saved) => saved && this.load());
  }

  remove(user: User): void {
    this.notify
      .confirm({
        title: 'Eliminar usuario',
        message: `Se eliminará la cuenta de ${user.fullName} (@${user.username}).`,
        confirmText: 'Eliminar',
        danger: true,
      })
      .subscribe((ok) => {
        if (!ok) return;
        this.service.delete(user.id).subscribe({
          next: () => {
            this.notify.success('Usuario eliminado');
            this.load();
          },
          error: (err) => this.notify.error(err),
        });
      });
  }
}
