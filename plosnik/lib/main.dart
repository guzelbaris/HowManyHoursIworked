import 'package:flutter/material.dart';
import 'Pages/navigationhomepage.dart';
import 'Services/database_service.dart';


import 'package:sqflite_common_ffi/sqflite_ffi.dart';
Future main() async {

// Initialize FFI
sqfliteFfiInit();


 databaseFactory = databaseFactoryFfi;
 runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Working Hours',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey.shade100),
        useMaterial3: true,
      ),
      home: const NavigationHomePage(),
    );
  }
}



// Placeholder pages for Weekly and Monthly Graphs


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DatabaseService _databaseService=DatabaseService.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    );
  }
}
