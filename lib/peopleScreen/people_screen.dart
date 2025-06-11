import 'package:flutter/material.dart';
import 'package:flutter_tindercard_2/flutter_tindercard_2.dart';
import 'package:get/get.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:shimmer/shimmer.dart';

import '../controllers/auth_controllers.dart';
import 'match_screen.dart';

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({super.key});

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> with TickerProviderStateMixin {
  bool isProcessingSwipe = false;
  String? myImageUrl;
  List<Map<String, dynamic>> profiles = [];
  final AuthController authController = Get.find();
  final CardController _controller = CardController();

  @override
  void initState() {
    super.initState();
    fetchProfiles();
    preloadMyImage();
  }

  Future<void> fetchProfiles() async {
    try {
      final currentUser = await ParseUser.currentUser() as ParseUser?;
      if (currentUser == null) return;

      final interactionQuery = QueryBuilder<ParseObject>(ParseObject('UserInteractions'))
        ..whereEqualTo('fromUser', currentUser);
      final interactionResults = await interactionQuery.find();

      final interactedUserPointers = <ParseUser>{};

      for (final interaction in interactionResults) {
        final toUser = interaction.get<ParseUser>('toUser');
        if (toUser != null) interactedUserPointers.add(toUser);
      }

      final query = QueryBuilder<ParseObject>(ParseObject('UserLogin'))
        ..whereNotEqualTo('userPointer', currentUser)
        ..whereEqualTo('isProfileComplete', true);

      if (interactedUserPointers.isNotEmpty) {
        query.whereNotContainedIn('userPointer', interactedUserPointers.toList());
      }

      final results = await query.find();
      final fetchedProfiles = <Map<String, dynamic>>[];

      for (final object in results) {
        final userPointer = object.get<ParseUser>('userPointer');
        final dob = object.get<DateTime>('dob');
        final imageFile = object.get<ParseFile>('imageProfile');

        String? gender;
        bool showOnProfile = false;

        final basicQuery = QueryBuilder<ParseObject>(ParseObject('Basic'))
          ..whereEqualTo('userPointer', userPointer);
        final basicResult = await basicQuery.query();

        if (basicResult.success && basicResult.results != null && basicResult.results!.isNotEmpty) {
          final basic = basicResult.results!.first;
          showOnProfile = basic.get<bool>('showOnProfile') ?? false;
          if (showOnProfile) {
            gender = basic.get<String>('Gender');
          }
        }

        final imageUrl = imageFile?.url ?? '';
        fetchedProfiles.add({
          'name': object.get<String>('name') ?? '',
          'dob': dob,
          'imageUrl': imageUrl,
          'gender': gender,
          'showOnProfile': showOnProfile,
          'userPointer': userPointer,
        });

        if (imageUrl.isNotEmpty) {
          precacheImage(NetworkImage(imageUrl), context);
        }
      }

      setState(() {
        profiles = fetchedProfiles;
      });
    } catch (_) {}
  }

  void preloadMyImage() async {
    myImageUrl = await authController.fetchUserImage();
  }

  int calculateAge(DateTime dob) {
    final today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: const Text(
          "PairFect",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: profiles.isNotEmpty
                ? TinderSwapCard(
              swipeUp: true,
              swipeDown: false,
              orientation: AmassOrientation.top,
              totalNum: profiles.length,
              stackNum: 3,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              minWidth: MediaQuery.of(context).size.width * 0.8,
              minHeight: MediaQuery.of(context).size.height * 0.7,
              cardBuilder: (context, index) {
                final profile = profiles[index];
                final name = profile['name'] as String;
                final imageUrl = profile['imageUrl'] as String?;
                final dob = profile['dob'] as DateTime?;
                final age = dob != null ? calculateAge(dob) : null;
                final gender = profile['gender'] as String?;
                final showOnProfile = profile['showOnProfile'] as bool?;

                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: imageUrl != null && imageUrl.isNotEmpty
                          ? FadeInImage.assetNetwork(
                        placeholder: 'assets/images/profile_avatar.jpg',
                        image: imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      )
                          : Image.asset(
                        'assets/images/profile_avatar.jpg',
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      child: Text(
                        "$name, ${age ?? 'N/A'}",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (showOnProfile ?? false)
                      Positioned(
                        bottom: 50,
                        left: 20,
                        child: Text(
                          gender ?? '',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 10.0,
                                color: Colors.black,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
              cardController: _controller,
              swipeCompleteCallback: (CardSwipeOrientation orientation, int index) async {
                if (index >= profiles.length) return;

                final profile = profiles[index];
                final toUser = profile['userPointer'] as ParseUser;
                final currentUser = await ParseUser.currentUser() as ParseUser?;
                if (currentUser == null) return;

                String? interactionType;
                if (orientation == CardSwipeOrientation.right) {
                  interactionType = 'like';
                } else if (orientation == CardSwipeOrientation.up) {
                  interactionType = 'superlike';
                }

                if (interactionType != null) {
                  final isMatch = await authController.saveInteraction(
                    fromUser: currentUser,
                    toUser: toUser,
                    interactionType: interactionType,
                  );

                  if (isMatch) {
                    Future.delayed(const Duration(milliseconds: 300), () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MatchScreen(
                            myImageUrl: myImageUrl ?? "",
                            imageUrl: profile["imageUrl"] ?? '',
                            matchedUserName: profile['name'] ?? '',
                            interactionType: interactionType ?? "",
                          ),
                        ),
                      );
                    });
                  }
                }

                if (mounted) {
                  setState(() {
                    profiles.removeAt(index);
                  });
                }
              },
            )
                : Center(
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: ListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 150,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          if (profiles.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildIconButton(
                    icon: Icons.close,
                    color: Colors.red,
                    onPressed: () {
                      _controller.triggerLeft();
                    },
                  ),
                  _buildIconButton(
                    icon: Icons.star,
                    color: Colors.blue,
                    onPressed: () {
                      _controller.triggerUp();
                    },
                  ),
                  _buildIconButton(
                    icon: Icons.favorite,
                    color: Colors.green,
                    onPressed: () {
                      _controller.triggerRight();
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withAlpha(51),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(128),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: color),
        iconSize: 40,
        onPressed: onPressed,
      ),
    );
  }
}
