import { Component, inject } from '@angular/core';
import { FormBuilder, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { UI } from '../../shared/material';
import { AuthService } from '../../core/auth.service';
import { errorMessage } from '../../core/api';

@Component({
  standalone: true,
  imports: [...UI],
  template: `
    <div class="login">
      <section class="panel">
        <div class="box">
          <img src="assets/img/Logo.png" alt="Animanga" class="logo" />
          <h1>Panel de administración</h1>
          <p class="sub">Gestiona el catálogo, los usuarios y las ventas de la tienda.</p>

          <form [formGroup]="form" (ngSubmit)="submit()">
            <mat-form-field appearance="outline">
              <mat-label>Usuario</mat-label>
              <input matInput formControlName="username" autocomplete="username" />
              <mat-icon matSuffix>person</mat-icon>
            </mat-form-field>

            <mat-form-field appearance="outline">
              <mat-label>Contraseña</mat-label>
              <input matInput [type]="showPassword ? 'text' : 'password'" formControlName="password"
                     autocomplete="current-password" />
              <button mat-icon-button matSuffix type="button" (click)="showPassword = !showPassword"
                      [attr.aria-label]="showPassword ? 'Ocultar contraseña' : 'Mostrar contraseña'">
                <mat-icon>{{ showPassword ? 'visibility_off' : 'visibility' }}</mat-icon>
              </button>
            </mat-form-field>

            <p class="error" *ngIf="error">{{ error }}</p>

            <button mat-flat-button color="primary" class="submit" [disabled]="loading || form.invalid">
              <mat-progress-spinner *ngIf="loading" diameter="18" mode="indeterminate" />
              <span *ngIf="!loading">Iniciar sesión</span>
            </button>
          </form>

          <div class="demo">
            <mat-icon>info</mat-icon>
            <div>
              <strong>Cuenta de demostración</strong>
              <span>Usuario <code>admin</code> · Contraseña <code>Admin1234</code></span>
              <button mat-button color="primary" type="button" (click)="fillDemo()">Rellenar</button>
            </div>
          </div>
        </div>
      </section>
      <section class="art" aria-hidden="true"></section>
    </div>
  `,
  styles: [
    `.login { min-height: 100vh; display: grid; grid-template-columns: minmax(360px, 520px) 1fr; background: var(--surface); }
     .panel { display: flex; align-items: center; justify-content: center; padding: 40px 32px; }
     .box { width: 100%; max-width: 380px; }
     .logo { width: 240px; max-width: 100%; margin-bottom: 28px; }
     h1 { font-size: 26px; margin: 0 0 6px; }
     .sub { color: var(--muted); margin: 0 0 28px; }
     form { display: flex; flex-direction: column; gap: 4px; }
     .submit { height: 48px; font-size: 16px; display: flex; justify-content: center; }
     .error { color: var(--danger); margin: -4px 0 12px; font-size: 14px; }
     .demo { margin-top: 28px; display: flex; gap: 12px; padding: 14px 16px; border-radius: 12px; background: var(--brand-soft); color: var(--brand-dark); }
     .demo div { display: flex; flex-direction: column; align-items: flex-start; gap: 2px; font-size: 14px; }
     .demo button { margin-left: -12px; }
     code { background: rgba(255,255,255,.7); padding: 1px 6px; border-radius: 4px; }
     .art { background: #121826 url('/assets/img/login-art.jpg') center / cover no-repeat; }
     @media (max-width: 860px) { .login { grid-template-columns: 1fr; } .art { display: none; } }`,
  ],
})
export class LoginComponent {
  private readonly auth = inject(AuthService);
  private readonly router = inject(Router);

  readonly form = inject(FormBuilder).nonNullable.group({
    username: ['', Validators.required],
    password: ['', Validators.required],
  });

  loading = false;
  showPassword = false;
  error = '';

  fillDemo(): void {
    this.form.setValue({ username: 'admin', password: 'Admin1234' });
  }

  submit(): void {
    if (this.form.invalid) return;
    this.loading = true;
    this.error = '';
    const { username, password } = this.form.getRawValue();
    this.auth.login(username.trim(), password).subscribe({
      next: (user) => {
        this.loading = false;
        if (user.role !== 'ADMIN') {
          this.auth.logout(false);
          this.error = 'Este panel es solo para administradores. Usa la app móvil para comprar.';
          return;
        }
        this.router.navigate(['/']);
      },
      error: (err) => {
        this.loading = false;
        this.error = err.status === 401 ? 'Usuario o contraseña incorrectos' : errorMessage(err);
      },
    });
  }
}
