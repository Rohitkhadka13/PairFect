import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pairfect/profileScreen/moreAboutYou/politics_screen.dart';

import '../../controllers/auth_controllers.dart';
import '../complete_profile.dart';

class ZodiacScreen extends StatefulWidget {
  const ZodiacScreen({super.key});

  @override
  State<ZodiacScreen> createState() => _ZodiacScreenState();
}

class _ZodiacScreenState extends State<ZodiacScreen> {
  final AuthController _authController = Get.find();
  String _selectedZodiac = "";
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

  Future<void> _handleZodiac(String zodiac) async {
    await _authController.saveZodiac(zodiac);
    if (_isProfileCompleted) {
      Get.to(() => CompleteProfile());
    } else {
      Get.offAll(() => PoliticsScreen());
    }
  }

  Future<void> _loadZodiac() async {
    try {
      final savedZodiac = await _authController.loadZodiac();
      setState(() {
        _selectedZodiac = savedZodiac;
      });
    } catch (e) {
      Get.snackbar("Error", "Failed to load  data: $e");
    }
  }

  @override
  void initState() {
    _checkProfileCompletion();
    _loadZodiac();
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
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Center(
              child: Column(
            
                children: [
                  Icon(
                    Icons.star,
                    size: 50,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "What's your zodiac  sign?",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                  ),
                  SizedBox(height: 30),
                  _buildZodiacContainer("Aries"),
                  SizedBox(
                    height: 10,
                  ),
                  _buildZodiacContainer("Taurus"),
                  SizedBox(
                    height: 10,
                  ),
                  _buildZodiacContainer("Gemini"),
                  SizedBox(
                    height: 10,
                  ),
                  _buildZodiacContainer("Cancer"),
                  SizedBox(
                    height: 10,
                  ),
                  _buildZodiacContainer("Leo"),
                  SizedBox(
                    height: 10,
                  ),
                  _buildZodiacContainer("Virgo"),
                  SizedBox(
                    height: 10,
                  ),
                  _buildZodiacContainer("Libra"),
                  SizedBox(
                    height: 10,
                  ),
                  _buildZodiacContainer("Scorpio"),
                  SizedBox(
                    height: 10,
                  ),
                  _buildZodiacContainer("Sagittarius"),
                  SizedBox(
                    height: 10,
                  ),
                  _buildZodiacContainer("Capricorn"),
                  SizedBox(
                    height: 10,
                  ),
                  _buildZodiacContainer("Aquarius"),
                  SizedBox(
                    height: 10,
                  ),
                  _buildZodiacContainer("Pisces"),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildZodiacContainer(String zodiac) {
    return GestureDetector(
      onTap: () {
        _handleZodiac(zodiac);
      },
      child: Container(
        height: 80,
        width: double.infinity,
        decoration: BoxDecoration(
          color:_selectedZodiac == zodiac ? Colors.black : Colors.grey.shade200,
          border: Border.all(
            color:
            _selectedZodiac == zodiac ? Colors.black : Colors.grey,
            width: _selectedZodiac == zodiac ? 4 : 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            zodiac,
            style: TextStyle(
              fontSize: 20,
              color: _selectedZodiac == zodiac ? Colors.white :Colors.black
            ),
          ),
        ),
      ),
    );
  }
}
