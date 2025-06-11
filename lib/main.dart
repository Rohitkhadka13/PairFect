import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:pairfect/authScreen/loading_screen.dart';
import 'package:pairfect/controllers/auth_controllers.dart';
import 'package:pairfect/controllers/password_controller.dart';
import 'package:pairfect/controllers/profile_controller.dart';

import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  final keyApplicationId = dotenv.env['APPLICATION_ID']!;
  final keyClientKey = dotenv.env['CLIENT_KEY']!;
  final keyParseServerUrl = dotenv.env['PARSE_SERVER_URL']!;

  await Parse().initialize(
    keyApplicationId,
    keyParseServerUrl,
    clientKey: keyClientKey,
    debug: true,
    autoSendSessionId: true,
  );

  Get.put(AuthController());
  Get.put(PasswordController());
  Get.put(ProfileController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'PairFect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(scaffoldBackgroundColor: Colors.white),
      home: const LoadingScreen(),
    );
  }
}
