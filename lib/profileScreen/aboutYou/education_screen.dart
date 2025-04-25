import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pairfect/profileScreen/aboutYou/add_Education_screen.dart';

import '../../controllers/auth_controllers.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  final AuthController _authController = Get.find();
  @override
  Widget build(BuildContext context) {
    _authController.fetchEducation();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: const Text("Education"),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "First education is only shown on profile",
              style: TextStyle(fontSize: 24),
            ),

            const SizedBox(height: 20),
            GestureDetector(
              onTap: () async {
                if(_authController.edu.length < 5) {
                  final result = await Get.to(() => const AddEducationScreen());
                  if (result == true) {
                    _authController.fetchEducation();
                  }
                }
                else{
                  AlertDialog alert = AlertDialog(
                    title: Text("Error!"),
                    content: Text("You can only add 5 education at once "),
                    actions: [

                      TextButton(onPressed: (){
                        Navigator.pop(context);
                      }, child: Text("Ok"))
                    ],
                  );
                  showDialog(context: context, builder: (BuildContext context){
                    return alert;
                  });
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Add education",
                    style: TextStyle(fontSize: 20),
                  ),
                  Icon(Icons.arrow_forward_ios_outlined)
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Obx(() {
                if (_authController.edu.isEmpty) {
                  return const Center(child: Text("No education available"));
                }

                return ListView.builder(
                  itemCount: _authController.edu.length,
                  itemBuilder: (context, index) {
                    final educ = _authController.edu[index];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            blurRadius: 5,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Institution: ${educ['institution']}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text("Year: ${educ['year']}"),
                            ],
                          ),
                          Row(
                            children: [

                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  await _authController.deleteUserEducation(index);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );  }
}
