import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  RangeValues ageRange = const RangeValues(18, 60);
  double locationRange = 50;
  List<bool> genderSelections = [true, false, false, false];
  final List<String> genders = ['All', 'Male', 'Female', 'Non-binary'];
  final Color primaryColor = const Color(0xFFFD6F96);
  final Color secondaryColor = const Color(0xFF6D6875);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Filter Preferences",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF9FB),
              Color(0xFFFFF0F3),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.favorite, color: primaryColor),
                          const SizedBox(width: 8),
                          Text(
                            "Age Range",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: secondaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      RangeSlider(
                        values: ageRange,
                        min: 18,
                        max: 100,
                        divisions: 82,
                        activeColor: primaryColor,
                        inactiveColor: primaryColor.withOpacity(0.3),
                        labels: RangeLabels(
                          "${ageRange.start.toInt()}",
                          "${ageRange.end.toInt()}",
                        ),
                        onChanged: (RangeValues values) {
                          setState(() => ageRange = values);
                        },
                      ),
                      Text(
                        "${ageRange.start.toInt()} - ${ageRange.end.toInt()} years",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: secondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.people, color: primaryColor),
                          const SizedBox(width: 8),
                          Text(
                            "Gender",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: secondaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ToggleButtons(
                        borderRadius: BorderRadius.circular(10),
                        fillColor: primaryColor.withOpacity(0.2),
                        color: secondaryColor,
                        selectedColor: primaryColor,
                        selectedBorderColor: primaryColor,
                        borderColor: Colors.grey.shade300,
                        isSelected: genderSelections,
                        children: genders
                            .map(
                              (g) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(
                              g,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        )
                            .toList(),
                        onPressed: (index) {
                          setState(() {
                            for (int i = 0; i < genderSelections.length; i++) {
                              genderSelections[i] = (i == index);
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on, color: primaryColor),
                          const SizedBox(width: 8),
                          Text(
                            "Location Radius",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: secondaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Slider(
                        value: locationRange,
                        min: 20,
                        max: 3000,
                        divisions: 24,
                        activeColor: primaryColor,
                        inactiveColor: primaryColor.withOpacity(0.3),
                        label: "${locationRange.toInt()} miles",
                        onChanged: (value) {
                          setState(() => locationRange = value);
                        },
                      ),
                      Text(
                        "${locationRange.toInt()} miles",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: secondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        ageRange = const RangeValues(18, 60);
                        locationRange = 50;
                        genderSelections = [true, false, false, false];
                      });
                    },
                    icon: Icon(Icons.refresh, color: primaryColor),
                    label: Text(
                      "Reset",
                      style: TextStyle(color: primaryColor),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: primaryColor),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      final selectedGender = genders[genderSelections.indexWhere((e) => e)];
                      Navigator.pop(context, {
                        'ageStart': ageRange.start.toInt(),
                        'ageEnd': ageRange.end.toInt(),
                        'locationMiles': locationRange.toInt(),
                        'gender': selectedGender,
                      });
                    },
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text(
                      "Apply",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
