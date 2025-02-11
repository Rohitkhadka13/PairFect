import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controllers.dart';
import 'complete_profile.dart';

class QualitiesScreen extends StatefulWidget {
  const QualitiesScreen({super.key});

  @override
  State<QualitiesScreen> createState() => _QualitiesScreenState();
}

class _QualitiesScreenState extends State<QualitiesScreen> {


  final Map<String, List<String>> qualityList = {
    "Their qualities": [
      "Ambition",
      "Confidence",
      "Empathy",
      "Generosity",
      "Humor",
      "Kindness",
      "Openness",
      "Optimism",
      "Playfulness",
      "Sassiness",
      "Leadership",
      "Curiosity",
      "Gratitude",
      "Humility",
      "Loyalty",
      "Sarcasm",
      "Emotional Intelligence"
    ]
  };

  List<String> qualitySelection = [];
  final AuthController _authController = Get.find<AuthController>();

  Future<void> loadUserQualities() async {
    final quality = await _authController.getUserQualities();
    setState(() {
      qualitySelection = quality;
    });
  }

  void saveQuality() {
    if (qualitySelection.isEmpty) {
      Get.snackbar("Error", "Please select at least one quality.");
      return;
    }
    _authController.saveUserQualities(qualitySelection);
  }

  void toggleSelection(String quality) {
    setState(() {
      if (qualitySelection.contains(quality)) {
        qualitySelection.remove(quality);
      } else {
        if (qualitySelection.length < 3) {
          qualitySelection.add(quality);
        }
      }
    });
  }

  @override
  void initState() {
    loadUserQualities();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Their qualities", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Texts
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: "Tell us what you value in a ",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: Colors.black),
                  ),
                  TextSpan(
                    text: "person",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: Colors.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              "Choose 3 values that would make a connection much stronger",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            // Qualities List
            Expanded(
              child: ListView(
                children: qualityList.entries.map((entry) {
                  return Column(

                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 15,
                        runSpacing: 15,
                        alignment: WrapAlignment.center,
                        children: entry.value.map((quality) {
                          final isSelected = qualitySelection.contains(quality);
                          return ChoiceChip(
                            label: Text(
                              quality,
                              style: TextStyle(
                                fontSize: 18,
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: Colors.black,
                            backgroundColor: Colors.grey[200],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isSelected ? Colors.transparent : Colors.grey.shade400,
                              ),
                            ),
                            onSelected: (_) => toggleSelection(quality),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                    ],
                  );
                }).toList(),
              ),
            ),
            // Save Button
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
                  saveQuality();
                  Get.to(() => const CompleteProfile());
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
