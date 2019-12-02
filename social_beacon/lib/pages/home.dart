import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:social_beacon/pages/activity_feed.dart';
import 'package:social_beacon/pages/timeline.dart';
import 'package:social_beacon/pages/upload.dart';



final GoogleSignIn googleSignIn = GoogleSignIn();


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
    /*
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    }).catchError((err) {
      print('Error Signin In: $err');
      print('isAuth: $isAuth');
    });
    */
  }


  // Determines if user is signed in
  handleSignIn(GoogleSignInAccount account) {
    if (account != null) {
        setState(() {
          isAuth = true;
        });
        print('User signed in: $account');
      } else {
        setState(() {
          isAuth = false;
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
    pageController.jumpToPage(pageIndex);
  }

  // Screen to be displayed for Authenticated users
  Scaffold buildAuthScreen() {
    return Scaffold(
      body: PageView(
        children: <Widget>[
          Timeline(),
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
    /*
    return RaisedButton(
      color: Colors.white,
      child: Text('Logout'),
      onPressed: logout(),
    );
    */
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