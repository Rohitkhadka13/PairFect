import 'dart:ui';

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
        title: const Text('Discover',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.pinkAccent)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_rounded,
                color: Colors.pinkAccent, size: 28),
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
                  Icon(Icons.sentiment_dissatisfied_rounded,
                      size: 80, color: Colors.pink[200]),
                  const SizedBox(height: 20),
                  Text(
                    "No profiles found",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink[800]),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Try changing your filters or refresh to see new profiles.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16, color: Colors.pink[300], height: 1.4),
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
                    icon: const Icon(Icons.filter_alt_rounded),
                    label: const Text("Change Filters"),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.pinkAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: () => controller.fetchProfiles(),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text("Refresh"),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.pinkAccent,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return PageView.builder(
          controller: controller.pageController,
          onPageChanged: (index) {
            controller.currentIndex.value = index;
          },
          scrollDirection: Axis.vertical,
          itemCount: controller.profiles.length,
          itemBuilder: (context, index) {
            final profile = controller.profiles[index];
            return Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(profile['imageUrl']),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                      child: Container(
                        color: Colors.black.withOpacity(0.1),
                      ),
                    ),
                  ),
                ),

                Positioned.fill(
                  child: CachedNetworkImage(
                    imageUrl: profile['imageUrl'],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    memCacheWidth: (MediaQuery.of(context).size.width * 2).toInt(),
                    memCacheHeight: (MediaQuery.of(context).size.height * 2).toInt(),
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.pink[200],
                        ),
                      ),
                    ),
                    fadeInDuration: const Duration(milliseconds: 300),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: Center(
                        child: Icon(Icons.error, color: Colors.pink[300]),
                      ),
                    ),
                  ),
                ),

                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8)
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.5, 1.0],
                      ),
                    ),
                  ),
                ),

                Positioned(
                  left: 16,
                  bottom: 120,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "${profile['name']}, ",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              shadows: [
                                Shadow(
                                    blurRadius: 8,
                                    color: Colors.black54,
                                    offset: Offset(1, 1))
                              ],
                            ),
                          ),
                          Text(
                            _calculateAge(profile['dob']).toString(),
                            style: TextStyle(
                              color: Colors.pink[100],
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              shadows: const [
                                Shadow(
                                    blurRadius: 8,
                                    color: Colors.black54,
                                    offset: Offset(1, 1))
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (profile['distance'] != '') ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.location_on_rounded,
                                color: Colors.pink[100], size: 22),
                            const SizedBox(width: 6),
                            Text(
                              "${profile['distance']} miles away",
                              style: TextStyle(
                                color: Colors.pink[100],
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                shadows: const [
                                  Shadow(
                                      blurRadius: 6,
                                      color: Colors.black54,
                                      offset: Offset(1, 1))
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: [
                          if (profile['zodiac'] != null)
                            buildTag(profile['zodiac'], FontAwesomeIcons.star),
                          if (profile['religion'] != null)
                            buildTag(profile['religion'], FontAwesomeIcons.cross),
                          if (profile['height'] != null)
                            buildTag(profile['height'],
                                FontAwesomeIcons.rulerVertical),
                          if (profile['exercise'] != null)
                            buildTag(profile['exercise'],
                                FontAwesomeIcons.dumbbell),
                          if (profile['politics'] != null)
                            buildTag(profile['politics'],
                                FontAwesomeIcons.landmark),
                          if (profile['gender'] != null)
                            buildTag(profile['gender'],
                                FontAwesomeIcons.venusMars),
                          if (profile['smoking'] != null)
                            buildTag(
                                getSmokingDisplayText(profile['smoking']),
                                FontAwesomeIcons.smoking),
                          if (profile['drinking'] != null)
                            buildTag(
                                getDrinkingDisplayText(profile['drinking']),
                                FontAwesomeIcons.wineGlass),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (profile['lookingFor'] != null &&
                          profile['lookingFor'].isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(
                            profile['lookingFor'].length,
                                (index) => Chip(
                              label: Text(
                                profile['lookingFor'][index],
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.pink.withOpacity(0.7),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              side: BorderSide.none,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 30,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FloatingActionButton(
                        heroTag: 'dislikeFAB',
                        backgroundColor: Colors.white.withOpacity(0.9),
                        onPressed: () {
                          controller.interactWithUser(
                              profile['userPointer'], 'dislike');
                        },
                        child: Icon(Icons.close_rounded,
                            color: Colors.pink[800], size: 30),
                      ),
                      const SizedBox(width: 40),
                      FloatingActionButton(
                        heroTag: 'likeFAB',
                        backgroundColor: Colors.pinkAccent,
                        onPressed: () {
                          controller.interactWithUser(
                              profile['userPointer'], 'like');
                        },
                        child: const Icon(Icons.favorite_rounded,
                            color: Colors.white, size: 30),
                      ),
                    ],
                  ),
                ),

                Positioned(
                  top: 16,
                  right: 16,
                  child: PopupMenuButton<String>(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.more_vert_rounded,
                          color: Colors.white),
                    ),
                    onSelected: (value) async {
                      if (value == 'report_user') {
                        final profileIndex = controller.currentIndex.value;
                        final profile = controller.profiles.isNotEmpty &&
                            profileIndex < controller.profiles.length
                            ? controller.profiles[profileIndex]
                            : null;

                        if (profile != null) {
                          String selectedReason = 'Inappropriate Content';
                          String selectedDetail = '';

                          final Map<String, List<String>> detailsMap = {
                            'Inappropriate Content': [
                              'Offensive Photo',
                              'Nudity',
                              'Violence'
                            ],
                            'Spam': [
                              'Repeated Messages',
                              'Suspicious Links',
                              'Fake Offers'
                            ],
                            'Fake Profile': [
                              'Fake Name',
                              'Fake Photo',
                              'Pretending to be Someone'
                            ],
                            'Harassment': ['Threats', 'Abuse', 'Stalking'],
                            'Other': [
                              'Not Relevant to App',
                              'Other Reason'
                            ],
                          };

                          Get.dialog(
                            StatefulBuilder(
                              builder: (context, setState) => AlertDialog(
                                title: const Text('Report User',
                                    style: TextStyle(color: Colors.pinkAccent)),
                                backgroundColor: Colors.grey[50],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    DropdownButtonFormField<String>(
                                      isExpanded: true,
                                      value: selectedReason,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(12),
                                        ),
                                        contentPadding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                      ),
                                      items: detailsMap.keys.map((reason) {
                                        return DropdownMenuItem(
                                          value: reason,
                                          child: Text(reason),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          selectedReason = value!;
                                          selectedDetail = '';
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    DropdownButtonFormField<String>(
                                      isExpanded: true,
                                      hint: const Text('Select detail'),
                                      value:
                                      selectedDetail.isEmpty ? null : selectedDetail,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(12),
                                        ),
                                        contentPadding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                      ),
                                      items: detailsMap[selectedReason]!
                                          .map((detail) {
                                        return DropdownMenuItem(
                                          value: detail,
                                          child: Text(detail),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          selectedDetail = value!;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(),
                                    child: const Text('Cancel',
                                        style: TextStyle(color: Colors.grey)),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      if (selectedDetail.isEmpty) {
                                        Get.snackbar("Missing Detail",
                                            "Please select a specific detail.",
                                            backgroundColor: Colors.pink[100]);
                                        return;
                                      }
                                      Get.back();
                                      controller.reportUser(
                                        profile['userPointer'],
                                        selectedReason,
                                        detail: selectedDetail,
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.pinkAccent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text('Submit',
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'report_user',
                        child: Text('Report User'),
                      ),
                    ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.pink.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 16, color: Colors.pink[100]),
          const SizedBox(width: 8),
          Text(text,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
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