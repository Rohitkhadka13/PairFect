import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:pairfect/profileScreen/complete_profile.dart';
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.settings,
                  size: 30,
                )),
          )
        ],
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
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Edit Name",
                      style: TextStyle(fontSize: 20),
                    ),
                    Icon(Icons.arrow_forward_ios),
                  ],
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    authController.clearImages();
                    await authController.logout();
                  },
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Logout"),
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
