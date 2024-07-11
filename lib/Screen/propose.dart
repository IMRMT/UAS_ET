import 'dart:convert';

import 'package:et_uas/Screen/browse.dart';
import 'package:flutter/material.dart';
import 'package:et_uas/Class/animal.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Propose extends StatefulWidget {
  final Animal animal;

  Propose({required this.animal});

  @override
  _ProposeState createState() => _ProposeState();
}

class _ProposeState extends State<Propose> {
  final _formKey = GlobalKey<FormState>();
  String _keterangan = "";

  //buat ambil id
  String _activeUser = "";

  String getGenderString(AnimalGender gender) {
    switch (gender) {
      case AnimalGender.jantan:
        return 'Jantan';
      case AnimalGender.betina:
        return 'Betina';
      default:
        return 'Unknown';
    }
  }

  @override
  void initState() {
    super.initState();
    _getActiveUser();
  }

  _getActiveUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _activeUser = prefs.getString("user_email") ?? "";
    });
  }

void submit() async {
  if (_activeUser.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User ID not found')));
    return;
  }

  final response = await http.post(
    Uri.parse("https://ubaya.me/flutter/160421056/uas/submitPropose.php"),
    body: {
      'status': 'Pending',
      'keterangan': _keterangan,
      'user_email': _activeUser,
      'animal_id': widget.animal.id.toString(),
    },
  );

  if (response.statusCode == 200) {
    Map json = jsonDecode(response.body);
    if (json['result'] == 'success') {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sukses Menambah Data')));
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Browse()),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error')));
    throw Exception('Failed to read API');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Propose to Adopt ${widget.animal.name}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          Form(
            key: _formKey,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Name: ${widget.animal.name}',
                    style: TextStyle(fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: SizedBox(
                      width: 200,
                      height: 200,
                      child: Image.network(
                        widget.animal.image_url,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Text(
                    'Type: ${widget.animal.tipe}',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Gender: ${getGenderString(widget.animal.gender)}',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Age (Bulan): ${widget.animal.umur}',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  // INI KETERANGAN
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Keterangan',
                      ),
                      onChanged: (value) {
                        _keterangan = value;
                      },
                      keyboardType: TextInputType.multiline,
                      minLines: 3,
                      maxLines: 6,
                      validator: (value) {
                        if (value == null || value.length < 10) {
                          return 'Harus lebih dari 10 karakter';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState != null &&
                            _formKey.currentState!.validate()) {
                          submit();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Harap Isian diperbaiki')));
                        }
                      },
                      child: Text('Submit'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
