import 'dart:convert';

import 'package:et_uas/Class/adoptlist.dart';
import 'package:et_uas/Class/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:et_uas/Class/animal.dart';

class Adopt extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AdoptState();
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

class _AdoptState extends State<Adopt> {
  List<AdoptList> adopts = [];
  String _temp = 'waiting API respond…';

  @override
  void initState() {
    super.initState();
    checkUser().then((User? user) {
      setState(() {
        active_user = user;
        _txtOwner = active_user?.user_email ?? '';
        bacaData();
      });
    });
  }

  void bacaData() {
    fetchData().then((value) {
      Map<String, dynamic> json = jsonDecode(value);
      List<dynamic> data = json['data'];
      List<AdoptList> loadedAdopts =
          data.map((adp) => AdoptList.fromJson(adp)).toList();
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
        body: {'cari': _txtCari, 'owner': _txtOwner});
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  // Widget daftarAnimal(List<Animal> animals) {
  //   if (animals != null && animals.isNotEmpty) {
  //     return ListView.builder(
  //       itemCount: animals.length,
  //       itemBuilder: (BuildContext context, int index) {
  //         return Card(
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: <Widget>[
  //               ListTile(
  //                 leading: Image.network(
  //                   animals[index].image_url,
  //                   width: 50,
  //                   height: 50,
  //                   fit: BoxFit.cover,
  //                 ),
  //                 title: Text(animals[index].name),
  //               ),
  //               ButtonBar(
  //                 children: <Widget>[
  //                   TextButton(
  //                     child: const Text('PROPOSE'),
  //                     onPressed: () {
  //                       Navigator.push(
  //                         context,
  //                         MaterialPageRoute(
  //                           builder: (context) => Propose(animal: animals[index]),
  //                         ),
  //                       );
  //                     },
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         );
  //       },
  //     );
  //   } else {
  //     return Center(child: CircularProgressIndicator());
  //   }
  // }

  Widget daftarAdopt2(String data) {
    List<AdoptList> adopts2 = [];
    Map<String, dynamic> json = jsonDecode(data);
    List<dynamic> jsonData = json['data'];
    adopts2 = jsonData.map((adp) => AdoptList.fromJson(adp)).toList();

    return ListView.builder(
      itemCount: adopts2.length,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // ListTile(
              //   contentPadding:
              //       EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              //       leading: SizedBox(
              //         width: 50,
              //         height: 50,
              //         child: Image.network(
              //           animal.image_url,
              //           fit: BoxFit.cover,
              //         ),
              //       ),
              // ),
              ListTile(
                title: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(adopts2[index].user_email),
                ),
              ),
              ListTile(
                title: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(adopts2[index].keterangan),
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
      appBar: AppBar(title: const Text('Browse')),
      body: ListView(
        children: <Widget>[
          TextFormField(
            decoration: const InputDecoration(
              icon: Icon(Icons.search),
              labelText: 'Adopsi mengandung kata:',
            ),
            onFieldSubmitted: (value) {
              setState(() {
                _txtCari = value;
                bacaData();
              });
            },
          ),
          // Container(
          //   height: MediaQuery.of(context).size.height - 200,
          //   child: daftarAnimal(animals),
          // ),
          Divider(height: 50),
          Container(
            height: MediaQuery.of(context).size.height / 2,
            child: FutureBuilder(
              future: fetchData(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return daftarAdopt2(snapshot.requireData as String);
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