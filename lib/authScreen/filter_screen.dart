import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Filter"),
        centerTitle: true,

      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("Age Range", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            RangeSlider(
              values: ageRange,
              min: 18,
              max: 100,
              divisions: 82,
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
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 30),

            const Text("Gender", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ToggleButtons(
              borderRadius: BorderRadius.circular(10),
              isSelected: genderSelections,
              children: genders.map((g) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(g),
              )).toList(),
              onPressed: (index) {
                setState(() {
                  for (int i = 0; i < genderSelections.length; i++) {
                    genderSelections[i] = (i == index);
                  }
                });
              },
            ),
            const SizedBox(height: 30),

            const Text("Location Radius (Miles)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Slider(
              value: locationRange,
              min: 20,
              max: 3000,
              divisions: 24,
              label: "${locationRange.toInt()} miles",
              onChanged: (value) {
                setState(() => locationRange = value);
              },
            ),
            Text(
              "${locationRange.toInt()} miles",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
                  icon: const Icon(Icons.refresh),
                  label: const Text("Reset"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
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
                  icon: const Icon(Icons.check),
                  label: const Text("Apply"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
