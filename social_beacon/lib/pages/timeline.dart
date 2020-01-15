import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_beacon/models/user.dart';
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


  @override
  void initState() {
    super.initState();

    getTimeline();
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
      return Text(
        'no posts',
        textAlign: TextAlign.center,
      );
    }
    return ListView(children: posts);
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