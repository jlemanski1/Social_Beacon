import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';



final GoogleSignIn googleSignIn = GoogleSignIn();


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth = false;


  // Determines if user is signed in
  handleSignIn(GoogleSignInAccount account) {
    if (account != null) {
        print('User signed in: $account');
        setState(() {
          isAuth = true;
        });
      } else {
        setState(() {
          isAuth = false;
        });
      }
  }


  // Handle account logins
  login() {
    googleSignIn.signIn();
  }

  // Handle account logout
  logout() {
    googleSignIn.signOut();
  }


  @override
  void initState() {
    super.initState();

    // Detects when a user is signed in
    googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      handleSignIn(account);
    }, onError: (err) {
        print('Error Signin In: $err');
    });

    // ReAuth user when app is opened
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    }).catchError((err) {
      print('Error Signin In: $err');
    });
  }


  // Screen to be displayed for Authenticated users
  Widget buildAuthScreen() {
    return RaisedButton(
      child: Text('Logout'),
      onPressed: logout(),
    );
  }


  // Screen to be displayed for unAthenticated users
  Scaffold buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).accentColor
            ]
          )
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Social Beacon',
              style: TextStyle(
                fontFamily: 'Signatra',
                fontSize: 90.0,
                color: Colors.white,
              )
            ),
            GestureDetector(
              onTap: login(),
              child: Container(
                width: 260.0,
                height: 60.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/google_signin_button.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() :  buildUnAuthScreen();

  }
}