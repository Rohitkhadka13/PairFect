import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class ProfileController extends GetxController {
  var profiles = <Map<String, dynamic>>[].obs;
  final PageController pageController = PageController();
  final RxInt currentIndex = 0.obs;

  void setCurrentIndex(int index) {
    currentIndex.value = index;
  }
  @override
  void onInit() {
    super.onInit();
    fetchProfiles();
  }
  double calculateDistanceMiles(
      double lat1, double lon1, double lat2, double lon2)
  {
    const earthRadius = 3958.8; 
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);

    final a =
        (sin(dLat / 2) * sin(dLat / 2)) +
            cos(_degToRad(lat1)) * cos(_degToRad(lat2)) *
                (sin(dLon / 2) * sin(dLon / 2));
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degToRad(double deg) => deg * (pi / 180);


  Future<void> fetchProfiles({int? ageStart, int? ageEnd, String? gender, int? locationMiles}) async {
    final currentUser = await ParseUser.currentUser() as ParseUser?;
    if (currentUser == null) return;

    final currentLoginQuery = QueryBuilder<ParseObject>(ParseObject('UserLogin'))
      ..whereEqualTo('userPointer', currentUser);
    final currentLoginResult = await currentLoginQuery.first();
    final userLocation = currentLoginResult?.get<ParseGeoPoint>('location');
    final userDOB = currentLoginResult?.get<DateTime>('dob');

    if (userLocation == null || userDOB == null) return;

    final interactionQuery = QueryBuilder<ParseObject>(ParseObject('UserInteractions'))
      ..whereEqualTo('fromUser', currentUser);
    final interactionResponse = await interactionQuery.query();

    final interactedUserPointers = <ParseUser>{};
    if (interactionResponse.success && interactionResponse.results != null) {
      for (final interaction in interactionResponse.results!) {
        final toUser = interaction.get<ParseUser>('toUser');
        if (toUser != null) interactedUserPointers.add(toUser);
      }
    }

    final query = QueryBuilder<ParseObject>(ParseObject('UserLogin'))
      ..whereNotEqualTo('userPointer', currentUser)
      ..whereEqualTo('isProfileComplete', true)
      ..setLimit(20);

    if (interactedUserPointers.isNotEmpty) {
      query.whereNotContainedIn('userPointer', interactedUserPointers.toList());
    }

    if (gender != null && gender != "All") {
      final basicQuery = QueryBuilder<ParseObject>(ParseObject('Basic'))
        ..whereEqualTo('Gender', gender);

      final basicResult = await basicQuery.query();
      final genderMatchedUsers = basicResult.results
          ?.map((obj) => obj.get<ParseUser>('userPointer'))
          .whereType<ParseUser>()
          .toList();

      if (genderMatchedUsers != null && genderMatchedUsers.isNotEmpty) {
        query.whereContainedIn('userPointer', genderMatchedUsers);
      }
    }

    final resultsResponse = await query.query();
    if (!resultsResponse.success || resultsResponse.results == null) {
      profiles.value = [];
      return;
    }

    final List<Map<String, dynamic>> fetchedProfiles = [];

    for (final object in resultsResponse.results!) {
      final userPointer = object.get<ParseUser>('userPointer');
      final dob = object.get<DateTime>('dob');
      final imageFile = object.get<ParseFile>('imageProfile');
      final targetLocation = object.get<ParseGeoPoint>('location');

      if (dob == null || targetLocation == null) continue;

      final age = DateTime.now().year - dob.year;
      final distanceMiles = calculateDistanceMiles(
        userLocation.latitude,
        userLocation.longitude,
        targetLocation.latitude,
        targetLocation.longitude,
      );

      // Filter by age
      if (ageStart != null && ageEnd != null && (age < ageStart || age > ageEnd)) continue;

      // Filter by location
      if (locationMiles != null && distanceMiles > locationMiles) continue;

      // aboutYou data
      String? religion, zodiac, height, exercise, politics, smoking, drinking;
      List<String> lookingFor = [];

      final aboutQuery = QueryBuilder<ParseObject>(ParseObject('aboutYou'))
        ..whereEqualTo('userPointer', userPointer);
      final aboutResult = await aboutQuery.query();

      if (aboutResult.success && aboutResult.results != null && aboutResult.results!.isNotEmpty) {
        final about = aboutResult.results!.first;
        religion = about.get<String>('Religion');
        zodiac = about.get<String>('Zodiac');
        height = about.get<String>('Height');
        exercise = about.get<String>('Exercise');
        politics = about.get<String>('Politics');
        smoking = about.get<String>('Smoking');
        drinking = about.get<String>('Drinking');
        lookingFor = List<String>.from(about.get<List>('lookingFor') ?? []);
      }

      // Basic gender
      String? genderFromBasic;
      final basicQuery = QueryBuilder<ParseObject>(ParseObject('Basic'))
        ..whereEqualTo('userPointer', userPointer);
      final basicResult = await basicQuery.query();

      if (basicResult.success && basicResult.results != null && basicResult.results!.isNotEmpty) {
        genderFromBasic = basicResult.results!.first.get<String>('Gender');
      }

      fetchedProfiles.add({
        'name': object.get<String>('name') ?? '',
        'dob': dob,
        'imageUrl': imageFile?.url ?? '',
        'religion': religion,
        'zodiac': zodiac,
        'height': height,
        'exercise': exercise,
        'politics': politics,
        'smoking': smoking,
        'drinking': drinking,
        'gender': genderFromBasic,
        'lookingFor': lookingFor,
        'userPointer': userPointer,
        'distance': distanceMiles.toStringAsFixed(1),
      });
    }

    fetchedProfiles.shuffle();
    profiles.value = fetchedProfiles.take(5).toList();
  }





  Future<bool> interactWithUser(ParseUser targetUser, String action) async {
    final currentUser = await ParseUser.currentUser() as ParseUser?;
    if (currentUser == null) return false;

    final reverseQuery = QueryBuilder<ParseObject>(ParseObject('UserInteractions'))
      ..whereEqualTo('fromUser', targetUser)
      ..whereEqualTo('toUser', currentUser)
      ..whereContainedIn('interactionType', ['like', 'superlike']);

    final reverseResult = await reverseQuery.query();

    bool isMatch = reverseResult.success &&
        reverseResult.results != null &&
        reverseResult.results!.isNotEmpty &&
        (action == 'like' || action == 'superlike');

    final interaction = ParseObject('UserInteractions')
      ..set('fromUser', currentUser.toPointer())
      ..set('toUser', targetUser.toPointer())
      ..set('interactionType', action)
      ..set('isMatch', isMatch);

    await interaction.save();

    profiles.removeWhere((profile) =>
    (profile['userPointer'] as ParseUser).objectId == targetUser.objectId);


    await fetchProfiles();

    return isMatch;
  }

  Future<void> reportUser(ParseObject toUser, String reason, {required String detail}) async {
    final currentUser = await ParseUser.currentUser() as ParseUser;

    final query = QueryBuilder<ParseObject>(ParseObject('Reports'))
      ..whereEqualTo('fromUser', currentUser)
      ..whereEqualTo('toUser', toUser);

    final List<ParseObject> results = await query.find();

    if (results.isNotEmpty) {
      Get.snackbar("Already Reported", "You have already reported this user.",
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    final report = ParseObject('Reports')
      ..set('fromUser', currentUser)
      ..set('toUser', toUser)
      ..set('reason', reason)
      ..set('details', detail)
      ..set('status', 'pending');

    final ParseResponse saveResponse = await report.save();

    if (saveResponse.success) {
      Get.snackbar("Reported", "Profile has been reported.",
          backgroundColor: Colors.black87, colorText: Colors.white);
    } else {
      Get.snackbar("Error", "Failed to report profile.",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }






}
