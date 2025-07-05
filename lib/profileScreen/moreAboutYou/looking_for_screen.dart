import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pairfect/authScreen/nav_screen.dart';
import 'package:pairfect/profileScreen/profile_screen.dart';

import '../../controllers/auth_controllers.dart';

class LookingForScreen extends StatefulWidget {
  const LookingForScreen({super.key});

  @override
  State<LookingForScreen> createState() => _LookingForScreenState();
}

class _LookingForScreenState extends State<LookingForScreen> {
  final AuthController authController = Get.find<AuthController>();
  bool _isProfileCompleted = false;
  List<bool> isSelected = List.generate(6, (index) => false);
  List<String> options = [
    "A Long term relationship",
    "Fun, casual dates",
    "Marriage",
    "Intimacy, without commitment",
    "A life partner",
    "Ethical non-monogamy"
  ];

  @override
  void initState() {
    super.initState();
    _checkProfileCompletion();
    _loadSelectedOptions();
  }

  Future<void> _checkProfileCompletion() async {
    try {
      final isCompleted = await authController.isProfileCompleted();
      setState(() {
        _isProfileCompleted = isCompleted;
      });
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  void _loadSelectedOptions() async {
    List<String> savedOptions = await authController.loadLookingFor();
    setState(() {
      for (int i = 0; i < options.length; i++) {
        isSelected[i] = savedOptions.contains(options[i]);
      }
    });
  }

  void _saveSelectedOptions() async {
    List<String> selectedOptions = [];
    for (int i = 0; i < options.length; i++) {
      if (isSelected[i]) {
        selectedOptions.add(options[i]);
      }
    }
    await authController.saveLookingFor(selectedOptions);

    Get.offAll(() => MainNavigationScreen(initialIndex: 0));  }

  void _handleCheckboxSelection(int index) {
    setState(() {
      if (isSelected[index]) {
        isSelected[index] = false;
      } else {
        int selectedCount = isSelected.where((selected) => selected).length;
        if (selectedCount < 2) {
          isSelected[index] = true;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isProfileCompleted
          ? AppBar(
              backgroundColor: Colors.transparent,
              leading: IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: const Icon(
                  Icons.close,
                  size: 40,
                  color: Colors.black87,
                ),
              ),
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              const Icon(
                Icons.search_outlined,
                size: 50,
              ),
              const SizedBox(height: 20),
              const Text(
                "What do you want from your",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
              ),
              const Text(
                "dates?",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
              ),
              const SizedBox(height: 15),
              const Text(
                "You can choose 1 or 2 options",
                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 22),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: ListView.builder(
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    return _buildCheckboxContainer(index, options[index]);
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _saveSelectedOptions();
                  authController.setProfileCompleted();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Save and Close",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxContainer(int index, String text) {
    return GestureDetector(
      onTap: () => _handleCheckboxSelection(index),
      child: Container(
        height: 80,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: isSelected[index] ? Colors.black : Colors.grey.shade200,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const SizedBox(width: 10),
            Checkbox(
              value: isSelected[index],
              onChanged: (value) {
                _handleCheckboxSelection(index);
              },
            ),
            const SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                  fontSize: 20,
                  color: isSelected[index] ? Colors.white : Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
