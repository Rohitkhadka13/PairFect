import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pairfect/profileScreen/moreAboutYou/height_screen.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../authScreen/home_screen.dart';
import '../authScreen/login_screen.dart';
import '../profileScreen/profile_screen.dart';

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


  @override
  void onInit() {
    super.onInit();
    initSharedPreferences();
    getUserInterests();
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
      imageFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (imageFile != null) {
        pickedFile.value = File(imageFile!.path);
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
            Get.offAll(() => HomeScreen());
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
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      await uploadImage(index, imageFile);
    }
  }

  // Upload an image to the database
  Future<void> uploadImage(int index, File imageFile) async {
    final parseFile = ParseFile(imageFile);
    await parseFile.save();

    final user = await ParseUser.currentUser() as ParseUser;
    final query = QueryBuilder<ParseObject>(ParseObject('UserImage'))
      ..whereEqualTo('UserPointer', user.toPointer());

    final response = await query.query();

    if (response.success &&
        response.results != null &&
        response.results!.isNotEmpty) {
      // Update existing record
      final userImage = response.results!.first;
      userImage.set('Image${index + 1}', parseFile);
      await userImage.save();
    } else {
      // Create new record
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
        jobs.clear(); // No jobs found
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
    try {
      final user = await ParseUser.currentUser() as ParseUser?;
      if (user == null) throw Exception("User not logged in");

      // Get the pointer to UserLogin
      final userPointer = user.get<ParseObject>('userPointer');
      if (userPointer != null) {
        // Set the isProfileComplete field in the UserLogin object
        userPointer.set('isProfileComplete', true);

        // Save the changes to the UserLogin object
        final response = await userPointer.save();

        if (!response.success) {
          throw Exception("Failed to update profile completion: ${response.error?.message}");
        }
      } else {
        throw Exception("UserPointer not found");
      }
    } catch (e) {
      throw Exception("Error setting profile completion: $e");
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
      if (queryResult.success && queryResult.results != null && queryResult.results!.isNotEmpty) {
        aboutYou = queryResult.results!.first as ParseObject;
      } else {
        aboutYou = ParseObject('aboutYou')..set('userPointer', currentUser.toPointer());
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

      if (queryResult.success && queryResult.results != null && queryResult.results!.isNotEmpty) {
        return (queryResult.results!.first as ParseObject).get<List<dynamic>>('lookingFor')?.cast<String>() ?? [];
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
      if (queryResult.success && queryResult.results != null && queryResult.results!.isNotEmpty) {
        aboutYou = queryResult.results!.first as ParseObject;
      } else {
        aboutYou = ParseObject('aboutYou')..set('userPointer', currentUser.toPointer());
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

      if (queryResult.success && queryResult.results != null && queryResult.results!.isNotEmpty) {
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
      if (queryResult.success && queryResult.results != null && queryResult.results!.isNotEmpty) {
        aboutYou = queryResult.results!.first as ParseObject;
      } else {
        aboutYou = ParseObject('aboutYou')..set('userPointer', currentUser.toPointer());
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

      if (queryResult.success && queryResult.results != null && queryResult.results!.isNotEmpty) {
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
    interests.assignAll(fetchedCauses);
  }

}


