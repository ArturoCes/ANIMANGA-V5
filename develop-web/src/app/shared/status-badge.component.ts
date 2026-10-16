import { Component, Input } from '@angular/core';
import { ORDER_STATUS_LABEL, OrderStatus } from '../core/models';

@Component({
  selector: 'app-status-badge',
  standalone: true,
  template: `<span class="badge status-{{ status }}">{{ label[status] }}</span>`,
  styles: [
    `.status-PAID { background: var(--brand-soft); color: var(--brand-dark); }
     .status-SHIPPED { background: rgba(33, 150, 243, .14); color: #1e88e5; }
     .status-DELIVERED { background: rgba(76, 175, 80, .15); color: var(--ok); }
     .status-CANCELLED { background: rgba(198, 40, 40, .12); color: var(--danger); }`,
  ],
})
export class StatusBadgeComponent {
  @Input({ required: true }) status!: OrderStatus;
  readonly label = ORDER_STATUS_LABEL;
}
