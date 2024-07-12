import 'package:et_uas/Class/animal.dart';

class AdoptList {
  final int id;
  String status;
  String keterangan;
  String user_email;
  final List? animal;

  AdoptList({
    required this.id,
    required this.status,
    required this.keterangan,
    required this.user_email,
    this.animal,
  });

  factory AdoptList.fromJson(Map<String, dynamic> json) {

    return AdoptList(
      id: json['id'] as int,
      status: json['status'] as String,
      keterangan: json['keterangan'] as String,
      user_email: json['user_email'] as String,
      animal : json['animal'],
    );
  }
}