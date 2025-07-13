import 'dart:math';
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
  ParseGeoPoint? _currentUserLocation;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserLocation();
  }

  Future<void> _fetchCurrentUserLocation() async {
    final currentUser = await ParseUser.currentUser() as ParseUser?;
    if (currentUser == null) return;

    final query = QueryBuilder<ParseObject>(ParseObject('UserLogin'))
      ..whereEqualTo('userPointer', currentUser);

    final response = await query.query();
    if (response.success && response.results != null && response.results!.isNotEmpty) {
      final location = response.results!.first.get<ParseGeoPoint>('location');
      setState(() {
        _currentUserLocation = location;
      });
    }
  }

  double _calculateDistanceInMiles(ParseGeoPoint otherLocation) {
    if (_currentUserLocation == null) return 0.0;

    const earthRadius = 6371.0;
    final lat1 = _currentUserLocation!.latitude * (pi / 180.0);
    final lon1 = _currentUserLocation!.longitude * (pi / 180.0);
    final lat2 = otherLocation.latitude * (pi / 180.0);
    final lon2 = otherLocation.longitude * (pi / 180.0);

    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final distanceInKm = earthRadius * c;

    return distanceInKm * 0.621371;
  }

  Future<List<Map<String, dynamic>>> fetchProfiles() async {
    final currentUser = await ParseUser.currentUser() as ParseUser?;
    if (currentUser == null) return [];

    if (_currentUserLocation == null) {
      await _fetchCurrentUserLocation();
    }

    final query1 = QueryBuilder<ParseObject>(ParseObject('UserInteractions'))
      ..whereEqualTo('fromUser', currentUser)
      ..whereEqualTo('isMatch', true);

    final query2 = QueryBuilder<ParseObject>(ParseObject('UserInteractions'))
      ..whereEqualTo('toUser', currentUser)
      ..whereEqualTo('isMatch', true);

    final results1 = await query1.query();
    final results2 = await query2.query();

    final matchedUsers = <ParseUser>[];
    if (results1.success && results1.results != null) {
      matchedUsers.addAll(results1.results!
          .map((e) => e.get<ParseUser>('toUser'))
          .whereType<ParseUser>());
    }
    if (results2.success && results2.results != null) {
      matchedUsers.addAll(results2.results!
          .map((e) => e.get<ParseUser>('fromUser'))
          .whereType<ParseUser>());
    }

    if (matchedUsers.isEmpty) return [];

    final uniqueUserIds = matchedUsers.map((u) => u.objectId).toSet();
    final uniqueUsers = matchedUsers.where((u) => uniqueUserIds.remove(u.objectId)).toList();

    final loginQuery = QueryBuilder<ParseObject>(ParseObject('UserLogin'))
      ..whereContainedIn('userPointer', uniqueUsers)
      ..whereEqualTo('isProfileComplete', true)
      ..includeObject(['userPointer', 'location']);

    final loginResults = await loginQuery.query();
    if (!loginResults.success || loginResults.results == null) return [];

    final fetchedProfiles = <Map<String, dynamic>>[];
    for (final object in loginResults.results!) {
      final userPointer = object.get<ParseUser>('userPointer');
      final location = object.get<ParseGeoPoint>('location');
      final dob = object.get<DateTime>('dob');
      final imageUrl = object.get<ParseFile>('imageProfile')?.url ?? '';
      final bio = object.get<String>('Bio') ?? 'User has no bio';

      double distance = 0.0;
      bool hasLocation = false;

      if (_currentUserLocation != null && location != null) {
        distance = _calculateDistanceInMiles(location);
        hasLocation = true;
      }

      fetchedProfiles.add({
        'name': object.get<String>('name') ?? '',
        'dob': dob,
        'imageUrl': imageUrl,
        'bio': bio,
        'userPointer': userPointer,
        'distance': distance,
        'hasLocation': hasLocation,
      });
    }

    fetchedProfiles.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
    return fetchedProfiles;
  }

  int calculateAge(DateTime? dob) {
    if (dob == null) return 0;
    final today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
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
      backgroundColor: Colors.grey[50],
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchProfiles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.pink[800]!),
              ),
            );
          }

          final profiles = snapshot.data ?? [];
          if (profiles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.pink[300]),
                  SizedBox(height: 20),
                  Text("No matches yet",
                      style: TextStyle(
                          fontSize: 22,
                          color: Colors.pink[800],
                          fontWeight: FontWeight.w500)),
                  SizedBox(height: 8),
                  Text("Keep swiping to find your perfect match",
                      style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 8),
            itemCount: profiles.length,
            itemBuilder: (context, index) {
              final profile = profiles[index];
              final name = profile['name'] ?? '';
              final dob = profile['dob'] as DateTime?;
              final imageUrl = profile['imageUrl'] ?? '';
              final age = dob != null ? calculateAge(dob) : '';
              final distance = profile['distance'] as double;
              final hasLocation = profile['hasLocation'] as bool;

              String distanceText;
              if (!hasLocation) {
                distanceText = "Location not shared";
              } else if (distance < 1) {
                distanceText = "Nearby";
              } else {
                distanceText = "${distance.toStringAsFixed(1)} miles away";
              }

              return Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      Container(
                        height: 380,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.7),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.8),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text("$name, ",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      )),
                                  Text("$age",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                      )),
                                ],
                              ),
                              SizedBox(height: 4),
                              Text(
                                distanceText,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                profile['bio'] ?? 'User has no bio',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
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
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.pink[300],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.message, size: 20),
                                      SizedBox(width: 8),
                                      Text("Send Message",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.pink[600],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.favorite, color: Colors.white, size: 24),
                        ),
                      ),
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