import 'dart:convert';
import 'package:et_uas/Screen/propose.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:et_uas/Class/animal.dart';

class Browse extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BrowseState();
  }
}

class _BrowseState extends State<Browse> {
  List<Animal> animals = [];
  String _temp = 'waiting API respond…';

  @override
  void initState() {
    super.initState();
    bacaData();
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
    final response = await http.get(
        Uri.parse("https://ubaya.me/flutter/160421056/uas/animal_list.php"));
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
                    child: const Text('PROPOSE'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              Propose(animal: animals2[index]),
                        ),
                      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Browse')),
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
    );
  }
}
