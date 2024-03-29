import 'package:flutter/material.dart';
import 'package:social_beacon/pages/home.dart';
import 'package:social_beacon/widgets/header.dart';
import 'package:social_beacon/widgets/post.dart';
import 'package:social_beacon/widgets/progress.dart';


class PostScreen extends StatelessWidget {
  final String userId;
  final String postId;

  PostScreen({this.postId, this.userId});


  // TODO: Add 2-3 most recent comments underneath the post screen like how insta does,
  //       maybe do that on post and not post screen so its viewable everywhere

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: postsRef.document(userId).collection('userPosts').document(postId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        Post post = Post.fromDocument(snapshot.data);
        return Center(
          child: Scaffold(
            appBar: header(context, titleText: post.description ?? ''),
            body: ListView(
              children: <Widget>[
                Container(
                  child: post,
                )
              ],
            ),
          )
        );
      },
    );
  }
}