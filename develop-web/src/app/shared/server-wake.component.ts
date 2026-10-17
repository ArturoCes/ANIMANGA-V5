import { Component, OnDestroy, OnInit, inject, signal } from '@angular/core';
import { Router } from '@angular/router';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { MatIconModule } from '@angular/material/icon';
import { NgIf } from '@angular/common';
import { API } from '../core/api';

/**
 * La demo usa el plan gratuito de Render, que duerme la API tras un rato sin visitas.
 * Al abrir el panel se comprueba si responde; si tarda, se muestra un aviso hasta que despierte.
 */
@Component({
  selector: 'app-server-wake',
  standalone: true,
  imports: [NgIf, MatProgressBarModule, MatIconModule],
  template: `
    <div *ngIf="state() === 'waking' || state() === 'done'" class="wake-backdrop" role="alertdialog" aria-live="polite" aria-labelledby="wake-title">
        <div class="wake-card">
          <ng-container *ngIf="state() === 'waking'; else ready">
            <mat-icon class="wake-icon">bedtime</mat-icon>
            <h2 id="wake-title">Despertando el servidor…</h2>
            <p>
              Esta demo está en un servidor gratuito que se duerme cuando nadie la usa.
              La primera vez tarda <strong>hasta un minuto</strong> en arrancar; después va normal.
            </p>
            <mat-progress-bar mode="indeterminate" />
            <p class="wake-time">{{ seconds() }} s</p>
          </ng-container>
          <ng-template #ready>
            <mat-icon class="wake-icon ok">check_circle</mat-icon>
            <h2 id="wake-title">¡Servidor listo!</h2>
          </ng-template>
        </div>
      </div>
  `,
  styles: [
    `.wake-backdrop { position: fixed; inset: 0; z-index: 2000; display: grid; place-items: center; padding: 16px;
                      background: rgba(10, 8, 16, .72); backdrop-filter: blur(4px); }
     .wake-card { width: min(420px, 100%); padding: 28px 24px 22px; border-radius: 18px; text-align: center;
                  background: var(--surface); color: var(--text); border: 1px solid var(--border);
                  box-shadow: 0 24px 60px rgba(0, 0, 0, .4); }
     .wake-icon { font-size: 40px; width: 40px; height: 40px; color: var(--brand); }
     .wake-icon.ok { color: #22c55e; }
     h2 { margin: 10px 0 8px; font-size: 20px; }
     p { margin: 0 0 16px; color: var(--muted); line-height: 1.5; font-size: 14px; }
     .wake-time { margin: 10px 0 0; font-size: 12px; font-variant-numeric: tabular-nums; }`,
  ],
})
export class ServerWakeComponent implements OnInit, OnDestroy {
  private readonly router = inject(Router);
  /** checking = aún no se sabe (no se muestra nada); waking = aviso visible; done = acaba de despertar. */
  readonly state = signal<'checking' | 'waking' | 'done' | 'ready'>('checking');
  readonly seconds = signal(0);
  private timer?: ReturnType<typeof setInterval>;
  private stopped = false;

  ngOnInit(): void {
    const start = Date.now();
    // Solo se avisa si la primera respuesta tarda: con el servidor despierto no se ve nada
    const showAfter = setTimeout(() => {
      if (this.state() === 'checking') this.state.set('waking');
    }, 1500);
    this.timer = setInterval(() => this.seconds.set(Math.round((Date.now() - start) / 1000)), 1000);
    this.poll().then(() => {
      clearTimeout(showAfter);
      clearInterval(this.timer);
      if (this.state() === 'checking') {
        this.state.set('ready');
        return;
      }
      this.state.set('done');
      setTimeout(() => {
        // Lo que se pidió mientras dormía falló: se recarga para volver a pedirlo (en el login no hace falta)
        if (!this.router.url.startsWith('/login')) location.reload();
        else this.state.set('ready');
      }, 900);
    });
  }

  ngOnDestroy(): void {
    this.stopped = true;
    clearInterval(this.timer);
  }

  /** Reintenta hasta que la API conteste (Netlify corta las peticiones largas, así que se repiten). */
  private async poll(): Promise<void> {
    while (!this.stopped) {
      const ctrl = new AbortController();
      const timeout = setTimeout(() => ctrl.abort(), 15000);
      try {
        const res = await fetch(`${API}actuator/health`, { signal: ctrl.signal, cache: 'no-store' });
        if (res.ok) return;
      } catch {
        // dormida o arrancando: se vuelve a intentar
      } finally {
        clearTimeout(timeout);
      }
      await new Promise((r) => setTimeout(r, 3000));
    }
  }
}
