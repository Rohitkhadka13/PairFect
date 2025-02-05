import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:pairfect/profileScreen/complete_profile.dart';
import 'package:pairfect/profileScreen/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Center(
        child: Column(
          children: [
            Text("This is a Home Screen"),
            ElevatedButton(onPressed: (){
              Get.to(()=> ProfileScreen());
            }, child: Text("vrrrorm"))
          ],
        ),
      ),
    );
  }
}
