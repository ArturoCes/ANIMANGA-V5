import { Component, Inject, inject } from '@angular/core';
import { MAT_DIALOG_DATA, MatDialogRef } from '@angular/material/dialog';
import { Observable } from 'rxjs';
import { UI } from '../../shared/material';
import { CatalogService } from '../../core/catalog.service';
import { NotifyService } from '../../core/notify.service';
import { Volume } from '../../core/models';

const MAX_PAGES = 20;

/** Páginas del avance ("Leer avance") de un volumen: subir, ordenar, previsualizar y quitar. */
@Component({
  standalone: true,
  imports: [...UI],
  template: `
    <div mat-dialog-title class="dialog-head">
      <div>
        <span class="title">Avance · {{ volume.title }}</span>
        <span class="sub">{{ pages.length }} de {{ max }} páginas · se muestran en la app en este orden</span>
      </div>
    </div>
    <mat-dialog-content>
      <mat-progress-bar *ngIf="busy" mode="indeterminate" class="progress" />

      <div class="viewer" *ngIf="pages.length; else empty">
        <div class="stage">
          <button mat-icon-button class="nav" (click)="select(current - 1)" [disabled]="current === 0" aria-label="Anterior">
            <mat-icon>chevron_left</mat-icon>
          </button>
          <img [src]="pages[current] | imageUrl" alt="Página {{ current + 1 }}" />
          <button mat-icon-button class="nav" (click)="select(current + 1)" [disabled]="current === pages.length - 1"
                  aria-label="Siguiente">
            <mat-icon>chevron_right</mat-icon>
          </button>
        </div>
        <div class="stage-bar">
          <span class="muted">Página {{ current + 1 }} / {{ pages.length }}</span>
          <span class="spacer"></span>
          <button mat-icon-button (click)="move(current, current - 1)" [disabled]="busy || current === 0"
                  matTooltip="Mover antes"><mat-icon>arrow_back</mat-icon></button>
          <button mat-icon-button (click)="move(current, current + 1)" [disabled]="busy || current === pages.length - 1"
                  matTooltip="Mover después"><mat-icon>arrow_forward</mat-icon></button>
          <button mat-icon-button color="warn" (click)="remove(current)" [disabled]="busy"
                  matTooltip="Quitar página"><mat-icon>delete</mat-icon></button>
        </div>
        <div class="thumbs">
          <button type="button" class="thumb-btn" *ngFor="let p of pages; let i = index" [class.active]="i === current"
                  (click)="select(i)" [attr.aria-label]="'Página ' + (i + 1)">
            <img [src]="p | imageUrl" alt="" />
            <span class="num">{{ i + 1 }}</span>
          </button>
        </div>
      </div>
      <ng-template #empty>
        <button type="button" class="drop" (click)="input.click()">
          <mat-icon>auto_stories</mat-icon>
          <strong>Este volumen aún no tiene avance</strong>
          <span class="muted">Sube las primeras páginas para que los clientes puedan leerlas desde la app.</span>
        </button>
      </ng-template>
      <input #input type="file" accept="image/*" multiple hidden (change)="upload($event)" />
    </mat-dialog-content>
    <mat-dialog-actions>
      <span class="hint">JPG, PNG o WEBP · máx. 5 MB por página</span>
      <span class="spacer"></span>
      <button mat-button (click)="close()">Cerrar</button>
      <button mat-flat-button color="primary" (click)="input.click()" [disabled]="busy || pages.length >= max">
        <mat-icon>upload</mat-icon> Añadir páginas
      </button>
    </mat-dialog-actions>
  `,
  styles: [
    `.dialog-head::before { display: none !important; }
     .dialog-head { padding-top: 22px !important; padding-bottom: 6px !important; }
     .dialog-head > div { display: flex; flex-direction: column; line-height: 1.35; }
     .title { font-size: 20px; font-weight: 700; }
     .sub { font-size: 13px; font-weight: 400; color: var(--muted); }
     .progress { margin-bottom: 8px; }
     .stage { display: flex; align-items: center; gap: 8px; background: #111; border-radius: 12px; padding: 12px; }
     .stage img { flex: 1; min-width: 0; height: 46vh; max-height: 440px; object-fit: contain; }
     .nav { color: #fff !important; flex-shrink: 0; }
     .nav:disabled { opacity: .3; }
     .stage-bar { display: flex; align-items: center; gap: 2px; padding: 6px 0 4px; }
     .spacer { flex: 1; }
     .thumbs { display: flex; gap: 8px; overflow-x: auto; padding: 4px 2px 8px; }
     .thumb-btn { position: relative; flex-shrink: 0; width: 58px; height: 84px; padding: 0; border-radius: 6px; cursor: pointer;
                  overflow: hidden; border: 2px solid transparent; background: var(--surface-2); opacity: .6; transition: opacity .15s; }
     .thumb-btn:hover { opacity: .9; }
     .thumb-btn.active { border-color: var(--brand); opacity: 1; }
     .thumb-btn img { width: 100%; height: 100%; object-fit: cover; display: block; }
     .num { position: absolute; left: 3px; bottom: 3px; font-size: 11px; font-weight: 700; padding: 0 5px; border-radius: 4px;
            background: rgba(0,0,0,.65); color: #fff; }
     .drop { width: 100%; display: flex; flex-direction: column; align-items: center; gap: 6px; padding: 40px 24px;
             border: 1px dashed var(--border); border-radius: 12px; background: var(--surface-2); color: var(--text);
             cursor: pointer; text-align: center; font: inherit; }
     .drop:hover { border-color: var(--brand); }
     .drop mat-icon { font-size: 40px; width: 40px; height: 40px; color: var(--brand); }
     mat-dialog-actions { gap: 8px; padding: 8px 24px 16px !important; }
     .hint { font-size: 12px; color: var(--muted); }
     @media (max-width: 600px) { .hint { display: none; } }`,
  ],
})
export class PreviewPagesDialog {
  private readonly catalog = inject(CatalogService);
  private readonly notify = inject(NotifyService);
  private readonly ref = inject(MatDialogRef<PreviewPagesDialog>);

