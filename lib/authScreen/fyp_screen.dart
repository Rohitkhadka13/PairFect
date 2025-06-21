import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/profile_controller.dart';
import 'filter_screen.dart';

class ForYouPage extends StatelessWidget {
  ForYouPage({super.key});

  final ProfileController controller = Get.put(ProfileController());

  int _calculateAge(DateTime? dob) {
    if (dob == null) return 0;
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onSelected: (value) async {
            if (value == 'report_user') {
                final profile = controller.profiles.isNotEmpty ? controller.profiles[0] : null;
                if (profile != null) {
                  String selectedReason = 'Inappropriate Content';
                  Get.dialog(
                    StatefulBuilder(
                      builder: (context, setState) => AlertDialog(
                        title: const Text('Report User'),
                        content: DropdownButton<String>(
                          isExpanded: true,
                          value: selectedReason,
                          items: [
                            'Inappropriate Content',
                            'Spam',
                            'Fake Profile',
                            'Harassment',
                            'Other',
                          ].map((reason) => DropdownMenuItem(
                            value: reason,
                            child: Text(reason),
                          )).toList(),
                          onChanged: (value) => setState(() {
                            selectedReason = value!;
                          }),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Get.back();
                              controller.reportUser(profile['userPointer'], selectedReason);
                            },
                            child: const Text('Submit'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              } else if (value == 'filters') {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FilterScreen()),
                );
                if (result != null && result is Map) {
                  controller.fetchProfiles(
                    ageStart: result['ageStart'],
                    ageEnd: result['ageEnd'],
                    locationMiles: result['locationMiles'],
                    gender: result['gender'],
                  );
                }
              }

            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'change_location',
                child: Text('Change Location'),
              ),
              const PopupMenuItem(
                value: 'report_user',
                child: Text('Report User'),
              ),
              const PopupMenuItem(
                value: 'filters',
                child: Text('Filters'),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (controller.profiles.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_off, size: 80, color: Colors.grey),
                  const SizedBox(height: 20),
                  const Text(
                    "No profiles found",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Try changing your filters or refresh to see new profiles.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FilterScreen()),
                      );
                      if (result != null && result is Map) {
                        controller.fetchProfiles(
                          ageStart: result['ageStart'],
                          ageEnd: result['ageEnd'],
                          locationMiles: result['locationMiles'],
                          gender: result['gender'],
                        );
                      }
                    },
                    icon: const Icon(Icons.filter_alt),
                    label: const Text("Change Filters"),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () => controller.fetchProfiles(),
                    icon: const Icon(Icons.refresh),
                    label: const Text("Refresh"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }


        return PageView.builder(
          scrollDirection: Axis.vertical,
          itemCount: controller.profiles.length,
          itemBuilder: (context, index) {
            final profile = controller.profiles[index];
            return Stack(
              children: [
                Positioned.fill(
                  child: CachedNetworkImage(
                    imageUrl: profile['imageUrl'],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    memCacheWidth: (MediaQuery.of(context).size.width * 2).toInt(),
                    memCacheHeight: (MediaQuery.of(context).size.height * 2).toInt(),
                    placeholder: (context, url) => Container(color: Colors.grey[300]),
                    fadeInDuration: const Duration(milliseconds: 200),
                    errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
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
                        "${profile['name']}, ${_calculateAge(profile['dob'])}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          shadows: [Shadow(blurRadius: 6, color: Colors.black)],
                        ),
                      ),
                      if (profile['distance'] != '') ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.white70, size: 24),
                            const SizedBox(width: 6),
                            Text(
                              "${profile['distance']} miles away",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: [
                          if (profile['zodiac'] != null) buildTag(profile['zodiac'], FontAwesomeIcons.star),
                          if (profile['religion'] != null) buildTag(profile['religion'], FontAwesomeIcons.cross),
                          if (profile['height'] != null) buildTag(profile['height'], FontAwesomeIcons.rulerVertical),
                          if (profile['exercise'] != null) buildTag(profile['exercise'], FontAwesomeIcons.dumbbell),
                          if (profile['politics'] != null) buildTag(profile['politics'], FontAwesomeIcons.landmark),
                          if (profile['gender'] != null) buildTag(profile['gender'], FontAwesomeIcons.venusMars),
                          if (profile['smoking'] != null)
                            buildTag(getSmokingDisplayText(profile['smoking']), FontAwesomeIcons.smoking),
                          if (profile['drinking'] != null)
                            buildTag(getDrinkingDisplayText(profile['drinking']), FontAwesomeIcons.wineGlass),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (profile['lookingFor'] != null && profile['lookingFor'].isNotEmpty)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: List.generate(
                              profile['lookingFor'].length,
                                  (index) => Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Chip(
                                  label: Text(
                                    profile['lookingFor'][index],
                                    style: const TextStyle(color: Colors.white),
                                  ),
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
                    heroTag: 'dislikeFAB',
                    backgroundColor: Colors.grey.withOpacity(0.8),
                    onPressed: () {
                      controller.interactWithUser(profile['userPointer'], 'dislike');
                    },
                    child: const Icon(Icons.clear, color: Colors.white),
                  ),
                ),
                Positioned(
                  right: 32,
                  bottom: 30,
                  child: FloatingActionButton(
                    heroTag: 'likeFAB',
                    backgroundColor: Colors.pink,
                    onPressed: () {
                      controller.interactWithUser(profile['userPointer'], 'like');
                    },
                    child: const Icon(Icons.favorite, color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      }),
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
