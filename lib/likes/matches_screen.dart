import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../chats/message_screen.dart';

class YourMatchScreen extends StatefulWidget {
  const YourMatchScreen({super.key});

  @override
  State<YourMatchScreen> createState() => _YourMatchScreenState();
}

class _YourMatchScreenState extends State<YourMatchScreen> {

  Future<List<Map<String, dynamic>>> fetchProfiles() async {
    final currentUser = await ParseUser.currentUser() as ParseUser?;
    if (currentUser == null) return [];


    final interactionQuery = QueryBuilder<ParseObject>(ParseObject('UserInteractions'))
      ..whereEqualTo('fromUser', currentUser)
      ..whereEqualTo('isMatch', true);

    final interactionResults = await interactionQuery.find();

    final toUsers = interactionResults
        .map((e) => e.get<ParseUser>('toUser'))
        .whereType<ParseUser>()
        .toList();

    if (toUsers.isEmpty) return [];

    final loginQuery = QueryBuilder<ParseObject>(ParseObject('UserLogin'))
      ..whereContainedIn('userPointer', toUsers)
      ..whereEqualTo('isProfileComplete', true);

    final loginResults = await loginQuery.find();

    final userPointers = loginResults
        .map((obj) => obj.get<ParseUser>('userPointer'))
        .whereType<ParseUser>()
        .toList();

    final basicQuery = QueryBuilder<ParseObject>(ParseObject('Basic'))
      ..whereContainedIn('userPointer', userPointers);
    final basicResults = await basicQuery.find();

    final bioQuery = QueryBuilder<ParseObject>(ParseObject('aboutYou'))
      ..whereContainedIn('userPointer', userPointers);
    final bioResults = await bioQuery.find();

    final basicMap = {
      for (var b in basicResults)
        b.get<ParseUser>('userPointer')?.objectId: b
    };

    final bioMap = {
      for (var b in bioResults)
        b.get<ParseUser>('userPointer')?.objectId: b.get<String>('Bio') ?? ''
    };

    final fetchedProfiles = <Map<String, dynamic>>[];

    for (final object in loginResults) {
      final userPointer = object.get<ParseUser>('userPointer');
      final objectId = userPointer?.objectId;
      final dob = object.get<DateTime>('dob');
      final imageUrl = object.get<ParseFile>('imageProfile')?.url ?? '';
      final basic = basicMap[objectId];
      final bio = bioMap[objectId] ?? 'User has no bio';

      fetchedProfiles.add({
        'name': object.get<String>('name') ?? '',
        'dob': dob,
        'imageUrl': imageUrl,
        'bio': bio,
        'userPointer': userPointer,
      });
    }

    return fetchedProfiles;
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


  Future<ParseObject?> getOrCreateChatRoom(ParseUser sender, ParseUser receiver) async {
    final query1 = QueryBuilder<ParseObject>(ParseObject('ChatRoom'))
      ..whereEqualTo('sender', sender)
      ..whereEqualTo('receiver', receiver);

    final query2 = QueryBuilder<ParseObject>(ParseObject('ChatRoom'))
      ..whereEqualTo('sender', receiver)
      ..whereEqualTo('receiver', sender);

    final res1 = await query1.query();
    final res2 = await query2.query();

    if (res1.success && res1.results != null && res1.results!.isNotEmpty) {
      return res1.results!.first;
    }

    if (res2.success && res2.results != null && res2.results!.isNotEmpty) {
      return res2.results!.first;
    }

    final newChatRoom = ParseObject('ChatRoom')
      ..set('sender', sender)
      ..set('receiver', receiver);

    final saveRes = await newChatRoom.save();
    return saveRes.success ? saveRes.results?.first : null;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchProfiles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final profiles = snapshot.data ?? [];

          if (profiles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.swipe, size: 80, color: Colors.grey),
                  SizedBox(height: 12),
                  Text("No matches yet!, Keep Swiping", style: TextStyle(fontSize: 18)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: profiles.length,
            itemBuilder: (context, index) {
              final profile = profiles[index];
              final name = profile['name'] ?? '';
              final dob = profile['dob'] as DateTime?;
              final imageUrl = profile['imageUrl'] ?? '';
              final age = dob != null ? calculateAge(dob) : '';
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius:
                            BorderRadius.vertical(top: Radius.circular(16)),
                            child: Image.network(
                              imageUrl,
                              height: 300,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 300,
                                color: Colors.grey[300],
                                child: Center(child: Icon(Icons.person, size: 100)),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 28,
                            left: 0,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              child: Text("$name, $age",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 24)),
                            ),
                          ),
                          Positioned(
                            bottom: 3,
                            left: 0,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              child: Text("10 miles away",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18)),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(profile['bio'] ?? 'User has no bio',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final currentUser = await ParseUser.currentUser() as ParseUser;
                                  final matchedUser = profile['userPointer'] as ParseUser;

                                  final chatRoom = await getOrCreateChatRoom(currentUser, matchedUser);

                                  if (chatRoom != null) {
                                    Get.to(() => ChatScreen(), arguments: {
                                      'chatRoomId': chatRoom.objectId,
                                      'receiverName': profile['name'] ?? 'User',
                                    });
                                  } else {
                                    Get.snackbar("Error", "Failed to start chat.");
                                  }
                                },
                                icon: Icon(Icons.message, color: Colors.white),
                                label: Text("Send Message",
                                    style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink,

                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
