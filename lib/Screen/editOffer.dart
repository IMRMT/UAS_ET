import 'dart:convert';

import 'package:et_uas/Class/animal.dart';
import 'package:et_uas/Class/user.dart';
import 'package:et_uas/Screen/offer.dart';
import 'package:et_uas/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

User? active_user;
String _txtOwner = "";

Future<User?> checkUser() async {
  final prefs = await SharedPreferences.getInstance();
  String? user_email = prefs.getString("user_email") ?? '';
  int? user_id = prefs.getInt("user_id") ?? 0;
  String? user_name = prefs.getString("user_name") ?? '';
  String? user_password = prefs.getString("user_password") ?? '';

  if (user_id != null &&
      user_email != null &&
      user_name != null &&
      user_password != null) {
    return User(
      user_id: user_id,
      user_email: user_email,
      user_name: user_name,
      user_password: user_password,
    );
  }
  return null; // Return null if any data is missing
}

class EditOffer extends StatefulWidget {
  int animalID;
  EditOffer({super.key, required this.animalID});
  @override
  State<StatefulWidget> createState() {
    return _EditOfferState();
  }
}

class _EditOfferState extends State<EditOffer> {
  final _formKey = GlobalKey<FormState>();
  AnimalGender selectedGender = AnimalGender.jantan;
  late Animal _anim;

  TextEditingController _nameCont = TextEditingController();
  TextEditingController _umurCont = TextEditingController();
  TextEditingController _urlCont = TextEditingController();
  TextEditingController _tipeCont = TextEditingController();
  @override
  void initState() {
    super.initState();
    checkUser().then((User? user) {
      setState(() {
        active_user = user;
        _txtOwner = active_user?.user_email ?? '';
      });
    });
    bacaData();
  }

  Future<String> fetchData() async {
    final response = await http.post(
        Uri.parse("https://ubaya.me/flutter/160421056/uas/offer_detail.php"),
        body: {'id': widget.animalID.toString()});
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  bacaData() {
    fetchData().then((value) {
      Map json = jsonDecode(value);
      _anim = Animal.fromJson(json['data']);
      setState(() {
        _nameCont.text = _anim.name;
        _umurCont.text = _anim.umur.toString();
        _urlCont.text = _anim.image_url;
        _tipeCont.text = _anim.tipe;
      });
    });
  }

  String genderToString(AnimalGender gender) {
    switch (gender) {
      case AnimalGender.jantan:
        return 'Jantan';
      case AnimalGender.betina:
        return 'Betina';
      case AnimalGender.unknown:
        return 'Unknown';
      default:
        return '';
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Edit Offer'),
          backgroundColor: Colors.greenAccent,
        ),
        body: Container(
          key: _formKey,
          height: 580,
          margin: EdgeInsets.all(20),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(30)),
              border: Border.all(width: 1),
              color: Colors.white,
              boxShadow: [BoxShadow(blurRadius: 20)]),
          child: Column(children: [
            Padding(
                padding: EdgeInsets.all(10),
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Name',
                  ),
                  onChanged: (value) {
                    _anim.name = value;
                  },
                  controller: _nameCont,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'nama harus diisi';
                    }
                    return null;
                  },
                )),
            Padding(
                padding: EdgeInsets.all(10),
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Umur (Bulan)',
                  ),
                  onChanged: (value) {
                    _anim.umur = int.parse(value);
                  },
                  controller: _umurCont,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'umur harus diisi';
                    }
                    return null;
                  },
                )),
            Padding(
                padding: EdgeInsets.all(10),
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Image Url',
                  ),
                  onChanged: (value) {
                    _anim.image_url = value;
                  },
                  controller: _urlCont,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Url gambar animal harus diisi';
                    }
                    return null;
                  },
                )),
            Padding(
                padding: EdgeInsets.all(10),
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Tipe Hewan',
                  ),
                  onChanged: (value) {
                    _anim.tipe = value;
                  },
                  controller: _tipeCont,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tipe animal harus diisi';
                    }
                    return null;
                  },
                )),
            DropdownButton<AnimalGender>(
              value: selectedGender,
              onChanged: (AnimalGender? newValue) {
                setState(() {
                  selectedGender = newValue ?? AnimalGender.unknown;
                });
              },
              items: AnimalGender.values.map((AnimalGender gender) {
                return DropdownMenuItem<AnimalGender>(
                  value: gender,
                  child: Text(genderToString(gender)),
                );
              }).toList(),
            ),
            Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  height: 50,
                  width: 300,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(20)),
                  child: ElevatedButton(
                    onPressed: () {
                      submit();
                    },
                    child: Text(
                      'Update',
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ),
                  ),
                )),
          ]),
        ));
  }

  void submit() async {
    final response = await http.post(
        Uri.parse("https://ubaya.me/flutter/160421056/uas/updateoffer.php"),
        body: {
          'id': widget.animalID.toString(),
          'name': _anim.name,
          'umur': _anim.umur.toString(),
          'image_url': _anim.image_url,
          'tipe': _anim.tipe,
          'gender': genderToString(selectedGender),
        });
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Sukses Mengedit Data')));
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Offer()));
      } else {
        throw Exception('Failed to read API');
      }
    }
  }
}
