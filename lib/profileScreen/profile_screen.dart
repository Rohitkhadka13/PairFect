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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text("PairFect Profile"),
        centerTitle: true,
        elevation: 0,

      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isLoading)
            Center(child: CircularProgressIndicator())
          else
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Row(
                children: [
                  // Display profile image
                  CircleAvatar(
                    radius: 70,
                    backgroundImage: _imageProfileUrl != null
                        ? CachedNetworkImageProvider(_imageProfileUrl!)
                        : null,
                    child: _imageProfileUrl == null
                        ? Icon(Icons.person, size: 70)
                        : null,
                  ),
                  SizedBox(width: 20),
                  // Display name and age
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (_name != null)
                            Text(
                              "$_name,",
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          if (_age != null)
                            Text(
                              "$_age",
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          if (_name == null && _age == null)
                            Text(
                              "No data available",
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.normal,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(9)),
                        child: GestureDetector(
                          onTap: () {
                            Get.to(() => CompleteProfile());
                          },
                          child: Text(
                            "Complete Profile",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          SizedBox(
            height: 50,
          ),
          Container(
            color: Colors.grey[300],
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                GestureDetector(
                    onTap:(){
                      Get.to(()=>EditProfile());
                    },
                    child: _settingsRow("Edit Profile", Icons.arrow_forward_ios)),
                const Divider(),
                GestureDetector(
                    onTap: (){
                      Get.to(()=> AboutUsScreen());
                    },
                    child: _settingsRow("About Us", Icons.arrow_forward_ios)),
                const Divider(),
                GestureDetector(
                    onTap: (){
                      Get.to(()=> MatchingHomeScreen());
                    },
                    child: _settingsRow("Privacy & Policy", Icons.arrow_forward_ios)),
                const Divider(),


                GestureDetector(
                    onTap: (){
                      Get.to(()=> TermsAndConditionScreen());
                    },
                    child: _settingsRow("Terms & Conditions", Icons.description)),
                const Divider(),
                _settingsRow("App Version", Icons.info),
                const Divider(),
                _settingsRow("Delete My Account", Icons.delete, textColor: Colors.red),
                const Divider(),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    authController.clearImages();
                    await authController.logout();
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Text(
                      "Logout",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
Widget _settingsRow(String label, IconData icon, {Color textColor = Colors.black}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 18, color: textColor),
        ),
        Icon(icon, color: textColor, size: 18),
      ],
    ),
  );
}
