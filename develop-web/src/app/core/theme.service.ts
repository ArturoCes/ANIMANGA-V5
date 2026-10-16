import { Injectable, signal } from '@angular/core';

type Theme = 'light' | 'dark';
const KEY = 'animanga.theme';

/**
 * Modo claro/oscuro. Respeta la preferencia del sistema hasta que el usuario elige uno,
 * y cambia tanto el tema de Angular Material como las variables CSS propias.
 */
@Injectable({ providedIn: 'root' })
export class ThemeService {
  readonly theme = signal<Theme>(this.initial());

  constructor() {
    this.apply(this.theme());
  }

  toggle(): void {
    const next: Theme = this.theme() === 'dark' ? 'light' : 'dark';
    try {
      localStorage.setItem(KEY, next);
    } catch {
      /* sin almacenamiento: el cambio dura hasta recargar */
    }
    this.theme.set(next);
    this.apply(next);
  }

  private apply(theme: Theme): void {
    document.documentElement.classList.toggle('dark', theme === 'dark');
    let link = document.getElementById('material-theme') as HTMLLinkElement | null;
    if (!link) {
      link = document.createElement('link');
      link.id = 'material-theme';
      link.rel = 'stylesheet';
      document.head.prepend(link);
    }
    link.href = theme === 'dark' ? 'theme-dark.css' : 'theme-light.css';
  }

  private initial(): Theme {
    try {
      const saved = localStorage.getItem(KEY);
      if (saved === 'light' || saved === 'dark') return saved;
    } catch {
      /* ignorado */
    }
    return window.matchMedia?.('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
  }
}
