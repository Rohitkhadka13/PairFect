import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pairfect/profileScreen/complete_profile.dart';
import '../controllers/auth_controllers.dart';

class InterestScreen extends StatefulWidget {
  const InterestScreen({super.key});

  @override
  State<InterestScreen> createState() => _InterestScreenState();
}

class _InterestScreenState extends State<InterestScreen> {
  final Map<String, List<String>> interestCategories = {
    "Self-care": [
      "Aromatherapy", "Astrology", "Cold plunging", "Crystals", "Deep chats",
      "Journaling", "Mindfulness", "Nutrition", "Retreats", "Skin care"
    ],
    "Sports": ["Football", "Basketball", "Tennis", "Swimming", "Cycling", "Cricket"],
    "Creativity": ["Painting", "Writing", "Photography", "Designing", "Sculpting"],
    "Going Out": ["Concerts", "Parties", "Nightclubs", "Festivals", "Events"],
    "Staying In": ["Gaming", "Cooking", "Reading", "DIY Projects", "Meditation"],
    "Film & TV": ["Movies", "TV Shows", "Documentaries", "Anime", "Theater"],
    "Reading": ["Novels", "Comics", "Poetry", "Non-fiction", "Magazines"],
    "Music": ["Rock", "Pop", "Jazz", "Classical", "Hip-Hop"],
    "Food & Drink": ["Coffee", "Wine", "Vegan", "BBQ", "Baking"],
    "Travelling": ["Road Trips", "Backpacking", "Luxury Travel", "Cruises", "Camping"],
    "Pets": ["Dogs", "Cats", "Birds", "Reptiles", "Small Pets"]
  };

  List<String> selectedInterests = [];
  final AuthController _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    loadUserInterests();
  }

  Future<void> loadUserInterests() async {
    final interests = await _authController.getUserInterests();
    setState(() {
      selectedInterests = interests;
    });
  }

  void saveInterests() {
    if (selectedInterests.isEmpty) {
      Get.snackbar("Error", "Please select at least one interest.");
      return;
    }
    _authController.saveUserInterests(selectedInterests);
  }

  void toggleSelection(String interest) {
    setState(() {
      if (selectedInterests.contains(interest)) {
        selectedInterests.remove(interest);
      } else {
        if (selectedInterests.length < 5) {
          selectedInterests.add(interest);
        } else {
          Get.snackbar("Limit Reached", "You can select up to 5 interests.");
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFFAFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Interests", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Choose up to 5 interests for your profile",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: interestCategories.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: entry.value.map((interest) {
                          final isSelected = selectedInterests.contains(interest);
                          return ChoiceChip(
                            label: Text(interest),
                            selected: isSelected,
                            selectedColor: Colors.black,
                            backgroundColor: Colors.grey[200],
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                            onSelected: (_) => toggleSelection(interest),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }).toList(),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed:(){ saveInterests();
                  Get.to(()=> CompleteProfile());
                  },
                child: const Text(
                  "Continue",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}