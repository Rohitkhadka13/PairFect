import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pairfect/profileScreen/complete_profile.dart';
import 'package:pairfect/profileScreen/moreAboutYou/exercise_screen.dart';
import '../../controllers/auth_controllers.dart';

class HeightScreen extends StatefulWidget {
  const HeightScreen({super.key});

  @override
  State<HeightScreen> createState() => _HeightScreenState();
}

class _HeightScreenState extends State<HeightScreen> {
  String _selectedHeight = "Enter your height";
  final AuthController _authController = Get.find();
  bool _isProfileCompleted = false;

  @override
  void initState() {
    super.initState();
    _checkProfileCompletion();
    _loadHeight();

  }
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

  Future<void> _loadHeight() async {
    try {
      final savedHeight = await _authController.fetchHeight();
      if (savedHeight != null && savedHeight.isNotEmpty) {
        setState(() {
          _selectedHeight = savedHeight;
        });
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  void _showHeightDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: SizedBox(
            height: 300,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    "Select your height",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: 131,
                    itemBuilder: (context, index) {
                      final height = 90 + index;
                      return ListTile(
                        title: Text("$height cm"),
                        onTap: () async {
                          setState(() {
                            _selectedHeight = "$height cm";
                          });


                          await _authController.saveHeight(_selectedHeight);
                          if(_isProfileCompleted){
                            Get.to(()=> CompleteProfile());
                          }else{
                            Get.off(()=> ExerciseScreen());
                          }

                         // Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
          padding: const EdgeInsets.all(15.0),
          child: Center(
            child: Column(
              children: [
                const Icon(
                  Icons.height,
                  size: 50,
                ),
                const SizedBox(height: 20),
                const Text(
                  "What is your height?",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                ),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: _showHeightDialog,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 2),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey[200],
                    ),
                    child: Center(
                      child: Text(
                        _selectedHeight,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
