import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pairfect/profileScreen/aboutYou/education_screen.dart';
import 'package:pairfect/profileScreen/aboutYou/gender_screen.dart';
import 'package:pairfect/profileScreen/aboutYou/occupation_screen.dart';
import 'package:pairfect/profileScreen/causes_screen.dart';
import 'package:pairfect/profileScreen/interest_screen.dart';
import 'package:pairfect/profileScreen/location_screen.dart';
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

import '../authScreen/nav_screen.dart';
import '../controllers/auth_controllers.dart';

class CompleteProfile extends StatefulWidget {
  const CompleteProfile({super.key});

  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
  bool _isLoading = true;
  final TextEditingController _bioController = TextEditingController();

  final AuthController _authController = Get.find<AuthController>();
  late final Map<String, Future<String> Function()> _loaders;

  final Map<String, String> _userData = {
    "job": "Add",
    "education": "Add",
    "gender": "Add",
    "location": "Add",
    "height": "Add",
    "exercise": "Add",
    "drinking": "Add",
    "smoking": "Add",
    "lookingFor": "Add",
    "kids": "Add",
    "haveKids": "Add",
    "zodiac": "Add",
    "politics": "Add",
    "religion": "Add",
  };

  Future<void> _loadUserData() async {
    for (var key in _loaders.keys) {
      try {
        final value = await _loaders[key]!();
        if (!mounted) return;
        setState(() {
          _userData[key] = value.isNotEmpty ? value : "Add";
        });
      } catch (e) {
        if (!mounted) return;
        Get.snackbar("Error", "Failed to load $key data: $e");
      }
    }
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadCurrentBio() async {
    final currentBio = await _authController.getUserBio();
    _bioController.text = currentBio;
  }

  @override
  void initState() {
    _authController.fetchImages();

    _authController.loadUserInterests();
    _authController.loadUserCauses();
    _authController.loadUserQuality();
    _loadCurrentBio();
    _loaders = {
      "job": () async {
        await _authController.fetchJob();
        return _authController.jobs.isNotEmpty
            ? _authController.jobs.first["title"] ?? "Add"
            : "Add";
      },
      "education": () async {
        await _authController.fetchEducation();
        return _authController.edu.isNotEmpty
            ? "${_authController.edu.first["institution"]} ${_authController.edu.first["year"]}"
            : "Add";
      },
      "gender": () async =>
          (await _authController.getUserGender())?["gender"] ?? "Add",
      "height": () async => await _authController.fetchHeight() ?? "Add",
      "exercise": () => _authController.loadExercise(),
      "drinking": () => _authController.loadDrinkingHabits(),
      "smoking": () => _authController.loadSmokingHabits(),
      "lookingFor": () async {
        List<String> lookingFor = await _authController.loadLookingFor();
        return lookingFor.isNotEmpty ? lookingFor.join(", ") : "Add";
      },
      "kids": () => _authController.loadPlanForKids(),
      "haveKids": () => _authController.loadHaveKids(),
      "zodiac": () => _authController.loadZodiac(),
      "politics": () => _authController.loadPoliticalLeaning(),
      "religion": () => _authController.loadReligion(),
    };

    _loadUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.offAll(() => MainNavigationScreen(initialIndex: 0));
          },
          icon: Icon(
            Icons.chevron_left_rounded,
            size: 40,
          ),
        ),
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
              SizedBox(height: 5),
              Text(
                "Pick some that show the true you.",
                style: TextStyle(fontSize: 19),
              ),
              SizedBox(height: 10),

