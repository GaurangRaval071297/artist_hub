import 'dart:convert';

import 'package:artist_hub/dashboards/artist_dashboard/artist_dashboard.dart';
import 'package:artist_hub/models/login_model.dart';
import 'package:artist_hub/shared/constants/api_urls.dart';
import 'package:flutter/material.dart';
import 'package:artist_hub/auth/register_screen.dart';
import 'package:artist_hub/shared/constants/app_colors.dart';
import 'package:artist_hub/shared/constants/app_messages.dart';
import 'package:artist_hub/shared/constants/custom_dialog.dart';
import 'package:artist_hub/shared/preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../dashboards/customer_dashboard/customer_dashboard.dart';
import '../shared/widgets/common_textfields/common_textfields.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _selectedRole;
  final List<String> _roles = ['artist', 'customer'];

  void validateLogin() {
    print("=== VALIDATE LOGIN ===");
    print("Email: ${_emailController.text}");
    print("Password: ${_passwordController.text}");
    print("Selected Role: $_selectedRole");

    if (_selectedRole == null) {
      showAlert('Alert', 'Please Select Role');
      return;
    }
    if (_emailController.text.isEmpty) {
      showAlert('Alert', 'Please Enter Email');
      return;
    } else if (_passwordController.text.isEmpty) {
      showAlert('Alert', 'Please Enter Password');
      return;
    } else if (!RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(_emailController.text)) {
      showAlert('Alert', 'Please Enter Valid Email');
      return;
    } else if (_passwordController.text.length < 6) {
      showAlert('Alert', 'Password must be at least 6 characters');
      return;
    } else {
      _login();
    }
  }

  void showAlert(String title, String message, {bool isSuccess = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomAlertDialog(
        title: title,
        message: message,
        icon: isSuccess
            ? Icons.check_circle_outline
            : Icons.warning_amber_rounded,
        isSuccess: isSuccess,
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  void _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse(ApiUrls.loginUrl);
      final response = await http.post(
        url,
        body: {
          'email': _emailController.text,
          'password': _passwordController.text,
          'role': _selectedRole,
        },
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final loginModel = LoginModel.fromJson(responseData);

        if (loginModel.status == true) {
          await SharedPreferencesHelper.init();
          await SharedPreferencesHelper.setUserLoggedIn(true);
          await SharedPreferencesHelper.setUserEmail(_emailController.text);
          await SharedPreferencesHelper.setUserType(_selectedRole!);

          if (_selectedRole == 'artist') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ArtistDashboard()),
            );
          } else if (_selectedRole == 'customer') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => CustomerDashboard()),
            );
          }
          showAlert(
            'Success',
            loginModel.message ?? 'Login Successful',
            isSuccess: true,
          );
        } else {
          showAlert('Error', loginModel.message ?? 'Login failed');
        }
      } else {
        showAlert('Error', 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Login Error: $e');
      showAlert('Error', 'Network error: $e');
    }
    setState(() {
      _isLoading = false;
    });
  }

  Widget _buildRoleDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButtonFormField<String>(
          initialValue: _selectedRole,
          onChanged: (String? newValue) {
            setState(() {
              _selectedRole = newValue;
            });
          },
          decoration: const InputDecoration(
            border: InputBorder.none,
            prefixIcon: Icon(Icons.person_outline, color: AppColors.grey600),
          ),
          hint: const Text('Select Role', style: TextStyle(color: Colors.grey)),
          items: _roles.map((String role) {
            return DropdownMenuItem<String>(
              value: role,
              child: Text(
                role == 'artist' ? 'Artist' : 'Customer',
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            );
          }).toList(),
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.grey600),
          isExpanded: true,
          dropdownColor: Colors.white,
          style: const TextStyle(color: Colors.black87, fontSize: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 380;

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
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header Section
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
                  child: Column(
                    children: [
                      SizedBox(height: size.height * 0.03),
                      Text(
                        "Welcome Back",
                        style: TextStyle(
                          fontSize: isSmallScreen ? 28 : 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 8 : 12),
                      Text(
                        "Sign in to your account",
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),

                // Form Section
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          SizedBox(height: isSmallScreen ? 10 : 20),

                          // Logo/Icon
                          Container(
                            width: isSmallScreen ? 80 : 100,
                            height: isSmallScreen ? 80 : 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.shade100,
                              border: Border.all(
                                color: AppColors.appBarGradient.colors[0]
                                    .withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.person,
                              size: isSmallScreen ? 40 : 50,
                              color: AppColors.grey600,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 8 : 12),
                          Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 20 : 30),

                          // Form Container
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.grey.shade200,
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Role Selection
                                  _buildRoleDropdown(),
                                  SizedBox(height: isSmallScreen ? 15 : 20),
                                  CommonTextfields(
                                    keyboardType: TextInputType.emailAddress,
                                    controller: _emailController,
                                    hintText: 'Enter your email',
                                    inputAction: TextInputAction.next,
                                    preFixIcon: Icon(
                                      Icons.email_outlined,
                                      color: AppColors.grey600,
                                      size: isSmallScreen ? 20 : 22,
                                    ),
                                  ),
                                  SizedBox(height: isSmallScreen ? 15 : 20),

                                  // Password Field
                                  CommonTextfields(
                                    keyboardType: TextInputType.visiblePassword,
                                    controller: _passwordController,
                                    hintText: 'Enter your password',
                                    obsureText: _obscurePassword,
                                    inputAction: TextInputAction.done,
                                    preFixIcon: Icon(
                                      Icons.lock_outline,
                                      color: AppColors.grey600,
                                      size: isSmallScreen ? 20 : 22,
                                    ),
                                    sufFixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Colors.grey.shade600,
                                        size: isSmallScreen ? 20 : 22,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 25 : 30),

                          // Login Button
                          Container(
                            height: isSmallScreen ? 50 : 56,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.appBarGradient.colors[0]
                                      .withOpacity(0.9),
                                  AppColors.appBarGradient.colors[1]
                                      .withOpacity(0.7),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.appBarGradient.colors[0]
                                      .withOpacity(0.3),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 5),
                                ),
                              ],
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
                                      height: isSmallScreen ? 20 : 24,
                                      width: isSmallScreen ? 20 : 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : Text(
                                      'Sign In',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isSmallScreen ? 16 : 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 20 : 25),

                          // Register Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: isSmallScreen ? 13 : 14,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const Register(),
                                    ),
                                  );
                                },
                                child: ShaderMask(
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
                                  child: Text(
                                    'Register',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 14 : 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isSmallScreen ? 15 : 20),

                          // Info Text
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 10 : 20,
                            ),
                            child: Text(
                              AppMessages.rememberEmail,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 11 : 12,
                                color: Colors.grey.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                          SizedBox(height: size.height * 0.02),
                        ],
                      ),
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
