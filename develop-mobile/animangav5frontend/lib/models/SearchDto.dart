class SearchDto {
  SearchDto({
    required this.name
  });
  late final String name;

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['name'] = name;
    return _data;
  }
}