import { Component, OnInit, inject } from '@angular/core';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { MatDialog } from '@angular/material/dialog';
import { UI } from '../../shared/material';
import { CatalogService } from '../../core/catalog.service';
import { NotifyService } from '../../core/notify.service';
import { avatarUrl } from '../../core/api';
import { MangaCharacter, MangaDetail, Review, Volume } from '../../core/models';
import { MangaFormDialog } from '../mangas/manga-form.dialog';
import { VolumeFormDialog } from './volumen-form.dialog';
import { CharacterFormDialog } from './character-form.dialog';

@Component({
  standalone: true,
  imports: [...UI, RouterLink],
  template: `
    <a mat-button routerLink="/mangas" class="back"><mat-icon>arrow_back</mat-icon> Mangas</a>

    <mat-progress-bar *ngIf="!manga" mode="indeterminate" />

    <ng-container *ngIf="manga as m">
      <section class="card hero">
        <img class="cover" [src]="m.coverImage | imageUrl" [alt]="'Portada de ' + m.title" />
        <div class="info">
          <div class="info-head">
            <div>
              <h1>{{ m.title }}</h1>
              <p class="muted">
                {{ m.author }}<span *ngIf="m.publisher"> · {{ m.publisher }}</span>
                <span *ngIf="m.releaseDate"> · {{ m.releaseDate | date: 'longDate' }}</span>
              </p>
            </div>
            <button mat-stroked-button (click)="edit()"><mat-icon>edit</mat-icon> Editar</button>
          </div>
          <div class="tags"><span class="tag" *ngFor="let c of m.categories">{{ c.name }}</span></div>
          <p class="description">{{ m.synopsis }}</p>
          <div class="facts">
            <div><span class="fact-value">{{ m.volumes.length }}</span><span class="muted">volúmenes</span></div>
            <div><span class="fact-value">{{ stock }}</span><span class="muted">uds. en stock</span></div>
            <div><span class="fact-value">{{ m.unitsSold }}</span><span class="muted">vendidas</span></div>
            <div>
              <span class="fact-value"><mat-icon class="star">star</mat-icon>{{ m.ratingCount ? (m.ratingAverage | number: '1.1-1') : '—' }}</span>
              <span class="muted">{{ m.ratingCount }} reseñas</span>
            </div>
          </div>
        </div>
      </section>

      <!-- Volúmenes -->
      <div class="page-header section-header">
        <h2>Volúmenes</h2>
        <button mat-flat-button color="primary" (click)="openVolume()"><mat-icon>add</mat-icon> Nuevo volumen</button>
      </div>
      <div class="card table-card">
        <div class="table-scroll">
          <table mat-table [dataSource]="m.volumes">
            <ng-container matColumnDef="cover">
              <th mat-header-cell *matHeaderCellDef></th>
              <td mat-cell *matCellDef="let v"><img class="thumb" [src]="v.coverImage | imageUrl" alt="" /></td>
            </ng-container>
            <ng-container matColumnDef="title">
              <th mat-header-cell *matHeaderCellDef>Volumen</th>
              <td mat-cell *matCellDef="let v"><strong>{{ v.title }}</strong><div class="muted small">Tomo {{ v.number }}</div></td>
            </ng-container>
            <ng-container matColumnDef="isbn">
              <th mat-header-cell *matHeaderCellDef>ISBN</th>
              <td mat-cell *matCellDef="let v" class="mono">{{ v.isbn || '—' }}</td>
            </ng-container>
            <ng-container matColumnDef="price">
              <th mat-header-cell *matHeaderCellDef>Precio</th>
              <td mat-cell *matCellDef="let v">{{ v.price | currency: 'EUR' }}</td>
            </ng-container>
            <ng-container matColumnDef="stock">
              <th mat-header-cell *matHeaderCellDef>Stock</th>
              <td mat-cell *matCellDef="let v">
                <span class="badge" [class.badge-danger]="v.stock === 0" [class.badge-warn]="v.stock > 0 && v.stock <= 5"
                      [class.badge-ok]="v.stock > 5">{{ v.stock === 0 ? 'Agotado' : v.stock + ' uds.' }}</span>
              </td>
            </ng-container>
            <ng-container matColumnDef="actions">
              <th mat-header-cell *matHeaderCellDef></th>
              <td mat-cell *matCellDef="let v" class="actions">
                <button mat-icon-button (click)="openVolume(v)" matTooltip="Editar"><mat-icon>edit</mat-icon></button>
                <button mat-icon-button (click)="removeVolume(v)" matTooltip="Eliminar"><mat-icon>delete</mat-icon></button>
              </td>
            </ng-container>
            <tr mat-header-row *matHeaderRowDef="volumeColumns"></tr>
            <tr mat-row *matRowDef="let row; columns: volumeColumns"></tr>
            <tr class="mat-row" *matNoDataRow>
              <td class="empty-cell" [attr.colspan]="volumeColumns.length">Este manga todavía no tiene volúmenes</td>
            </tr>
          </table>
        </div>
      </div>

      <!-- Personajes -->
      <div class="page-header section-header">
        <h2>Personajes</h2>
        <button mat-stroked-button (click)="openCharacter()"><mat-icon>person_add</mat-icon> Añadir personaje</button>
      </div>
      <div class="characters">
        <div class="card character" *ngFor="let c of m.characters">
          <img [src]="c.image | imageUrl" alt="" />
          <div class="character-info">
            <strong>{{ c.name }}</strong>
            <span class="muted small" *ngIf="c.age">{{ c.age }} años</span>
            <p class="muted small">{{ c.description }}</p>
          </div>
          <div class="character-actions">
            <button mat-icon-button (click)="openCharacter(c)" matTooltip="Editar"><mat-icon>edit</mat-icon></button>
            <button mat-icon-button (click)="removeCharacter(c)" matTooltip="Eliminar"><mat-icon>delete</mat-icon></button>
          </div>
        </div>
        <p class="muted" *ngIf="!m.characters.length">Sin personajes todavía.</p>
      </div>

      <!-- Reseñas -->
      <div class="page-header section-header"><h2>Reseñas</h2></div>
      <div class="card">
        <p class="muted" *ngIf="!reviews.length">Nadie ha valorado este manga todavía.</p>
        <div class="review" *ngFor="let r of reviews">
          <img class="avatar" [src]="avatar(r.author.avatar, r.author.fullName)" alt="" />
          <div class="review-main">
            <div class="review-head">
              <strong>{{ r.author.fullName }}</strong>
              <span class="stars">
                <mat-icon *ngFor="let s of [1, 2, 3, 4, 5]">{{ s <= r.rating ? 'star' : 'star_border' }}</mat-icon>
              </span>
              <span class="badge badge-ok" *ngIf="r.verifiedPurchase">Compra verificada</span>
              <span class="muted small">{{ r.createdAt | date: 'd MMM y' }}</span>
            </div>
            <p *ngIf="r.comment">{{ r.comment }}</p>
          </div>
          <button mat-icon-button (click)="removeReview(r)" matTooltip="Borrar reseña (moderación)"><mat-icon>delete</mat-icon></button>
        </div>
        <button mat-button color="primary" *ngIf="moreReviews" (click)="loadReviews(true)">Ver más reseñas</button>
      </div>
    </ng-container>
  `,
  styles: [
    `.back { margin: -8px 0 12px -8px; }
     .hero { display: flex; gap: 28px; }
     .cover { width: 200px; aspect-ratio: 2 / 3; object-fit: cover; border-radius: 12px; box-shadow: var(--shadow-lg); flex-shrink: 0; }
     .info { flex: 1; min-width: 0; }
     .info-head { display: flex; justify-content: space-between; gap: 16px; align-items: flex-start; }
     h1 { margin: 0 0 4px; font-size: 28px; }
     .tags { margin: 8px 0 12px; }
     .description { line-height: 1.6; max-width: 70ch; }
     .facts { display: flex; gap: 32px; margin-top: 20px; flex-wrap: wrap; }
     .facts div { display: flex; flex-direction: column; }
     .fact-value { font-size: 22px; font-weight: 700; display: inline-flex; align-items: center; }
     .star { color: #f5a623; }
     .section-header { margin-top: 28px; }
     .section-header h2 { margin: 0; }
     .mono { font-family: ui-monospace, monospace; font-size: 13px; }
     .small { font-size: 13px; }
     .characters { display: grid; grid-template-columns: repeat(auto-fill, minmax(260px, 1fr)); gap: 12px; }
     .character { display: flex; gap: 12px; align-items: flex-start; padding: 14px; }
     .character img { width: 64px; height: 64px; border-radius: 50%; object-fit: cover; flex-shrink: 0; }
     .character-info { flex: 1; display: flex; flex-direction: column; min-width: 0; }
     .character-info p { margin: 4px 0 0; }
     .character-actions { display: flex; flex-direction: column; }
     .review { display: flex; gap: 12px; padding: 12px 0; border-top: 1px solid var(--border); }
     .review:first-of-type { border-top: none; }
     .review .avatar { width: 40px; height: 40px; border-radius: 50%; }
     .review-main { flex: 1; }
     .review-main p { margin: 6px 0 0; line-height: 1.5; }
     .review-head { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }
     .stars mat-icon { color: #f5a623; font-size: 18px; width: 18px; height: 18px; }
     @media (max-width: 700px) {
       .hero { flex-direction: column; align-items: center; }
       .cover { width: 160px; }
       .info-head { flex-direction: column; }
     }`,
  ],
})
export class MangaDetailComponent implements OnInit {
  private readonly route = inject(ActivatedRoute);
  private readonly catalog = inject(CatalogService);
  private readonly dialog = inject(MatDialog);
  private readonly notify = inject(NotifyService);