              Obx(() {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildImageContainer(0),
                        _buildImageContainer(1),
                        _buildImageContainer(2),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildImageContainer(3),
                        _buildImageContainer(4),
                        _buildImageContainer(5),
                      ],
                    ),
                  ],
                );
              }),

              SizedBox(height: 15),
              Text(
                "Interests",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(
                "Get specific about the things you love.",
                style: TextStyle(fontSize: 19),
              ),
              SizedBox(height: 10),
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
                    constraints: BoxConstraints(minHeight: 60, maxHeight: 150),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: interests.isNotEmpty
                              ? SingleChildScrollView(
                                  child: Wrap(
                                    spacing: 8.0,
                                    runSpacing: 4.0,
                                    children: interests
                                        .map((interest) =>
                                            Chip(label: Text(interest)))
                                        .toList(),
                                  ),
                                )
                              : Text(
                                  "Add interest badges",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
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
                                        .map(
                                            (cause) => Chip(label: Text(cause)))
                                        .toList(),
                                  ),
                                )
                              : Text(
                                  "Add Causes and  communities",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
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
                                        .map((quality) =>
                                            Chip(label: Text(quality)))
                                        .toList(),
                                  ),
                                )
                              : Text(
                                  "Add their qualities",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                        ),
                        Icon(Icons.arrow_forward_ios_outlined),
                      ],
                    ),
                  );
                }),
              ),

              SizedBox(height: 15),
              Text(
                "Bio",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(
                "Write a fun and punchy intro.",
                style: TextStyle(fontSize: 19),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _bioController,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (value) {
                    _authController.updateUserBio(value);
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    hintText: "A little bit about you",
                    border: InputBorder.none,
                  ),
                ),
              ),

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
                onPressed: () {
                  Get.to(() => OccupationScreen());
                },
                leading: Icons.work,
                title: "Work",
                trailing: _userData["job"],
              ),

              //Add Education
              CustomListTile(
                onPressed: () {
                  Get.to(() => EducationScreen());
                },
                leading: Icons.school,
                title: "Education",
                trailing: _userData["education"],
              ),

              //Add Gender
              CustomListTile(
                onPressed: () {
                  Get.to(() => GenderScreen());
                },
                leading: Icons.person,
                title: "Gender",
                trailing: _userData["gender"],
              ),

              //Add Location
              CustomListTile(
                onPressed: () {
                  Get.to(() => LocationScreen());
                },
                leading: Icons.location_pin,
                title: "Location",
                trailing: _userData["location"],
              ),

              //Add HomeTown
              CustomListTile(
                leading: Icons.home,
                title: "Hometown",
                trailing: "Add",
              ),

              SizedBox(height: 25),
              Text(
                "More About you",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(
                "Cover things most people are curious about.",
                style: TextStyle(fontSize: 19),
              ),
              SizedBox(height: 25),

              CustomListTile(
                onPressed: () {
                  Get.to(() => HeightScreen());
                },
                leading: Icons.height,
                title: "Height",
                trailing: _userData['height'],
              ),
              CustomListTile(
                onPressed: () {
                  Get.to(() => ExerciseScreen());
                },
                leading: Icons.fitness_center_outlined,
                title: "Exercise",
                trailing: _userData["exercise"],
              ),
              CustomListTile(
                onPressed: () {
                  Get.to(() => DrinkingScreen());
                },
                leading: Icons.local_bar,
                title: "Drinking",
                trailing: _userData["drinking"],
              ),
              CustomListTile(
                onPressed: () {
                  Get.to(() => SmokingScreen());
                },
                leading: Icons.smoking_rooms_rounded,
                title: "Smoking",
                trailing: _userData["smoking"],
              ),
              CustomListTile(
                onPressed: () {
                  Get.to(() => LookingForScreen());
                },
                leading: Icons.search_outlined,
                title: "Looking for",
                trailing: _userData["lookingFor"],
              ),
              CustomListTile(
                onPressed: () {
                  Get.to(() => KidsScreen());
                },
                leading: Icons.escalator_warning_outlined,
                title: "Kids",
                trailing: _userData["kids"],
              ),
              CustomListTile(
                onPressed: () {
                  Get.to(() => HaveKidsScreen());
                },
                leading: Icons.child_care,
                title: "Have kids",
                trailing: _userData["haveKids"],
              ),
              CustomListTile(
                onPressed: () {
                  Get.to(() => ZodiacScreen());
                },
                leading: Icons.star,
                title: "Zodiac",
                trailing: _userData["zodiac"],
              ),
              CustomListTile(
                onPressed: () {
                  Get.to(() => PoliticsScreen());
                },
                leading: Icons.account_balance,
                title: "Politics",
                trailing: _userData["politics"],
              ),
              CustomListTile(
                onPressed: () {
                  Get.to(() => ReligionScreen());
                },
                leading: Icons.church_outlined,
                title: "Religion",
                trailing: _userData["religion"],
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
