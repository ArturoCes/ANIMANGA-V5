class Category {
  Category({
    required this.id,
    required this.name,
    required this.description,
  });
  late final String id;
  late final String name;
  late final String description;

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['name'] = name;
    _data['description'] = description;
    return _data;
  }
}
