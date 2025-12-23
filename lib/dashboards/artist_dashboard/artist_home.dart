import 'package:artist_hub/shared/widgets/common_appbar/Common_Appbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';

class ArtistHome extends StatefulWidget {
  const ArtistHome({super.key});

  @override
  State<ArtistHome> createState() => _ArtistHomeState();
}

class _ArtistHomeState extends State<ArtistHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Home'),
      ),
    );
  }
}
