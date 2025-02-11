import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pairfect/profileScreen/aboutYou/occupation_screen.dart';
import 'package:pairfect/profileScreen/causes_screen.dart';
import 'package:pairfect/profileScreen/interest_screen.dart';
import 'package:pairfect/profileScreen/moreAboutYou/drinking_screen.dart';
import 'package:pairfect/profileScreen/moreAboutYou/exercise_screen.dart';
import 'package:pairfect/profileScreen/moreAboutYou/have_kids_screen.dart';
import 'package:pairfect/profileScreen/moreAboutYou/height_screen.dart';
import 'package:pairfect/profileScreen/moreAboutYou/kids_screen.dart';
import 'package:pairfect/profileScreen/moreAboutYou/looking_for_screen.dart';
import 'package:pairfect/profileScreen/moreAboutYou/politics_screen.dart';
import 'package:pairfect/profileScreen/moreAboutYou/religion_screen.dart';
import 'package:pairfect/profileScreen/moreAboutYou/smoking_screen.dart';
import 'package:pairfect/profileScreen/moreAboutYou/zodiac_screen.dart';
import 'package:pairfect/profileScreen/qualities_screen.dart';
import 'package:pairfect/widgets/custom_listtile.dart';

import '../controllers/auth_controllers.dart';

class CompleteProfile extends StatefulWidget {
  const CompleteProfile({super.key});

  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
   String _exercise = "";
  final AuthController _authController = Get.find<AuthController>();




