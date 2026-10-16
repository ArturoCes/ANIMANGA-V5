import { Component, Input, computed, signal } from '@angular/core';
import { CommonModule } from '@angular/common';

export interface BarDatum {
  label: string;
  value: number;
  hint?: string;
}

/** Gráfico de barras en SVG (sin dependencias) con etiqueta al pasar el ratón. */
@Component({
  selector: 'app-bar-chart',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="chart" role="img" [attr.aria-label]="ariaLabel">
      <div class="bars">
        <div class="col" *ngFor="let d of data(); let i = index"
             (mouseenter)="hover.set(i)" (mouseleave)="hover.set(null)">
          <span class="tip" *ngIf="hover() === i">{{ format(d.value) }}<small *ngIf="d.hint"> · {{ d.hint }}</small></span>
          <div class="bar" [style.height.%]="max() ? (d.value / max()) * 100 : 0"
               [class.active]="hover() === i || (hover() === null && i === data().length - 1)"></div>
          <span class="label">{{ d.label }}</span>
        </div>
      </div>
    </div>
  `,
  styles: [
    `.chart { height: 220px; display: flex; }
     .bars { flex: 1; display: flex; align-items: flex-end; gap: 12px; padding-top: 28px; }
     .col { flex: 1; height: 100%; display: flex; flex-direction: column; justify-content: flex-end; align-items: center; position: relative; }
     .bar { width: 100%; max-width: 56px; min-height: 3px; border-radius: 8px 8px 3px 3px; background: var(--brand-soft); transition: background .15s, height .4s; }
     .bar.active { background: var(--brand); }
     .label { margin-top: 8px; font-size: 12px; color: var(--muted); text-transform: capitalize; white-space: nowrap; }
     .tip { position: absolute; top: 0; padding: 3px 8px; border-radius: 6px; background: var(--text); color: var(--surface);
            font-size: 12px; font-weight: 600; white-space: nowrap; transform: translateY(-4px); }
     .tip small { font-weight: 400; opacity: .8; }`,
  ],
})
export class BarChartComponent {
  @Input() ariaLabel = 'Gráfico';
  @Input() set values(v: BarDatum[]) {
    this.data.set(v ?? []);
  }
  @Input() format: (value: number) => string = (v) => String(v);

  readonly data = signal<BarDatum[]>([]);
  readonly max = computed(() => Math.max(0, ...this.data().map((d) => d.value)));
  readonly hover = signal<number | null>(null);
}
