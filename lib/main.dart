import 'package:et_uas/Screen/adopt.dart';
import 'package:et_uas/Screen/browse.dart';
import 'package:et_uas/Screen/home.dart';
import 'package:et_uas/Screen/login.dart';
import 'package:et_uas/Screen/offer.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

String active_user = "";
String _user_email = "";
int top_score = 0;

Future<String> checkUser() async {
  final prefs = await SharedPreferences.getInstance();
  String user_email = prefs.getString("user_email") ?? '';
  return user_email;
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  checkUser().then((String result) {
    if (result == '')
      runApp(MyLogin());
    else {
      active_user = result;
      runApp(MyApp());
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        'login': (context) => MyLogin(),
        'offer': (context) => Offer(),
        'adopt': (context) => Adopt(),
        'browse': (context) => Browse(),
      },
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(211, 129, 104, 172)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  final List<Widget> _screens = [Home()];
  final List<String> _judul = ['Home'];

  void _incrementCounter() {
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(_judul[_currentIndex]),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[],
        ),
      ),
      drawer: Drawer(
        elevation: 16.0,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text("xyz"),
                accountEmail: Text(active_user),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: NetworkImage("https://i.pravatar.cc/150"),
                ),
              ),
              ListTile(
                title: new Text("Browse"),
                leading: new Icon(Icons.manage_search_outlined),
                onTap: () {
                    Navigator.popAndPushNamed(
                        context, 'browse');}
              ),
              ListTile(
                title: new Text("Offer"),
                leading: new Icon(Icons.handshake),
                onTap: () {
                    Navigator.popAndPushNamed(
                        context, 'offer');}
              ),
              ListTile(
                title: new Text("Adopt"),
                leading: new Icon(Icons.task_alt),
                onTap: () {
                    Navigator.popAndPushNamed(
                        context, 'adopt');}
              ),
              ListTile(
                title: Text(active_user != "" ? "Logout" : "Login"),
                leading: Icon(active_user != "" ? Icons.logout : Icons.login),
                onTap: () {
                  if (active_user != "") {
                    doLogout();
                  } else {
                    Navigator.popAndPushNamed(
                      context,
                      'login',
                    ); // This closes the drawer when the drawer item is clicked
                  }
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: bottomNav(),
    );
  }

  BottomNavigationBar bottomNav() {
    return BottomNavigationBar(
        currentIndex: 0,
        fixedColor: Colors.teal,
        items: [
          BottomNavigationBarItem(
            label: "Home",
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            label: "Search",
            icon: Icon(Icons.search, size: 20),
          ),
          BottomNavigationBarItem(
            label: "History",
            icon: Icon(Icons.history),
          ),
          // BottomNavigationBarItem(
          //   label: "Setting",
          //   icon: Icon(Icons.settings),
          // ),
        ],
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        });
  }

  void doLogout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("user_email");
    main();
  }
}
