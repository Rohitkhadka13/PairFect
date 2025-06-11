import 'package:get/get.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class ProfileController extends GetxController {
  var profiles = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfiles();
  }

  Future<void> fetchProfiles() async {
    final currentUser = await ParseUser.currentUser() as ParseUser?;
    if (currentUser == null) return;

    final interactionQuery =
    QueryBuilder<ParseObject>(ParseObject('UserInteractions'))
      ..whereEqualTo('fromUser', currentUser);
    final interactionResults = await interactionQuery.find();

    final interactedUserPointers = <ParseUser>{};
    for (final interaction in interactionResults) {
      final toUser = interaction.get<ParseUser>('toUser');
      if (toUser != null) interactedUserPointers.add(toUser);
    }

    final query = QueryBuilder<ParseObject>(ParseObject('UserLogin'))
      ..whereNotEqualTo('userPointer', currentUser)
      ..whereEqualTo('isProfileComplete', true)
      ..setLimit(10);

    if (interactedUserPointers.isNotEmpty) {
      query.whereNotContainedIn('userPointer', interactedUserPointers.toList());
    }

    final results = await query.find();
    results.shuffle();
    final selected = results.take(5).toList();

    final fetchedProfiles = <Map<String, dynamic>>[];

    for (final object in selected) {
      final userPointer = object.get<ParseUser>('userPointer');
      final dob = object.get<DateTime>('dob');
      final imageFile = object.get<ParseFile>('imageProfile');

      final aboutQuery = QueryBuilder<ParseObject>(ParseObject('aboutYou'))
        ..whereEqualTo('userPointer', userPointer);
      final aboutResult = await aboutQuery.query();

      String? religion, zodiac, height, exercise, politics, smoking, drinking;
      List<String> lookingFor = [];

      if (aboutResult.success &&
          aboutResult.results != null &&
          aboutResult.results!.isNotEmpty) {
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

      final basicQuery = QueryBuilder<ParseObject>(ParseObject('Basic'))
        ..whereEqualTo('userPointer', userPointer);
      final basicResult = await basicQuery.query();

      String? gender;
      if (basicResult.success &&
          basicResult.results != null &&
          basicResult.results!.isNotEmpty) {
        final basic = basicResult.results!.first;
        gender = basic.get<String>('Gender');
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
        'gender': gender,
        'lookingFor': lookingFor,
        'userPointer': userPointer,
      });
    }

    profiles.value = fetchedProfiles;
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

  Future<bool> reportUser(ParseUser targetUser, String reason, {String status = 'pending'}) async {
    final currentUser = await ParseUser.currentUser() as ParseUser?;
    if (currentUser == null) return false;

    final report = ParseObject('Reports')
      ..set('fromUser', currentUser.toPointer())
      ..set('toUser', targetUser.toPointer())
      ..set('reason', reason)
      ..set('status', status);

    final response = await report.save();
    return response.success;
  }

}
