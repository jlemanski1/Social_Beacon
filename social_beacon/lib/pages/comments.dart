import 'package:flutter/material.dart';
import 'package:social_beacon/widgets/header.dart';

class Comments extends StatefulWidget {
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;

  Comments({
    this.postId,
    this.postOwnerId,
    this.postMediaUrl,
  });

  @override
  _CommentsState createState() => _CommentsState(
    postId: this.postId,
    postOwnerId: this.postOwnerId,
    postMediaUrl: this.postMediaUrl,
  );
}

class _CommentsState extends State<Comments> {
  TextEditingController commentController = TextEditingController();
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;

  _CommentsState({
    this.postId,
    this.postOwnerId,
    this.postMediaUrl,
  });

  buildComments() {
    return Text('comment');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: 'Comments'),
      body: Column(
        children: <Widget>[
          Expanded(
            child: buildComments(),
          ),
          Divider(),
          ListTile(
            title: TextFormField(
              controller: commentController,
              decoration: InputDecoration(labelText: 'Leave a comment...'),
            ),
            trailing: OutlineButton(
              onPressed:  () => print('add comment'),
              borderSide: BorderSide.none,
              child: Text('post'),
            ),
          )
        ],
      ),
    );
  }
}





class Comment extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Text('Comment');
  }
}