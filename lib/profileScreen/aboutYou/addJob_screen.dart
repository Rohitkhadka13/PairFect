import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controllers.dart';

class AddjobScreen extends StatefulWidget {
  const AddjobScreen({super.key});

  @override
  State<AddjobScreen> createState() => _AddjobScreenState();
}

class _AddjobScreenState extends State<AddjobScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final AuthController _authController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text("Add job"),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios)),
        actions: [
          IconButton(
              onPressed: () {
                final title = _titleController.text.trim();
                final company = _companyController.text.trim();

                if (title.isEmpty || company.isEmpty) {
                  Get.snackbar("Error", "Title and Company cannot be empty");
                  return;
                }

                _authController.addJob(title, company);
                Navigator.pop(context, true);
              },
              icon: Icon(
                Icons.check_rounded,
                size: 25,
              ))
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: "Title",
                hintStyle: TextStyle(fontWeight: FontWeight.bold),
                filled: true,
                fillColor: Colors.grey[200],
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            TextField(
              controller: _companyController,
              decoration: InputDecoration(
                hintText: "Company (or industry)",
                hintStyle: TextStyle(fontWeight: FontWeight.bold),
                filled: true,
                fillColor: Colors.grey[200],
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
