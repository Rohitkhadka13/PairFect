import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pairfect/controllers/password_controller.dart';

class CustomTextFieldWidget extends StatelessWidget {
  final TextEditingController? editingController;
  final IconData? iconData;
  final String? asset;
  final String? labelText;
  final bool? isObscure;
  final IconData? iconData1;
  final TextInputType? keyboard;
  final String? Function(String?)? validator;

  const CustomTextFieldWidget({
    super.key,
    this.editingController,
    this.iconData,
    this.asset,
    this.labelText,
    this.isObscure,
    this.iconData1,
    this.keyboard,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final PasswordController passwordController = Get.find();

    return Obx(() {
      return TextFormField(
        controller: editingController,
        validator: validator,
        keyboardType: keyboard,
        obscureText: passwordController.isPasswordVisible.value ? false : (isObscure ?? false),
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: iconData != null
              ? Icon(iconData)
              : Padding(
            padding: EdgeInsets.all(8),
            child: Image.asset(asset.toString()),
          ),
          suffixIcon: isObscure == true
              ? IconButton(
            icon: Icon(
              passwordController.passwordIcon.value,
            ),
            onPressed: () {
              passwordController.toggleVisibility();
            },
          )
              : Icon(iconData1),
          labelStyle: const TextStyle(
            fontSize: 18,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(
              color: Colors.grey,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(
              color: Colors.grey,
            ),
          ),
        ),
      );
    });
  }
}