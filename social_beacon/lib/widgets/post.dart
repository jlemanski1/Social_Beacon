import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_beacon/models/user.dart';
import 'package:social_beacon/pages/home.dart';
import 'package:social_beacon/widgets/load_image.dart';
import 'package:social_beacon/widgets/progress.dart';

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  final dynamic likes;

  Post({
    this.postId,
    this.ownerId,
    this.username,
    this.location,
    this.description,
    this.mediaUrl,
    this.likes,
  });

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      postId: doc['postId'],
      ownerId: doc['ownerId'],
      username: doc['username'],
      location: doc['location'],
      description: doc['description'],
      mediaUrl: doc['mediaUrl'],
      likes: doc['likes'],
    );
  }

  // Returns the number of likes the post has
  int getLikeCount(likes) {
    if (likes == null) {
      return 0;
    } else {
      int count = 0;
      // Key is explicitly set to true, add like
      likes.values.forEach((val) {
        if (val == true) {
          count++;
        }
      });
      return count;
    }
  }

  @override
  _PostState createState() => _PostState(
    postId: this.postId,
    ownerId: this.ownerId,
    username: this.username,
    location: this.location,
    description: this.description,
    mediaUrl: this.mediaUrl,
    likes: this.likes,
    likeCount: getLikeCount(this.likes),
  );
}

class _PostState extends State<Post> {
  final String currentUserId = currentUser?.id;
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;

  int likeCount;
  bool isLiked; // Used for border/filling in heart button
  Map likes;

  _PostState({
    this.postId,
    this.ownerId,
    this.username,
    this.location,
    this.description,
    this.mediaUrl,
    this.likeCount,
    this.likes,
  });


  // Handles everything to do with liking posts
  handleLikePost() {
    // check if post is liked (userId in the likes map)
    bool _isLiked = likes[currentUserId] == true;

    // Post already liked
    if (_isLiked) {
      postsRef.document(ownerId).collection('userPosts').document(postId).updateData({'likes.$currentUserId': false});

      // decrement post likes, set to unliked and remove user from likes map
      setState(() {
        likeCount--;
        isLiked = false;
        likes[currentUserId] = false;
      });

    // Post not liked
    } else if (!_isLiked) {
      postsRef.document(ownerId).collection('userPosts').document(postId).updateData({'likes.$currentUserId': true});

      // increment post likes, set to liked and add user to likes map
      setState(() {
        likeCount++;
        isLiked = true;
        likes[currentUserId] = true;
      });
    }
  }

  // Builds the header section of a post
  buildPostHeader() {
    return FutureBuilder(
      future: usersRef.document(ownerId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }

        User user = User.fromDocument(snapshot.data);
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(user.photoUrl),
            backgroundColor: Colors.grey,
          ),
          title: GestureDetector(
            onTap: () => print('showing profile'),
            child: Text(
              user.username,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              )
            ),
          ),
          subtitle: Text(location),
          trailing: IconButton(
            onPressed: () => print('deleting post'),
            icon: Icon(Icons.more_vert),
          ),
        );
      },
    );
  }

  // Builds the image section of an image/photo post
  buildPostImage() {
    return GestureDetector(
      onDoubleTap: () => handleLikePost,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          cachedNetworkImage(mediaUrl),
        ],
      ),
    );
  }

  // Builds the text section of a text post
  buildPostText() {
    // TODO: Implement option for either image or text post, and call the appropriate build method
      // Text post might need a different footer since the caption is the post itself... unless...
      // That's to figure out later
  }

  // Builds the footer section of a post
  buildPostFooter() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(padding: EdgeInsets.only(top: 40.0, left: 20.0),),
            GestureDetector(
              onTap: () => handleLikePost,
              child: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                size: 28.0,
                color: Colors.pink,
              ),
            ),
            Padding(padding: EdgeInsets.only(right: 20.0),),
            GestureDetector(
              onTap: () => print('showing comments'),
              child: Icon(
                Icons.chat,
                size: 28.0,
                color: Colors.blue[900],
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                '$likeCount likes',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                '$username ',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(child: Text(description),),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // ensure isLiked is not null
    isLiked = (likes[currentUserId] == true);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildPostHeader(),
        buildPostImage(),
        buildPostFooter(),
      ],
    );
  }
}