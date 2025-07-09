import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:pairfect/profileScreen/about_us_screen.dart';
import 'package:pairfect/profileScreen/complete_profile.dart';
import 'package:pairfect/profileScreen/moreAboutYou/edit_profile.dart';
import 'package:pairfect/profileScreen/privacy&policy_screen.dart';
import 'package:pairfect/profileScreen/terms_screen.dart';
import 'package:pairfect/quiz_mood/matching_screen.dart';
import '../controllers/auth_controllers.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthController authController = Get.find();
  String? _imageProfileUrl;
  String? _name;
  int? _age;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  int calculateAge(DateTime dob) {
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  Future<void> fetchData() async {
    final imageUrl = await authController.fetchUserImage();
    final name = await authController.fetchName();
    final dob = await authController.fetchDate();

    int? age;
    if (dob != null) {
      age = calculateAge(dob);
    }

    setState(() {
      _imageProfileUrl = imageUrl;
      _name = name;
      _age = age;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "My Profile",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFF881337),
            fontFamily: 'PlayfairDisplay',
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF881337)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 100),
                  child: CircularProgressIndicator(
                    color: Color(0xFFFB7185),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pink.shade100,
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFF9A8D4),
                              width: 3,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: const Color(0xFFFBCFE8),
                            backgroundImage: _imageProfileUrl != null
                                ? CachedNetworkImageProvider(_imageProfileUrl!)
                                : null,
                            child: _imageProfileUrl == null
                                ? const Icon(
                              Icons.person,
                              size: 40,
                              color: Color(0xFF881337),
                            )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (_name != null)
                                    Text(
                                      _name!,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF881337),
                                      ),
                                    ),
                                  const SizedBox(width: 8),
                                  if (_age != null)
                                    Text(
                                      '$_age',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF881337),
                                      ),
                                    ),
                                  if (_name == null && _age == null)
                                    const Text(
                                      "No data available",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              InkWell(
                                onTap: () {
                                  Get.to(
                                        () => CompleteProfile(),
                                    transition: Transition.rightToLeftWithFade,
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFB7185),
                                        Color(0xFFF472B6),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    "Complete Profile",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 32),
            // Settings section with romantic cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildRomanticCard(
                    icon: Icons.edit,
                    title: "Edit Profile",
                    onTap: () => Get.to(
                          () => EditProfile(),
                      transition: Transition.rightToLeftWithFade,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRomanticCard(
                    icon: Icons.favorite,
                    title: "About Us",
                    onTap: () => Get.to(
                          () => AboutUsScreen(),
                      transition: Transition.rightToLeftWithFade,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRomanticCard(
                    icon: Icons.privacy_tip,
                    title: "Privacy Policy",
                    onTap: () => Get.to(
                          () => PrivacyAndPolicyScreen(),
                      transition: Transition.rightToLeftWithFade,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRomanticCard(
                    icon: Icons.description,
                    title: "Terms & Conditions",
                    onTap: () => Get.to(
                          () => TermsAndConditionScreen(),
                      transition: Transition.rightToLeftWithFade,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRomanticCard(
                    icon: Icons.info,
                    title: "App Version",
                    onTap: () {},
                  ),
                  const SizedBox(height: 16),
                  _buildRomanticCard(
                    icon: Icons.delete,
                    title: "Delete Account",
                    color: const Color(0xFFEF4444),
                    onTap: () {},
                  ),
                  const SizedBox(height: 24),
                  InkWell(
                    onTap: () async {
                      authController.clearImages();
                      await authController.logout();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.pink.shade100,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          "Logout",
                          style: TextStyle(
                            color: Color(0xFFEF4444),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRomanticCard({
    required IconData icon,
    required String title,
    Color color = const Color(0xFF881337),
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.pink.shade100,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}