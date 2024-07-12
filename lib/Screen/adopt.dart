import 'dart:convert';

import 'package:et_uas/Class/adoptList.dart';
import 'package:et_uas/Class/animal.dart';
import 'package:et_uas/Class/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class Adopt extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AdoptState();
  }
}

User? activeUser;
String _txtOwner = "";

Future<User?> checkUser() async {
  final prefs = await SharedPreferences.getInstance();
  String? userEmail = prefs.getString("user_email");
  int? userId = prefs.getInt("user_id");
  String? userName = prefs.getString("user_name");
  String? userPassword = prefs.getString("user_password");

  if (userId != null && userEmail != null && userName != null && userPassword != null) {
    return User(
      user_id: userId,
      user_email: userEmail,
      user_name: userName,
      user_password: userPassword,
    );
  }
  return null;
}

class _AdoptState extends State<Adopt> {
  List<AdoptList> adopts = [];
  String _temp = 'waiting API response…';

  @override
  void initState() {
    super.initState();
    checkUser().then((User? user) {
      setState(() {
        activeUser = user;
        _txtOwner = activeUser?.user_email ?? '';
        bacaData();
      });
    });
  }

  void bacaData() {
    fetchData().then((value) {
      Map<String, dynamic> json = jsonDecode(value);
      List<dynamic> data = json['data'];
      List<AdoptList> loadedAdopts = data.map((adp) => AdoptList.fromJson(adp)).toList();
      setState(() {
        adopts = loadedAdopts;
        if (adopts.isNotEmpty) {
          _temp = adopts[2].status;
        }
      });
    });
  }

  String _txtCari = "";
  Future<String> fetchData() async {
    final response = await http.post(
      Uri.parse("https://ubaya.me/flutter/160421056/uas/adopt_list.php"),
      body: {'cari': _txtCari, 'owner': _txtOwner},
    );
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  Widget daftarAdopt2(String data) {
    List<AdoptList> adopts2 = [];
    Map<String, dynamic> json = jsonDecode(data);
    List<dynamic> jsonData = json['data'];
    adopts2 = jsonData.map((adp) => AdoptList.fromJson(adp)).toList();

    return ListView.builder(
      itemCount: adopts2.length,
      itemBuilder: (BuildContext context, int index) {
        Animal animal = Animal.fromJson(jsonData[index]);

        return Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                leading: SizedBox(
                  width: 50,
                  height: 50,
                  child: Image.network(
                    animal.image_url,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              ListTile(
                title: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Animal name : ${animal.name}'),
                ),
              ),
              ListTile(
                title: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Tipe : ${animal.tipe}'),
                ),
              ),
              ListTile(
                title: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Umur : ${animal.umur.toString()} Bulan'),
                ),
              ),
              ListTile(
                title: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('User : ${adopts2[index].user_email}'),
                ),
              ),
              ListTile(
                title: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('keterangan : ${adopts2[index].keterangan}'),
                ),
              ),
              Divider(height: 15),
              ListTile(
                title: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(adopts2[index].status),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adopt')),
      body: ListView(
        children: <Widget>[
          TextFormField(
            decoration: const InputDecoration(
              icon: Icon(Icons.search),
              labelText: 'Status (Berhasil,Pending,Gagal):',
            ),
            onFieldSubmitted: (value) {
              setState(() {
                _txtCari = value;
                bacaData();
              });
            },
          ),
          Divider(height: 50),
          Container(
            height: MediaQuery.of(context).size.height / 2,
            child: FutureBuilder<String>(
              future: fetchData(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return daftarAdopt2(snapshot.data!);
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
