import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pairfect/profileScreen/moreAboutYou/kids_screen.dart';

import '../../controllers/auth_controllers.dart';
import '../complete_profile.dart';

class SmokingScreen extends StatefulWidget {
  const SmokingScreen({super.key});

  @override
  State<SmokingScreen> createState() => _SmokingScreenState();
}

class _SmokingScreenState extends State<SmokingScreen> {
  final AuthController _authController = Get.find();
  String _selectedSmokingHabits = "";
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

  Future<void> _handleSmokingHabitSelection(String smoking) async {
    await _authController.saveSmokingHabits(smoking);
    if (_isProfileCompleted) {
      Get.to(() => CompleteProfile());
    } else {
      Get.offAll(() => KidsScreen());
    }
  }

  Future<void> _loadSelectedSmokingHabit() async {
    try {
      final savedHabits = await _authController.loadSmokingHabits();
      setState(() {
        _selectedSmokingHabits = savedHabits;
      });
    } catch (e) {
      Get.snackbar("Error", "Failed to load  data: $e");
    }
  }

  @override
  void initState() {
    _checkProfileCompletion();
    _loadSelectedSmokingHabit();
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
                  Icons.smoking_rooms_rounded,
                  size: 50,
                ),
                SizedBox(height: 20),
                Text(
                  "Do you smoke?",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                ),
                SizedBox(height: 30),
                _buildSmokingHabits("I smoke sometimes"),
                SizedBox(
                  height: 10,
                ),
                _buildSmokingHabits("No,I don't smoke"),
                SizedBox(
                  height: 10,
                ),
                _buildSmokingHabits("Yes,I smoke"),
                SizedBox(
                  height: 10,
                ),
                _buildSmokingHabits("I'm trying to quit"),
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

  Widget _buildSmokingHabits(String smoking) {
    return GestureDetector(
      onTap: () {
        _handleSmokingHabitSelection(smoking);
      },
      child: Container(
        height: 80,
        width: double.infinity,
        decoration: BoxDecoration(
          color:_selectedSmokingHabits == smoking ?Colors.black: Colors.grey.shade200,
          border: Border.all(
            color:
                _selectedSmokingHabits == smoking ? Colors.black : Colors.grey,
            width: _selectedSmokingHabits == smoking ? 4 : 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            smoking,
            style: TextStyle(
              fontSize: 20,
              color:  _selectedSmokingHabits == smoking ? Colors.white:Colors.black
            ),
          ),
        ),
      ),
    );
  }
}
