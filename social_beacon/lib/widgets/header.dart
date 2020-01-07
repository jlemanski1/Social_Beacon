import 'package:flutter/material.dart';

AppBar header(context, { bool isAppTitle = false, String titleText, rmBackButton = false }) {
  return AppBar(
    automaticallyImplyLeading: rmBackButton ? false : true,
    title: Text(
      isAppTitle ? 'Social Beacon': titleText,
      style: TextStyle(
        color: Colors.white,
        fontFamily: isAppTitle ? 'Signatra' : '',
        fontSize: isAppTitle ? 50.0 : 22.0,
      ),
      overflow: TextOverflow.ellipsis,
    ),
    centerTitle: true,
    backgroundColor: Theme.of(context).primaryColor,
  );
}