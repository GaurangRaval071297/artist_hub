import 'package:artist_hub/Constants/app_colors.dart';
import 'package:artist_hub/Screen/Auth/Register.dart';
import 'package:artist_hub/Widgets/Common%20Textfields/common_textfields.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: AppColors.appBarGradient,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: .center,
            children: [
              SizedBox(height: 125),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: CommonTextfields(
                  keyboardType: TextInputType.emailAddress,
                  controller: email,
                  hintText: 'Enter Email',
                  inputAction: .next,
                  preFixIcon: Icon(Icons.email_outlined),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: CommonTextfields(
                  keyboardType: TextInputType.visiblePassword,
                  controller: password,
                  hintText: 'Enter Password',
                  obsureText: _obscurePassword,
                  inputAction: .done,
                  sufFixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              TextButton(onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Register()));
              }, child: const Text("Don't have an account? Join Us", style: TextStyle(color: Colors.white),))
            ],
          ),
        ),
      ),
    );
  }
}
