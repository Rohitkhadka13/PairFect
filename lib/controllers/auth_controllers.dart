import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart'as geo;
import 'package:location/location.dart' as loc;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pairfect/authScreen/nav_screen.dart';
import 'package:pairfect/profileScreen/moreAboutYou/height_screen.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../authScreen/login_screen.dart';
import 'package:path_provider/path_provider.dart';

class AuthController extends GetxController {
  static AuthController authController = Get.find();
  Rx<File?> pickedFile = Rx<File?>(null);

  File? get profileImage => pickedFile.value;
  XFile? imageFile;
  late SharedPreferences prefs;
  final ImagePicker _picker = ImagePicker();
  final RxList<ParseFile?> _images = List<ParseFile?>.filled(6, null).obs;

  List<ParseFile?> get images => _images;

  final RxList<Map<String, dynamic>> jobs = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> edu = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    initSharedPreferences();
  }

  Future<void> initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  void clearImage() {
    imageFile = null;
    pickedFile.value = null;
  }

  Future<void> pickImageFileFromGallery() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final originalFilename = pickedFile.name;
        final sanitizedFilename =
            originalFilename.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');

        final originalFile = File(pickedFile.path);
        final tempDir = await getTemporaryDirectory();
        final newFile =
            await originalFile.copy('${tempDir.path}/$sanitizedFilename');

        this.pickedFile.value = newFile;
      } else {
        Get.snackbar(
            "Profile Image", "Please select an image for your profile");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to pick image: $e");
    }
  }

  String encryptPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // SignUp User Using Email Password
  Future<void> signup({
    required String name,
    required String email,
    required String password,
    required String dob,
    required File profileImage,
    required bool isProfileComplete,
  }) async {
    if (pickedFile.value == null) {
      Get.snackbar("Error", "Please select a profile image");
      return;
    }

    try {
      // Check if the email already exists
      final QueryBuilder<ParseUser> query =
          QueryBuilder<ParseUser>(ParseUser.forQuery())
            ..whereEqualTo('email', email);

      final ParseResponse response = await query.query();

      if (response.success &&
          response.results != null &&
          response.results!.isNotEmpty) {
        Get.snackbar("Error", "An account with this email already exists.");
        return;
      }

      // Encrypt the password
      String encryptedPassword = encryptPassword(password);

      // Create a new Parse user
      ParseUser user = ParseUser(email, encryptedPassword, email)
        ..set('username', email) // Set email as username
        ..set('email', email);

      final ParseResponse signUpResponse = await user.signUp();

      if (!signUpResponse.success) {
        Get.snackbar("Error",
            "Failed to register user: ${signUpResponse.error?.message}");
        return;
      }

      // Upload the profile image
      final ParseFile parseImageFile = ParseFile(profileImage);
      final ParseResponse imageResponse = await parseImageFile.save();

      if (!imageResponse.success) {
        Get.snackbar(
            "Error", "Failed to upload image: ${imageResponse.error?.message}");
        return;
      }

      // Parse the date of birth string into a DateTime object
      DateTime dobDateTime = DateFormat('yyyy-MM-dd').parse(dob);

      // Save additional user details in UserLogin table
      ParseObject userObject = ParseObject('UserLogin')
        ..set('name', name)
        ..set('dob', dobDateTime)
        ..set('email', email)
        ..set('imageProfile', parseImageFile)
        ..set('isProfileComplete', isProfileComplete)
        ..set('userPointer', user.toPointer());

      final ParseResponse saveResponse = await userObject.save();

      if (!saveResponse.success) {
        Get.snackbar("Error",
            "Failed to save user data: ${saveResponse.error?.message}");
        return;
      }

      Get.snackbar("Success", "User registered successfully!");
    } catch (e) {
      Get.snackbar("Error", "Failed to register user: $e");
    }
  }

  //SignIn User Using Email, Password

  Future<void> signIn({required String email, required String password}) async {
    try {
      // Encrypt the password (same as during sign-up)
      String encryptedPassword = encryptPassword(password);

      // Sign in using Parse Server
      ParseUser user = ParseUser(email, encryptedPassword, email);
      final ParseResponse response = await user.login();

      if (response.success) {
        await prefs.setString('sessionToken', user.sessionToken!);

        // Fetch the user's data from the UserLogin table
        final QueryBuilder<ParseObject> userLoginQuery =
            QueryBuilder<ParseObject>(ParseObject('UserLogin'))
              ..whereEqualTo('userPointer', user.toPointer());

        final ParseResponse userLoginResponse = await userLoginQuery.query();

        if (userLoginResponse.success && userLoginResponse.results != null) {
          ParseObject userLogin = userLoginResponse.results!.first;
          bool isProfileComplete =
              userLogin.get<bool>('isProfileComplete') ?? false;

          if (isProfileComplete) {
            Get.offAll(() => MainNavigationScreen(
                  initialIndex: 0,
                ));
          } else {
            Get.offAll(() => HeightScreen());
          }
        } else {
          Get.snackbar(
            "Error",
            "Failed to fetch user data: ${userLoginResponse.error?.message}",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          "Error",
          "Failed to login: ${response.error?.message}",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to login: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void clearImages() {
    _images.value = List<ParseFile?>.filled(6, null);
  }

  //fetch user ProfileImage from DB
  Future<String?> fetchUserImage() async {
    try {
      // Fetch the current user
      final user = await ParseUser.currentUser() as ParseUser?;
      if (user == null) {
        return null;
      }

      // Query the UserLogin class to fetch the profile
      final query = QueryBuilder<ParseObject>(ParseObject('UserLogin'))
        ..whereEqualTo('userPointer', user.toPointer());

      final response = await query.query();

      if (response.success &&
          response.results != null &&
          response.results!.isNotEmpty) {
        final userProfile = response.results!.first;
        final imageProfile = userProfile.get<ParseFile>('imageProfile');

        if (imageProfile != null) {
          return imageProfile.url;
        }
      }
    } catch (e) {
      print('Error fetching user image: $e');
    }

    return null;
  }

  // Fetch User name
  Future<String?> fetchName() async {
    try {
      // Fetch the current user
      final user = await ParseUser.currentUser() as ParseUser?;
      if (user == null) {
        return null;
      }

      // Query the UserLogin class to fetch the name
      final query = QueryBuilder<ParseObject>(ParseObject('UserLogin'))
        ..whereEqualTo('userPointer', user.toPointer());

      final response = await query.query();

      if (response.success &&
          response.results != null &&
          response.results!.isNotEmpty) {
        final userProfile = response.results!.first;
        final name = userProfile.get<String>('name');

        if (name != null) {
          return name;
        }
      }
    } catch (e) {
      print('Error fetching user name: $e');
    }

    return null;
  }

  //fetch Date Of Birth
  Future<DateTime?> fetchDate() async {
    try {
      // Fetch the current user
      final user = await ParseUser.currentUser() as ParseUser?;
      if (user == null) {
        return null;
      }

      // Query the UserLogin class to fetch the name
      final query = QueryBuilder<ParseObject>(ParseObject('UserLogin'))
        ..whereEqualTo('userPointer', user.toPointer());

      final response = await query.query();

      if (response.success &&
          response.results != null &&
          response.results!.isNotEmpty) {
        final userProfile = response.results!.first;
        final dob = userProfile.get<DateTime>('dob');

        if (dob != null) {
          return dob;
        }
      }
    } catch (e) {
      print('Error fetching user name: $e');
    }
    return null;
  }

  // Fetch images from the database
  Future<void> fetchImages() async {
    final user = await ParseUser.currentUser() as ParseUser;
    final query = QueryBuilder<ParseObject>(ParseObject('UserImage'))
      ..whereEqualTo('UserPointer', user.toPointer());

    final response = await query.query();

    if (response.success &&
        response.results != null &&
        response.results!.isNotEmpty) {
      final userImage = response.results!.first;
      for (int i = 0; i < 6; i++) {
        _images[i] = userImage.get<ParseFile>('Image${i + 1}');
      }
      update();
    }
  }

  // Pick an image from the gallery
  Future<void> pickImage(int index) async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final originalFilename = pickedFile.name;
        final sanitizedFilename =
            originalFilename.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');

        final originalFile = File(pickedFile.path);
        final tempDir = await getTemporaryDirectory();
        final newFile =
            await originalFile.copy('${tempDir.path}/$sanitizedFilename');

        await uploadImage(index, newFile);
      } else {
        Get.snackbar("Image Picker", "No image selected.");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to pick image: $e");
    }
  }

  // Upload an image to the database
  Future<void> uploadImage(int index, File imageFile) async {
    final safeFileName =
        'user_image_${index + 1}_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final parseFile = ParseFile(imageFile, name: safeFileName);
    final saveResult = await parseFile.save();

    if (!saveResult.success) {
      Get.snackbar("Upload Failed", "Error: ${saveResult.error?.message}");
      return;
    }

    final user = await ParseUser.currentUser() as ParseUser;
    final query = QueryBuilder<ParseObject>(ParseObject('UserImage'))
      ..whereEqualTo('UserPointer', user.toPointer());

    final response = await query.query();

    if (response.success &&
        response.results != null &&
        response.results!.isNotEmpty) {
      final userImage = response.results!.first;
      userImage.set('Image${index + 1}', parseFile);
      await userImage.save();
    } else {
      final userImage = ParseObject('UserImage')
        ..set('UserPointer', user.toPointer())
        ..set('Image${index + 1}', parseFile);
      await userImage.save();
    }

    _images[index] = parseFile;
    update();
  }

  // Delete an image from the database
  Future<void> deleteImage(int index) async {
    final user = await ParseUser.currentUser() as ParseUser;
    final query = QueryBuilder<ParseObject>(ParseObject('UserImage'))
      ..whereEqualTo('UserPointer', user.toPointer());

    final response = await query.query();

    if (response.success &&
        response.results != null &&
        response.results!.isNotEmpty) {
      final userImage = response.results!.first;
      userImage.unset('Image${index + 1}'); // Remove the image from the column
      await userImage.save();
    }

    _images[index] = null;
    update();
  }

//logout User
  Future<void> logout() async {
    try {
      // Get the current user
      final user = await ParseUser.currentUser() as ParseUser?;

      if (user != null) {
        final ParseResponse response = await user.logout();

        if (response.success) {
          await prefs.remove('sessionToken');

          // Navigate to the LoginScreen
          Get.offAll(() => LoginScreen());
        } else {
          Get.snackbar(
            "Logout Failed",
            response.error?.message ?? "An error occurred during logout",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          "Logout Failed",
          "No user is currently logged in",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to logout: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  //add job
  Future<void> addJob(String title, String company) async {
    try {
      final currentUser = await ParseUser.currentUser() as ParseUser?;
      if (currentUser == null) {
        throw Exception("User not logged in");
      }

      final query = QueryBuilder<ParseObject>(ParseObject('aboutYou'))
        ..whereEqualTo('userPointer', currentUser.toPointer());
      final queryResult = await query.query();

      ParseObject aboutYou;
      if (queryResult.success &&
          queryResult.results != null &&
          queryResult.results!.isNotEmpty) {
        aboutYou = queryResult.results!.first as ParseObject;
      } else {
        aboutYou = ParseObject('aboutYou')
          ..set('userPointer', currentUser.toPointer())
          ..set('Work', []);
      }

      final currentWork = aboutYou.get<List<dynamic>>('Work') ?? [];
      currentWork.add({'title': title, 'company': company});
      aboutYou.set('Work', currentWork);

      final response = await aboutYou.save();
      if (!response.success) {
        throw Exception(
            "Failed to save job details: ${response.error?.message}");
      }

      // Update reactive jobs list
      jobs.assignAll(currentWork.cast<Map<String, dynamic>>());
      Get.snackbar("Success", "Job details added successfully!");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  //fetch job
  Future<void> fetchJob() async {
    try {
      final currentUser = await ParseUser.currentUser() as ParseUser?;
      if (currentUser == null) {
        throw Exception("User not logged in");
      }

      final query = QueryBuilder<ParseObject>(ParseObject('aboutYou'))
        ..whereEqualTo('userPointer', currentUser.toPointer());
      final queryResult = await query.query();

      if (queryResult.success &&
          queryResult.results != null &&
          queryResult.results!.isNotEmpty) {
        final aboutYou = queryResult.results!.first as ParseObject;
        final fetchedJobs = aboutYou.get<List<dynamic>>('Work') ?? [];
        jobs.assignAll(fetchedJobs.cast<Map<String, dynamic>>());
      } else {
        jobs.clear();
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  //delete job
  Future<void> deleteUserJob(int index) async {
    try {
      final currentUser = await ParseUser.currentUser() as ParseUser?;
      if (currentUser == null) {
        throw Exception("User not logged in");
      }

      final query = QueryBuilder<ParseObject>(ParseObject('aboutYou'))
        ..whereEqualTo('userPointer', currentUser.toPointer());
      final queryResult = await query.query();

      if (queryResult.success &&
          queryResult.results != null &&
          queryResult.results!.isNotEmpty) {
        final aboutYou = queryResult.results!.first as ParseObject;
        final currentWork = aboutYou.get<List<dynamic>>('Work') ?? [];

        if (index >= 0 && index < currentWork.length) {
          currentWork.removeAt(index);
          aboutYou.set('Work', currentWork);
          final response = await aboutYou.save();

          if (!response.success) {
            throw Exception("Failed to delete job: ${response.error?.message}");
          }

          // Update reactive jobs list
          jobs.assignAll(currentWork.cast<Map<String, dynamic>>());
          Get.snackbar("Success", "Job deleted successfully!");
        }
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  //add education
  Future<void> addEducation(String institution, String year) async {
    try {
      final currentUser = await ParseUser.currentUser() as ParseUser?;
      if (currentUser == null) {
        throw Exception("User not logged in");
      }

      final query = QueryBuilder<ParseObject>(ParseObject('aboutYou'))
        ..whereEqualTo('userPointer', currentUser.toPointer());
      final queryResult = await query.query();

      ParseObject aboutYou;
      if (queryResult.success &&
          queryResult.results != null &&
          queryResult.results!.isNotEmpty) {
        aboutYou = queryResult.results!.first as ParseObject;
      } else {
        aboutYou = ParseObject('aboutYou')
          ..set('userPointer', currentUser.toPointer())
          ..set('Education', []);
      }

      final currentEdu = aboutYou.get<List<dynamic>>('Education') ?? [];
      currentEdu.add({'institution': institution, 'year': year});
      aboutYou.set('Education', currentEdu);

      final response = await aboutYou.save();
      if (!response.success) {
        throw Exception(
            "Failed to save education details: ${response.error?.message}");
      }

      // Update reactive education list
      edu.assignAll(currentEdu.cast<Map<String, dynamic>>());
      Get.snackbar("Success", "Education  added successfully!");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  //fetch education
  Future<void> fetchEducation() async {
    try {
      final currentUser = await ParseUser.currentUser() as ParseUser?;
      if (currentUser == null) {
        throw Exception("User not logged in");
      }

      final query = QueryBuilder<ParseObject>(ParseObject('aboutYou'))
        ..whereEqualTo('userPointer', currentUser.toPointer());
      final queryResult = await query.query();

      if (queryResult.success &&
          queryResult.results != null &&
          queryResult.results!.isNotEmpty) {
        final aboutYou = queryResult.results!.first as ParseObject;
        final fetchedEdu = aboutYou.get<List<dynamic>>('Education') ?? [];
        edu.assignAll(fetchedEdu.cast<Map<String, dynamic>>());
      } else {
        edu.clear();
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  //delete education
  Future<void> deleteUserEducation(int index) async {
    try {
      final currentUser = await ParseUser.currentUser() as ParseUser?;
      if (currentUser == null) {
        throw Exception("User not logged in");
      }

      final query = QueryBuilder<ParseObject>(ParseObject('aboutYou'))
        ..whereEqualTo('userPointer', currentUser.toPointer());
      final queryResult = await query.query();

      if (queryResult.success &&
          queryResult.results != null &&
          queryResult.results!.isNotEmpty) {
        final aboutYou = queryResult.results!.first as ParseObject;
        final cuerrentEdu = aboutYou.get<List<dynamic>>('Education') ?? [];

        if (index >= 0 && index < cuerrentEdu.length) {
          cuerrentEdu.removeAt(index);
          aboutYou.set('Education', cuerrentEdu);
          final response = await aboutYou.save();

          if (!response.success) {
            throw Exception(
                "Failed to delete education: ${response.error?.message}");
          }

          // Update reactive jobs list
          edu.assignAll(cuerrentEdu.cast<Map<String, dynamic>>());
          Get.snackbar("Success", "Education deleted successfully!");
        }
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  //add height
  Future<void> saveHeight(String height) async {
    try {
      final currentUser = await ParseUser.currentUser() as ParseUser?;
      if (currentUser == null) {
        throw Exception("User not logged in");
      }

      final query = QueryBuilder<ParseObject>(ParseObject('aboutYou'))
        ..whereEqualTo('userPointer', currentUser.toPointer());
      final queryResult = await query.query();

      ParseObject aboutYou;
      if (queryResult.success &&
          queryResult.results != null &&
          queryResult.results!.isNotEmpty) {
        aboutYou = queryResult.results!.first as ParseObject;
      } else {
        aboutYou = ParseObject('aboutYou')
          ..set('userPointer', currentUser.toPointer());
      }

      aboutYou.set('Height', height);
      final response = await aboutYou.save();

      if (!response.success) {
        throw Exception("Failed to save height: ${response.error?.message}");
      }

      Get.snackbar("Success", "Height saved successfully!");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  //fetch height
  Future<String?> fetchHeight() async {
    try {
      final currentUser = await ParseUser.currentUser() as ParseUser?;
      if (currentUser == null) {
        throw Exception("User not logged in");
      }

      final query = QueryBuilder<ParseObject>(ParseObject('aboutYou'))
        ..whereEqualTo('userPointer', currentUser.toPointer());
      final queryResult = await query.query();

      if (queryResult.success &&
          queryResult.results != null &&
          queryResult.results!.isNotEmpty) {
        final aboutYou = queryResult.results!.first as ParseObject;
        return aboutYou.get<String>('Height');
      }
      return null;
    } catch (e) {
      throw Exception("Failed to fetch height: $e");
    }
  }

  //check isProfileCompleted
  Future<bool> isProfileCompleted() async {
    try {
      final user = await ParseUser.currentUser() as ParseUser?;
      if (user != null) {
        final query = QueryBuilder<ParseObject>(ParseObject('UserLogin'))
          ..whereEqualTo('userPointer', user);

        final response = await query.first();
        if (response != null) {
          final isCompleted = response.get<bool>('isProfileComplete') ?? false;
          return isCompleted;
        }
      }
      return false;
    } catch (e) {
      throw Exception("Failed to check profile completion: $e");
    }
  }

  //set IsProfileCompleted to true
  Future<void> setProfileCompleted() async {
    final user = await ParseUser.currentUser() as ParseUser?;
    if (user == null) throw Exception("User not logged in");

    final query = QueryBuilder<ParseObject>(ParseObject('UserLogin'))
      ..whereEqualTo('userPointer', user);

    final response = await query.query();
    if (response.success &&
        response.results != null &&
        response.results!.isNotEmpty) {
      final userLogin = response.results!.first as ParseObject;
      final isComplete = userLogin.get<bool>('isProfileComplete');

      if (isComplete != true) {
        userLogin.set('isProfileComplete', true);
        final saveResponse = await userLogin.save();

        if (!saveResponse.success) {
          throw Exception("Failed to update: ${saveResponse.error?.message}");
        }
      }
    } else {
      throw Exception("UserLogin object not found");
    }
  }

//save exercise
  Future<void> saveExercise(String exercise) async {
    try {
      final currentUser = await ParseUser.currentUser() as ParseUser?;
      if (currentUser == null) {
        throw Exception("User not logged in");
      }

      final query = QueryBuilder<ParseObject>(ParseObject('aboutYou'))
        ..whereEqualTo('userPointer', currentUser.toPointer());
      final queryResult = await query.query();

      ParseObject aboutYou;
      if (queryResult.success &&
          queryResult.results != null &&
          queryResult.results!.isNotEmpty) {
        aboutYou = queryResult.results!.first as ParseObject;
      } else {
        aboutYou = ParseObject('aboutYou')
          ..set('userPointer', currentUser.toPointer());
      }

      aboutYou.set('Exercise', exercise); // Set exercise value
      final response = await aboutYou.save();

      if (!response.success) {
        throw Exception("Failed to save exercise: ${response.error?.message}");
      }

      Get.snackbar("Success", "Exercise saved successfully!");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  //load exercise
  Future<String> loadExercise() async {
    try {
      final currentUser = await ParseUser.currentUser() as ParseUser?;
      if (currentUser == null) {
        throw Exception("User not logged in");
      }

      final query = QueryBuilder<ParseObject>(ParseObject('aboutYou'))
        ..whereEqualTo('userPointer', currentUser.toPointer());
      final queryResult = await query.query();

      if (queryResult.success &&
          queryResult.results != null &&
          queryResult.results!.isNotEmpty) {
        final aboutYou = queryResult.results!.first as ParseObject;
        return aboutYou.get<String>('Exercise') ??
            ""; // Fetch the exercise data
      }
      return ""; // Return empty string if no exercise found
    } catch (e) {
      throw Exception("Failed to load exercise: $e");
    }
  }

  //save drinking habits
  Future<void> saveDrinkingHabits(String drinking) async {
    try {
      final currentUser = await ParseUser.currentUser() as ParseUser?;
      if (currentUser == null) {
        throw Exception("User not logged in");
      }

      final query = QueryBuilder<ParseObject>(ParseObject('aboutYou'))
        ..whereEqualTo('userPointer', currentUser.toPointer());
      final queryResult = await query.query();

      ParseObject aboutYou;
      if (queryResult.success &&
          queryResult.results != null &&
          queryResult.results!.isNotEmpty) {
        aboutYou = queryResult.results!.first as ParseObject;
      } else {
        aboutYou = ParseObject('aboutYou')
          ..set('userPointer', currentUser.toPointer());
      }

      aboutYou.set('Drinking', drinking);
      final response = await aboutYou.save();

      if (!response.success) {
        throw Exception("Failed to save : ${response.error?.message}");
      }

      Get.snackbar("Success", "");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

//load drinking habits
  Future<String> loadDrinkingHabits() async {
    try {
      final currentUser = await ParseUser.currentUser() as ParseUser?;
      if (currentUser == null) {
        throw Exception("User not logged in");
      }

      final query = QueryBuilder<ParseObject>(ParseObject('aboutYou'))
        ..whereEqualTo('userPointer', currentUser.toPointer());
      final queryResult = await query.query();

      if (queryResult.success &&
          queryResult.results != null &&
          queryResult.results!.isNotEmpty) {
        final aboutYou = queryResult.results!.first as ParseObject;
        return aboutYou.get<String>('Drinking') ?? "";
      }
      return "";
    } catch (e) {
      throw Exception("Failed to load drinking habits: $e");
    }
  }

  //save smoking habits
  Future<void> saveSmokingHabits(String smoking) async {
    try {
      final currentUser = await ParseUser.currentUser() as ParseUser?;
      if (currentUser == null) {
        throw Exception("User not logged in");
      }

      final query = QueryBuilder<ParseObject>(ParseObject('aboutYou'))
        ..whereEqualTo('userPointer', currentUser.toPointer());
      final queryResult = await query.query();

      ParseObject aboutYou;
      if (queryResult.success &&
          queryResult.results != null &&
          queryResult.results!.isNotEmpty) {
        aboutYou = queryResult.results!.first as ParseObject;
      } else {
        aboutYou = ParseObject('aboutYou')
          ..set('userPointer', currentUser.toPointer());
      }

      aboutYou.set('Smoking', smoking);
      final response = await aboutYou.save();

      if (!response.success) {
        throw Exception("Failed to save : ${response.error?.message}");
      }

      Get.snackbar("Success", "");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  //load smoking habits
  Future<String> loadSmokingHabits() async {
    try {
      final currentUser = await ParseUser.currentUser() as ParseUser?;
      if (currentUser == null) {
        throw Exception("User not logged in");
      }

      final query = QueryBuilder<ParseObject>(ParseObject('aboutYou'))
        ..whereEqualTo('userPointer', currentUser.toPointer());
      final queryResult = await query.query();

      if (queryResult.success &&
          queryResult.results != null &&
          queryResult.results!.isNotEmpty) {
        final aboutYou = queryResult.results!.first as ParseObject;
        return aboutYou.get<String>('Smoking') ?? "";
      }
      return "";
    } catch (e) {
      throw Exception("Failed to load : $e");
    }
  }

  //save plan for kids
  Future<void> savePlanForKids(String kidsPlan) async {
    try {
      final currentUser = await ParseUser.currentUser() as ParseUser?;
      if (currentUser == null) {
        throw Exception("User not logged in");
      }

      final query = QueryBuilder<ParseObject>(ParseObject('aboutYou'))
        ..whereEqualTo('userPointer', currentUser.toPointer());
      final queryResult = await query.query();

      ParseObject aboutYou;
      if (queryResult.success &&
          queryResult.results != null &&
          queryResult.results!.isNotEmpty) {
        aboutYou = queryResult.results!.first as ParseObject;
      } else {
        aboutYou = ParseObject('aboutYou')
          ..set('userPointer', currentUser.toPointer());
      }

      aboutYou.set('Kids', kidsPlan);
      final response = await aboutYou.save();

      if (!response.success) {
        throw Exception("Failed to save : ${response.error?.message}");
      }

      Get.snackbar("Success", "");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  //load plan for kids
  Future<String> loadPlanForKids() async {
    try {
      final currentUser = await ParseUser.currentUser() as ParseUser?;
      if (currentUser == null) {
        throw Exception("User not logged in");
      }

      final query = QueryBuilder<ParseObject>(ParseObject('aboutYou'))
        ..whereEqualTo('userPointer', currentUser.toPointer());
      final queryResult = await query.query();

      if (queryResult.success &&
          queryResult.results != null &&
          queryResult.results!.isNotEmpty) {
        final aboutYou = queryResult.results!.first as ParseObject;
        return aboutYou.get<String>('Kids') ?? "";
      }
      return "";
    } catch (e) {
      throw Exception("Failed to load : $e");
    }
  }

  //save haveKids
  Future<void> saveHaveKids(String kids) async {
    try {
      final currentUser = await ParseUser.currentUser() as ParseUser?;
      if (currentUser == null) {
        throw Exception("User not logged in");
      }

      final query = QueryBuilder<ParseObject>(ParseObject('aboutYou'))
        ..whereEqualTo('userPointer', currentUser.toPointer());
      final queryResult = await query.query();

      ParseObject aboutYou;
      if (queryResult.success &&
          queryResult.results != null &&
          queryResult.results!.isNotEmpty) {
        aboutYou = queryResult.results!.first as ParseObject;
      } else {
        aboutYou = ParseObject('aboutYou')
          ..set('userPointer', currentUser.toPointer());
      }

      aboutYou.set('haveKids', kids);
      final response = await aboutYou.save();

      if (!response.success) {
        throw Exception("Failed to save : ${response.error?.message}");
      }

      Get.snackbar("Success", "");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  //load haveKids
  Future<String> loadHaveKids() async {
    try {
      final currentUser = await ParseUser.currentUser() as ParseUser?;
      if (currentUser == null) {
        throw Exception("User not logged in");
      }

      final query = QueryBuilder<ParseObject>(ParseObject('aboutYou'))
        ..whereEqualTo('userPointer', currentUser.toPointer());
      final queryResult = await query.query();

      if (queryResult.success &&
          queryResult.results != null &&
          queryResult.results!.isNotEmpty) {
        final aboutYou = queryResult.results!.first as ParseObject;
        return aboutYou.get<String>('haveKids') ?? "";
      }
      return "";
    } catch (e) {
      throw Exception("Failed to load : $e");
    }
  }

  //save zodiac
  Future<void> saveZodiac(String zodiac) async {
    try {
      final currentUser = await ParseUser.currentUser() as ParseUser?;
      if (currentUser == null) {
        throw Exception("User not logged in");
      }

      final query = QueryBuilder<ParseObject>(ParseObject('aboutYou'))
        ..whereEqualTo('userPointer', currentUser.toPointer());
      final queryResult = await query.query();

      ParseObject aboutYou;
      if (queryResult.success &&
          queryResult.results != null &&
          queryResult.results!.isNotEmpty) {
        aboutYou = queryResult.results!.first as ParseObject;
      } else {
        aboutYou = ParseObject('aboutYou')
          ..set('userPointer', currentUser.toPointer());
      }

      aboutYou.set('Zodiac', zodiac);
      final response = await aboutYou.save();

      if (!response.success) {
        throw Exception("Failed to save : ${response.error?.message}");
      }

      Get.snackbar("Success", "");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  //load zodiac
  Future<String> loadZodiac() async {
    try {
      final currentUser = await ParseUser.currentUser() as ParseUser?;
      if (currentUser == null) {
        throw Exception("User not logged in");
      }

      final query = QueryBuilder<ParseObject>(ParseObject('aboutYou'))
        ..whereEqualTo('userPointer', currentUser.toPointer());
      final queryResult = await query.query();

      if (queryResult.success &&
          queryResult.results != null &&
          queryResult.results!.isNotEmpty) {
        final aboutYou = queryResult.results!.first as ParseObject;
        return aboutYou.get<String>('Zodiac') ?? "";
      }
      return "";
    } catch (e) {
      throw Exception("Failed to load : $e");
    }
  }

  //save politicalLeanings
  Future<void> savePoliticalLeaning(String politics) async {
    try {
      final currentUser = await ParseUser.currentUser() as ParseUser?;
      if (currentUser == null) {
        throw Exception("User not logged in");
      }

      final query = QueryBuilder<ParseObject>(ParseObject('aboutYou'))
        ..whereEqualTo('userPointer', currentUser.toPointer());
      final queryResult = await query.query();

      ParseObject aboutYou;
      if (queryResult.success &&
          queryResult.results != null &&
          queryResult.results!.isNotEmpty) {
        aboutYou = queryResult.results!.first as ParseObject;
      } else {
        aboutYou = ParseObject('aboutYou')
          ..set('userPointer', currentUser.toPointer());
      }

      aboutYou.set('Politics', politics);
      final response = await aboutYou.save();

      if (!response.success) {
        throw Exception("Failed to save : ${response.error?.message}");
      }

      Get.snackbar("Success", "");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  //load politicalLeaning
  Future<String> loadPoliticalLeaning() async {
    try {
      final currentUser = await ParseUser.currentUser() as ParseUser?;
      if (currentUser == null) {
        throw Exception("User not logged in");
      }

      final query = QueryBuilder<ParseObject>(ParseObject('aboutYou'))
        ..whereEqualTo('userPointer', currentUser.toPointer());
      final queryResult = await query.query();

      if (queryResult.success &&
          queryResult.results != null &&
          queryResult.results!.isNotEmpty) {
        final aboutYou = queryResult.results!.first as ParseObject;
        return aboutYou.get<String>('Politics') ?? "";
      }
      return "";
    } catch (e) {
      throw Exception("Failed to load : $e");
    }
  }

  //save lookingFor
  Future<void> saveLookingFor(List<String> selectedOptions) async {
    try {
      final currentUser = await ParseUser.currentUser() as ParseUser?;
      if (currentUser == null) {
        throw Exception("User not logged in");
      }

      final query = QueryBuilder<ParseObject>(ParseObject('aboutYou'))
        ..whereEqualTo('userPointer', currentUser.toPointer());
      final queryResult = await query.query();

      ParseObject aboutYou;
      if (queryResult.success &&
          queryResult.results != null &&
          queryResult.results!.isNotEmpty) {
        aboutYou = queryResult.results!.first as ParseObject;
      } else {
        aboutYou = ParseObject('aboutYou')
          ..set('userPointer', currentUser.toPointer());
      }

      aboutYou.set('lookingFor', selectedOptions);
      final response = await aboutYou.save();

      if (!response.success) {
        throw Exception("Failed to save options: ${response.error?.message}");
      }

      Get.snackbar("Success", "Looking for options saved successfully!");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  //load lookingFor
  Future<List<String>> loadLookingFor() async {
    try {
      final currentUser = await ParseUser.currentUser() as ParseUser?;
      if (currentUser == null) {
        throw Exception("User not logged in");
      }

      final query = QueryBuilder<ParseObject>(ParseObject('aboutYou'))
        ..whereEqualTo('userPointer', currentUser.toPointer());
      final queryResult = await query.query();

      if (queryResult.success &&
          queryResult.results != null &&
          queryResult.results!.isNotEmpty) {
        return (queryResult.results!.first as ParseObject)
                .get<List<dynamic>>('lookingFor')
                ?.cast<String>() ??
            [];
      }

      return [];
    } catch (e) {
      Get.snackbar("Error", e.toString());
      return [];
    }
  }

  //save religion
  Future<void> saveReligion(String religion) async {
    try {
      final currentUser = await ParseUser.currentUser() as ParseUser?;
      if (currentUser == null) {
        throw Exception("User not logged in");
      }

      final query = QueryBuilder<ParseObject>(ParseObject('aboutYou'))
        ..whereEqualTo('userPointer', currentUser.toPointer());
      final queryResult = await query.query();

      ParseObject aboutYou;
      if (queryResult.success &&
          queryResult.results != null &&
          queryResult.results!.isNotEmpty) {
        aboutYou = queryResult.results!.first as ParseObject;
      } else {
        aboutYou = ParseObject('aboutYou')
          ..set('userPointer', currentUser.toPointer());
      }

      aboutYou.set('Religion', religion);
      final response = await aboutYou.save();

      if (!response.success) {
        throw Exception("Failed to save : ${response.error?.message}");
      }

      Get.snackbar("Success", "");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  //load religion
  Future<String> loadReligion() async {
    try {
      final currentUser = await ParseUser.currentUser() as ParseUser?;
      if (currentUser == null) {
        throw Exception("User not logged in");
      }

      final query = QueryBuilder<ParseObject>(ParseObject('aboutYou'))
        ..whereEqualTo('userPointer', currentUser.toPointer());
      final queryResult = await query.query();

      if (queryResult.success &&
          queryResult.results != null &&
          queryResult.results!.isNotEmpty) {
        final aboutYou = queryResult.results!.first as ParseObject;
        return aboutYou.get<String>('Religion') ?? "";
      }
      return "";
    } catch (e) {
      throw Exception("Failed to load : $e");
    }
  }

  //save interests
  Future<void> saveUserInterests(List<String> selectedInterests) async {
    try {
      final currentUser = await ParseUser.currentUser() as ParseUser?;
      if (currentUser == null) {
        throw Exception("User not logged in");
      }

      final query = QueryBuilder<ParseObject>(ParseObject('aboutYou'))
        ..whereEqualTo('userPointer', currentUser.toPointer());
      final queryResult = await query.query();

      ParseObject aboutYou;
      if (queryResult.success &&
          queryResult.results != null &&
          queryResult.results!.isNotEmpty) {
        aboutYou = queryResult.results!.first as ParseObject;
      } else {
        aboutYou = ParseObject('aboutYou')
          ..set('userPointer', currentUser.toPointer());
      }

      aboutYou.set('Interests', selectedInterests);

      final response = await aboutYou.save();

      if (!response.success) {
        throw Exception("Failed to save interests: ${response.error?.message}");
      }
      interests.assignAll(selectedInterests);

      Get.snackbar("Success", "Interests saved successfully!");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  //load interests
  Future<List<String>> getUserInterests() async {
    try {
      final currentUser = await ParseUser.currentUser() as ParseUser?;
      if (currentUser == null) {
        throw Exception("User not logged in");
      }

      final query = QueryBuilder<ParseObject>(ParseObject('aboutYou'))
        ..whereEqualTo('userPointer', currentUser.toPointer());
      final queryResult = await query.query();

      if (queryResult.success &&
          queryResult.results != null &&
          queryResult.results!.isNotEmpty) {
        final aboutYou = queryResult.results!.first as ParseObject;
        final fetchedInterests = aboutYou.get<List<dynamic>>('Interests') ?? [];
        return fetchedInterests.map((e) => e.toString()).toList();
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
    return [];
  }

  var interests = <String>[].obs;

  Future<void> loadUserInterests() async {
    final fetchedInterests = await getUserInterests();
    interests.assignAll(fetchedInterests);
  }

  //save causes
  Future<void> saveUserCauses(List<String> selectedCauses) async {
    try {
      final currentUser = await ParseUser.currentUser() as ParseUser?;
      if (currentUser == null) {
        throw Exception("User not logged in");
      }

      final query = QueryBuilder<ParseObject>(ParseObject('aboutYou'))
        ..whereEqualTo('userPointer', currentUser.toPointer());
      final queryResult = await query.query();

      ParseObject aboutYou;
      if (queryResult.success &&
          queryResult.results != null &&
          queryResult.results!.isNotEmpty) {
        aboutYou = queryResult.results!.first as ParseObject;
      } else {
        aboutYou = ParseObject('aboutYou')
          ..set('userPointer', currentUser.toPointer());
      }

      aboutYou.set('Causes', selectedCauses);

      final response = await aboutYou.save();

      if (!response.success) {
        throw Exception("Failed to save interests: ${response.error?.message}");
      }
      causes.assignAll(selectedCauses);

      Get.snackbar("Success", "Interests saved successfully!");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  //load causes
  Future<List<String>> getUserCauses() async {
    try {
      final currentUser = await ParseUser.currentUser() as ParseUser?;
      if (currentUser == null) {
        throw Exception("User not logged in");
      }

      final query = QueryBuilder<ParseObject>(ParseObject('aboutYou'))
        ..whereEqualTo('userPointer', currentUser.toPointer());
      final queryResult = await query.query();

      if (queryResult.success &&
          queryResult.results != null &&
          queryResult.results!.isNotEmpty) {
        final aboutYou = queryResult.results!.first as ParseObject;
        final fetchedCauses = aboutYou.get<List<dynamic>>('Causes') ?? [];
        return fetchedCauses.map((e) => e.toString()).toList();
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
    return [];
  }

  var causes = <String>[].obs;

  Future<void> loadUserCauses() async {
    final fetchedCauses = await getUserCauses();
    causes.assignAll(fetchedCauses);
  }

  //save qualities
  Future<void> saveUserQualities(List<String> selectedQuality) async {
    try {
      final currentUser = await ParseUser.currentUser() as ParseUser?;
      if (currentUser == null) {
        throw Exception("User not logged in");
      }

      final query = QueryBuilder<ParseObject>(ParseObject('aboutYou'))
        ..whereEqualTo('userPointer', currentUser.toPointer());
      final queryResult = await query.query();

      ParseObject aboutYou;
      if (queryResult.success &&
          queryResult.results != null &&
          queryResult.results!.isNotEmpty) {
        aboutYou = queryResult.results!.first as ParseObject;
      } else {
        aboutYou = ParseObject('aboutYou')
          ..set('userPointer', currentUser.toPointer());
      }

      aboutYou.set('Qualities', selectedQuality);

      final response = await aboutYou.save();

      if (!response.success) {
        throw Exception("Failed to save interests: ${response.error?.message}");
      }
      quality.assignAll(selectedQuality);

      Get.snackbar("Success", "Interests saved successfully!");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

// load qualities
  Future<List<String>> getUserQualities() async {
    try {
      final currentUser = await ParseUser.currentUser() as ParseUser?;
      if (currentUser == null) {
        throw Exception("User not logged in");
      }

      final query = QueryBuilder<ParseObject>(ParseObject('aboutYou'))
        ..whereEqualTo('userPointer', currentUser.toPointer());
      final queryResult = await query.query();

      if (queryResult.success &&
          queryResult.results != null &&
          queryResult.results!.isNotEmpty) {
        final aboutYou = queryResult.results!.first as ParseObject;
        final fetchedQuality = aboutYou.get<List<dynamic>>('Qualities') ?? [];
        return fetchedQuality.map((e) => e.toString()).toList();
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
    return [];
  }

  var quality = <String>[].obs;

  Future<void> loadUserQuality() async {
    final fetchedQuality = await getUserQualities();
    quality.assignAll(fetchedQuality);
  }

  //save user bio
  Future<void> updateUserBio(String bio) async {
    try {
      final ParseUser? currentUser = await ParseUser.currentUser();
      if (currentUser == null) {
        throw Exception("User not logged in");
      }

      final QueryBuilder<ParseObject> query =
          QueryBuilder<ParseObject>(ParseObject('aboutYou'))
            ..whereEqualTo('userPointer', currentUser.toPointer());
      final ParseResponse response = await query.query();

      ParseObject aboutYouObject;
      if (response.success &&
          response.results != null &&
          response.results!.isNotEmpty) {
        aboutYouObject = response.results!.first as ParseObject;
      } else {
        aboutYouObject = ParseObject('aboutYou');
        aboutYouObject.set('userPointer', currentUser.toPointer());
      }

      aboutYouObject.set<String>('Bio', bio);

      final ParseResponse saveResponse = await aboutYouObject.save();
      if (saveResponse.success) {
        print("Bio updated successfully.");
      } else {
        print("Error updating bio: ${saveResponse.error?.message}");
      }
    } catch (e) {
      Get.snackbar("Error", "Exception updating bio: $e");
    }
  }

  //get user bio
  Future<String> getUserBio() async {
    try {
      final ParseUser? currentUser = await ParseUser.currentUser();
      if (currentUser == null) return '';

      final QueryBuilder<ParseObject> query =
          QueryBuilder<ParseObject>(ParseObject('aboutYou'))
            ..whereEqualTo('userPointer', currentUser.toPointer());
      final ParseResponse response = await query.query();

      if (response.success &&
          response.results != null &&
          response.results!.isNotEmpty) {
        final aboutYou = response.results!.first as ParseObject;
        return aboutYou.get<String>('Bio') ?? '';
      }
    } catch (e) {
      Get.snackbar("Error", "Exception getting bio: $e");
    }
    return '';
  }

  //save user gender and show on Profile
  Future<void> saveUserAge(String gender, bool showOnProfile) async {
    try {
      final currentUser = await ParseUser.currentUser() as ParseUser?;
      if (currentUser == null) {
        throw Exception("User not logged in");
      }

      final query = QueryBuilder<ParseObject>(ParseObject('Basic'))
        ..whereEqualTo('userPointer', currentUser.toPointer());
      final queryResult = await query.query();

      ParseObject aboutYou;
      if (queryResult.success &&
          queryResult.results != null &&
          queryResult.results!.isNotEmpty) {
        aboutYou = queryResult.results!.first as ParseObject;
      } else {
        aboutYou = ParseObject('Basic')
          ..set('userPointer', currentUser.toPointer());
      }

      aboutYou
        ..set('Gender', gender)
        ..set('showOnProfile', showOnProfile);

      final response = await aboutYou.save();

      if (!response.success) {
        throw Exception("Failed to save data: ${response.error?.message}");
      }

      Get.snackbar("Success", "Profile updated successfully!");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  //get user gender and show on profile
  Future<Map<String, dynamic>?> getUserGender() async {
    try {
      final currentUser = await ParseUser.currentUser() as ParseUser?;
      if (currentUser == null) {
        throw Exception("User not logged in");
      }

      final query = QueryBuilder<ParseObject>(ParseObject('Basic'))
        ..whereEqualTo('userPointer', currentUser.toPointer());
      final queryResult = await query.query();

      if (queryResult.success &&
          queryResult.results != null &&
          queryResult.results!.isNotEmpty) {
        final aboutYou = queryResult.results!.first as ParseObject;
        return {
          "gender": aboutYou.get<String>('Gender') ?? "",
          "showOnProfile": aboutYou.get<bool>('showOnProfile') ?? true,
        };
      }

      return null;
    } catch (e) {
      Get.snackbar("Error", e.toString());
      return null;
    }
  }

// fetch User matches from database
  Future<List> fetchMatches() async {
    final currentUser = await ParseUser.currentUser() as ParseUser?;
    if (currentUser == null) return [];

    final query = QueryBuilder<ParseObject>(ParseObject('UserInteractions'))
      ..whereEqualTo('fromUser', currentUser)
      ..whereEqualTo('isMatch', true)
      ..includeObject(['toUser']);

    final response = await query.query();

    if (response.success && response.results != null) {
      return response.results!
          .map((interaction) => interaction.get<ParseUser>('toUser')!)
          .toList();
    }
    return [];
  }

//save user swipe interaction
  Future<bool> saveInteraction({
    required ParseUser fromUser,
    required ParseUser toUser,
    required String interactionType,
  }) async {
    final reverseQuery =
        QueryBuilder<ParseObject>(ParseObject('UserInteractions'))
          ..whereEqualTo('fromUser', toUser)
          ..whereEqualTo('toUser', fromUser)
          ..whereContainedIn('interactionType', ['like', 'superlike']);

    final reverseResult = await reverseQuery.query();

    final isMutual = reverseResult.success &&
        reverseResult.results != null &&
        reverseResult.results!.isNotEmpty;

    final newInteraction = ParseObject('UserInteractions')
      ..set('fromUser', fromUser)
      ..set('toUser', toUser)
      ..set('interactionType', interactionType)
      ..set('isMatch', isMutual);

    await newInteraction.save();

    if (isMutual) {
      final reverseInteraction = reverseResult.results!.first;
      reverseInteraction.set('isMatch', true);
      await reverseInteraction.save();
    }

    return isMutual;
  }

//save location in db
  final loc.Location location = loc.Location();

  Future<void> fetchAndSaveUserLocation() async {
    bool _serviceEnabled;
    loc.PermissionStatus _permissionGranted;

    // Check service
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) return;
    }

    // Check permission
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == loc.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != loc.PermissionStatus.granted) return;
    }

    // Get location
    final currentLocation = await location.getLocation();
    final geoPoint = ParseGeoPoint(
      latitude: currentLocation.latitude!,
      longitude: currentLocation.longitude!,
    );

    final currentUser = await ParseUser.currentUser() as ParseUser?;
    if (currentUser == null) return;

    final loginQuery = QueryBuilder<ParseObject>(ParseObject('UserLogin'))
      ..whereEqualTo('userPointer', currentUser);

    final result = await loginQuery.query();

    if (result.success && result.results != null && result.results!.isNotEmpty) {
      final userLogin = result.results!.first;
      userLogin.set('location', geoPoint);
      await userLogin.save();
    }
  }




  //fetch location from db
  Future<String?> fetchAndDisplayUserLocation() async {
    final currentUser = await ParseUser.currentUser() as ParseUser?;
    if (currentUser == null) return null;

    final loginQuery = QueryBuilder<ParseObject>(ParseObject('UserLogin'))
      ..whereEqualTo('userPointer', currentUser);

    final result = await loginQuery.query();

    if (result.success && result.results != null && result.results!.isNotEmpty) {
      final userLogin = result.results!.first;
      final geoPoint = userLogin.get<ParseGeoPoint>('location');
      if (geoPoint == null) return null;

      final placemarks = await geo.placemarkFromCoordinates(
        geoPoint.latitude!,
        geoPoint.longitude!,
      );

      final place = placemarks.first;
      final locationString =
          "${place.locality}, ${place.administrativeArea}, ${place.country}";
      return locationString;
    }

    return null;
  }


}
