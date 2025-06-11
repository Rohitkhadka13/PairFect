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
      body: SingleChildScrollView(
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 120),
                Image.asset(
                  "assets/images/logo1.png",
                  width: 200,
                ),
                const Text(
                  "Welcome",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "Login now To Find Your Best Match",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Email
                SizedBox(
                  width: MediaQuery.of(context).size.width - 36,
                  height: 60,
                  child: CustomTextFieldWidget(
                    editingController: emailTextEditingController,
                    labelText: "Email",
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
                ),
                const SizedBox(height: 20),

                // Password
                SizedBox(
                  width: MediaQuery.of(context).size.width - 36,
                  height: 60,
                  child: CustomTextFieldWidget(
                    editingController: passwordTextEditingController,
                    labelText: "Password",
                    isObscure: true,
                    iconData: Icons.lock,
                    iconData1: Icons.visibility_off,
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
                ),
                const SizedBox(height: 20),

                // Login Button
                Container(
                  width: MediaQuery.of(context).size.width - 36,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(12),
                    ),
                  ),
                  child: InkWell(
                    onTap: () async {
                      // Validate the form
                      if (_formKey.currentState!.validate()) {
                        String email = emailTextEditingController.text.trim();
                        String password =
                            passwordTextEditingController.text.trim();

                        setState(() {
                          showProgressBar = true;
                        });

                        try {
                          await authController.signIn(
                            email: email,
                            password: password,
                          );
                        } catch (e) {
                          rethrow;
                        } finally {
                          setState(() {
                            showProgressBar = false;
                          });
                        }
                      }
                    },
                    child: const Center(
                      child: Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an Account? ",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    InkWell(
                      onTap: () {
                        Get.to(() => const RegisterScreen());
                      },
                      child: const Text(
                        "Register Here",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // Progress Bar
                showProgressBar
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                      )
                    : Container(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
