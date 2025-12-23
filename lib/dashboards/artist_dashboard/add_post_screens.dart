import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddPostScreens extends StatefulWidget {
  const AddPostScreens({super.key});

  @override
  State<AddPostScreens> createState() => _AddPostScreensState();
}

class _AddPostScreensState extends State<AddPostScreens> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Add Post Screen')));
  }
}
