import { Component, ViewChild, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { BreakpointObserver } from '@angular/cdk/layout';
import { NavigationEnd, Router, RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';
import { MatSidenav, MatSidenavModule } from '@angular/material/sidenav';
import { MatListModule } from '@angular/material/list';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatMenuModule } from '@angular/material/menu';
import { MatTooltipModule } from '@angular/material/tooltip';
import { toSignal } from '@angular/core/rxjs-interop';
import { filter, map } from 'rxjs';
import { AuthService } from '../core/auth.service';
import { NotifyService } from '../core/notify.service';
import { ThemeService } from '../core/theme.service';
import { avatarUrl } from '../core/api';

interface NavItem {
  label: string;
  icon: string;
  link: string;
}

@Component({
  selector: 'app-shell',
  standalone: true,
  imports: [
    CommonModule, RouterOutlet, RouterLink, RouterLinkActive, MatSidenavModule, MatListModule,
    MatIconModule, MatButtonModule, MatMenuModule, MatTooltipModule,
  ],
  template: `
    <mat-sidenav-container class="shell">
      <mat-sidenav #nav [mode]="isMobile() ? 'over' : 'side'" [opened]="!isMobile()" class="sidebar">
        <a routerLink="/" class="brand" (click)="closeOnMobile()">
          <img src="assets/img/logo-mark.png" alt="" />
          <span>ANIMANGA</span>
        </a>
        <span class="section">Panel de administración</span>
        <nav>
          <a *ngFor="let item of navItems" [routerLink]="item.link" routerLinkActive="active"
             [routerLinkActiveOptions]="{ exact: item.link === '/' }" class="nav-item" (click)="closeOnMobile()">
            <mat-icon>{{ item.icon }}</mat-icon>
            <span>{{ item.label }}</span>
          </a>
        </nav>
        <div class="sidebar-footer">Proyecto de fin de grado</div>
      </mat-sidenav>

      <mat-sidenav-content>
        <header class="topbar">
          <button mat-icon-button *ngIf="isMobile()" (click)="nav.toggle()" aria-label="Menú">
            <mat-icon>menu</mat-icon>
          </button>
          <span class="spacer"></span>
          <button mat-icon-button (click)="theme.toggle()"
                  [matTooltip]="theme.theme() === 'dark' ? 'Modo claro' : 'Modo oscuro'" aria-label="Cambiar tema">
            <mat-icon>{{ theme.theme() === 'dark' ? 'light_mode' : 'dark_mode' }}</mat-icon>
          </button>
          <button class="user-chip" [matMenuTriggerFor]="menu" *ngIf="auth.user() as user">
            <img [src]="avatar(user.avatar, user.fullName)" alt="" />
            <span class="user-name">{{ user.fullName }}</span>
            <mat-icon>expand_more</mat-icon>
          </button>
          <mat-menu #menu="matMenu" xPosition="before">
            <a mat-menu-item routerLink="/perfil"><mat-icon>person</mat-icon>Mi perfil</a>
            <button mat-menu-item (click)="logout()"><mat-icon>logout</mat-icon>Cerrar sesión</button>
          </mat-menu>
        </header>
        <main class="content">
          <router-outlet />
        </main>
      </mat-sidenav-content>
    </mat-sidenav-container>
  `,
  styleUrls: ['./shell.component.css'],
})
export class ShellComponent {
  @ViewChild('nav') sidenav!: MatSidenav;

  readonly auth = inject(AuthService);
  readonly theme = inject(ThemeService);
  readonly avatar = avatarUrl;
  private readonly notify = inject(NotifyService);

  readonly isMobile = toSignal(
    inject(BreakpointObserver).observe('(max-width: 900px)').pipe(map((r) => r.matches)),
    { initialValue: false }
  );

  readonly navItems: NavItem[] = [
    { label: 'Resumen', icon: 'space_dashboard', link: '/' },
    { label: 'Mangas', icon: 'auto_stories', link: '/mangas' },
    { label: 'Categorías', icon: 'sell', link: '/categorias' },
    { label: 'Usuarios', icon: 'group', link: '/usuarios' },
    { label: 'Pedidos', icon: 'local_shipping', link: '/pedidos' },
  ];

  constructor() {
    // Al navegar en móvil se cierra el menú lateral
    inject(Router).events.pipe(filter((e) => e instanceof NavigationEnd)).subscribe(() => this.closeOnMobile());
  }

  closeOnMobile(): void {
    if (this.isMobile()) this.sidenav?.close();
  }

  logout(): void {
    this.notify
      .confirm({ title: 'Cerrar sesión', message: '¿Seguro que quieres salir del panel?', confirmText: 'Salir' })
      .subscribe((ok) => ok && this.auth.logout());
  }
}
