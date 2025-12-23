import 'dart:convert';
import 'dart:io';
import 'package:artist_hub/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Shared/Constants/api_urls.dart';
import '../Shared/Constants/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:artist_hub/Shared/widgets/common_textfields/common_textfields.dart';
import 'package:artist_hub/shared/constants/custom_dialog.dart';

import '../models/register_model.dart';
import '../shared/preferences/shared_preferences.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  // Store both display value and API value
  String selectedRoleDisplay = "Customer";
  String selectedRoleApi = "customer";
  List<String> roles = ["Customer", "Artist"];
  bool _password = true;
  bool _confirmPassword = true;
  bool _isLoading = false;

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

  void validateFields() {
    if (nameController.text.isEmpty) {
      showAlert("Alert", "Please Enter Name");
    } else if (emailController.text.isEmpty) {
      showAlert("Alert", "Please Enter Email");
    } else if (!RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(emailController.text)) {
      showAlert("Alert", "Please Enter Valid Email");
    } else if (passwordController.text.isEmpty) {
      showAlert("Alert", "Please Enter Password");
    } else if (passwordController.text.length < 6) {
      showAlert("Alert", "Password must be at least 6 characters");
    } else if (confirmPasswordController.text.isEmpty) {
      showAlert("Alert", "Please Enter Confirm Password");
    } else if (passwordController.text != confirmPasswordController.text) {
      showAlert("Alert", "Password & Confirm Password Do Not Match");
    } else if (phoneController.text.isEmpty) {
      showAlert("Alert", "Please Enter Mobile Number");
    } else if (!RegExp(r'^[0-9]{10}$').hasMatch(phoneController.text)) {
      showAlert("Alert", "Please Enter Valid 10-digit Phone Number");
    } else if (addressController.text.isEmpty) {
      showAlert("Alert", "Please Enter Address");
    } else if (selectedRoleDisplay.isEmpty) {
      showAlert("Alert", "Please Select Role");
    } else {
      _registerUser();
    }
  }

  void _registerUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse(ApiUrls.registerUrl);
      final request = http.MultipartRequest('POST', url);

      // Add text fields
      request.fields['name'] = nameController.text.trim();
      request.fields['email'] = emailController.text.trim();
      request.fields['password'] = passwordController.text.trim();
      request.fields['phone'] = phoneController.text.trim();
      request.fields['address'] = addressController.text.trim();
      request.fields['role'] = selectedRoleApi;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final registerModel = RegisterModel.fromJson(responseData);

        if (registerModel.status == true) {
          showAlert(
            "Success",
            registerModel.message ?? "Registration Successful!",
            isSuccess: true,
          );

          // Save user data to SharedPreferences
          if (registerModel.user != null) {
            final user = registerModel.user!;

            await SharedPreferencesHelper.setUserEmail(
              user.email ?? emailController.text,
            );
            await SharedPreferencesHelper.setUserType(
              user.role ?? selectedRoleApi,
            );
            await SharedPreferencesHelper.setUserLoggedIn(true);
            await SharedPreferencesHelper.setUserName(
              user.name ?? nameController.text,
            );

            // Save profile image URL if provided by server
            if (user.profilePic != null && user.profilePic!.isNotEmpty) {
              await SharedPreferencesHelper.setUserProfilePic(user.profilePic!);
            }
          }

          // Navigate to login screen after 2 seconds
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          });
        } else {
          showAlert("Error", registerModel.message ?? "Registration failed");
        }
      } else {
        showAlert("Error", "Server error: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Registration Error: $e');
      showAlert("Error", "Network error: $e");
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
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Fill in your details to get started",
                        style: TextStyle(
                          fontSize: 16,
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
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),

                        // Form Fields Container
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
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
                                // Name Field
                                CommonTextfields(
                                  keyboardType: TextInputType.name,
                                  controller: nameController,
                                  hintText: 'Full Name',
                                  inputAction: TextInputAction.next,
                                  preFixIcon: Icon(
                                    Icons.person_outline,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 15),

                                // Email Field
                                CommonTextfields(
                                  keyboardType: TextInputType.emailAddress,
                                  controller: emailController,
                                  hintText: 'Email Address',
                                  inputAction: TextInputAction.next,
                                  preFixIcon: const Icon(
                                    Icons.email_outlined,
                                    color: AppColors.grey600,
                                  ),
                                ),
                                const SizedBox(height: 15),

                                // Password Field
                                CommonTextfields(
                                  keyboardType: TextInputType.visiblePassword,
                                  controller: passwordController,
                                  hintText: 'Password',
                                  obsureText: _password,
                                  inputAction: TextInputAction.next,
                                  preFixIcon: const Icon(
                                    Icons.lock_outline,
                                    color: AppColors.grey600,
                                  ),
                                  sufFixIcon: IconButton(
                                    icon: Icon(
                                      _password
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: AppColors.grey600,
                                    ),
                                    onPressed: () => setState(() {
                                      _password = !_password;
                                    }),
                                  ),
                                ),
                                const SizedBox(height: 15),

                                // Confirm Password Field
                                CommonTextfields(
                                  keyboardType: TextInputType.visiblePassword,
                                  controller: confirmPasswordController,
                                  hintText: 'Confirm Password',
                                  obsureText: _confirmPassword,
                                  inputAction: TextInputAction.next,
                                  preFixIcon: const Icon(
                                    Icons.lock_outline,
                                    color: AppColors.grey600,
                                  ),
                                  sufFixIcon: IconButton(
                                    icon: Icon(
                                      _confirmPassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: AppColors.grey600,
                                    ),
                                    onPressed: () => setState(() {
                                      _confirmPassword = !_confirmPassword;
                                    }),
                                  ),
                                ),
                                const SizedBox(height: 15),

                                // Phone Field
                                CommonTextfields(
                                  keyboardType: TextInputType.phone,
                                  maxLength: 10,
                                  controller: phoneController,
                                  hintText: 'Phone Number',
                                  inputAction: TextInputAction.next,
                                  preFixIcon: const Icon(
                                    Icons.phone_outlined,
                                    color: AppColors.grey600,
                                  ),
                                ),
                                const SizedBox(height: 15),

                                // Address Field
                                CommonTextfields(
                                  keyboardType: TextInputType.streetAddress,
                                  controller: addressController,
                                  hintText: 'Address',
                                  inputAction: TextInputAction.next,
                                  preFixIcon: const Icon(
                                    Icons.location_on_outlined,
                                    color: AppColors.grey600,
                                  ),
                                ),
                                const SizedBox(height: 15),

                                // Role Dropdown
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: selectedRoleDisplay,
                                        isExpanded: true,
                                        icon: Icon(
                                          Icons.arrow_drop_down,
                                          color: Colors.grey[600],
                                        ),
                                        items: roles.map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            selectedRoleDisplay = value!;
                                            // Convert to lowercase for API
                                            selectedRoleApi = value
                                                .toLowerCase();
                                            print(
                                              "Selected role (display): $selectedRoleDisplay",
                                            );
                                            print(
                                              "Selected role (API): $selectedRoleApi",
                                            );
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Register Button
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
                            onPressed: _isLoading ? null : validateFields,
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
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                    ),
                                  )
                                : const Text(
                                    'Create Account',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Login Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account?  ",
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
                                      builder: (context) => const LoginScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
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