  readonly max = MAX_PAGES;
  pages: string[];
  current = 0;
  busy = false;
  private changed = false;

  constructor(@Inject(MAT_DIALOG_DATA) public volume: Volume) {
    this.pages = [...volume.previewPages];
    // Al cerrar con Esc o clic fuera también hay que avisar de los cambios para refrescar la ficha
    this.ref.disableClose = true;
    this.ref.backdropClick().subscribe(() => this.close());
    this.ref.keydownEvents().subscribe((e) => e.key === 'Escape' && this.close());
  }

  select(i: number): void {
    if (i >= 0 && i < this.pages.length) this.current = i;
  }

  upload(event: Event): void {
    const input = event.target as HTMLInputElement;
    // Se ordenan por nombre para que "pag-01, pag-02…" queden en su sitio
    const files = Array.from(input.files ?? []).sort((a, b) => a.name.localeCompare(b.name, 'es', { numeric: true }));
    input.value = '';
    if (!files.length) return;
    const free = this.max - this.pages.length;
    if (files.length > free) {
      this.notify.error(`Solo caben ${free} páginas más (máximo ${this.max}).`);
      return;
    }
    const first = this.pages.length;
    this.run(this.catalog.addPreviewPages(this.volume.id, files), `${files.length} página(s) añadidas`, () => (this.current = first));
  }

  move(from: number, to: number): void {
    this.run(this.catalog.movePreviewPage(this.volume.id, from, to), null, () => (this.current = to));
  }

  remove(index: number): void {
    this.notify
      .confirm({ title: 'Quitar página', message: `¿Quitar la página ${index + 1} del avance?`, confirmText: 'Quitar', danger: true })
      .subscribe((ok) => ok && this.run(this.catalog.deletePreviewPage(this.volume.id, index), 'Página quitada',
        () => (this.current = Math.min(index, this.pages.length - 1))));
  }

  close(): void {
    this.ref.close(this.changed);
  }

  private run(request: Observable<Volume>, message: string | null, after: () => void): void {
    this.busy = true;
    request.subscribe({
      next: (v) => {
        this.pages = v.previewPages;
        this.changed = true;
        this.busy = false;
        after();
        if (message) this.notify.success(message);
      },
      error: (err) => {
        this.busy = false;
        this.notify.error(err);
      },
    });
  }
}
