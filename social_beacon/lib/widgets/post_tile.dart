import 'package:flutter/material.dart';
import 'package:social_beacon/widgets/load_image.dart';
import 'package:social_beacon/widgets/post.dart';

/*
  PostTiles reside on the profile page giving users an at-a-glance view of their recent posts
*/


class PostTile extends StatelessWidget {
  final Post post;

  PostTile(this.post);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => print('showing post'),
      child: cachedNetworkImage(post.mediaUrl),
    );
  }
}