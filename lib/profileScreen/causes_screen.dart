import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controllers.dart';
import 'complete_profile.dart';

class CausesScreen extends StatefulWidget {
  const CausesScreen({super.key});

  @override
  State<CausesScreen> createState() => _CausesScreenState();
}

class _CausesScreenState extends State<CausesScreen> {
  final Map<String, List<String>> causesList = {
    "Causes and communities": [
      "Black Lives Matter",
      "Feminism",
      "Environmentalism",
      "Trans rights",
      "Disability rights",
      "Reproductive rights",
      "Indigenous rights",
      "Voter rights",
      "Human rights",
      "LGBTQ+ rights",
      "Neurodiversity",
      "Volunteering",
      "End religious hate"
    ]
  };

  List<String> causesSelection = [];
  final AuthController _authController = Get.find<AuthController>();

  @override
  void initState() {
    loadUserCauses();
    super.initState();
  }

  Future<void> loadUserCauses() async {
    final causes = await _authController.getUserCauses();
    setState(() {
      causesSelection = causes;
    });
  }

  void saveCauses() {
    if (causesSelection.isEmpty) {
      Get.snackbar("Error", "Please select at least one causes.");
      return;
    }
    _authController.saveUserCauses(causesSelection);
  }

  void toggleSelection(String causes) {
    setState(() {
      if (causesSelection.contains(causes)) {
        causesSelection.remove(causes);
      } else {
        if (causesSelection.length < 3) {
          causesSelection.add(causes);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFFAFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Causes and communities",
            style: TextStyle(color: Colors.black)),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Choose up to 3 options  close to your heart.",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            Expanded(
                child: ListView(
              children: causesList.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 20,
                      runSpacing: 15,
                      children: entry.value.map((causes) {
                        final isSelected = causesSelection.contains(causes);
                        return ChoiceChip(
                          label: Text(causes),
                          selected: isSelected,
                          selectedColor: Colors.black,
                          backgroundColor: Colors.grey[200],
                          labelStyle: TextStyle(
                            fontSize: 18,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                          onSelected: (_) => toggleSelection(causes),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }).toList(),
            )),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  saveCauses();
                  Get.to(() => CompleteProfile());
                },
                child: const Text(
                  "Save",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
