import { Component } from '@angular/core';
import { Purchase, PurchaseResponse } from 'src/app/models/interfaces/purchaseResponse';
import { UserService } from 'src/app/services/user.service';

@Component({
  selector: 'app-purchase-table',
  templateUrl: './purchase-table.component.html',
  styleUrls: ['./purchase-table.component.css'],
})
export class PurchaseTableComponent {
  purchases: Purchase[] = [];
  constructor(private userService: UserService) {}
  ngOnInit() {
    this.userService
      .findAllPurchases('0', '10')
      .subscribe((data: PurchaseResponse) => {
        this.purchases = data.content;
      });
  }
}
