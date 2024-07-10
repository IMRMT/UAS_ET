import 'dart:convert';

import 'package:et_uas/Screen/register.dart';
import 'package:et_uas/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

String _user_name = '';
String _user_id = '';
String _user_password = '';
String error_login = '';

class MyLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Login(),
    );
  }
}

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginState();
  }
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Login'),
          backgroundColor: Colors.greenAccent,
        ),
        body: Container(
          height: 300,
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
                  _user_name = v;
                  _user_password = v;
                },
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Username',
                    hintText: 'Enter your username'),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              //padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    hintText: 'Enter secure password'),
              ),
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
                      doLogin();
                    },
                    child: Text(
                      'Login',
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ),
                  ),
                )),
            ElevatedButton(
                // style: ButtonStyle(backgroundColor:),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Register()));
                },
                child: Text("Register")),
          ]),
        ));
  }

  void doLogin() async {
    //later, we use web service here to check the user id and password
    // final prefs = await SharedPreferences.getInstance();
    // prefs.setString("user_id", _user_id);
    // main();\
    final response = await http.post(
        Uri.parse("https://ubaya.me/flutter/160421056/uas/login.php"),
        body: {'user_name': _user_name, 'user_password': _user_password});
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        final prefs = await SharedPreferences.getInstance();
        prefs.setString("user_name", _user_name);
        prefs.setString("user_id", _user_id);
        main();
      } else {
        setState(() {
          error_login = "Incorrect user or password";
        });
      }
    } else {
      throw Exception('Failed to read API');
    }
  }
}
