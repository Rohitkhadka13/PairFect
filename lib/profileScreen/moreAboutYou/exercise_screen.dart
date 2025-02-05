import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pairfect/profileScreen/complete_profile.dart';
import '../../controllers/auth_controllers.dart';
import 'drinking_screen.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  final AuthController _authController = Get.find();
  String _selectedExercise = "";
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

  Future<void> _handleExerciseSelection(String exercise) async {
    await _authController.saveExercise(exercise);
   if(_isProfileCompleted){
     Get.to(()=> CompleteProfile());
   }else{
     Get.offAll(()=> DrinkingScreen());
   }
  }


  Future<void> _loadSelectedExercise() async {
    try {
      final savedExercise = await _authController.loadExercise();
      setState(() {
        _selectedExercise = savedExercise;
      });
    } catch (e) {
      Get.snackbar("Error", "Failed to load exercise data: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _checkProfileCompletion();
    _loadSelectedExercise();
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
                  Icons.fitness_center_outlined,
                  size: 50,
                ),
                SizedBox(height: 20),
                Text(
                  "Do you work out?",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                ),
                SizedBox(height: 30),
                _buildExerciseOption("Active"),
                SizedBox(height: 10),
                _buildExerciseOption("Sometimes"),
                SizedBox(height: 10),
                _buildExerciseOption("Almost never"),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildExerciseOption(String exercise) {
    return GestureDetector(
      onTap: () {
        _handleExerciseSelection(exercise);
      },
      child: Container(
        height: 80,
        width: double.infinity,
        decoration: BoxDecoration(
          color:_selectedExercise == exercise ? Colors.black : Colors.grey.shade300,
          border: Border.all(
            color: _selectedExercise == exercise ? Colors.black : Colors.grey,
            width: _selectedExercise == exercise ?4:2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            exercise,
            style: TextStyle(
              fontSize: 20,
              color: _selectedExercise == exercise ? Colors.white: Colors.black
            ),
          ),
        ),
      ),
    );
  }
}
