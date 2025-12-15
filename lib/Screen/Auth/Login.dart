import 'package:artist_hub/Constants/api_urls.dart';
import 'package:artist_hub/Constants/app_colors.dart';
import 'package:artist_hub/Screen/Auth/Register.dart';
import 'package:artist_hub/Services/api_services.dart';
import 'package:artist_hub/Widgets/Common%20Textfields/common_textfields.dart';
import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';

import '../../Models/register_model.dart';
import '../Dashboard/Artist Dashboard/artist_dashboard.dart';
import '../Dashboard/Customer Dashboard/customer dashboard.dart';
import '../Shared Preference/shared_pref.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  // Role selection variables
  String? _selectedRole;
  final List<String> _roles = ['artist', 'customer'];

  void showAlert(String msg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Alert",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
          ),
        ),
        content: Text(msg, textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK", style: TextStyle(color: AppColors.primaryColor)),
          ),
        ],
      ),
    );
  }

  void validateLogin() async {
    // Role validation
    if (_selectedRole == null) {
      showAlert("Please select a role");
      return;
    }

    if (email.text.isEmpty) {
      showAlert("Please enter email");
    } else if (password.text.isEmpty) {
      showAlert("Please enter password");
    } else {
      await loginUser();
    }
  }

  Future<void> loginUser() async {
    setState(() {
      _isLoading = true;
    });

    // Add role to data for API
    Map<String, dynamic> data = {
      "email": email.text,
      "password": password.text,
      "role": _selectedRole ?? '',
    };

    print("Login Data: $data");
    print("Login URL: ${ApiUrls.loginUrl}");

    try {
      var response = await ApiServices.postApi(ApiUrls.loginUrl, data);

      print("Login Response: $response");

      setState(() {
        _isLoading = false;
      });

      if (response["status"] == true || response["code"] == 200) {
        // Parse the response using your RegisterModel
        var registerModel = RegisterModel.fromJson(response);

        if (registerModel.user != null) {
          // SAVE USER DATA TO SHARED PREFERENCES
          Map<String, dynamic> userData = {
            'id': registerModel.user!.userId?.toString() ?? '',
            'name': registerModel.user!.name ?? '',
            'email': registerModel.user!.email ?? '',
            'role': registerModel.user!.role?.toLowerCase() ?? 'customer',
            'phone': registerModel.user!.phone ?? '',
            'address': registerModel.user!.address ?? '',
            'profile_pic': registerModel.user!.profilePic ?? '',
            'artist_id': registerModel.user!.artistId?.toString() ?? '',
          };

          // Save to SharedPreferences
          await SharedPreferencesService.saveUserData(userData);

          // Print saved data for debugging
          SharedPreferencesService.printAllData();

          // Check user role and navigate accordingly
          String userRole =
              registerModel.user!.role?.toLowerCase() ?? 'customer';

          showAlert("Login Successful");

          // Wait a moment before navigation
          await Future.delayed(const Duration(milliseconds: 1500));

          // Close the alert dialog
          Navigator.of(context, rootNavigator: true).pop();

          // Navigate based on role
          if (userRole == 'artist') {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const ArtistDashboard()),
              (route) => false,
            );
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const CustomerDashboard(),
              ),
              (route) => false,
            );
          }
        } else {
          showAlert("User data not found in response");
        }
      } else {
        showAlert(response["message"] ?? "Login failed");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showAlert(
        "Connection error: Please check your internet and server connection",
      );
      print("Login Error Details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.appBarGradient.colors[0].withOpacity(0.9),
                AppColors.appBarGradient.colors[1].withOpacity(0.7),
              ],
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header Section
                Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      SizedBox(height: 30),
                      Text(
                        "Welcome Back",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Sign in to your account",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),

                // White Form Section
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        SizedBox(height: 20),

                        // Profile Icon
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[100],
                            border: GradientBoxBorder(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.appBarGradient.colors[0]
                                      .withOpacity(0.9),
                                  AppColors.appBarGradient.colors[1]
                                      .withOpacity(0.7),
                                ],
                              ),
                            ),
                          ),
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: AppColors.grey600,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 30),

                        // Form Fields Container
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[50]!,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.grey[200]!,
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                // Role Dropdown
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                      width: 1,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: DropdownButtonFormField<String>(
                                      value: _selectedRole,
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedRole = newValue;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        prefixIcon: Icon(
                                          Icons.person_outline,
                                          color: AppColors.grey600,
                                        ),
                                        hintText: 'Select Role',
                                        hintStyle: TextStyle(
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                      items: _roles.map((String role) {
                                        return DropdownMenuItem<String>(
                                          value: role,
                                          child: Text(
                                            role == 'artist'
                                                ? 'Artist'
                                                : 'Customer',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      icon: Icon(
                                        Icons.arrow_drop_down,
                                        color: AppColors.grey600,
                                      ),
                                      isExpanded: true,
                                      dropdownColor: Colors.white,
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 16,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please select a role';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(height: 15),

                                // Email Field
                                CommonTextfields(
                                  keyboardType: TextInputType.emailAddress,
                                  controller: email,
                                  hintText: 'Email Address',
                                  inputAction: TextInputAction.next,
                                  preFixIcon: Icon(
                                    Icons.email_outlined,
                                    color: AppColors.grey600,
                                  ),
                                ),
                                SizedBox(height: 15),

                                // Password Field
                                CommonTextfields(
                                  keyboardType: TextInputType.visiblePassword,
                                  controller: password,
                                  hintText: 'Password',
                                  obsureText: _obscurePassword,
                                  inputAction: TextInputAction.done,
                                  preFixIcon: Icon(
                                    Icons.lock_outline,
                                    color: AppColors.grey600,
                                  ),
                                  sufFixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.grey[600],
                                    ),
                                    onPressed: () => setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    }),
                                  ),
                                ),

                                // Forgot Password
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      showAlert(
                                        "Forgot Password feature coming soon!",
                                      );
                                    },
                                    child: Text(
                                      "Forgot Password?",
                                      style: TextStyle(
                                        color: AppColors.primaryColor,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 30),

                        // Login Button
                        Container(
                          height: 50,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            gradient: LinearGradient(
                              colors: [
                                AppColors.appBarGradient.colors[0].withOpacity(
                                  0.9,
                                ),
                                AppColors.appBarGradient.colors[1].withOpacity(
                                  0.7,
                                ),
                              ],
                            ),
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : validateLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Sign In',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),

                        SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            ShaderMask(
                              blendMode: BlendMode.srcIn,
                              shaderCallback: (bounds) {
                                return LinearGradient(
                                  colors: [
                                    AppColors.appBarGradient.colors[0]
                                        .withOpacity(0.9),
                                    AppColors.appBarGradient.colors[1]
                                        .withOpacity(0.7),
                                  ],
                                ).createShader(
                                  Rect.fromLTWH(
                                    0,
                                    0,
                                    bounds.width,
                                    bounds.height,
                                  ),
                                );
                              },
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Register(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Register',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
