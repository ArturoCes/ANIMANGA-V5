class PurchaseDto {
  PurchaseDto({
    required this.numCreditCard,
    required this.idCart,
  });
  late final String numCreditCard;
  late final String idCart;

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['numCreditCard'] = numCreditCard;
    _data['idCart'] = idCart;
    return _data;
  }
}
