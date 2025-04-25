import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controllers.dart';
import 'addJob_screen.dart';

class OccupationScreen extends StatelessWidget {
  final AuthController _authController = Get.find();

  OccupationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    _authController.fetchJob();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: const Text("Occupation"),
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
              "First job is only shown on profile",
              style: TextStyle(fontSize: 24),
            ),

            const SizedBox(height: 20),
            GestureDetector(
              onTap: () async {
                if(_authController.jobs.length < 5) {
                  final result = await Get.to(() => const AddjobScreen());
                  if (result == true) {
                    _authController.fetchJob();
                  }
                }else{

                  AlertDialog alert = AlertDialog(
                    title: Text("Error!"),
                    content: Text("You can only add 5 jobs at once "),
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
                    "Add a job",
                    style: TextStyle(fontSize: 20),
                  ),
                  Icon(Icons.arrow_forward_ios_outlined)
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Obx(() {
                if (_authController.jobs.isEmpty) {
                  return const Center(child: Text("No jobs available"));
                }

                return ListView.builder(
                  itemCount: _authController.jobs.length,
                  itemBuilder: (context, index) {
                    final job = _authController.jobs[index];
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
                                "Title: ${job['title']}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text("Company: ${job['company']}"),
                            ],
                          ),
                          Row(
                            children: [

                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  await _authController.deleteUserJob(index);
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
    );
  }
}
