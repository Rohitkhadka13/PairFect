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

  int calculateAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    if (currentDate.month < birthDate.month ||
        (currentDate.month == birthDate.month && currentDate.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
                primary: Color(0xFFFD6F96),
                onPrimary: Colors.white,
                onSurface: Color(0xFF6D6875)),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFFFD6F96),
              ),
            ),
          ),
          child: child!,
        );
      },
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
                SizedBox(height: 60),
                Text(
                  "Begin Your Love Story",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6D6875),
                    fontFamily: 'PlayfairDisplay',
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Create your account to start matching",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFFB5838D),
                  ),
                ),
                SizedBox(height: 32),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    authController.pickedFile.value == null
                        ? CircleAvatar(
                      radius: 80,
                      backgroundColor: Color(0xFFFD6F96).withOpacity(0.2),
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: Color(0xFFFD6F96),
                      ),
                    )
                        : Container(
                      width: 160,
                      height: 160,
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
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFFD6F96),
                      ),
                      child: IconButton(
                        onPressed: () async {
                          await authController.pickImageFileFromGallery();
                          setState(() {});
                        },
                        icon: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextFieldWidget(
                        editingController: nameTextEditingController,
                        labelText: "Your Name",
                        isObscure: false,
                        iconData: Icons.person_outline,
                      ),
                      SizedBox(height: 16),
                      CustomTextFieldWidget(
                        editingController: emailTextEditingController,
                        labelText: "Email Address",
                        isObscure: false,
                        iconData: Icons.email_outlined,
                      ),
                      SizedBox(height: 16),
                      CustomTextFieldWidget(
                        editingController: passwordTextEditingController,
                        labelText: "Password",
                        isObscure: true,
                        iconData: Icons.lock_outline,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: dobTextEditingController,
                        decoration: InputDecoration(
                          labelText: "Date of Birth",
                          labelStyle: TextStyle(color: Color(0xFF6D6875)),
                          prefixIcon: Icon(
                            Icons.calendar_today,
                            color: Color(0xFFB5838D),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 16,
                          ),
                        ),
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your date of birth';
                          }
                          try {
                            DateTime dob = DateFormat('yyyy-MM-dd').parse(value);
                            int age = calculateAge(dob);
                            if (age < 18) {
                              return 'You must be at least 18 years old';
                            }
                          } catch (e) {
                            return 'Invalid date format';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              if (dobTextEditingController.text.isNotEmpty) {
                                try {
                                  DateTime dob = DateFormat('yyyy-MM-dd')
                                      .parse(dobTextEditingController.text);
                                  int age = calculateAge(dob);
                                  if (age < 18) {
                                    Get.snackbar(
                                      "Age Restriction",
                                      "You must be at least 18 years old to register",
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Color(0xFFFD6F96),
                                      colorText: Colors.white,
                                    );
                                    return;
                                  }
                                } catch (e) {
                                  Get.snackbar(
                                    "Error",
                                    "Invalid date format",
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Color(0xFFFD6F96),
                                    colorText: Colors.white,
                                  );
                                  return;
                                }
                              }

                              if (authController.pickedFile.value == null) {
                                Get.snackbar(
                                  "Profile Image",
                                  "Please select a profile image",
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Color(0xFFFD6F96),
                                  colorText: Colors.white,
                                );
                                return;
                              }

                              setState(() {
                                showProgressBar = true;
                              });

                              try {
                                await authController.signup(
                                  name: nameTextEditingController.text.trim(),
                                  email: emailTextEditingController.text.trim(),
                                  password: passwordTextEditingController.text.trim(),
                                  dob: dobTextEditingController.text.trim(),
                                  profileImage: authController.pickedFile.value!,
                                  isProfileComplete: false,
                                );

                                nameTextEditingController.clear();
                                emailTextEditingController.clear();
                                passwordTextEditingController.clear();
                                dobTextEditingController.clear();
                                authController.clearImage();

                                Get.to(() => LoginScreen());
                              } catch (e) {
                                Get.snackbar(
                                  "Error",
                                  "Failed to register: $e",
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
                            "Create Account",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      TextButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: RichText(
                          text: TextSpan(
                            text: "Already have an account? ",
                            style: TextStyle(
                              color: Color(0xFF6D6875),
                            ),
                            children: [
                              TextSpan(
                                text: "Sign In",
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