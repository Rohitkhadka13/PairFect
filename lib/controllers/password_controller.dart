import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PasswordController extends GetxController{
  var isPasswordVisible = false.obs;
  var passwordIcon = Icons.visibility_off.obs;

  void toggleVisibility(){
    isPasswordVisible.toggle();
    passwordIcon.value = isPasswordVisible.value ? Icons.visibility : Icons.visibility_off;
  }
}