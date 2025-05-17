import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../controllers/profile_controller.dart';

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
      body: Obx(() {
        if (controller.profiles.isEmpty) {
          return const Center(child: CircularProgressIndicator());
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
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
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
                        "${profile['name']}, ${_calculateAge(profile['dob'])}",
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
                          if (profile['zodiac'] != null) buildTag(profile['zodiac'], FontAwesomeIcons.star),
                          if (profile['religion'] != null) buildTag(profile['religion'], FontAwesomeIcons.cross),
                          if (profile['height'] != null) buildTag(profile['height'], FontAwesomeIcons.rulerVertical),
                          if (profile['exercise'] != null) buildTag(profile['exercise'], FontAwesomeIcons.dumbbell),
                          if (profile['politics'] != null) buildTag(profile['politics'], FontAwesomeIcons.landmark),
                          if (profile['gender'] != null) buildTag(profile['gender'], FontAwesomeIcons.venusMars),
                          if (profile['smoking'] != null)
                            buildTag(getSmokingDisplayText(profile['smoking']), FontAwesomeIcons.smoking),
                          if (profile['drinking'] != null)
                            buildTag(getDrinkingDisplayText(profile['drinking']), FontAwesomeIcons.wineGlassAlt),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (profile['lookingFor'] != null && profile['lookingFor'].isNotEmpty)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
