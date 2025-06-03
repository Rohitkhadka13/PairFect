import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controllers.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final AuthController _authController = Get.find<AuthController>();
  String? _location;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    final loc = await _authController.fetchAndDisplayUserLocation();
    setState(() {
      _location = loc;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(_location ?? "Loading location..."),
      ),
    );
  }
}
