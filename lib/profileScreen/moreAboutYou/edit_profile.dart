import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pairfect/profileScreen/profile_screen.dart';
import 'dart:io';

import '../../controllers/auth_controllers.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final authController = Get.put(AuthController());
  final TextEditingController nameController = TextEditingController();
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    authController.fetchName().then((value) {
      nameController.text = value ?? '';
    });
    authController.fetchUserImage().then((url) {
      authController.userImageUrl.value = url ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: () => authController.pickImageFileFromGallery(),
                child: Obx(() {
                  final localFile = authController.pickedFile.value;
                  final imageUrl = authController.userImageUrl.value;

                  return CircleAvatar(
                    radius: 60,
                    backgroundImage: localFile != null
                        ? FileImage(localFile)
                        : imageUrl.isNotEmpty
                        ? NetworkImage(imageUrl)
                        : const AssetImage('assets/images/profile_avatar.jpg')
                    as ImageProvider,
                    child: localFile == null && imageUrl.isEmpty
                        ? const Icon(Icons.camera_alt, size: 30)
                        : null,
                  );
                }),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  final currentPassword = currentPasswordController.text.trim();
                  final newPassword = newPasswordController.text.trim();

                  if (name.isEmpty || currentPassword.isEmpty || newPassword.isEmpty) {
                    Get.snackbar("Missing Info", "All fields are required.");
                    return;
                  }

                  authController.updateProfileWithPasswordCheck(
                    name: name,
                    currentPassword: currentPassword,
                    newPassword: newPassword,
                  );
                  Get.offAll(()=>ProfileScreen());
                },
                child: const Text("Save Changes"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
