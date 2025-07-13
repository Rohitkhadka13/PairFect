import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pairfect/authScreen/register_screen.dart';
import 'package:pairfect/controllers/auth_controllers.dart';
import 'package:pairfect/widgets/custom_text_field_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  bool showProgressBar = false;

  var authController = AuthController.authController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF9FB),
              Color(0xFFFFF0F3),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                SizedBox(height: 80),
                Image.asset(
                  "assets/images/logo1.png",
                  width: 180,
                ),
                SizedBox(height: 24),
                Text(
                  "Welcome Back",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6D6875),
                    fontFamily: 'PlayfairDisplay',
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Login to continue your love journey",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFFB5838D),
                  ),
                ),
                SizedBox(height: 40),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextFieldWidget(
                        editingController: emailTextEditingController,
                        labelText: "Email Address",
                        isObscure: false,
                        iconData: Icons.email_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your email";
                          }
                          if (!RegExp(
                              r'^[\w-]+(\.[\w-]+)*@([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,7}$')
                              .hasMatch(value)) {
                            return "Please enter a valid email";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      CustomTextFieldWidget(
                        editingController: passwordTextEditingController,
                        labelText: "Password",
                        isObscure: true,
                        iconData: Icons.lock_outline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your password";
                          }
                          if (value.length < 6) {
                            return "Password must be at least 6 characters";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: Color(0xFFFD6F96),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              String email = emailTextEditingController.text.trim();
                              String password = passwordTextEditingController.text.trim();

                              setState(() {
                                showProgressBar = true;
                              });

                              try {
                                await authController.signIn(
                                  email: email,
                                  password: password,
                                );
                              } catch (e) {
                                Get.snackbar(
                                  "Login Failed",
                                  e.toString(),
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Color(0xFFFD6F96),
                                  colorText: Colors.white,
                                );
                              } finally {
                                setState(() {
                                  showProgressBar = false;
                                });
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFD6F96),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: showProgressBar
                              ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 32),
                      TextButton(
                        onPressed: () {
                          Get.to(() => const RegisterScreen());
                        },
                        child: RichText(
                          text: TextSpan(
                            text: "Don't have an account? ",
                            style: TextStyle(
                              color: Color(0xFF6D6875),
                            ),
                            children: [
                              TextSpan(
                                text: "Register Here",
                                style: TextStyle(
                                  color: Color(0xFFFD6F96),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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