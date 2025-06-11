import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pairfect/profileScreen/moreAboutYou/zodiac_screen.dart';

import '../../controllers/auth_controllers.dart';
import '../complete_profile.dart';

class HaveKidsScreen extends StatefulWidget {
  const HaveKidsScreen({super.key});

  @override
  State<HaveKidsScreen> createState() => _HaveKidsScreenState();
}

class _HaveKidsScreenState extends State<HaveKidsScreen> {
  final AuthController _authController = Get.find();
  String _selectedHaveChild = "";
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

  Future<void> _handleHaveKids(String kids) async {
    await _authController.saveHaveKids(kids);
    if (_isProfileCompleted) {
      Get.to(() => CompleteProfile());
    } else {
      Get.offAll(() => ZodiacScreen());
    }
  }

  Future<void> _loadSelectedHaveKid() async {
    try {
      final savedPlan = await _authController.loadHaveKids();
      setState(() {
        _selectedHaveChild = savedPlan;
      });
    } catch (e) {
      Get.snackbar("Error", "Failed to load  data: $e");
    }
  }

  @override
  void initState() {
    _checkProfileCompletion();
   _loadSelectedHaveKid();
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
                  Icons.child_care,
                  size: 50,
                ),
                SizedBox(height: 20),
                Text(
                  "Do you have kids?",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                ),

                SizedBox(height: 30),
               _buildHaveKid("Have kids"),
                SizedBox(height: 10,),
               _buildHaveKid("Don't have kids"),
                SizedBox(height: 10,),
              _buildHaveKid("Want kids"),
                SizedBox(height: 10,),
                _buildHaveKid("Not sure")


              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHaveKid(String kids) {
    return GestureDetector(
      onTap: () {
        _handleHaveKids(kids);
      },
      child: Container(
        height: 80,
        width: double.infinity,
        decoration: BoxDecoration(
          color: _selectedHaveChild == kids ? Colors.black : Colors.grey.shade200,
          border: Border.all(
            color:
            _selectedHaveChild == kids ? Colors.black : Colors.grey,
            width: _selectedHaveChild == kids ? 4 : 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            kids,
            style: TextStyle(
              fontSize: 20,
              color:  _selectedHaveChild == kids ? Colors.white :Colors.black
            ),
          ),
        ),
      ),
    );
  }
}
