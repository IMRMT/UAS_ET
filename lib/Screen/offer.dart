import 'dart:convert';

import 'package:et_uas/Class/animal.dart';
import 'package:et_uas/Class/user.dart';
import 'package:et_uas/Screen/decision.dart';
import 'package:et_uas/Screen/editOffer.dart';
import 'package:et_uas/Screen/newOffer.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Offer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _OfferState();
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

class _OfferState extends State<Offer> {
  List<Animal> animals = [];
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
      List<Animal> loadedAnimals =
          data.map((anim) => Animal.fromJson(anim)).toList();
      setState(() {
        animals = loadedAnimals;
        if (animals.isNotEmpty) {
          _temp = animals[2].name;
        }
      });
    });
  }

  Future<String> fetchData() async {
    final response = await http.post(
        Uri.parse("https://ubaya.me/flutter/160421056/uas/offer_list.php"),
        body: {'user_email': _txtOwner});
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  Widget daftarAnimal2(String data) {
    List<Animal> animals2 = [];
    Map<String, dynamic> json = jsonDecode(data);
    List<dynamic> jsonData = json['data'];
    animals2 = jsonData.map((anim) => Animal.fromJson(anim)).toList();

    return ListView.builder(
      itemCount: animals2.length,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                leading: SizedBox(
                  width: 50,
                  height: 50,
                  child: Image.network(
                    animals2[index].image_url,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(animals2[index].name),
                ),
              ),
              ButtonBar(
                children: <Widget>[
                  TextButton(
                    child: const Text('Decision'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              Decision(animalID: animals2[index].id),
                        ),
                      );
                    },
                  ),
                ],
              ),
              ButtonBar(
                children: <Widget>[
                  TextButton(
                    child: const Text('Edit'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditOffer(animalID: animals2[index].id),
                        ),
                      );
                    },
                  ),
                ],
              ),
              ButtonBar(
                children: <Widget>[
                  TextButton(
                    child: const Text('Delete'),
                    onPressed: () {
                      delete(animals2[index].id);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  FloatingActionButton myFab(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => NewOffer()));
      },
      tooltip: 'Create New Offer',
      child: const Icon(Icons.add),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offer')),
      body: ListView(
        children: <Widget>[
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
                  return daftarAnimal2(snapshot.requireData as String);
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: myFab(context),
    );
  }

  void delete(int AnimalID) async {
    final response = await http.post(
        Uri.parse("https://ubaya.me/flutter/160421056/uas/deleteoffer.php"),
        body: {
          'id': AnimalID.toString(),
        });
    if (response.statusCode == 200) {
      setState(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Offer(),
          ),
        );
      });
    } else {
      throw Exception('Failed to read API');
    }
  }
}
