class CharacterResponse {
 late List<Character> characters;

  CharacterResponse({required this.characters});

  CharacterResponse.fromJson(Map<String, dynamic> json) {
    characters = List.from(json['characters'])
        .map((e) => Character.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['characters'] = characters.map((e) => e.toJson()).toList();

    return _data;
  }
}

class Character {
  String? id;
  String? name;
  String? description;

  Character({this.id, this.name, this.description});

  Character.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    name = json["name"];
    description = json["description"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["name"] = name;
    _data["description"] = description;
    return _data;
  }
}
