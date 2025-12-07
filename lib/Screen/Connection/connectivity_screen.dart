import 'dart:async';
import 'package:artist_hub/Screen/Auth/Login.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityErrorScreen extends StatefulWidget {
  final VoidCallback? onRetry;

  const ConnectivityErrorScreen({super.key, this.onRetry});

  @override
  State<ConnectivityErrorScreen> createState() => _ConnectivityErrorScreenState();
}

class _ConnectivityErrorScreenState extends State<ConnectivityErrorScreen> {
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _navigated = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(  // Added this to prevent overflow
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start, // Changed from center to start
              children: [
                // Main Icon with Background Circle
                Container(
                  width: 150,
                  height: 150,
                  margin: const EdgeInsets.only(top: 40, bottom: 20), // Added margin
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEEBEB),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.1),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.wifi_off_rounded,
                        size: 70,
                        color: const Color(0xFFE53935),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "OFFLINE",
                        style: TextStyle(
                          color: const Color(0xFFE53935),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20), // Reduced from 40

                // Title
                Text(
                  "No Internet Connection",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontFamily: 'Roboto',
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12), // Reduced from 16

                // Description
                Text(
                  "Your connection to Artist Hub has been lost. "
                      "Please check your internet and try again.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 30), // Reduced from 40

                // Tips Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline_rounded,
                            color: Colors.orange[700],
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "Quick Tips",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildTipRow("Check if Wi-Fi is turned on"),
                      _buildTipRow("Enable mobile data"),
                      _buildTipRow("Restart your router"),
                      _buildTipRow("Move to better signal area"),
                    ],
                  ),
                ),

                const SizedBox(height: 30), // Reduced from 40

                // Action Buttons
                Column(
                  children: [
                    // Retry Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _checkConnectivity,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE53935),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.refresh_rounded, size: 22),
                            SizedBox(width: 10),
                            Text("TRY AGAIN"),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Help Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () => _showHelpDialog(context),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(
                            color: Colors.grey[400]!,
                            width: 1.5,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.help_outline_rounded,
                                size: 22,
                                color: Colors.blue[700]),
                            const SizedBox(width: 10),
                            Text(
                              "GET HELP",
                              style: TextStyle(
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Footer Text
                GestureDetector(
                  onTap: () => _showHelpDialog(context),
                  child: Text(
                    "Need more help? Tap here",
                    style: TextStyle(
                      color: Colors.blue[600],
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),

                const SizedBox(height: 30), // Added extra space at bottom for scroll
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTipRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: Colors.green[600],
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dialog Title
              Row(
                children: [
                  Icon(
                    Icons.help_rounded,
                    color: Colors.blue[700],
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Connection Help",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Dialog Content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHelpSection(
                    "Wi-Fi Issues",
                    "• Make sure Wi-Fi is turned on\n• Restart your Wi-Fi router\n• Check password is correct",
                  ),

                  const SizedBox(height: 16),

                  _buildHelpSection(
                    "Mobile Data",
                    "• Turn on mobile data\n• Check signal strength\n• Restart your phone",
                  ),

                  const SizedBox(height: 16),

                  _buildHelpSection(
                    "Device Settings",
                    "• Disable airplane mode\n• Update network settings\n• Restart your device",
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Close Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "UNDERSTOOD",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  void _checkConnectivity() {
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) async {
          if (_navigated) return;

          if (result.contains(ConnectivityResult.mobile) ||
              result.contains(ConnectivityResult.wifi)) {

            // Show loading dialog
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.green[600],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Connecting...",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );

            await Future.delayed(const Duration(seconds: 2));

            if (mounted) {
              Navigator.pop(context); // Close loading dialog
              setState(() => _navigated = true);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Login()),
              );
            }

          } else {
            setState(() => _navigated = true);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ConnectivityErrorScreen()),
            );
          }
        });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}