   Future<void> _loadSelectedExercise() async {
    try {
      final savedExercise = await _authController.loadExercise();
      setState(() {
        _exercise = savedExercise;
      });
    } catch (e) {
      Get.snackbar("Error", "Failed to load exercise data: $e");
    }
  }
  @override
  void initState() {
    _authController.fetchImages();
    _loadSelectedExercise();
    _authController.loadUserInterests();
    _authController.loadUserCauses();
    _authController.loadUserQuality();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.chevron_left_rounded,
              size: 40,
            )),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Upload Photos
              Text(
                "Upload Photos",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                "Pick some that show the true you.",
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.normal),
              ),
              SizedBox(
                height: 10,
              ),

              Obx(() {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildImageContainer(0),
                        _buildImageContainer(1),
                        _buildImageContainer(2),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildImageContainer(3),
                        _buildImageContainer(4),
                        _buildImageContainer(5),
                      ],
                    ),
                  ],
                );
              }),

              //// Interests

              SizedBox(
                height: 15,
              ),
              Text(
                "Interests",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                "Get specific about the things you love.",
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.normal),
              ),
              SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () async {
                  await Get.to(() => InterestScreen());
                  await _authController.getUserInterests();
                },
                child: Obx(() {
                  final interests = _authController.interests;
                  return Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    constraints: BoxConstraints(
                      minHeight: 60,
                      maxHeight: 150, // Prevent overflow
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: interests.isNotEmpty
                              ? SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Wrap(
                              spacing: 8.0,
                              runSpacing: 4.0,
                              children: interests
                                  .map((interest) => Chip(label: Text(interest)))
                                  .toList(),
                            ),
                          )
                              : Text(
                            "Add interest badges",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios_outlined),
                      ],
                    ),
                  );
                }),
              ),




              SizedBox(
                height: 15,
              ),

              //Causes and Communities

              Text(
                "My causes and communities",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                "Add up to 3 causes close to your heart.",
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.normal),
              ),
              SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () async {
                  await Get.to(() => CausesScreen());
                  await _authController.getUserCauses();
                },
                child: Obx(() {
                  final causes = _authController.causes;
                  return Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    constraints: BoxConstraints(
                      minHeight: 60,
                      maxHeight: 150, // Prevent overflow
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: causes.isNotEmpty
                              ? SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Wrap(
                              spacing: 8.0,
                              runSpacing: 4.0,
                              children: causes
                                  .map((cause) => Chip(label: Text(cause)))
                                  .toList(),
                            ),
                          )
                              : Text(
                            "Add Causes and  communities",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios_outlined),
                      ],
                    ),
                  );
                }),
              ),

              //Qualities i value
              SizedBox(
                height: 15,
              ),
              Text(
                "Qualities I value",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                "Choose up to 3 qualities you value in person.",
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.normal),
              ),
              SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () async {
                  await Get.to(() => QualitiesScreen());
                  await _authController.getUserQualities();
                },
                child: Obx(() {
                  final quality = _authController.quality;
                  return Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    constraints: BoxConstraints(
                      minHeight: 60,
                      maxHeight: 150,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: quality.isNotEmpty
                              ? SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Wrap(
                              spacing: 8.0,
                              runSpacing: 4.0,
                              children: quality
                                  .map((quality) => Chip(label: Text(quality)))
                                  .toList(),
                            ),
                          )
                              : Text(
                            "Add their qualities",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios_outlined),
                      ],
                    ),
                  );
                }),
              ),

              //Bio
              SizedBox(
                height: 15,
              ),
              Text(
                "Bio",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                "Write a fun and punchy intro.",
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.normal),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 2),
                      borderRadius: BorderRadius.circular(12)),
                  child: TextField(
                    decoration: InputDecoration(
                        hintText: "A little bit about you",
                        border: InputBorder.none),
                  )),

              // About You Section
              SizedBox(
                height: 25,
              ),
              Text(
                "About you",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 15,
              ),

              //Add work
              CustomListTile(
                onPressed: (){Get.to(()=> OccupationScreen());},
                leading: Icons.work,
                title: "Work",
                trailing: "Add",
              ),

              //Add Education
              CustomListTile(
                leading: Icons.school,
                title: "Education",
                trailing: "Add",
              ),

              //Add Gender
              CustomListTile(
                leading: Icons.person,
                title: "Gender",
                trailing: "Add",
              ),

              //Add Location
              CustomListTile(
                leading: Icons.location_pin,
                title: "Location",
                trailing: "Add",
              ),

              //Add HomeTown
              CustomListTile(
                leading: Icons.home,
                title: "Hometown",
                trailing: "Add",
              ),

              //More About You
              SizedBox(
                height: 25,
              ),
              Text(
                "More About you",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                "Cover things most people are curious about.",
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.normal),
              ),
              SizedBox(
                height: 25,
              ),

              //Add Height
              CustomListTile(
                onPressed: () {
                  Get.to(() => HeightScreen());
                },
                leading: Icons.height,
                title: "Height",
                trailing: "Add",
              ),

              //Add Exercise
              CustomListTile(
                onPressed: () {
                  Get.to(() => ExerciseScreen());
                },
                leading: Icons.fitness_center_outlined,
                title: "Exercise",
                trailing: _exercise ?? "Add",
              ),

              //Add Drinking Habits
              CustomListTile(
                onPressed: () {
                  Get.to(() => DrinkingScreen());
                },
                leading: Icons.local_bar,
                title: "Drinking",
                trailing: "Add",
              ),

              //Add Smoking habits
              CustomListTile(
                onPressed: () {
                  Get.to(() => SmokingScreen());
                },
                leading: Icons.smoking_rooms_rounded,
                title: "Smoking",
                trailing: "Add",
              ),

              //Add Looking for in partner
              CustomListTile(
                onPressed: () {
                  Get.to(() => LookingForScreen());
                },
                leading: Icons.search_outlined,
                title: "Looking for",
                trailing: "Add",
              ),

              //Add Kids
              CustomListTile(
                onPressed: () {
                  Get.to(() => KidsScreen());
                },
                leading: Icons.escalator_warning_outlined,
                title: "Kids",
                trailing: "Add",
              ),

              //Add Want Kids
              CustomListTile(
                onPressed: () {
                  Get.to(() => HaveKidsScreen());
                },
                leading: Icons.child_care,
                title: "Have kids",
                trailing: "Add",
              ),

              //Add Star Sign
              CustomListTile(
                onPressed: () {
                  Get.to(() => ZodiacScreen());
                },
                leading: Icons.star,
                title: "Zodiac",
                trailing: "Add",
              ),

              //Add Politics
              CustomListTile(
                onPressed: (){Get.to(()=> PoliticsScreen());},
                leading: Icons.account_balance,
                title: "Politics",
                trailing: "Add",
              ),

              //Add Religion
              CustomListTile(
                onPressed: (){Get.to(()=> ReligionScreen());},
                leading: Icons.church_outlined,
                title: "Religion",
                trailing: "Add",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageContainer(int index) {
    return GestureDetector(
      onTap: () async {
        if (_authController.images[index] == null) {
          await _authController.pickImage(index);
        }
      },
      child: Stack(
        children: [
          Container(
            height: 125,
            width: 125,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _authController.images[index] != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      _authController.images[index]!.url!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(
                    Icons.add,
                    size: 50,
                    color: Colors.grey,
                  ),
          ),
          if (_authController.images[index] != null)
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: () async {
                  await _authController.deleteImage(index);
                },
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
