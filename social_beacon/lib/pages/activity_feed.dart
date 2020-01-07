import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_beacon/pages/home.dart';
import 'package:social_beacon/widgets/header.dart';
import 'package:social_beacon/widgets/progress.dart';


class ActivityFeed extends StatefulWidget {
  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {


  getActivityFeed() async {
    QuerySnapshot snapshot = await feedRef.document(currentUser.id).collection('feedItems').orderBy('timestamp', descending: true).limit(50).getDocuments();
  
    snapshot.documents.forEach((doc) {
      print('activity feed item: ${doc.data}');
    });
    return snapshot.documents;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: 'Activity Feed'),
      body: Container(
        child: FutureBuilder(
          future: getActivityFeed(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return circularProgress();
            }

            return Text('activity feed');
          },
        ),
      ),
    );
  }
}

class ActivityFeedItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('Activity Feed Item');
  }
}