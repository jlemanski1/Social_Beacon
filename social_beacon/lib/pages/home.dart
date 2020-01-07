import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:social_beacon/models/user.dart';

import 'package:social_beacon/pages/activity_feed.dart';
import 'package:social_beacon/pages/create_account.dart';
import 'package:social_beacon/pages/timeline.dart';
import 'package:social_beacon/pages/upload.dart';
import 'package:social_beacon/pages/profile.dart';
import 'package:social_beacon/pages/search.dart';


// Firestore collection references
final postsRef = Firestore.instance.collection('posts');
final usersRef = Firestore.instance.collection('users');
final commentsRef = Firestore.instance.collection('comments');

// Firebase Storage ref
final StorageReference storageRef = FirebaseStorage.instance.ref();

final GoogleSignIn googleSignIn = GoogleSignIn();
User currentUser;

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
    pageController = PageController();

    // Detects when a user signs in
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
    });
    
  }


  // Determines if user is signed in
  handleSignIn(GoogleSignInAccount account) {
    if (account != null) {
      createFirestoreUser();
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  // Creates a user in the firestore database
  createFirestoreUser() async {
    // Check if user exists in users collection (according to id)
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await usersRef.document(user.id).get();

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
      doc = await usersRef.document(user.id).get(); // Update doc
    }

    currentUser = User.fromDocument(doc);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }


  // Handle Google Sign in
  Future<void> login() async {
    try {
      await googleSignIn.signIn();
    } catch (err) {
      print(err);
    }
  }


  // Handle account logout
  Future<void> logout() async{
    await googleSignIn.disconnect();
  }

  // Set page index in state and rebuild
  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  // Animate to the passed in page
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
            onPressed: logout,
          ),
          ActivityFeed(),
          Upload(
            currentUser: currentUser,
          ),
          Search(),
          Profile(
            profileId: currentUser?.id,
          ),
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
              onTap: login,
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