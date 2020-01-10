import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_beacon/pages/activity_feed.dart';
import 'package:social_beacon/widgets/header.dart';
import 'package:social_beacon/widgets/progress.dart';
import 'home.dart';
import 'package:timeago/timeago.dart' as timeAgo;

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

  // Fetch and display comments in realtime
  StreamBuilder buildComments() {
    return StreamBuilder(
      stream: commentsRef.document(postId).collection('comments').orderBy('timestamp', descending: false).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<Comment> comments = [];
        // Iterate over snapshot docs and add each to comments List
        snapshot.data.documents.forEach((doc) {
          comments.add(Comment.fromDocument(doc));
        });
        
        return ListView(
          children: comments,
        );
      },
    );
  }


  // Adds comment & comment notification to the respective Firestore collections
  addComment() {
    commentsRef.document(postId).collection('comments').add({
      'username': currentUser.username,
      'comment': commentController.text,
      'timestamp': DateTime.now(),
      'avatarUrl': currentUser.photoUrl,
      'userId': currentUser.id,
    });

    // Add comment notification to Firestore collection
    bool notPostOwner = postOwnerId != currentUser.id;
    if (notPostOwner) {
      feedRef.document(postOwnerId).collection('feedItems').add({
        'type': 'comment',
        'commentData': commentController.text,
        'username': currentUser.username,
        'userId': currentUser.id,
        'userProfileImg': currentUser.photoUrl,
        'postId': postId,
        'mediaUrl': postMediaUrl,
        'timestamp': DateTime.now(),  
      });
    }
    // Clear text field
    commentController.clear();
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
              onPressed:  addComment,
              borderSide: BorderSide.none,
              child: Text('Post'),
            ),
          )
        ],
      ),
    );
  }
}



class Comment extends StatelessWidget {
  final String username;
  final String userId;
  final String avatarUrl;
  final String comment;
  final Timestamp timestamp;

  Comment({
  this.username,
  this.userId,
  this.avatarUrl,
  this.comment,
  this.timestamp,
  });


  // Deserialize Comment from Firestore collection
  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      username: doc['username'],
      userId: doc['userId'],
      comment: doc['comment'],
      timestamp: doc['timestamp'],
      avatarUrl: doc['avatarUrl'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(comment),
          leading: Column(
            children: <Widget>[
              GestureDetector(
                onTap: () => showProfile(context, profileId: userId),
                child: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(avatarUrl),
                ),
              ),
              Text(username),
            ],
          ),
          subtitle: Text(timeAgo.format(timestamp.toDate())),
        ),
        Divider(),
      ],
    );
  }
}