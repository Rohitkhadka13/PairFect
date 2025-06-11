import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pairfect/profileScreen/moreAboutYou/smoking_screen.dart';

import '../../controllers/auth_controllers.dart';
import '../complete_profile.dart';

class DrinkingScreen extends StatefulWidget {
  const DrinkingScreen({super.key});

  @override
  State<DrinkingScreen> createState() => _DrinkingScreenState();
}

class _DrinkingScreenState extends State<DrinkingScreen> {
  final AuthController _authController = Get.find();
  String _selectedHabits = "";
  bool _isProfileCompleted = false;

  Future<void> _checkProfileCompletion() async {
    try {
      final isCompleted = await _authController.isProfileCompleted();
      setState(() {
        _isProfileCompleted = isCompleted;
      });
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> _handledrinkingHabitSelection(String drinking) async {
    await _authController.saveDrinkingHabits(drinking);
    if (_isProfileCompleted) {
      Get.to(() => CompleteProfile());
    } else {
      Get.offAll(() => SmokingScreen());
    }
  }

  Future<void> _loadSelectedDrinkingHabit() async {
    try {
      final savedHabits = await _authController.loadDrinkingHabits();
      setState(() {
        _selectedHabits = savedHabits;
      });
    } catch (e) {
      Get.snackbar("Error", "Failed to load  data: $e");
    }
  }

  @override
  void initState() {
    _checkProfileCompletion();
    _loadSelectedDrinkingHabit();
    super.initState();
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
          padding: EdgeInsets.all(15),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.local_bar,
                  size: 50,
                ),
                SizedBox(height: 20),
                Text(
                  "Do you drink?",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                ),
                SizedBox(height: 30),

                _buildDrinkingHabits("Yes,I drink"),
                SizedBox(
                  height: 10,
                ),
                _buildDrinkingHabits("I drink sometime"),
                SizedBox(
                  height: 10,
                ),
                _buildDrinkingHabits("I rarely drink"),
                SizedBox(
                  height: 10,
                ),
                _buildDrinkingHabits("No,I don't drink"),
                SizedBox(
                  height: 10,
                ),
                _buildDrinkingHabits("I'm sober"),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrinkingHabits(String drinking) {
    return GestureDetector(
      onTap: () {
        _handledrinkingHabitSelection(drinking);
      },
      child: Container(
        height: 80,
        width: double.infinity,
        decoration: BoxDecoration(
          color: _selectedHabits == drinking ?Colors.black :Colors.grey.shade200,
          border: Border.all(
            color: _selectedHabits == drinking ? Colors.black : Colors.grey,
            width: _selectedHabits == drinking? 4:2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            drinking,
            style: TextStyle(
              fontSize: 20,
              color: _selectedHabits == drinking ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
