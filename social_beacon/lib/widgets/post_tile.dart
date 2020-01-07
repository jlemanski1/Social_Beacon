import 'package:flutter/material.dart';
import 'package:social_beacon/pages/post_screen.dart';
import 'package:social_beacon/widgets/load_image.dart';
import 'package:social_beacon/widgets/post.dart';

/*
  PostTiles reside on the profile page giving users an at-a-glance view of their recent posts
*/


class PostTile extends StatelessWidget {
  final Post post;

  PostTile(this.post);

  // Open up the full screen post page
  showPost(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => PostScreen(
      postId: post.postId,
      userId: post.ownerId,
    )));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showPost(context),
      child: cachedNetworkImage(post.mediaUrl),
    );
  }
}