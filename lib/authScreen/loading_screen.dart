import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pairfect/authScreen/login_screen.dart';
import 'package:pairfect/authScreen/nav_screen.dart';
import 'package:pairfect/profileScreen/moreAboutYou/height_screen.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/auth_controllers.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    checkSessionAndNavigate();
  }

  Future<void> checkSessionAndNavigate() async {
    await Future.delayed(Duration(seconds: 4));

    final prefs = await SharedPreferences.getInstance();
    String? sessionToken = prefs.getString('sessionToken');

    if (sessionToken == null) {
      Get.offAll(() => LoginScreen());
      return;
    }

    final user = await ParseUser.currentUser();
    if (user == null) {
      Get.offAll(() => LoginScreen());
      return;
    }

    final query = QueryBuilder<ParseObject>(ParseObject('UserLogin'))
      ..whereEqualTo('userPointer', user.toPointer());

    final response = await query.query();

    if (response.success &&
        response.results != null &&
        response.results!.isNotEmpty) {
      final userProfile = response.results!.first;
      final isProfileComplete =
          userProfile.get<bool>('isProfileComplete') ?? false;

//save location
      // await Get.find<AuthController>().fetchAndSaveUserLocation();
      if (isProfileComplete) {
        Get.offAll(() => MainNavigationScreen(
              initialIndex: 0,
            ));
      } else {
        Get.offAll(() => HeightScreen());
      }
    } else {
      Get.offAll(() => LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: SizedBox(
          height: 500,
          width: 500,
          child: Image.asset("assets/images/logo1.png"),
        ),
      ),
    );
  }
}
