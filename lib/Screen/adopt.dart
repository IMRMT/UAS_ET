import 'dart:convert';

import 'package:et_uas/Class/adoptlist.dart';
import 'package:et_uas/Class/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

String _temp = 'waiting API respond…';
String _txtCari = "";

Future<String> fetchData(String cari) async {
  final response = await http.post(
    Uri.parse("https://ubaya.me/flutter/160421056/uas/adopt_list.php"),
    body: {'cari': cari},
  );
  if (response.statusCode == 200) {
    return response.body;
  } else {
    throw Exception('Failed to read API');
  }
}

class Adopt extends StatefulWidget {
  @override
  _AdoptState createState() => _AdoptState();
}

class _AdoptState extends State<Adopt> {
  List<AdoptList> PMs = [];
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

  void bacaData(String cari) {
    fetchData(cari).then((value) {
      setState(() {
        Map json = jsonDecode(value);
        PMs.clear(); // Clear existing data
        for (var act in json['data']) {
          AdoptList pm = AdoptList.fromJson(act);
          PMs.add(pm);
        }
        _temp = PMs.isNotEmpty ? PMs[0].status : 'No data available';
      });
    }).catchError((error) {
      print('Error fetching data: $error');
      // Handle error state here if needed
    });
  }

  @override
  void initState() {
    super.initState();
    checkUser().then((User? user) {
      setState(() {
        active_user = user;
        _txtOwner = active_user?.user_email ?? '';
        bacaData(_txtCari); // Fetch initial data on app start
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adopt'),
      ),
      body: Column(
        children: <Widget>[
          TextFormField(
            decoration: const InputDecoration(
              icon: Icon(Icons.search),
              labelText: 'Search:',
            ),
            onFieldSubmitted: (value) {
              setState(() {
                _txtCari = value;
                bacaData(_txtCari); // Fetch data when search text changes
              });
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: PMs.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        title: Text('Nama: ${PMs[index].userEmail ?? ""}'),
                      ),
                      ListTile(
                        title: Text('Status: ${PMs[index].status ?? ""}'),
                      ),
                      ListTile(
                        title: Text('Keterangan: ${PMs[index].keterangan ?? ""}'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

Widget DaftarAdopt2(data) {
  List<AdoptList> PMs2 = [];
  Map json = jsonDecode(data);
  for (var act in json['data']) {
    AdoptList pm = AdoptList.fromJson(act);
    PMs2.add(pm);
  }
  return ListView.builder(
    itemCount: PMs2.length,
    itemBuilder: (BuildContext ctxt, int index) {
      return Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: PMs2[index]?.animals?.length ?? 0,
                itemBuilder: (BuildContext ctxt, int idx) {
                  return Text(PMs2[index]?.animals?[idx]['name'] ?? '');
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: PMs2[index]?.animals?.length ?? 0,
                itemBuilder: (BuildContext ctxt, int idx) {
                  return Text(PMs2[index]?.animals?[idx]['umur'] ?? '');
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: PMs2[index]?.animals?.length ?? 0,
                itemBuilder: (BuildContext ctxt, int idx) {
                  return Text(PMs2[index]?.animals?[idx]['tipe'] ?? '');
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: PMs2[index]?.animals?.length ?? 0,
                itemBuilder: (BuildContext ctxt, int idx) {
                  return Text(PMs2[index]?.animals?[idx]['gender'] ?? '');
                },
              ),
            ),
            ListTile(
              title: Text('nama: ${PMs2[index].userEmail.toString()}'),
            ),
            ListTile(
              title: Text('status: ${PMs2[index].status.toString()}'),
            ),
            ListTile(
              title: Text('keterangan: ${PMs2[index].keterangan.toString()}'),
            ),
          ],
        ),
      );
    },
  );
}
