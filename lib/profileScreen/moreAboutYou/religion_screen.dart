import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pairfect/profileScreen/moreAboutYou/looking_for_screen.dart';

import '../../controllers/auth_controllers.dart';
import '../complete_profile.dart';

class ReligionScreen extends StatefulWidget {
  const ReligionScreen({super.key});

  @override
  State<ReligionScreen> createState() => _ReligionScreenState();
}

class _ReligionScreenState extends State<ReligionScreen> {
  final AuthController _authController = Get.find();
  String _selectedReligion = "";
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

  Future<void> _handleReligion(String religion) async {
    await _authController.saveReligion(religion);
    if (_isProfileCompleted) {
      Get.offAll(() => CompleteProfile());
    } else {
      Get.offAll(() => LookingForScreen());
    }
  }
  Future<void> _loadReligion() async {
    try {
      final savedReligion = await _authController.loadReligion();
      setState(() {
        _selectedReligion = savedReligion;
      });
    } catch (e) {
      Get.snackbar("Error", "Failed to load  data: $e");
    }
  }

  @override
  void initState() {
    _checkProfileCompletion();
  _loadReligion();
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
        child: SingleChildScrollView(
          padding: EdgeInsets.all(15),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.church_outlined,
                  size: 50,
                ),
                SizedBox(height: 20),
                Text(
                  "Do you identify with a religions?",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                ),
                SizedBox(height: 30),
                _religionContainer("Agnostic"),
                SizedBox(
                  height: 10,
                ),
                _religionContainer("Atheist"),
                SizedBox(
                  height: 10,
                ),
                _religionContainer("Buddhist"),
                SizedBox(
                  height: 10,
                ),
                _religionContainer("Catholic"),
                SizedBox(
                  height: 10,
                ),
                _religionContainer("Christian"),
                SizedBox(
                  height: 10,
                ),
                _religionContainer("Hindu"),
                SizedBox(
                  height: 10,
                ),
                _religionContainer("Jain"),
                SizedBox(
                  height: 10,
                ),
                _religionContainer("Jewish"),
                SizedBox(
                  height: 10,
                ),
                _religionContainer("Mormon"),
                SizedBox(
                  height: 10,
                ),
                _religionContainer("Latter-day Saint"),
                SizedBox(
                  height: 10,
                ),
                _religionContainer("Muslim"),
                SizedBox(
                  height: 10,
                ),
                _religionContainer("Zoroastrian"),
                SizedBox(
                  height: 10,
                ),
                _religionContainer("Sikh"),
                SizedBox(
                  height: 10,
                ),
                _religionContainer("Spiritual"),
                SizedBox(
                  height: 10,
                ),
                _religionContainer("Other"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _religionContainer(String religion) {
    return GestureDetector(
      onTap: () {
        _handleReligion(religion);
      },
      child: Container(
        height: 80,
        width: double.infinity,
        decoration: BoxDecoration(
          color:_selectedReligion == religion ?Colors.black: Colors.grey.shade200,
          border: Border.all(
            color:
            _selectedReligion == religion? Colors.black : Colors.grey,
            width: _selectedReligion == religion ? 4 : 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            religion,
            style: TextStyle(
                fontSize: 20,
                color:  _selectedReligion == religion ? Colors.white:Colors.black
            ),
          ),
        ),
      ),
    );
  }
}
