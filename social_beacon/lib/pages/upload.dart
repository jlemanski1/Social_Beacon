import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:social_beacon/models/user.dart';
import 'package:social_beacon/widgets/progress.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';
import 'package:social_beacon/pages/home.dart';

class Upload extends StatefulWidget {
  final User currentUser;

  Upload({this.currentUser});

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  TextEditingController locationController = TextEditingController();
  TextEditingController captionController = TextEditingController();
  File file;
  bool isUploading = false;
  String postId = Uuid().v4();

  // Handles opening and selecting an image from the gallery
  handleChooseImage() async {
    Navigator.pop(context); // Remove dialog first
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      this.file = file;
    });
  }


  // Handles opening the camera and taking photos
  handleTakePhoto() async {
    Navigator.pop(context); // Remove dialog first
    File file = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );
    setState(() {
      this.file = file;
    });
  }


  // The dialog for image/photo uploads
  selectImage(parentContext) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          title: Text('Create Post'),
          children: <Widget>[
            SimpleDialogOption(
              child: Text('Photo with Camera'),
              onPressed: handleTakePhoto,
            ),
            SimpleDialogOption(
              child: Text('Image from Gallery'),
              onPressed: handleChooseImage,
            ),
            SimpleDialogOption(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      }
    );
  }

  // Builds the splashscreen to show when file is null
  Container buildSplashScreen() {
    return Container(
      color: Theme.of(context).accentColor.withOpacity(0.6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset('assets/images/upload.svg', height: 260.0,),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                'Upload Image',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.0,
                ),
              ),
              color: Colors.deepOrange,
              onPressed: () => selectImage(context),
            ),
          ),
          
        ],
      ),
    );
  }

  // Resets the state's file
  clearImage() {
    setState(() {
      file = null;
    });
  }

  // Compress images before uploading to save on Firebase Storage costs
  compressImage() async {
    // Create tmp dir for image path
    final tmpDir = await getTemporaryDirectory();
    final path = tmpDir.path;

    Im.Image imgFile = Im.decodeImage(file.readAsBytesSync());  // read in Image file
    final compressedImgFile = File('$path/img_$postId.jpg')..writeAsBytesSync(Im.encodeJpg(imgFile, quality: 85));  // Write compressed img to created unique path

    // Update state file with new compressed one
    setState(() {
      file = compressedImgFile;
    });
  }

  // Upload img to Firebase Storage
  Future uploadImage(imgFile) async {
    StorageUploadTask uploadTask = storageRef.child('post_$postId.jpg').putFile(imgFile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  // Add post with created mediaUrl to Cloudstore
  createPostInFirestore({String mediaUrl, String location, String description}) {
    postsRef.document(widget.currentUser.id).collection('userPosts').document(postId).setData({
      'postId': postId,
      'ownerId': widget.currentUser.id,
      'username': widget.currentUser.username,
      'mediaUrl': mediaUrl,
      'location': location,
      'timestamp': timestamp,
      'likes': {}
    });
  }

  // Handles everything pertaining to post uploads/submissions
  handleSubmitPost() async {
    // Set flag
    setState(() {
      isUploading = true;
    });
    await compressImage();  // Compress photo
    String mediaUrl = await uploadImage(file);  // Get mediaUrl from Firebase storage
    
    // Create post with new mediaUrl for the photo
    createPostInFirestore(
      mediaUrl: mediaUrl,
      location: locationController.text,
      description: captionController.text,
    );
    // clear TextEditingControllers
    captionController.clear();
    locationController.clear();

    // Reset file and isUploading after submission
    setState(() {
      file = null;
      isUploading = false;
    });
  }


  // builds the upload form to show when there is a file
  buildUploadForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black,),
          onPressed: clearImage,
          
        ),
        title: Text(
          'Caption Post',
          style: TextStyle(color: Colors.black),
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: isUploading ? null : () => handleSubmitPost(),
            child: Text(
              'Post',
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          isUploading ? linearProgress() : Text(''),
          Container(
            height: 222.0,
            width: MediaQuery.of(context).size.width * .8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: FileImage(file),
                    )
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(widget.currentUser.photoUrl),
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: captionController,
                decoration: InputDecoration(
                  hintText: 'Write a caption',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.pin_drop, color: Colors.orange, size: 35.0),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: locationController,
                decoration: InputDecoration(
                  hintText: 'Where was this taken?',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            width: 200.0,
            height: 100.0,
            alignment: Alignment.center,
            child: RaisedButton.icon(
              onPressed: () => print('get user location'),
              icon: Icon(Icons.my_location, color: Colors.white,),
              label: Text(
                'Use Current Location',
                style: TextStyle(color: Colors.white),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return file == null ? buildSplashScreen() : buildUploadForm();
  }
}