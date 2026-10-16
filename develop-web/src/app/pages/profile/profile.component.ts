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
    <div class="profile">
      <div class="page-header">
        <div class="identity">
          <img class="avatar" [src]="avatarOf()" alt="" />
          <div>
            <h1>{{ auth.user()?.fullName }}</h1>
            <p class="muted">
              &#64;{{ auth.user()?.username }} · Administrador
              <span class="badge badge-warn" *ngIf="auth.user() && !auth.user()!.emailVerified">Email sin verificar</span>
            </p>
          </div>
        </div>
      </div>

      <div class="grid">
        <section class="card">
          <h2>Datos personales</h2>
          <p class="muted section-sub">Tu nombre, email y foto en el panel.</p>
          <form [formGroup]="profile" (ngSubmit)="saveProfile()" class="stack-form">
            <app-image-picker label="Foto de perfil" [round]="true" [current]="avatarOf()"
                              (picked)="avatar = $event" />
            <mat-form-field appearance="outline">
              <mat-label>Nombre completo</mat-label>
              <input matInput formControlName="fullName" autocomplete="name" />
              <mat-error>El nombre es obligatorio</mat-error>
            </mat-form-field>
            <mat-form-field appearance="outline" subscriptSizing="dynamic">
              <mat-label>Email</mat-label>
              <input matInput type="email" formControlName="email" autocomplete="email" />
              <mat-error>Introduce un email válido</mat-error>
              <mat-hint>Si lo cambias, tendrás que confirmarlo desde el nuevo correo.</mat-hint>
            </mat-form-field>
            <div class="form-actions">
              <button mat-flat-button color="primary" [disabled]="savingProfile || (profile.pristine && !avatar)">
                {{ savingProfile ? 'Guardando…' : 'Guardar cambios' }}
              </button>
            </div>
          </form>
        </section>

        <section class="card">
          <h2>Cambiar contraseña</h2>
          <p class="muted section-sub">Usa al menos 8 caracteres.</p>
          <form [formGroup]="password" (ngSubmit)="savePassword()" class="stack-form">
            <mat-form-field appearance="outline">
              <mat-label>Contraseña actual</mat-label>
              <input matInput type="password" formControlName="password" autocomplete="current-password" />
            </mat-form-field>
            <mat-form-field appearance="outline">
              <mat-label>Nueva contraseña</mat-label>
              <input matInput type="password" formControlName="passwordNew" autocomplete="new-password" />
              <mat-error>Mínimo 8 caracteres</mat-error>
            </mat-form-field>
            <mat-form-field appearance="outline" subscriptSizing="dynamic">
              <mat-label>Repite la nueva contraseña</mat-label>
              <input matInput type="password" formControlName="passwordNewVerify" autocomplete="new-password" />
              <mat-hint class="error-hint" *ngIf="password.hasError('mismatch') && password.get('passwordNewVerify')?.touched">
                Las contraseñas no coinciden
              </mat-hint>
            </mat-form-field>
            <div class="form-actions">
              <button mat-flat-button color="primary" [disabled]="savingPassword || password.invalid">
                {{ savingPassword ? 'Guardando…' : 'Cambiar contraseña' }}
              </button>
            </div>
          </form>
        </section>
      </div>
    </div>
  `,
  styles: [
    `.profile { max-width: 980px; margin: 0 auto; }
     .identity { display: flex; align-items: center; gap: 16px; }
     .identity .avatar { width: 56px; height: 56px; border-radius: 50%; object-fit: cover; border: 2px solid var(--border); }
     .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 16px; align-items: stretch; }
     .grid .card { display: flex; flex-direction: column; padding: 24px; }
     .grid form { flex: 1; }
     .form-actions { margin-top: auto; padding-top: 12px; }
     h2 { margin: 0; font-size: 18px; }
     .section-sub { margin: 4px 0 20px; font-size: 14px; }
     app-image-picker { display: block; margin-bottom: 20px; }
     .error-hint { color: var(--danger) !important; }`,
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
