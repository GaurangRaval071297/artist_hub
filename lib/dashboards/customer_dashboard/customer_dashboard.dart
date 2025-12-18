import 'package:artist_hub/shared/widgets/common_appbar/Common_Appbar.dart';
import 'package:flutter/material.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppbar(
        title: 'Customer_Dashboard',
      ),
      body: Center(
        child: Text(''),
      ),
    );
  }
}
