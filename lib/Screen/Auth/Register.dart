import 'dart:convert';
import 'dart:io';
import 'package:artist_hub/Constants/api_urls.dart';
import 'package:artist_hub/Screen/Auth/Login.dart';
import 'package:artist_hub/Services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:artist_hub/Constants/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import '../../Models/register_model.dart';
import '../../Widgets/Common Textfields/common_textfields.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController name_Controller = TextEditingController();
  TextEditingController email_Controller = TextEditingController();
  TextEditingController password_Controller = TextEditingController();
  TextEditingController confmPassword_Controller = TextEditingController();
  TextEditingController phone_Controller = TextEditingController();
  TextEditingController address_Controller = TextEditingController();
  String selectedRole = "Customer";
  List<String> roles = ["Customer", "Artist"];

  final List<RegisterModel> _register = [];

  bool _password = true;
  bool _confirmPassword = true;
  File? selectedImage;
  bool _isLoading = false;

  void showAlert(String msg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Alert", textAlign: TextAlign.center),
        content: Text(msg, textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  void validateFields() {
    if (name_Controller.text.isEmpty) {
      showAlert("Please Enter Name");
    } else if (email_Controller.text.isEmpty) {
      showAlert("Please Enter Email");
    } else if (password_Controller.text.isEmpty) {
      showAlert("Please Enter Password");
    } else if (confmPassword_Controller.text.isEmpty) {
      showAlert("Please Enter Confirm Password");
    } else if (password_Controller.text != confmPassword_Controller.text) {
      showAlert("Password & Confirm Password Do Not Match");
    } else if (phone_Controller.text.isEmpty) {
      showAlert("Please Enter Mobile Number");
    } else if (address_Controller.text.isEmpty) {
      showAlert("Please Enter Address");
    } else if (selectedRole.isEmpty) {
      showAlert("Please Eelect Role");
    } else if (selectedImage == null) {
      showAlert("Please Select Image");
    } else if (selectedImage != null) {
      registerUser();
    }
  }

  Future<void> registerUser() async {
    setState(() {
      _isLoading = true;
    });

    Map<String, String> data = {
      "name": name_Controller.text,
      "email": email_Controller.text,
      "password": password_Controller.text,
      "phone": phone_Controller.text,
      "address": address_Controller.text,
      "role": selectedRole,
    };

    try {
      var response = await ApiServices.multipartApi(
        url: ApiUrls.registerUrl,
        fields: data,
        file: selectedImage,
        fileField: "profile_pic",
      );

      print(response);
      RegisterModel registerModel = RegisterModel.fromJson(response);
      print(registerModel.status);
      print(registerModel.message);

      if (registerModel.status == true) {
        showAlert("Registration Successful");

        Future.delayed(Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Login()),
          );
        });
      } else {
        showAlert(registerModel.message ?? "Something went wrong");
      }
    } catch (e) {
      showAlert("Registration failed. Please try again.");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text("Camera"),
                onTap: () {
                  pickImage(ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo),
                title: Text("Gallery"),
                onTap: () {
                  pickImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source);
    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
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
                AppColors.primaryColor,
                AppColors.primaryColor.withOpacity(0.8),
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
                        "Create Account",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),
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
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        SizedBox(height: 20),

                        // Profile Image
                        Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[200],
                                border: Border.all(
                                  color: AppColors.primaryColor,
                                  width: 2,
                                ),
                              ),
                              child: ClipOval(
                                child: selectedImage != null
                                    ? Image.file(
                                        selectedImage!,
                                        fit: BoxFit.cover,
                                      )
                                    : Icon(
                                        Icons.person,
                                        size: 50,
                                        color: Colors.grey[500],
                                      ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: showImagePickerOptions,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primaryColor,
                                  ),
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Add Profile Photo",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        SizedBox(height: 30),

                        // Form Fields
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
                                  controller: name_Controller,
                                  hintText: 'Full Name',
                                  inputAction: TextInputAction.next,
                                  preFixIcon: Icon(
                                    Icons.person_outline,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 15),

                                // Email Field
                                CommonTextfields(
                                  keyboardType: TextInputType.emailAddress,
                                  controller: email_Controller,
                                  hintText: 'Email Address',
                                  inputAction: TextInputAction.next,
                                  preFixIcon: Icon(
                                    Icons.email_outlined,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 15),

                                // Password Field
                                CommonTextfields(
                                  keyboardType: TextInputType.visiblePassword,
                                  controller: password_Controller,
                                  hintText: 'Password',
                                  obsureText: _password,
                                  inputAction: TextInputAction.next,
                                  preFixIcon: Icon(
                                    Icons.lock_outline,
                                    color: Colors.grey[600],
                                  ),
                                  sufFixIcon: IconButton(
                                    icon: Icon(
                                      _password
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.grey[600],
                                    ),
                                    onPressed: () => setState(() {
                                      _password = !_password;
                                    }),
                                  ),
                                ),
                                SizedBox(height: 15),

                                // Confirm Password Field
                                CommonTextfields(
                                  keyboardType: TextInputType.visiblePassword,
                                  controller: confmPassword_Controller,
                                  hintText: 'Confirm Password',
                                  obsureText: _confirmPassword,
                                  inputAction: TextInputAction.next,
                                  preFixIcon: Icon(
                                    Icons.lock_outline,
                                    color: Colors.grey[600],
                                  ),
                                  sufFixIcon: IconButton(
                                    icon: Icon(
                                      _confirmPassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.grey[600],
                                    ),
                                    onPressed: () => setState(() {
                                      _confirmPassword = !_confirmPassword;
                                    }),
                                  ),
                                ),
                                SizedBox(height: 15),

                                // Phone Field
                                CommonTextfields(
                                  keyboardType: TextInputType.phone,
                                  maxLength: 10,
                                  controller: phone_Controller,
                                  hintText: 'Phone Number',
                                  inputAction: TextInputAction.next,
                                  preFixIcon: Icon(
                                    Icons.phone_outlined,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 15),

                                // Address Field
                                CommonTextfields(
                                  keyboardType: TextInputType.streetAddress,
                                  controller: address_Controller,
                                  hintText: 'Address',
                                  inputAction: TextInputAction.next,
                                  preFixIcon: Icon(
                                    Icons.location_on_outlined,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 15),

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
                                        value: selectedRole,
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
                                            selectedRole = value!;
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

                        SizedBox(height: 30),

                        // Register Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : validateFields,
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
                                    'Create Account',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),

                        SizedBox(height: 20),

                        // Login Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account? ",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Login(),
                                  ),
                                );
                              },
                              child: Text(
                                "Login",
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
