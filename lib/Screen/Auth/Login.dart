import 'package:flutter/material.dart';
import 'package:artist_hub/Constants/api_urls.dart';
import 'package:artist_hub/Constants/app_colors.dart';
import 'package:artist_hub/Screen/Auth/Register.dart';
import 'package:artist_hub/Services/api_services.dart';
import 'package:artist_hub/Widgets/Common%20Textfields/common_textfields.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
  bool _isGoogleLoading = false;
  String? _selectedRole;
  final List<String> _roles = ['artist', 'customer'];
  late final GoogleSignIn _googleSignIn;

  @override
  void initState() {
    super.initState();
    _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
    _loadSavedUserData();
  }

  Future<void> _loadSavedUserData() async {
    try {
      String savedEmail = SharedPreferencesService.getUserEmail();
      String savedRole = SharedPreferencesService.getUserRole();
      print("=== LOADING SAVED USER DATA ===");
      print("Saved Email: $savedEmail");
      print("Saved Role: $savedRole");
      print("================================");

      if (mounted) {
        setState(() {
          email.text = savedEmail;
          if (savedRole.isNotEmpty && _roles.contains(savedRole)) {
            _selectedRole = savedRole;
          }
        });
      }
    } catch (e) {
      print("Error loading saved user data: $e");
    }
  }

  void showAlert(String msg) {
    print("Alert Dialog: $msg");
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

  Future<void> signInWithGoogle() async {
    print("=== GOOGLE SIGN IN STARTED ===");
    print("Selected Role: $_selectedRole");

    if (_selectedRole == null) {
      showAlert("Please select a role (Artist or Customer)");
      return;
    }

    setState(() {
      _isGoogleLoading = true;
    });

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print("Google sign in cancelled by user");
        setState(() {
          _isGoogleLoading = false;
        });
        showAlert("Google sign in cancelled");
        return;
      }

      print("=== GOOGLE USER DATA ===");
      print("User ID: ${googleUser.id}");
      print("Display Name: ${googleUser.displayName}");
      print("Email: ${googleUser.email}");
      print("Photo URL: ${googleUser.photoUrl}");
      print("=========================");

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      Map<String, dynamic> userData = {
        'id': googleUser.id,
        'name': googleUser.displayName ?? '',
        'email': googleUser.email,
        'role': _selectedRole,
        'profile_pic': googleUser.photoUrl ?? '',
        'provider': 'google',
        'phone': '',
        'address': '',
      };

      print("=== USER DATA TO SAVE ===");
      userData.forEach((key, value) {
        print("$key: $value");
      });
      print("=========================");

      await SharedPreferencesService.saveUserData(userData);

      print("=== AFTER SAVING TO SHARED PREFERENCES ===");
      SharedPreferencesService.printAllData();

      setState(() {
        _isGoogleLoading = false;
      });

      print("Google Login Successful! Navigating...");
      showAlert("Google Login Successful!");

      await Future.delayed(const Duration(milliseconds: 1500));
      Navigator.of(context, rootNavigator: true).pop();

      if (_selectedRole == 'artist') {
        print("Navigating to Artist Dashboard");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ArtistDashboard()),
              (route) => false,
        );
      } else {
        print("Navigating to Customer Dashboard");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const CustomerDashboard()),
              (route) => false,
        );
      }
    } catch (e) {
      setState(() {
        _isGoogleLoading = false;
      });
      print("=== GOOGLE SIGN IN ERROR ===");
      print("Error Type: ${e.runtimeType}");
      print("Error Message: ${e.toString()}");
      print("============================");

      String errorMessage = "Google login failed";
      if (e.toString().contains('sign_in_failed')) {
        errorMessage = "Google Sign-In failed. Please check your Google Play Services.";
      } else if (e.toString().contains('network_error')) {
        errorMessage = "Network error. Please check your internet connection.";
      } else if (e.toString().contains('developer_error')) {
        errorMessage = "Developer error. App not configured for Google Sign-In.";
      } else if (e.toString().contains('PlatformException')) {
        errorMessage = "Platform error. Please try again.";
      }
      showAlert("$errorMessage\n\nError details: ${e.toString()}");
    }
  }

  void validateLogin() async {
    print("=== VALIDATE LOGIN ===");
    print("Email: ${email.text}");
    print("Password: ${password.text}");
    print("Selected Role: $_selectedRole");

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
    print("=== LOGIN USER STARTED ===");
    print("API URL: ${ApiUrls.loginUrl}");
    print("Login Data:");
    print("- Email: ${email.text}");
    print("- Password: [HIDDEN]");
    print("- Role: ${_selectedRole ?? ''}");

    setState(() {
      _isLoading = true;
    });

    Map<String, dynamic> data = {
      "email": email.text,
      "password": password.text,
      "role": _selectedRole ?? '',
    };

    try {
      print("Sending API request...");
      var response = await ApiServices.postApi(ApiUrls.loginUrl, data);

      print("=== API RESPONSE ===");
      print("Full Response: $response");
      print("Status: ${response["status"]}");
      print("Code: ${response["code"]}");
      print("Message: ${response["message"]}");

      setState(() {
        _isLoading = false;
      });

      if (response["status"] == true || response["code"] == 200) {
        var registerModel = RegisterModel.fromJson(response);

        if (registerModel.user != null) {
          print("=== USER DATA FROM API ===");
          print("User ID: ${registerModel.user!.userId}");
          print("Name: ${registerModel.user!.name}");
          print("Email: ${registerModel.user!.email}");
          print("Role: ${registerModel.user!.role}");
          print("Phone: ${registerModel.user!.phone}");
          print("Address: ${registerModel.user!.address}");
          print("Profile Pic: ${registerModel.user!.profilePic}");
          print("Artist ID: ${registerModel.user!.artistId}");
          print("===========================");

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

          print("=== SAVING TO SHARED PREFERENCES ===");
          await SharedPreferencesService.saveUserData(userData);

          print("=== AFTER SAVING DATA ===");
          SharedPreferencesService.printAllData();

          String userRole = registerModel.user!.role?.toLowerCase() ?? 'customer';

          print("Login Successful! Role: $userRole");
          showAlert("Login Successful");

          await Future.delayed(const Duration(milliseconds: 1500));
          Navigator.of(context, rootNavigator: true).pop();

          if (userRole == 'artist') {
            print("Navigating to Artist Dashboard");
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const ArtistDashboard()),
                  (route) => false,
            );
          } else {
            print("Navigating to Customer Dashboard");
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const CustomerDashboard()),
                  (route) => false,
            );
          }
        } else {
          print("ERROR: User data not found in response");
          showAlert("User data not found in response");
        }
      } else {
        print("Login failed: ${response["message"] ?? "No message"}");
        showAlert(response["message"] ?? "Login failed");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      print("=== LOGIN ERROR ===");
      print("Error Type: ${e.runtimeType}");
      print("Error Message: ${e.toString()}");
      print("====================");

      showAlert("Connection error: Please check your internet and server connection");
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
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      Text(
                        "Welcome Back",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
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
                        const SizedBox(height: 20),
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[100],
                            border: GradientBoxBorder(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.appBarGradient.colors[0].withOpacity(0.9),
                                  AppColors.appBarGradient.colors[1].withOpacity(0.7),
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
                        const SizedBox(height: 5),
                        Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 30),
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
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: DropdownButtonFormField<String>(
                                      value: _selectedRole,
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedRole = newValue;
                                          print("Role changed to: $newValue");
                                        });
                                      },
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        prefixIcon: Icon(
                                          Icons.person_outline,
                                          color: AppColors.grey600,
                                        ),
                                        hintText: 'Select Role',
                                        hintStyle: TextStyle(color: Colors.grey[500]),
                                      ),
                                      items: _roles.map((String role) {
                                        return DropdownMenuItem<String>(
                                          value: role,
                                          child: Text(
                                            role == 'artist' ? 'Artist' : 'Customer',
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
                                const SizedBox(height: 15),
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
                                const SizedBox(height: 15),
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
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                        print("Password visibility toggled: $_obscurePassword");
                                      });
                                    },
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      print("Forgot Password clicked");
                                      showAlert("Forgot Password feature coming soon!");
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
                        const SizedBox(height: 30),
                        Container(
                          height: 50,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            gradient: LinearGradient(
                              colors: [
                                AppColors.appBarGradient.colors[0].withOpacity(0.9),
                                AppColors.appBarGradient.colors[1].withOpacity(0.7),
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
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Colors.white),
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
                        const SizedBox(height: 25),
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey[300])),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                'Or continue with',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.grey[300])),
                          ],
                        ),
                        const SizedBox(height: 25),
                        Container(
                          height: 50,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: Colors.grey[300]!, width: 1),
                            color: Colors.white,
                          ),
                          child: ElevatedButton(
                            onPressed: _isGoogleLoading ? null : signInWithGoogle,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 0,
                            ),
                            child: _isGoogleLoading
                                ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                const AlwaysStoppedAnimation<Color>(Colors.blue),
                              ),
                            )
                                : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.g_mobiledata,
                                  size: 24,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Continue with Google',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
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
                                    AppColors.appBarGradient.colors[0].withOpacity(0.9),
                                    AppColors.appBarGradient.colors[1].withOpacity(0.7),
                                  ],
                                ).createShader(
                                  Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                                );
                              },
                              child: GestureDetector(
                                onTap: () {
                                  print("Navigate to Register screen");
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => Register()),
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
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            "Note: Your email will be remembered for next login.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
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