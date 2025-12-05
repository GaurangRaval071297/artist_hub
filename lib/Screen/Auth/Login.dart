import 'package:artist_hub/Constants/api_urls.dart';
import 'package:artist_hub/Constants/app_colors.dart';
import 'package:artist_hub/Screen/Auth/Register.dart';
import 'package:artist_hub/Services/api_services.dart';
import 'package:artist_hub/Widgets/Common%20Textfields/common_textfields.dart';
import 'package:flutter/material.dart';
// 10.240.82.105
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

  void validateLogin() {
    if (email.text.isEmpty) {
      showAlert("Please enter email");
    } else if (password.text.isEmpty) {
      showAlert("Please enter password");
    } else {
      // Add your login API call here
      loginUser();
    }
  }

  Future<void> loginUser() async {
    setState(() {
      _isLoading = true;
    });

    Map<String, String> data = {
      "email": email.text.trim(),
      "password": password.text,
    };

    try {
      var response = await ApiServices.postApi(ApiUrls.loginUrl, data);

      setState(() {
        _isLoading = false;
      });

      showAlert(response["message"].toString());

    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showAlert("Login failed. Please try again.");
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
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primaryColor.withOpacity(0.9),
                AppColors.primaryColor.withOpacity(0.7),
                Colors.white,
                Colors.white,
              ],
              //stops: [0, 0.3, 0.3, 1],
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
                            border: Border.all(
                              color: AppColors.primaryColor,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: AppColors.primaryColor,
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
                                // Email Field
                                CommonTextfields(
                                  keyboardType: TextInputType.emailAddress,
                                  controller: email,
                                  hintText: 'Email Address',
                                  inputAction: TextInputAction.next,
                                  preFixIcon: Icon(
                                    Icons.email_outlined,
                                    color: AppColors.primaryColor,
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
                                    color: AppColors.primaryColor,
                                  ),
                                  sufFixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.grey[600],
                                    ),
                                    onPressed: () => setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
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
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : validateLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 3,
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

                        // Register Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Register(),
                                  ),
                                );
                              },
                              child: Text(
                                "Register Now",
                                style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.bold,
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
