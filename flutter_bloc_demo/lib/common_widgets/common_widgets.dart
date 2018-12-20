import 'package:flutter/material.dart';

class CommonWidget {

  Widget showLoading() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget showNoResult() {
    return Center(
      child: new Text(
        "No Result",
        style: new TextStyle(fontSize: 30.0),
      ),
    );
  }
}