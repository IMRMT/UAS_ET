enum AnimalGender {
  jantan,
  betina,
  unknown,
}

class Animal {
  final int id;
  final String name;
  final int umur;
  final String image_url;
  final String tipe;
  final AnimalGender gender;
  final int is_adopt;

  Animal(
      {required this.id,
      required this.name,
      required this.umur,
      required this.image_url,
      required this.tipe,
      required this.gender,
      required this.is_adopt,});
  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      id: json['id'] as int,
      name: json['name'] as String,
      umur: json['umur'] as int,
      image_url: json['image_url'] as String,
      tipe: json['tipe'] as String,
      gender: _parseAnimalGender(json['gender'] as String),
      is_adopt: json['is_adopt'] as int,
    );
  }

  static AnimalGender _parseAnimalGender(String gender) {
    switch (gender.toLowerCase()) {
      case 'jantan':
        return AnimalGender.jantan;
      case 'betina':
        return AnimalGender.betina;
      default:
        return AnimalGender.unknown;
    }
  }
}