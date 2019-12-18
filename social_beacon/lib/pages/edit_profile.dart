import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_beacon/models/user.dart';
import 'package:social_beacon/pages/home.dart';
import 'package:social_beacon/widgets/progress.dart';


class EditProfile extends StatefulWidget {
  final String currentUserId;

  EditProfile({this.currentUserId});
  
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  bool isLoading = false;
  User user;
  bool _displayNameValid = true;
  bool _bioValid = true;


  @override
  void initState() {
    super.initState();
    getUser();
  }

  // Gets and assigns the current user
  getUser() async {
    // Start loading
    setState(() {
      isLoading = true;
    });

    // Get user from cloud firestore
    DocumentSnapshot doc = await usersRef.document(widget.currentUserId).get();
    user = User.fromDocument(doc);

    // Set fields to displayname & bio
    displayNameController.text = user.displayName;
    bioController.text = user.bio;

    // Finish loading
    setState(() {
      isLoading = false;
    });
  }

  // Builds & returns the field for editing display name
  Column buildDisplayNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            'Display Name',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: displayNameController,
          decoration: InputDecoration(
            hintText: 'Update display name',
            errorText: _displayNameValid ? null : 'Display name too short',
          ),
        ),
      ],
    );
  }


  // Builds & returns the field for editing bio
  Column buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            'Bio',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: bioController,
          decoration: InputDecoration(
            hintText: 'Update bio',
            errorText: _bioValid ? null : 'Bio too long',
          ),
        )
      ],
    );
  }


  // Check for validity and update user profile
  updateProfileData() {
    // Check that inputted text is valid
    setState(() {
      displayNameController.text.trim().length < 3 || 
      displayNameController.text.isEmpty ? _displayNameValid = false : _displayNameValid = true;

      bioController.text.trim().length > 240 ? _bioValid = false : _bioValid = true;
    });

    // If valid, update user profile in firestore
    if (_displayNameValid && _bioValid) {
      usersRef.document(widget.currentUserId).updateData({
        'displayName': displayNameController.text,
        'bio': bioController.text,
      });

      //  Show snackbar to user so they know it's been updated
      SnackBar snackBar = SnackBar(content: Text('Profile Updated!'));
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }
  }

  // Logout and return user to home
  logout() async {
    await googleSignIn.signOut();
    Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.done,
              size: 30.0,
              color: Colors.green,
            ),
          )
        ],
      ),
      body: isLoading ? circularProgress() : ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
                  child: CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                    radius: 50.0,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      buildDisplayNameField(),
                      buildBioField(),
                    ],
                  ),
                ),
                RaisedButton(
                  onPressed: updateProfileData,
                  child: Text(
                    'Update profile',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: FlatButton.icon(
                    onPressed: logout,
                    icon: Icon(
                      Icons.cancel,
                      color: Colors.red,
                    ),
                    label: Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}