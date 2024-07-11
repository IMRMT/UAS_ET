import 'dart:convert';

import 'package:et_uas/Class/animal.dart';
import 'package:et_uas/Class/user.dart';
import 'package:et_uas/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

String _name = '';
String _umur = '';
String _imageUrl = '';
String _tipe = '';
String error_offer = '';

class NewOffer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Offer(),
    );
  }
}

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

class Offer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NewOfferState();
  }
}

class _NewOfferState extends State<Offer> {
  AnimalGender selectedGender = AnimalGender.jantan;
  @override
  void initState() {
    super.initState();
    checkUser().then((User? user) {
      setState(() {
        active_user = user;
        _txtOwner = active_user?.user_email ?? '';
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
          title: Text('New Offer'),
          backgroundColor: Colors.greenAccent,
        ),
        body: Container(
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
              child: TextField(
                onChanged: (v) {
                  _name = v;
                },
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Name',
                    hintText: 'Enter animal name'),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              //padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                onChanged: (v) {
                  _umur = v;
                },
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Umur (Bulan)',
                    hintText: 'Enter animal age'),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              //padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                onChanged: (v) {
                  _imageUrl = v;
                },
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Image Url',
                    hintText: 'Enter animal picture url'),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              //padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                onChanged: (v) {
                  _tipe = v;
                },
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Tipe Hewan',
                    hintText: 'Enter animal type'),
              ),
            ),
            // Padding(
            //   padding: EdgeInsets.all(10),
            //   child: TextField(
            //     onChanged: (v) {
            //       if (v.toLowerCase() == "jantan" ||
            //           v.toLowerCase() == "betina") {
            //         _gender = v.toLowerCase(); //menyimpan data yang sudah di lowercasekan
            //       } else {
            //         ScaffoldMessenger.of(context)
            //             .showSnackBar(SnackBar(content: Text('Error')));
            //         throw Exception('Convertion Gender Error');
            //       }
            //     },
            //     decoration: InputDecoration(
            //         border: OutlineInputBorder(),
            //         labelText: 'Animal Gender',
            //         hintText: 'Enter animal gender'),
            //   ),
            // ),
            DropdownButton<AnimalGender>(
              value: selectedGender,
              onChanged: (AnimalGender? newValue) {
                setState(() {
                  selectedGender = newValue!;
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
                      'Create',
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ),
                  ),
                )),
          ]),
        ));
  }

  void submit() async {
    final response = await http.post(
        Uri.parse("https://ubaya.me/flutter/160421056/uas/newoffer.php"),
        body: {
          'name': _name,
          'umur': _umur,
          'image_url': _imageUrl,
          'tipe': _tipe,
          'gender': genderToString(selectedGender),
          'owner': _txtOwner,
        });
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Sukses Menambah Data')));
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Offer()),
        );
      }
      main();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error')));
      throw Exception('Failed to read API');
    }
  }
}
