import 'package:flutter/material.dart';
import 'package:et_uas/Class/animal.dart';

class Propose extends StatelessWidget {
  final Animal animal;

  Propose({required this.animal});

  String getGenderString(AnimalGender gender) {//ini ambil dari class untuk di convert
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Propose to Adopt ${animal.name}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Name: ${animal.name}',
              style: TextStyle(fontSize: 24),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Image.network(
                animal.image_url,
                fit: BoxFit.cover,
              ),
            ),
            Text(
              'Type: ${animal.tipe}',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Gender: ${getGenderString(animal.gender)}',//ini nampilin hasil convert
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              'Age: ${animal.umur}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Handle the proposal action
                },
                child: Text('Propose to Adopt'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
