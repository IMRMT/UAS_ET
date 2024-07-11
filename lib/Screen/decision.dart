import 'dart:convert';
import 'package:et_uas/Class/animal.dart';
import 'package:et_uas/Class/user.dart';
import 'package:et_uas/Screen/offer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Decision extends StatefulWidget {
  final int animalID;

  Decision({Key? key, required this.animalID}) : super(key: key);

  @override
  _DecisionState createState() => _DecisionState();
}

class _DecisionState extends State<Decision> {
  List<Animal> animals = [];
  List<User> proposers = [];
  String _temp = 'waiting API respond…';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.post(
        Uri.parse("https://ubaya.me/flutter/160421056/uas/offerdecision.php"),
        body: {
          'id': widget.animalID.toString(),
        },
      );
      
      if (response.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(response.body);
        List<dynamic> data = json['data'];
        List<Animal> loadedAnimals = data.map((anim) => Animal.fromJson(anim)).toList();
        List<User> loadedUsers = data.map((usr) => User.fromJson(usr)).toList();

        setState(() {
          animals = loadedAnimals;
          proposers = loadedUsers;
          if (animals.isNotEmpty) {
            _temp = animals[2].name;
          }
        });
      } else {
        throw Exception('Failed to read API');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Decision'),
      ),
      body: FutureBuilder(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Animals:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                child: ListView.builder(
                  itemCount: animals.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      leading: SizedBox(
                        width: 50,
                        height: 50,
                        child: Image.network(
                          animals[index].image_url,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(animals[index].name),
                    );
                  },
                ),
              ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Proposers:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: proposers.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                              contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                              title: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(proposers[index].user_email),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text('Proposers:', style: TextStyle(fontSize: 16)),
                            SizedBox(height: 10),
                            ButtonBar(
                              children: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Accept(proposers[index].user_email, widget.animalID);
                                  },
                                  child: Text(
                                    'Accept',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all<Color>(
                                      Colors.green,
                                    ),
                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18.0),
                                      ),
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Reject(proposers[index].user_email, widget.animalID);
                                  },
                                  child: Text(
                                    'Reject',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all<Color>(
                                      Colors.red,
                                    ),
                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18.0),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  void Reject(String email, int animalID) async {
    try {
      final response = await http.post(
        Uri.parse("https://ubaya.me/flutter/160421056/uas/rejectproposal.php"),
        body: {
          'user_email': email,
          'animal_id': animalID.toString(),
        },
      );
      
      if (response.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(response.body);
        if (json['result'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User Rejected')));
          Navigator.push(context, MaterialPageRoute(builder: (context) => Offer()));
        } else {
          throw Exception('Failed to read API');
        }
      } else {
        throw Exception('Failed to read API');
      }
    } catch (e) {
      print('Error rejecting proposal: $e');
    }
  }

  void Accept(String email, int animalID) async {
    try {
      final response = await http.post(
        Uri.parse("https://ubaya.me/flutter/160421056/uas/acceptproposal.php"),
        body: {
          'user_email': email,
          'animal_id': animalID.toString(),
        },
      );
      
      if (response.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(response.body);
        if (json['result'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User Accepted')));
          Navigator.push(context, MaterialPageRoute(builder: (context) => Offer()));
        } else {
          throw Exception('Failed to read API');
        }
      } else {
        throw Exception('Failed to read API');
      }
    } catch (e) {
      print('Error accepting proposal: $e');
    }
  }
}