  readonly volumeColumns = ['cover', 'title', 'isbn', 'price', 'stock', 'actions'];
  readonly avatar = avatarUrl;
  manga: MangaDetail | null = null;
  reviews: Review[] = [];
  moreReviews = false;
  private reviewPage = 0;

  get stock(): number {
    return this.manga?.volumes.reduce((s, v) => s + v.stock, 0) ?? 0;
  }

  private get id(): string {
    return this.route.snapshot.paramMap.get('id')!;
  }

  ngOnInit(): void {
    this.route.paramMap.subscribe(() => {
      this.load();
      this.loadReviews();
    });
  }

  load(): void {
    this.catalog.manga(this.id).subscribe({
      next: (m) => (this.manga = m),
      error: (err) => this.notify.error(err),
    });
  }

  loadReviews(more = false): void {
    this.reviewPage = more ? this.reviewPage + 1 : 0;
    this.catalog.reviews(this.id, this.reviewPage, 5).subscribe({
      next: (page) => {
        this.reviews = more ? [...this.reviews, ...page.content] : page.content;
        this.moreReviews = !page.last;
      },
      error: (err) => this.notify.error(err),
    });
  }

  edit(): void {
    this.dialog
      .open(MangaFormDialog, { data: this.manga, width: '640px', maxWidth: '95vw' })
      .afterClosed()
      .subscribe((saved) => saved && this.load());
  }

