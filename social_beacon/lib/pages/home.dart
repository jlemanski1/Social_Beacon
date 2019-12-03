import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:social_beacon/pages/activity_feed.dart';
import 'package:social_beacon/pages/create_account.dart';
import 'package:social_beacon/pages/timeline.dart';
import 'package:social_beacon/pages/upload.dart';
import 'package:social_beacon/pages/profile.dart';
import 'package:social_beacon/pages/search.dart';



final GoogleSignIn googleSignIn = GoogleSignIn();
final usersRef = Firestore.instance.collection('users');
final DateTime timestamp = DateTime.now();

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth = false;
  PageController pageController;
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();

    pageController = PageController(
      initialPage: 0
    );

    // Detects when a user is signed in
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (err) {
        print('Error Signin In: $err');
    });

    // ReAuth user when app is opened
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    }).catchError((err) {
      print('Error Signin In: $err');
      print('isAuth: $isAuth');
    });
    
  }


  // Determines if user is signed in
  handleSignIn(GoogleSignInAccount account) {
    if (account != null) {
        setState(() {
          isAuth = true;
        });
        createFirestoreUser();
      } else {
        setState(() {
          isAuth = false;
        });
      }
  }

  // Creates a user in the firestore database
  createFirestoreUser() async {
    // Check if user exists in users collection
    final GoogleSignInAccount user = googleSignIn.currentUser;
    final DocumentSnapshot doc = await usersRef.document(user.id).get();

    if (!doc.exists) {
    // If user doesn't exist, nav to create profile page
    final username = await Navigator.push(context, MaterialPageRoute(builder: (context) => CreateAccount()));

      // Get username fromm profile, use to create user document in users collection
      usersRef.document(user.id).setData({
        'id': user.id,
        'username': username,
        'photoUrl': user.photoUrl,
        'email': user.email,
        'displayName': user.displayName,
        'bio': '',
        'timestamp': timestamp,

      });

    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }


  // Handle account logins
  login() {
    googleSignIn.signIn();

  }


  // Handle account logout
  logout() {
    googleSignIn.signOut();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut
    );
  }

  // Screen to be displayed for Authenticated users
  Scaffold buildAuthScreen() {
    return Scaffold(
      body: PageView(
        children: <Widget>[
          //Timeline(),
          RaisedButton(
            color: Colors.white,
            child: Text('Logout'),
            onPressed: logout(),
          ),
          ActivityFeed(),
          Upload(),
          Search(),
          Profile(),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: onTap,
        activeColor: Theme.of(context).primaryColor,
        items: [
          // Timeline
          BottomNavigationBarItem(
            icon: Icon(Icons.whatshot)
          ),
          // Activity Feed
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active)
          ),
          // Upload
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_camera, size: 35.0,)
          ),
          // Search
          BottomNavigationBarItem(
            icon: Icon(Icons.search)
          ),
          // Profile
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle)
          ),
        ]
      ),
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