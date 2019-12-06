import 'dart:async';

import 'package:flutter/material.dart';
import 'package:social_beacon/widgets/header.dart';


class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String username;

  // Save the input form state and send username back to CreateFirestoreUser (home.dart)
  submit() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      final SnackBar snackBar = SnackBar(content: Text('Welcome $username!'));

      // Show SnackBar for 2 secs then pop the screen
      _scaffoldKey.currentState.showSnackBar(snackBar);     
      Timer(Duration(seconds: 2), () {
        Navigator.pop(context, username);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(context, titleText: 'Profile Setup', rmBackButton: true),
      body: ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 25.0),
                  child: Center(
                    child: Text(
                      'Enter your username',
                      style: TextStyle(
                        fontSize: 25.0,
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Container(
                  child: Form(
                    key: _formKey,
                    autovalidate: true,
                    child: TextFormField(
                      validator: (value) {
                        if (value.trim().length < 3 || value.isEmpty) {
                          return 'Username too short';
                        } else if (value.trim().length > 12) {
                          return 'Username too long';
                        } else {
                          return null;
                        }
                      },
                      onSaved: (value) => username = value,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Username',
                        labelStyle: TextStyle(fontSize: 15.0),
                        hintText: 'Must be greater than 3 characters',
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: submit,
                child: Container(
                  height: 50.0,
                  width: 350.0,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(7.0),
                  ),
                  child: Center(
                    child: Text(
                      'Submit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              )
              ],
            ),
          ),
        ],
      ),
    );
  }
}