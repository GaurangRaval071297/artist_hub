import 'package:artist_hub/shared/widgets/common_appbar/Common_Appbar.dart';
import 'package:flutter/material.dart';

class ArtistDashboard extends StatefulWidget {
  const ArtistDashboard({super.key});

  @override
  State<ArtistDashboard> createState() => _ArtistDashboardState();
}

class _ArtistDashboardState extends State<ArtistDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppbar(
        title: 'Artist_Dashboard',
      ),
    );
  }
}
