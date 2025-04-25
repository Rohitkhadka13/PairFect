import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controllers.dart';

class AddEducationScreen extends StatefulWidget {
  const AddEducationScreen({super.key});

  @override
  State<AddEducationScreen> createState() => _AddEducationScreenState();
}

class _AddEducationScreenState extends State<AddEducationScreen> {
  final TextEditingController _institutionController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final AuthController _authController = Get.find();

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text("Add education"),
        leading: IconButton( onPressed: () {
          Navigator.pop(context);

        }, icon: Icon(Icons.arrow_back_ios)),
        actions: [
          IconButton(onPressed: (){
            final institution = _institutionController.text.trim();
            final year = _yearController.text.trim();

            if (institution.isEmpty || year.isEmpty) {
              Get.snackbar("Error", "institution and year cannot be empty");
              return;
            }

            _authController.addEducation(institution, year);
            Navigator.pop(context, true);
          }, icon: Icon(Icons.check_rounded, size: 25,))
        ],
      ),
      body: Padding(padding: EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _institutionController,
              decoration: InputDecoration(
                hintText:"Institution",
                hintStyle: TextStyle(
                    fontWeight: FontWeight.bold
                ),
                filled: true,
                fillColor: Colors.grey[200],
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                      color: Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                      color: Colors.transparent),
                ),

              ),
            ),
            SizedBox(height: 15,),
            TextField(
              keyboardType: TextInputType.number,
              controller: _yearController,
              decoration: InputDecoration(
                hintText:"Graduation Year ",
                hintStyle: TextStyle(
                    fontWeight: FontWeight.bold
                ),

                filled: true,
                fillColor: Colors.grey[200],
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                      color: Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                      color: Colors.transparent),
                ),

              ),
            ),
          ],
        ),
      ),

    );
  }
}
