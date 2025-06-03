import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pairfect/profileScreen/moreAboutYou/religion_screen.dart';

import '../../controllers/auth_controllers.dart';
import '../complete_profile.dart';

class PoliticsScreen extends StatefulWidget {
  const PoliticsScreen({super.key});

  @override
  State<PoliticsScreen> createState() => _PoliticsScreenState();
}

class _PoliticsScreenState extends State<PoliticsScreen> {
  final AuthController _authController = Get.find();
  String _selectedPolitics = "";
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

  Future<void> _handlePolitics(String politics) async {
    await _authController.savePoliticalLeaning(politics);
    if (_isProfileCompleted) {
      Get.to(() => CompleteProfile());
    } else {
      Get.offAll(() => ReligionScreen());
    }
  }

  Future<void> _loadSelectedPolitics() async {
    try {
      final savedPolitics = await _authController.loadPoliticalLeaning();
      setState(() {
        _selectedPolitics = savedPolitics;
      });
    } catch (e) {
      Get.snackbar("Error", "Failed to load  data: $e");
    }
  }

  @override
  void initState() {
    _checkProfileCompletion();
    _loadSelectedPolitics();
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
                  Icons.account_balance,
                  size: 50,
                ),
                SizedBox(height: 20),
                Text(
                  "What are your political leanings?",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                ),
                SizedBox(height: 30),
                _buildPolitics("Apolitical"),
                SizedBox(
                  height: 10,
                ),
                _buildPolitics("Moderate"),
                SizedBox(
                  height: 10,
                ),
                _buildPolitics("Liberal"),
                SizedBox(
                  height: 10,
                ),
                _buildPolitics("Conservative")
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPolitics(String politics) {
    return GestureDetector(
      onTap: () {
        _handlePolitics(politics);
      },
      child: Container(
        height: 80,
        width: double.infinity,
        decoration: BoxDecoration(
          color: _selectedPolitics == politics
              ? Colors.black
              : Colors.grey.shade200,
          border: Border.all(
            color: _selectedPolitics == politics ? Colors.black : Colors.grey,
            width: _selectedPolitics == politics ? 4 : 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            politics,
            style: TextStyle(
                fontSize: 20,
                color: _selectedPolitics == politics
                    ? Colors.white
                    : Colors.black),
          ),
        ),
      ),
    );
  }
}
