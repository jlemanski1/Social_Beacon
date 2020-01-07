import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_beacon/pages/home.dart';


void main() {
  runApp(MyApp());
  
  // Enable timestamps in snapshots
  Firestore.instance.settings(timestampsInSnapshotsEnabled: true).then(
    (_) {
      print('Timestamps enabled in snapshots\n');
    }, onError: (_) {
      print('error enabling timestamps in snapshots\n');
    }
  );
  
}




class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,  // Hide Banner in debug mode
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        primaryColor: Color(0XFF6A82FB),
        accentColor: Color(0XFFFC5C7D),
      ),
      home: Home(),
    );
  }
}
