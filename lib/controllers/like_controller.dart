
import 'package:get/get.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class LikesController extends GetxController {
  var profiles = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    fetchProfiles();
    super.onInit();
  }

  Future<void> fetchProfiles() async {
    final currentUser = await ParseUser.currentUser() as ParseUser?;
    if (currentUser == null) return;

    final interactionQuery =
    QueryBuilder<ParseObject>(ParseObject('UserInteractions'))
      ..whereEqualTo('toUser', currentUser)
      ..whereEqualTo('isMatch', false);

    final interactionResults = await interactionQuery.find();

    final fromUsers = interactionResults
        .map((e) => e.get<ParseUser>('fromUser'))
        .whereType<ParseUser>()
        .toList();

    if (fromUsers.isEmpty) return;

    final loginQuery = QueryBuilder<ParseObject>(ParseObject('UserLogin'))
      ..whereContainedIn('userPointer', fromUsers)
      ..whereEqualTo('isProfileComplete', true);

    final loginResults = await loginQuery.find();

    final userPointers = loginResults
        .map((obj) => obj.get<ParseUser>('userPointer'))
        .whereType<ParseUser>()
        .toList();

    final bioQuery = QueryBuilder<ParseObject>(ParseObject('aboutYou'))
      ..whereContainedIn('userPointer', userPointers);
    final bioResults = await bioQuery.find();

    final bioMap = {
      for (var b in bioResults)
        b.get<ParseUser>('userPointer')?.objectId: b.get<String>('Bio') ?? ''
    };

    final fetched = <Map<String, dynamic>>[];

    for (final object in loginResults) {
      final userPointer = object.get<ParseUser>('userPointer');
      final objectId = userPointer?.objectId;
      final dob = object.get<DateTime>('dob');
      final imageUrl = object.get<ParseFile>('imageProfile')?.url ?? '';
      final bio = bioMap[objectId] ?? 'User has no bio';

      fetched.add({
        'name': object.get<String>('name') ?? '',
        'dob': dob,
        'imageUrl': imageUrl,
        'bio': bio,
        'userPointer': userPointer,
      });
    }

    profiles.value = fetched;
  }

  int calculateAge(DateTime dob) {
    final today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }

  Future<void> skipProfile(int index) async {
    final currentUser = await ParseUser.currentUser() as ParseUser?;
    final fromUser = profiles[index]['userPointer'] as ParseUser?;

    final query = QueryBuilder<ParseObject>(ParseObject('UserInteractions'))
      ..whereEqualTo('toUser', currentUser)
      ..whereEqualTo('fromUser', fromUser);

    final results = await query.find();
    for (final interaction in results) {
      await interaction.delete();
    }

    profiles.removeAt(index);
  }
}
