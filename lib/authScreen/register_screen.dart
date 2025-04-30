import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pairfect/controllers/auth_controllers.dart';
import 'package:pairfect/widgets/custom_text_field_widget.dart';

import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController dobTextEditingController = TextEditingController();
  bool showProgressBar = false;

  var authController = AuthController.authController;

  // Function to show the date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        dobTextEditingController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 100),
                const Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "to get Started Now",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                authController.pickedFile.value == null
                    ? CircleAvatar(
                  radius: 80,
                  backgroundImage:
                  AssetImage("assets/images/profile_avatar.jpg"),
                  backgroundColor: Colors.black,
                )
                    : Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: FileImage(
                        File(authController.pickedFile.value!.path),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await authController.pickImageFileFromGallery();
                    setState(() {
                      // Rebuild the widget after selecting the image
                    });
                  },
                  icon: Icon(
                    Icons.image_outlined,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 30),

                // First Name
                SizedBox(
                  width: MediaQuery.of(context).size.width - 36,
                  height: 60,
                  child: CustomTextFieldWidget(
                    editingController: nameTextEditingController,
                    labelText: "First name",
                    isObscure: false,
                    iconData: Icons.person,
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
                  ),
                ),
                const SizedBox(height: 20),

                // Date of Birth
                SizedBox(
                  width: MediaQuery.of(context).size.width - 36,
                  height: 60,
                  child: TextFormField(
                    controller: dobTextEditingController,
                    decoration: InputDecoration(
                      labelText: "Date of Birth",
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(context),
                  ),
                ),
                const SizedBox(height: 20),

                // Register Button
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
                      if (_formKey.currentState!.validate()) {
                        String name = nameTextEditingController.text.trim();
                        String email = emailTextEditingController.text.trim();
                        String password = passwordTextEditingController.text.trim();
                        String dob = dobTextEditingController.text.trim();

                        // Check if profile image is selected
                        if (authController.pickedFile.value == null) {
                          Get.snackbar("Error", "Please select a profile image");
                          return;
                        }

                        setState(() {
                          showProgressBar = true;
                        });

                        try {
                          // Call signup function
                          await authController.signup(
                            name: name,
                            email: email,
                            password: password,
                            dob: dob,
                            profileImage: authController.pickedFile.value!,
                            isProfileComplete: false,
                          );

                          // Clear the form fields
                          nameTextEditingController.clear();
                          emailTextEditingController.clear();
                          passwordTextEditingController.clear();
                          dobTextEditingController.clear();
                          authController.clearImage();

                          // Navigate to the login screen
                          Get.to(() => LoginScreen());
                        } catch (e) {
                          Get.snackbar(
                            "Error",
                            "Failed to register: $e",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        } finally {
                          setState(() {
                            showProgressBar = false;
                          });
                        }
                      }
                    },
                    child: const Center(
                      child: Text(
                        "Register",
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

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an Account? ",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: const Text(
                        "Login Here",
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
