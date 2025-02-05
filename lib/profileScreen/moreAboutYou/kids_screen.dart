import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pairfect/profileScreen/moreAboutYou/have_kids_screen.dart';

import '../../controllers/auth_controllers.dart';
import '../complete_profile.dart';

class KidsScreen extends StatefulWidget {
  const KidsScreen({super.key});

  @override
  State<KidsScreen> createState() => _KidsScreenState();
}

class _KidsScreenState extends State<KidsScreen> {
  final AuthController _authController = Get.find();
  String _selectedPlanForChild = "";
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

  Future<void> _handlePlanForChildren(String kidsPlan) async {
    await _authController.savePlanForKids(kidsPlan);
    if (_isProfileCompleted) {
      Get.to(() => CompleteProfile());
    } else {
      Get.offAll(() => HaveKidsScreen());
    }
  }

  Future<void> _loadSelectedPlanForChildren() async {
    try {
      final savedPlan = await _authController.loadPlanForKids();
      setState(() {
        _selectedPlanForChild = savedPlan;
      });
    } catch (e) {
      Get.snackbar("Error", "Failed to load  data: $e");
    }
  }

  @override
  void initState() {
    _checkProfileCompletion();
    _loadSelectedPlanForChildren();
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
                  Icons.escalator_warning_outlined,
                  size: 50,
                ),
                SizedBox(height: 20),
                Text(
                  "What are your ideal plans for",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                ),
                Text(
                  "children?",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                ),
            
                SizedBox(height: 30),
                _buildPlanForChild("Don't want kids"),
                SizedBox(height: 10),
                _buildPlanForChild("Open to kids"),
                SizedBox(height: 10),
                _buildPlanForChild("Want kids"),
                SizedBox(height: 10),
                _buildPlanForChild("Not sure"),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanForChild(String kidsPlan) {
    return GestureDetector(
      onTap: () {
        _handlePlanForChildren(kidsPlan);
      },
      child: Container(
        height: 80,
        width: double.infinity,
        decoration: BoxDecoration(
          color:_selectedPlanForChild == kidsPlan ?Colors.black: Colors.grey.shade200,
          border: Border.all(
            color:
                _selectedPlanForChild == kidsPlan ? Colors.black : Colors.grey,
            width: _selectedPlanForChild == kidsPlan ? 4 : 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            kidsPlan,
            style: TextStyle(
              fontSize: 20,
              color: _selectedPlanForChild == kidsPlan ? Colors.white:Colors.black
            ),
          ),
        ),
      ),
    );
  }
}
