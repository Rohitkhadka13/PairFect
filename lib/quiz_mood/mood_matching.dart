import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import 'mood_profile_screen.dart';

class MoodMatchingScreen extends StatefulWidget {
  const MoodMatchingScreen({super.key});

  @override
  _MoodMatchingScreenState createState() => _MoodMatchingScreenState();
}

class _MoodMatchingScreenState extends State<MoodMatchingScreen> {
  String? _selectedMood;
  int? _selectedIntensity;
  bool _isLoading = false;
  bool _submitted = false;
  List<Map<String, dynamic>> _matches = [];

  final List<String> _moodOptions = [
    'Happy',
    'Adventurous',
    'Romantic',
    'Chill',
    'Energetic',
    'Thoughtful',
    'Playful',
    'Mysterious',
  ];

  final List<int> _intensityOptions = List.generate(10, (index) => index + 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        title: Text('Mood Matching', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.pink.shade400,
        elevation: 4,
        actions: [
          if (_submitted)
            IconButton(
              icon: Icon(Icons.refresh, color: Colors.white),
              onPressed: () {
                setState(() {
                  _selectedMood = null;
                  _selectedIntensity = null;
                  _submitted = false;
                  _matches.clear();
                });
              },
            ),
        ],
      ),
      body: !_submitted ? _buildMoodSelection() : _buildMatchingResults(),
    );
  }

  Widget _buildMoodSelection() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "What's your vibe today?",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _moodOptions.map((mood) {
                return ChoiceChip(
                  label: Text(mood),
                  selected: _selectedMood == mood,
                  onSelected: (selected) {
                    setState(() {
                      _selectedMood = selected ? mood : null;
                      _selectedIntensity = null;
                    });
                  },
                  selectedColor: Colors.pink.shade100,
                  labelStyle: TextStyle(
                    color: _selectedMood == mood
                        ? Colors.pink.shade700
                        : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                  backgroundColor: Colors.grey.shade200,
                );
              }).toList(),
            ),
            if (_selectedMood != null) ...[
              SizedBox(height: 30),
              Text(
                'How strongly are you feeling "$_selectedMood"?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 15),
              Wrap(
                spacing: 10,
                children: _intensityOptions.map((level) {
                  return ChoiceChip(
                    label: Text(level.toString()),
                    selected: _selectedIntensity == level,
                    onSelected: (selected) {
                      setState(
                          () => _selectedIntensity = selected ? level : null);
                    },
                    selectedColor: Colors.pink.shade300,
                    labelStyle: TextStyle(
                      color: _selectedIntensity == level
                          ? Colors.white
                          : Colors.black,
                    ),
                    backgroundColor: Colors.grey.shade200,
                  );
                }).toList(),
              ),
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed:
                      (_selectedMood != null && _selectedIntensity != null)
                          ? _saveAndFindMatches
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink.shade600,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    'Find Matches',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMatchingResults() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: Colors.pink));
    }

    return _matches.isEmpty
        ? Center(
            child: Text(
              'No matches found 💔',
              style: TextStyle(fontSize: 18, color: Colors.pink.shade400),
            ),
          )
        : ListView.builder(
            itemCount: _matches.length,
            itemBuilder: (context, index) {
              final match = _matches[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  contentPadding: EdgeInsets.all(12),
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(match['imageUrl'] ?? ''),
                    radius: 25,
                  ),
                  title: Text(
                    match['name'] ?? '',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Mood: ${match['mood']} (${match['intensity']}/10)',
                  ),
                  trailing:
                      Icon(Icons.favorite_border, color: Colors.pink.shade300),
                  onTap: () {
                    Get.to(() => MoodProfileScreen(user: match['user']));
                  },
                ),
              );
            },
          );
  }

  Future<void> _saveAndFindMatches() async {
    setState(() => _isLoading = true);

    try {
      final currentUser = await ParseUser.currentUser() as ParseUser?;
      if (currentUser == null) return;

      final moodQuery = QueryBuilder<ParseObject>(ParseObject('UserMood'))
        ..whereEqualTo('userPointer', currentUser.toPointer());

      final moodResponse = await moodQuery.query();

      ParseObject userMood;
      if (moodResponse.success && moodResponse.results != null && moodResponse.results!.isNotEmpty) {
        userMood = moodResponse.results!.first;
      } else {
        userMood = ParseObject('UserMood');
      }

      userMood
        ..set('userPointer', currentUser.toPointer())
        ..set('mood', _selectedMood)
        ..set('intensity', _selectedIntensity)
        ..set('timestamp', DateTime.now());

      final response = await userMood.save();

      if (response.success) {
        setState(() => _submitted = true);
        await _findMoodMatches();
      } else {
        Get.snackbar('Error', 'Failed to save mood. Please try again.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  Future<void> _findMoodMatches() async {
    final currentUser = await ParseUser.currentUser() as ParseUser?;
    if (currentUser == null) return;

    //  get all users the current user has interacted
    final interactionQuery =
        QueryBuilder<ParseObject>(ParseObject('UserInteractions'))
          ..whereEqualTo('fromUser', currentUser.toPointer());

    final interactionResponse = await interactionQuery.query();
    final interactedUserIds = <String>{};

    if (interactionResponse.success && interactionResponse.results != null) {
      for (final interaction in interactionResponse.results!) {
        final toUser = interaction.get<ParseUser>('toUser');
        if (toUser != null && toUser.objectId != null) {
          interactedUserIds.add(toUser.objectId!);
        }
      }
    }

    //  find  matches excluding interacted users
    final moodQuery = QueryBuilder<ParseObject>(ParseObject('UserMood'))
      ..whereEqualTo('mood', _selectedMood)
      ..whereNotEqualTo('userPointer', currentUser.toPointer())
      ..includeObject(['userPointer'])
      ..orderByDescending('timestamp')
      ..setLimit(20);

    // Exclude users already interacted
    if (interactedUserIds.isNotEmpty) {
      moodQuery.whereNotContainedIn(
          'userPointer',
          interactedUserIds
              .map((id) => ParseUser(null, null, null)..objectId = id)
              .toList());
    }

    final response = await moodQuery.query();

    if (response.success && response.results != null) {
      final matches =
          await Future.wait(response.results!.map((moodObject) async {
        final user = moodObject.get<ParseUser>('userPointer');
        if (user == null || user.objectId == currentUser.objectId) return null;

        final userData = await _fetchUserData(user);
        return {
          ...userData,
          'mood': moodObject.get<String>('mood'),
          'intensity': moodObject.get<int>('intensity'),
        };
      }));

      setState(() {
        _matches = matches.whereType<Map<String, dynamic>>().toList();
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<Map<String, dynamic>> _fetchUserData(ParseUser user) async {
    final query = QueryBuilder<ParseObject>(ParseObject('UserLogin'))
      ..whereEqualTo('userPointer', user);

    final response = await query.query();

    if (response.success &&
        response.results != null &&
        response.results!.isNotEmpty) {
      final object = response.results!.first;
      return {
        'user': user,
        'name': object.get<String>('name') ?? '',
        'imageUrl': object.get<ParseFile>('imageProfile')?.url ?? '',
      };
    }

    return {
      'user': user,
      'name': '',
      'imageUrl': '',
    };
  }
}
