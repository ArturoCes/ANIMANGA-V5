import { Component, inject } from '@angular/core';
import { AbstractControl, FormBuilder, ValidationErrors, Validators } from '@angular/forms';
import { UI } from '../../shared/material';
import { ImagePickerComponent } from '../../shared/image-picker.component';
import { AuthService } from '../../core/auth.service';
import { UsersService } from '../../core/users.service';
import { NotifyService } from '../../core/notify.service';
import { avatarUrl } from '../../core/api';

function passwordsMatch(group: AbstractControl): ValidationErrors | null {
  const { passwordNew, passwordNewVerify } = group.value;
  return passwordNew && passwordNew !== passwordNewVerify ? { mismatch: true } : null;
}

@Component({
  standalone: true,
  imports: [...UI, ImagePickerComponent],
  template: `
    <div class="page-header">
      <div>
        <h1>Mi perfil</h1>
        <p class="muted">&#64;{{ auth.user()?.username }} · Administrador
          <span class="badge badge-warn" *ngIf="auth.user() && !auth.user()!.emailVerified">Email sin verificar</span></p>
      </div>
    </div>

    <div class="grid">
      <section class="card">
        <h2>Datos personales</h2>
        <form [formGroup]="profile" (ngSubmit)="saveProfile()" class="stack">
          <app-image-picker label="Foto de perfil" [round]="true" [current]="avatarOf()"
                            (picked)="avatar = $event" />
          <mat-form-field appearance="outline">
            <mat-label>Nombre completo</mat-label>
            <input matInput formControlName="fullName" />
            <mat-error>El nombre es obligatorio</mat-error>
          </mat-form-field>
          <mat-form-field appearance="outline">
            <mat-label>Email</mat-label>
            <input matInput type="email" formControlName="email" />
            <mat-error>Introduce un email válido</mat-error>
            <mat-hint>Si lo cambias tendrás que confirmarlo desde el nuevo correo</mat-hint>
          </mat-form-field>
          <div>
            <button mat-flat-button color="primary" [disabled]="savingProfile || (profile.pristine && !avatar)">
              {{ savingProfile ? 'Guardando…' : 'Guardar cambios' }}
            </button>
          </div>
        </form>
      </section>

      <section class="card">
        <h2>Cambiar contraseña</h2>
        <form [formGroup]="password" (ngSubmit)="savePassword()" class="stack">
          <mat-form-field appearance="outline">
            <mat-label>Contraseña actual</mat-label>
            <input matInput type="password" formControlName="password" autocomplete="current-password" />
          </mat-form-field>
          <mat-form-field appearance="outline">
            <mat-label>Nueva contraseña</mat-label>
            <input matInput type="password" formControlName="passwordNew" autocomplete="new-password" />
            <mat-hint>Mínimo 8 caracteres</mat-hint>
            <mat-error>Mínimo 8 caracteres</mat-error>
          </mat-form-field>
          <mat-form-field appearance="outline">
            <mat-label>Repite la nueva contraseña</mat-label>
            <input matInput type="password" formControlName="passwordNewVerify" autocomplete="new-password" />
          </mat-form-field>
          <p class="error" *ngIf="password.hasError('mismatch') && password.get('passwordNewVerify')?.touched">
            Las contraseñas no coinciden
          </p>
          <div>
            <button mat-flat-button color="primary" [disabled]="savingPassword || password.invalid">
              {{ savingPassword ? 'Guardando…' : 'Cambiar contraseña' }}
            </button>
          </div>
        </form>
      </section>
    </div>
  `,
  styles: [
    `.grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 16px; align-items: start; }
     h2 { margin: 0 0 16px; font-size: 18px; }
     .stack { display: flex; flex-direction: column; gap: 4px; }
     app-image-picker { margin-bottom: 16px; }
     .error { color: var(--danger); margin: 0 0 8px; font-size: 14px; }`,
  ],
})
export class ProfileComponent {
  readonly auth = inject(AuthService);
  private readonly users = inject(UsersService);
  private readonly notify = inject(NotifyService);
  private readonly fb = inject(FormBuilder).nonNullable;

  readonly profile = this.fb.group({
    fullName: [this.auth.user()?.fullName ?? '', Validators.required],
    email: [this.auth.user()?.email ?? '', [Validators.required, Validators.email]],
  });

  readonly password = this.fb.group(
    {
      password: ['', Validators.required],
      passwordNew: ['', [Validators.required, Validators.minLength(8)]],
      passwordNewVerify: ['', Validators.required],
    },
    { validators: passwordsMatch }
  );

  avatar: File | null = null;

  avatarOf(): string | null {
    const u = this.auth.user();
    return u ? avatarUrl(u.avatar, u.fullName) : null;
  }
  savingProfile = false;
  savingPassword = false;

  saveProfile(): void {
    const user = this.auth.user();
    if (!user || this.profile.invalid) return;
    this.savingProfile = true;
    this.users.updateMe(this.profile.getRawValue()).subscribe({
      next: (updated) => {
        if (!this.avatar) return this.profileSaved(updated);
        this.users.updateAvatar(this.avatar).subscribe({
          next: (withAvatar) => this.profileSaved(withAvatar),
          error: (err) => this.profileFailed(err),
        });
      },
      error: (err) => this.profileFailed(err),
    });
  }

  savePassword(): void {
    if (this.password.invalid) return;
    const { password, passwordNew } = this.password.getRawValue();
    this.savingPassword = true;
    this.users.changePassword(password, passwordNew).subscribe({
      next: () => {
        this.savingPassword = false;
        this.password.reset();
        this.notify.success('Contraseña actualizada');
      },
      error: (err) => {
        this.savingPassword = false;
        this.notify.error(err);
      },
    });
  }

  private profileSaved(user: Parameters<AuthService['setUser']>[0]): void {
    this.auth.setUser(user);
    this.avatar = null;
    this.savingProfile = false;
    this.profile.markAsPristine();
    this.notify.success('Perfil actualizado');
  }

  private profileFailed(err: unknown): void {
    this.savingProfile = false;
    this.notify.error(err);
  }
}
