import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pairfect/profileScreen/complete_profile.dart';
import '../../controllers/auth_controllers.dart';

class GenderScreen extends StatefulWidget {
  const GenderScreen({super.key});

  @override
  State<GenderScreen> createState() => _GenderScreenState();
}

class _GenderScreenState extends State<GenderScreen> {
  final AuthController _authController = Get.find();
  String selectedGender = "Man";
  bool showOnProfile = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final userData = await _authController.getUserGender();
    if (userData != null) {
      setState(() {
        selectedGender = userData["gender"] ?? "Man";
        showOnProfile = userData["showOnProfile"] ?? true;
      });
    }
  }

  void _saveUserData() async {
    await _authController.saveUserAge(selectedGender, showOnProfile);
  }

  Widget genderOption(String title) {
    return GestureDetector(
      onTap: () => setState(() => selectedGender = title),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Radio(
          value: title,
          groupValue: selectedGender,
          onChanged: (value) => setState(() => selectedGender = value!),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Update your gender", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, size: 30),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Pick which best describes you", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            genderOption("Woman"),
            genderOption("Man"),
            genderOption("Non-binary"),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Shown on your profile", style: TextStyle(fontWeight: FontWeight.bold)),
                      Switch(
                        value: showOnProfile,
                        onChanged: (value) => setState(() => showOnProfile = value),
                      ),
                    ],
                  ),
                  if (showOnProfile)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          const Text("Shown as: "),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(color: Colors.yellow, borderRadius: BorderRadius.circular(20)),
                            child: Text(selectedGender, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15)),
                onPressed: (){
                  _saveUserData();
                  Get.to(()=> CompleteProfile());
                },
                child: const Text("Save and close", style: TextStyle(fontSize: 20)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
