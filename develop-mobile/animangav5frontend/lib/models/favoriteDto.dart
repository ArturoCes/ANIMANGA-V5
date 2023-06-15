class FavoriteResponse {
  FavoriteResponse({
    required this.favorito,
  });
  late final bool favorito;
  
  FavoriteResponse.fromJson(Map<String, dynamic> json){
    favorito = json['favorito'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['favorito'] = favorito;
    return _data;
  }
}