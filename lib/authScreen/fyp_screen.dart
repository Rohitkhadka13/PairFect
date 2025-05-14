import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ForYouPage extends StatefulWidget {
  const ForYouPage({super.key});

  @override
  State<ForYouPage> createState() => _ForYouPageState();
}

class _ForYouPageState extends State<ForYouPage> {
  late Future<List<Map<String, dynamic>>> profileFuture;

  @override
  void initState() {
    super.initState();
    profileFuture = fetchProfiles();
  }

  Future<List<Map<String, dynamic>>> fetchProfiles() async {
    try {
      final currentUser = await ParseUser.currentUser() as ParseUser?;
      if (currentUser == null) return [];

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
        query.whereNotContainedIn(
            'userPointer', interactedUserPointers.toList());
      }

      final results = await query.find();
      results.shuffle();
      final selected = results.take(5).toList();

      final fetchedProfiles = <Map<String, dynamic>>[];

      for (final object in selected) {
        final userPointer = object.get<ParseUser>('userPointer');
        final dob = object.get<DateTime>('dob');
        final imageFile = object.get<ParseFile>('imageProfile');
        List<String> lookingFor = [];
        String? religion,
            zodiac,
            height,
            exercise,
            politics,
            gender,
            smoking,
            drinking;

        final aboutQuery = QueryBuilder<ParseObject>(ParseObject('aboutYou'))
          ..whereEqualTo('userPointer', userPointer);
        final aboutResult = await aboutQuery.query();

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

        if (basicResult.success &&
            basicResult.results != null &&
            basicResult.results!.isNotEmpty) {
          final basic = basicResult.results!.first;
          gender = basic.get<String>('Gender');
        }

        final imageUrl = imageFile?.url ?? '';
        fetchedProfiles.add({
          'name': object.get<String>('name') ?? '',
          'dob': dob,
          'imageUrl': imageUrl,
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

        if (imageUrl.isNotEmpty) {
          precacheImage(NetworkImage(imageUrl), context);
        }
      }

      return fetchedProfiles;
    } catch (_) {
      return [];
    }
  }

  int _calculateAge(DateTime? dob) {
    if (dob == null) return 0;
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            profileFuture = fetchProfiles();
          });
        },
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: profileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingSkeleton();
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Something went wrong"),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          profileFuture = fetchProfiles();
                        });
                      },
                      child: const Text("Try Again"),
                    ),
                  ],
                ),
              );
            }

            final profiles = snapshot.data ?? [];
            if (profiles.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("No profiles found"),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          profileFuture = fetchProfiles();
                        });
                      },
                      child: const Text("Refresh"),
                    ),
                  ],
                ),
              );
            }

            return PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: profiles.length,
              itemBuilder: (context, index) {
                final profile = profiles[index];
                return buildFullScreenProfile(profile);
              },
            );
          },
        ),
      ),
    );
  }

  Widget buildFullScreenProfile(Map<String, dynamic> profile) {
    final name = profile['name'] ?? 'Unknown';
    final age = _calculateAge(profile['dob']);
    final userPointer = profile['userPointer'] as ParseUser;

    return Stack(
      children: [
        Positioned.fill(
          child: CachedNetworkImage(
            imageUrl: profile['imageUrl'],
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.black87],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        Positioned(
          left: 16,
          bottom: 110,
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$name, $age",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 6, color: Colors.black)],
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  if (profile['zodiac'] != null)
                    buildTag(profile['zodiac'], FontAwesomeIcons.star),
                  if (profile['religion'] != null)
                    buildTag(profile['religion'], FontAwesomeIcons.cross),
                  if (profile['height'] != null)
                    buildTag(profile['height'], FontAwesomeIcons.rulerVertical),
                  if (profile['exercise'] != null)
                    buildTag(profile['exercise'], FontAwesomeIcons.dumbbell),
                  if (profile['politics'] != null)
                    buildTag(profile['politics'], FontAwesomeIcons.landmark),
                  if (profile['gender'] != null)
                    buildTag(profile['gender'], FontAwesomeIcons.venusMars),
                  if (profile['smoking'] != null)
                    buildTag(getSmokingDisplayText(profile['smoking']),
                        FontAwesomeIcons.smoking),
                  if (profile['drinking'] != null)
                    buildTag(getDrinkingDisplayText(profile['drinking']),
                        FontAwesomeIcons.wineGlassAlt),
                ],
              ),
              const SizedBox(height: 10),
              if (profile['lookingFor'] != null &&
                  profile['lookingFor'].isNotEmpty)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                      profile['lookingFor'].length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Chip(
                          label: Text(profile['lookingFor'][index],
                              style: const TextStyle(color: Colors.white)),
                          backgroundColor: Colors.pink.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Positioned(
          left: 32,
          bottom: 30,
          child: FloatingActionButton(
            backgroundColor: Colors.grey.withOpacity(0.8),
            onPressed: () {},
            child: const Icon(Icons.clear, color: Colors.white),
          ),
        ),
        Positioned(
          right: 32,
          bottom: 30,
          child: FloatingActionButton(
            backgroundColor: Colors.pink,
            onPressed: () {},
            child: const Icon(Icons.favorite, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget buildTag(String text, IconData iconData) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 16, color: Colors.white),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return const Center(child: CircularProgressIndicator());
  }
}

String getDrinkingDisplayText(String? value) {
  switch (value?.toLowerCase()) {
    case 'i rarely drink':
    case 'i drink sometime':
      return 'Sometimes';
    case 'no,i don\'t drink':
      return 'Never';
    case 'yes,i drink':
      return 'Often';
    case 'i\'m sober':
      return 'Sober';
    default:
      return value ?? '';
  }
}

String getSmokingDisplayText(String? value) {
  switch (value?.toLowerCase()) {
    case 'yes,i smoke':
      return 'Smoker';
    case 'no,i don\'t smoke':
      return 'Non-Smoker';
    case 'i\'m trying to quit':
      return 'Trying to quit';
    case 'i smoke sometimes':
      return 'Occasionally';
    default:
      return value ?? '';
  }
}
