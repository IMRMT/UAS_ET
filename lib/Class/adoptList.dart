class AdoptList {
  final int id;
  final String status;
  final String keterangan;
  final String userEmail;
  final int animalId;
  final List? animals;

  AdoptList({
    required this.id,
    required this.status,
    required this.keterangan,
    required this.userEmail,
    required this.animalId,
    this.animals,
  });

  factory AdoptList.fromJson(Map<String, dynamic> json) {
    return AdoptList(
      id: json['id'] as int,
      status: json['status'] as String,
      keterangan: json['keterangan'] as String,
      userEmail: json['user_email'] as String,
      animalId: json['animal_id'] as int,
      animals: json['animals'],
    );
  }
}