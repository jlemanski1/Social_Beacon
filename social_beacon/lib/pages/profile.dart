import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:social_beacon/models/user.dart';
import 'package:social_beacon/pages/edit_profile.dart';
import 'package:social_beacon/pages/home.dart';
import 'package:social_beacon/widgets/header.dart';
import 'package:social_beacon/widgets/post.dart';
import 'package:social_beacon/widgets/post_tile.dart';
import 'package:social_beacon/widgets/progress.dart';


class Profile extends StatefulWidget {
  final String profileId;

  Profile({this.profileId});

  @override
  _ProfileState createState() => _ProfileState();
}


class _ProfileState extends State<Profile> {
  final String currentUserId = currentUser?.id; // Set current user's id if not null
  bool isLoading = false;
  bool postIsGrid = true;   // orientation of the posts on profile page
  int postCount = 0;
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();

    getProfilePosts();
  }


  // Fetches the users posts from cloud Firestore
  getProfilePosts() async {
    // Start loading
    setState(() {
      isLoading = true;
    });

    // Get user posts & sort by latest
    QuerySnapshot snapshot = await postsRef.document(widget.profileId).collection('userPosts').orderBy('timestamp', descending: true).getDocuments();

    // End loading, set post count, & map posts to list
    setState(() {
      isLoading = false;
      postCount = snapshot.documents.length;
      posts = snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    });
  }


  // Builds the column and adds count for posts, followers, following
  Column buildCountColumn(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
          )
        ),
        Container(
          margin: EdgeInsets.only(top: 4.0),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 15.0,
              fontWeight: FontWeight.w400,
            )
          ),
        )
      ],
    );
  }

  // Pushes to edit Profile page
  editProfile() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfile(currentUserId: currentUserId)));
  }


  // Builds button allowing user to edit profile
  buildButton({String text, Function onPressed}) {
    return Container(
      padding: EdgeInsets.only(top: 2.0),
      child: FlatButton(
        onPressed: editProfile,
        child: Container(
          width: 250.0,
          height: 27.0,
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.blue,
            border: Border.all(
              color: Colors.blue,
            ),
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
      ),
    );
  }


  // If viewing own profile, shows edit profile button, otherwise, follow button
  buildProfileButton() {
    bool isProfileOwner = currentUserId == widget.profileId;
    if (isProfileOwner) {
      return buildButton(
        text: 'Edit Profile',
        onPressed: editProfile,
      );
    }
  }


  // Builds the user's porfile header
  buildProfileHeader() {
    return FutureBuilder(
      future: usersRef.document(widget.profileId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data);
        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 40.0,
                    backgroundColor: Colors.grey,
                    backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildCountColumn('posts', postCount),
                            buildCountColumn('followers', 0),
                            buildCountColumn('following', 0),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildProfileButton()
                          ],
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(top: 12.0),
                          child: Text(
                            user.username,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(top: 4.0),
                          child: Text(
                            user.displayName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(top: 2.0),
                          child: Text(user.bio),
                        )
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  // Returns the users posts in state in either a column or grid view
  buildProfilePosts() {
    if (isLoading) {
      return circularProgress();
    // No posts, display splash image
    } else if (posts.isEmpty) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset('assets/images/no_content.svg', height: 260.0,),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Text(
                'No Posts',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 40.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    // Display posts in grid
    } else if (postIsGrid) {
      List<GridTile> gridTiles = [];
      posts.forEach((post) {
        gridTiles.add(GridTile(child: PostTile(post)));
      });

      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTiles,
      );
    // Display posts in list
    } else if (!postIsGrid) {
      return Column(children: posts,);
    }
  }

  // Set the profile page to display posts in grid view
  setPostGrid(bool isGrid) {
    setState(() {
      this.postIsGrid = isGrid;
    });
  }

  // Builds row of buttons for toggling between post orientations
  buildTogglePostOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          onPressed: () => setPostGrid(true),
          icon: Icon(Icons.grid_on),
          color: postIsGrid ? Theme.of(context).primaryColor : Colors.grey,
        ),
        IconButton(
          onPressed: () => setPostGrid(false),
          icon: Icon(Icons.list),
          color: postIsGrid ? Colors.grey : Theme.of(context).primaryColor,
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: 'Profile'),
      body: ListView(
        children: <Widget>[
          buildProfileHeader(),
          Divider(),
          buildTogglePostOrientation(),
          Divider(height: 0.0,),
          buildProfilePosts(),
        ],
      )
    );
  }
}