import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_beacon/models/user.dart';
import 'package:social_beacon/pages/search.dart';
import 'package:social_beacon/widgets/header.dart';
import 'package:social_beacon/widgets/post.dart';
import 'package:social_beacon/widgets/progress.dart';
import 'home.dart';

class Timeline extends StatefulWidget {
  final User currentUser;


  Timeline({this.currentUser});

  @override
  _TimelineState createState() => _TimelineState();
}


class _TimelineState extends State<Timeline> {
  List<Post> posts;
  List<String> followingList = [];

  @override
  void initState() {
    super.initState();

    getTimeline();
    getFollowing();
  }

  // Fetches users timeline and stores in a list of posts
  getTimeline() async {
    QuerySnapshot snapshot = await timelineRef.document(widget.currentUser.id).collection('timelinePosts').orderBy('timestamp', descending: true).getDocuments();
    List<Post> posts = snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();

    setState(() {
      this.posts = posts;
    });
  }

  // Builds the timeline by either displaying a loading indicator or a listView of posts
  buildTimeline() {
    if (posts == null) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return buildUsersToFollow();
    }
    return ListView(children: posts);
  }


  buildUsersToFollow() {
    return StreamBuilder(
      stream: usersRef.orderBy('timestamp', descending: true).limit(30).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<UserResult> userResults = [];
        snapshot.data.documents.forEach((doc) {
          User user = User.fromDocument(doc);
          // Remove auth user or followed users from recommended list
          final bool isAuthUser = currentUser.id == user.id;
          final bool isFollowingUser = followingList.contains(user.id);
          if (isAuthUser) {
            return;
          } else if (isFollowingUser) {
            return;
          } else {
            UserResult userResult = UserResult(user);
            userResults.add(userResult);
          }
        });
          return Container(
            color: Theme.of(context).accentColor.withOpacity(0.2),
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.person_add,
                        color: Theme.of(context).primaryColor,
                        size: 30.0,
                      ),
                      SizedBox(width: 8.0,),
                      Text(
                        'School Feeds to Follow:',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 30.0,
                        ),
                      )
                    ],
                  ),
                ),
                Column(children: userResults)
              ],
            ),
          );
      },
    );
  }


  getFollowing() async {
    QuerySnapshot snapshot =  await followingRef.document(currentUser.id).collection('userFollowing').getDocuments();
    setState(() {
      followingList = snapshot.documents.map((doc) => doc.documentID).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, isAppTitle: true),
      body: RefreshIndicator(
        onRefresh: () => getTimeline(),
        child: buildTimeline(),
      )
    );
  }
}