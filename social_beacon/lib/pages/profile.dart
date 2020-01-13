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
  bool isFollowing = false;
  String postOrientation = 'grid';
  int postCount = 0;
  int followerCount = 0;
  int followingCount = 0;
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();

    getProfilePosts();
    getFollowers();
    getFollowing();
    checkIfFollowing();
  }


  // Fetches the users posts from cloud Firestore
  void getProfilePosts() async {
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

  // Gets the follower count of a user to be displayed on their profile header
  void getFollowers() async {
    QuerySnapshot snapshot = await followersRef.document(widget.profileId).collection('userFollowers').getDocuments();
    setState(() {
      followerCount = snapshot.documents.length;
    });
  }

  // Gets the following count of a user to be displayed on their profile header
  void getFollowing() async {
    QuerySnapshot snapshot = await followingRef.document(widget.profileId).collection('userFollowing').getDocuments();
    setState(() {
      followingCount = snapshot.documents.length;
    });
  }


  // Checks if current user exists as a follower of the profile owner
  void checkIfFollowing() async {
    DocumentSnapshot doc = await followersRef.document(widget.profileId).collection('userFollowers').document(currentUserId).get();
    // isFollowing is true when the doc exists
    setState(() {
      isFollowing = doc.exists;
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
  void editProfile() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfile(currentUserId: currentUserId)));
  }


  /*
    Handles all database operations related to unfollowing a fellow user
  */
  void handleUnfollowUser() {
    setState(() {
      // Changes button from follow to unfollow
      isFollowing = false;
    });
    // Remove follower of other user, delete doc from collection if it exists
    followersRef.document(widget.profileId).collection('userFollowers').document(currentUserId).get().then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // remove following
    followingRef.document(currentUserId).collection('userFollowing').document(widget.profileId).get().then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // Remove activity feed item for follow
    feedRef.document(widget.profileId).collection('feedItems').document(currentUserId).get().then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }


  /*
    Handles all database operations related to following a fellow user
  */
  void handleFollowUser() {
    setState(() {
      // Changes button from unfollow to follow
      isFollowing = true;
    });
    // Make authed user follower of other user, update That  followers collection
    followersRef.document(widget.profileId).collection('userFollowers').document(currentUserId).setData({});
    // Put That user on the authed user's followering collection
    followingRef.document(currentUserId).collection('userFollowing').document(widget.profileId).setData({});
    // Add activity feed item for follow
    feedRef.document(widget.profileId).collection('feedItems').document(currentUserId).setData({
      'type': 'follow',
      'ownerId': widget.profileId,
      'username': currentUser.username,
      'userId': currentUserId,
      'userProfileImg': currentUser.photoUrl,
      'timestamp': timestamp,
    });
  }


  // Builds button allowing user to edit profile
  Container buildButton({String text, Function onPressed}) {
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
              color: isFollowing ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
            )
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isFollowing ? Colors.white : Colors.blue,
            border: Border.all(
              color: isFollowing ? Colors.grey : Colors.blue,
            ),
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
      ),
    );
  }

  /*
    Builds the appropriate profile button based on context. Your profile shows edit,
    Fellow user profiles will show either follow or unfollow, depending on follow status
  */
  dynamic buildProfileButton() {
    bool isProfileOwner = currentUserId == widget.profileId;
    if (isProfileOwner) {
      return buildButton(
        text: 'Edit Profile',
        onPressed: editProfile,
      );
    } else if (isFollowing) {
      return buildButton(
        text: 'Unfollow',
        onPressed: handleUnfollowUser,
      );
    } else if (!isFollowing) {
      return buildButton(
        text: 'Follow',
        onPressed: handleFollowUser,
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
                            buildCountColumn('posts', postCount ?? 0),
                            buildCountColumn('followers', followerCount ?? 0),
                            buildCountColumn('following', followingCount ?? 0),
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
                            user.username ?? 'Username',
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
                            user.displayName ?? 'Display Name',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(top: 2.0),
                          child: Text(user.bio ?? 'Bio'),
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
    } else if (postOrientation == 'grid') {
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
    } else if (postOrientation == 'list') {
      return Column(children: posts,);
    }
  }

  // Set the profile page to display posts in grid view
  void setPostOrientation(String orientation) {
    setState(() {
      this.postOrientation = orientation;
    });
  }

  // Builds row of buttons for toggling between post orientations
  Row buildTogglePostOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          onPressed: () => setPostOrientation('grid'),
          icon: Icon(Icons.grid_on),
          color: postOrientation == 'grid' ? Theme.of(context).primaryColor : Colors.grey,
        ),
        IconButton(
          onPressed: () => setPostOrientation('list'),
          icon: Icon(Icons.list),
          color: postOrientation == 'list' ? Theme.of(context).primaryColor : Colors.grey,
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