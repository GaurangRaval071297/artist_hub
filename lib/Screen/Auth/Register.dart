import 'dart:io';

import 'package:artist_hub/Constants/api_urls.dart';
import 'package:artist_hub/Screen/Auth/Login.dart';
import 'package:artist_hub/Services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:artist_hub/Constants/app_colors.dart';
import 'package:image_picker/image_picker.dart';
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
  TextEditingController role_Controller = TextEditingController();
  String selectedRole = "Customer";
  List<String> roles = ["Customer", "Artist"];

  bool _password = true;
  bool _confirmPassword = true;
  File? selectedImage;

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
      showAlert("Please enter name");
    } else if (email_Controller.text.isEmpty) {
      showAlert("Please enter email");
    } else if (password_Controller.text.isEmpty) {
      showAlert("Please enter password");
    } else if (confmPassword_Controller.text.isEmpty) {
      showAlert("Please enter confirm password");
    } else if (password_Controller.text != confmPassword_Controller.text) {
      showAlert("Password & Confirm Password do not match");
    } else if (phone_Controller.text.isEmpty) {
      showAlert("Please enter mobile number");
    } else if (address_Controller.text.isEmpty) {
      showAlert("Please enter address");
    } else if (selectedRole.isEmpty) {
      showAlert("Please select role");
    } else if (selectedImage == null) {
      showAlert("Please select image");
    } else if (selectedImage != null) {
      registerUser();
    }
  }

  Future<void> registerUser() async {
    Map<String, String> data = {
      "name": name_Controller.text,
      "email": email_Controller.text,
      "password": password_Controller.text,
      "phone": phone_Controller.text,
      "address": address_Controller.text,
      "role": selectedRole,
    };
    var response = await ApiServices.multipartApi(
      url: ApiUrls.registerUrl,
      fields: data,
      file: selectedImage,
      fileField: "profile_pic",
    );
    print(response);
    if (response["status"] == "success") {
      showAlert("Registration Success");
    } else {
      showAlert(response["message"].toString());
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
          decoration: BoxDecoration(gradient: AppColors.appBarGradient),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: .center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 32),
                Stack(
                  children: [
                    CircleAvatar(
                      backgroundImage: selectedImage != null
                          ? FileImage(selectedImage!)
                          : AssetImage('assets/default_img.jpeg'),
                      radius: 50,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: showImagePickerOptions,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 28,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: CommonTextfields(
                    keyboardType: TextInputType.name,
                    controller: name_Controller,
                    hintText: 'Enter Name',
                    inputAction: TextInputAction.next,
                    preFixIcon: Icon(Icons.person),
                  ),
                ),

                // EMAIL FIELD
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: CommonTextfields(
                    keyboardType: TextInputType.emailAddress,
                    controller: email_Controller,
                    hintText: 'Enter Email',
                    inputAction: TextInputAction.next,
                    preFixIcon: Icon(Icons.email_outlined),
                  ),
                ),

                // PASSWORD FIELD
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: CommonTextfields(
                    keyboardType: TextInputType.visiblePassword,
                    controller: password_Controller,
                    hintText: 'Enter Password',
                    obsureText: _password,
                    inputAction: TextInputAction.done,
                    sufFixIcon: IconButton(
                      icon: Icon(
                        _password ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () => setState(() {
                        _password = !_password;
                      }),
                    ),
                  ),
                ),

                // CONFIRM PASSWORD FIELD
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: CommonTextfields(
                    keyboardType: TextInputType.visiblePassword,
                    controller: confmPassword_Controller,
                    hintText: 'Enter Confirm Password',
                    obsureText: _confirmPassword,
                    inputAction: TextInputAction.done,
                    sufFixIcon: IconButton(
                      icon: Icon(
                        _confirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () => setState(() {
                        _confirmPassword = !_confirmPassword;
                      }),
                    ),
                  ),
                ),

                // PHONE FIELD
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: CommonTextfields(
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    controller: phone_Controller,
                    hintText: 'Enter Mobile Number',
                    inputAction: TextInputAction.done,
                    preFixIcon: Icon(Icons.call),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: CommonTextfields(
                    keyboardType: TextInputType.streetAddress,
                    maxLength: 50,
                    controller: address_Controller,
                    hintText: 'Enter Address',
                    inputAction: TextInputAction.done,
                    preFixIcon: Icon(Icons.call),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedRole,
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

                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Login()),
                    );
                  },
                  child: const Text(
                    "Already have an account? Login",
                    style: TextStyle(color: Colors.white),
                  ),
                ),

                ElevatedButton(
                  onPressed: validateFields,
                  child: const Text(
                    'Register',
                    style: TextStyle(color: Colors.black),
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
