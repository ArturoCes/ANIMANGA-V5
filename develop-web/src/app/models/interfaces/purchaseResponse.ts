export interface PurchaseResponse {
  content:          Purchase[];
  pageable:         Pageable;
  totalPages:       number;
  totalElements:    number;
  last:             boolean;
  size:             number;
  number:           number;
  sort:             Sort;
  first:            boolean;
  numberOfElements: number;
  empty:            boolean;
}

export interface Purchase {
  idPurchase:    string;
  numCreditCard: string;
  idCart:        string;
  idUser:        string;
  idVolumen:     string;
  precio:        number;
  fullName:      string;
  purchaseDate:  Date;
}

export interface Pageable {
  sort:       Sort;
  offset:     number;
  pageSize:   number;
  pageNumber: number;
  paged:      boolean;
  unpaged:    boolean;
}

export interface Sort {
  empty:    boolean;
  sorted:   boolean;
  unsorted: boolean;
}