  openVolume(volume?: Volume): void {
    this.dialog
      .open(VolumeFormDialog, { data: { manga: this.manga!, volume: volume ?? null }, width: '560px', maxWidth: '95vw' })
      .afterClosed()
      .subscribe((saved) => saved && this.load());
  }

  removeVolume(v: Volume): void {
    this.confirmDelete('Eliminar volumen', `¿Eliminar "${v.title}"? Los pedidos que lo incluyen se conservan.`, () =>
      this.catalog.deleteVolume(v.id).subscribe({
        next: () => { this.notify.success('Volumen eliminado'); this.load(); },
        error: (err) => this.notify.error(err),
      }));
  }

  openCharacter(character?: MangaCharacter): void {
    this.dialog
      .open(CharacterFormDialog, { data: { mangaId: this.id, character: character ?? null }, width: '520px', maxWidth: '95vw' })
      .afterClosed()
      .subscribe((saved) => saved && this.load());
  }

  removeCharacter(c: MangaCharacter): void {
    this.confirmDelete('Eliminar personaje', `¿Eliminar a ${c.name}?`, () =>
      this.catalog.deleteCharacter(c.id).subscribe({
        next: () => { this.notify.success('Personaje eliminado'); this.load(); },
        error: (err) => this.notify.error(err),
      }));
  }

  removeReview(r: Review): void {
    this.confirmDelete('Borrar reseña', `¿Borrar la reseña de ${r.author.fullName}?`, () =>
      this.catalog.deleteReview(r.id).subscribe({
        next: () => { this.notify.success('Reseña borrada'); this.load(); this.loadReviews(); },
        error: (err) => this.notify.error(err),
      }));
  }

  private confirmDelete(title: string, message: string, action: () => void): void {
    this.notify.confirm({ title, message, confirmText: 'Eliminar', danger: true }).subscribe((ok) => ok && action());
  }
}
