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
  static const _cardAspectRatio = 0.9;
  static const _stackNum = 3;
  static const _buttonIconSize = 40.0;
  static const _buttonShadowBlur = 10.0;
  static const _buttonShadowAlpha = 51;
  static const _matchDelay = Duration(milliseconds: 300);

  final _cardController = CardController();
  final _authController = Get.find<AuthController>();

  List<Map<String, dynamic>> _profiles = [];
  String? _myImageUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await Future.wait([
      _fetchProfiles(),
      _preloadMyImage(),
    ]);
    setState(() => _isLoading = false);
  }

  Future<void> _fetchProfiles() async {
    try {
      final currentUser = await ParseUser.currentUser() as ParseUser?;
      if (currentUser == null) return;

      final results = await Future.wait([
        _getInteractedUsers(currentUser),
        _getAllProfiles(currentUser),
      ]);

      final Set<String> interactedUsers = results[0] as Set<String>;
      final List<ParseObject> allProfiles = results[1] as List<ParseObject>;

      final filteredProfiles = allProfiles.where((profile) {
        final userPointer = profile.get<ParseUser>('userPointer');
        return !interactedUsers.contains(userPointer?.objectId);
      }).toList();

      final profiles = await Future.wait(
        filteredProfiles.map(_parseProfileData),
      );

      if (mounted) {
        setState(() => _profiles = profiles.whereType<Map<String, dynamic>>().toList());
      }
    } catch (e) {
      debugPrint('Error fetching profiles: $e');
    }
  }

  Future<Set<String>> _getInteractedUsers(ParseUser currentUser) async {
    final query = QueryBuilder<ParseObject>(ParseObject('UserInteractions'))
      ..whereEqualTo('fromUser', currentUser);
    final results = await query.find();
    return results
        .map((e) => e.get<ParseUser>('toUser')?.objectId)
        .whereType<String>()
        .toSet();
  }

  Future<List<ParseObject>> _getAllProfiles(ParseUser currentUser) async {
    final query = QueryBuilder<ParseObject>(ParseObject('UserLogin'))
      ..whereNotEqualTo('userPointer', currentUser)
      ..whereEqualTo('isProfileComplete', true);
    return await query.find();
  }

  Future<Map<String, dynamic>?> _parseProfileData(ParseObject object) async {
    try {
      final userPointer = object.get<ParseUser>('userPointer');
      if (userPointer == null) return null;

      final basicData = await _getBasicData(userPointer);
      final imageFile = object.get<ParseFile>('imageProfile');
      final imageUrl = imageFile?.url ?? '';

      if (imageUrl.isNotEmpty) {
        precacheImage(NetworkImage(imageUrl), context);
      }

      return {
        'name': object.get<String>('name') ?? '',
        'dob': object.get<DateTime>('dob'),
        'imageUrl': imageUrl,
        'gender': basicData['gender'],
        'showOnProfile': basicData['showOnProfile'],
        'userPointer': userPointer,
      };
    } catch (e) {
      debugPrint('Error parsing profile: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> _getBasicData(ParseUser userPointer) async {
    final query = QueryBuilder<ParseObject>(ParseObject('Basic'))
      ..whereEqualTo('userPointer', userPointer);
    final result = await query.query();

    if (!result.success || result.results == null || result.results!.isEmpty) {
      return {'gender': null, 'showOnProfile': false};
    }

    final basic = result.results!.first;
    return {
      'gender': basic.get<String>('Gender'),
      'showOnProfile': basic.get<bool>('showOnProfile') ?? false,
    };
  }

  Future<void> _preloadMyImage() async {
    _myImageUrl = await _authController.fetchUserImage();
  }

  int? _calculateAge(DateTime? dob) {
    if (dob == null) return null;
    final today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }

  Future<void> _handleSwipe(CardSwipeOrientation orientation, int index) async {
    if (index >= _profiles.length) return;

    final profile = _profiles[index];
    final currentUser = await ParseUser.currentUser() as ParseUser?;
    if (currentUser == null) return;

    final interactionType = _getInteractionType(orientation);
    if (interactionType == null) return;

    final isMatch = await _authController.saveInteraction(
      fromUser: currentUser,
      toUser: profile['userPointer'] as ParseUser,
      interactionType: interactionType,
    );

    if (isMatch && mounted) {
      Future.delayed(_matchDelay, () => _navigateToMatchScreen(profile, interactionType));
    }

    if (mounted) {
      setState(() => _profiles.removeAt(index));
    }
  }

  String? _getInteractionType(CardSwipeOrientation orientation) {
    return switch (orientation) {
      CardSwipeOrientation.right => 'like',
      CardSwipeOrientation.up => 'superlike',
      _ => null,
    };
  }

  void _navigateToMatchScreen(Map<String, dynamic> profile, String interactionType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MatchScreen(
          myImageUrl: _myImageUrl ?? "",
          imageUrl: profile["imageUrl"] ?? '',
          matchedUserName: profile['name'] ?? '',
          interactionType: interactionType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cardWidth = size.width * _cardAspectRatio;
    final cardHeight = size.height * 0.8;

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
            child: _isLoading
                ? _buildShimmerLoader()
                : _profiles.isNotEmpty
                ? _buildTinderCards(cardWidth, cardHeight)
                : _buildEmptyState(),
          ),
          if (_profiles.isNotEmpty) _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildShimmerLoader() {
    return Center(
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListView.builder(
          itemCount: 5,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(height: 150, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildTinderCards(double width, double height) {
    return TinderSwapCard(
      swipeUp: true,
      swipeDown: false,
      orientation: AmassOrientation.top,
      totalNum: _profiles.length,
      stackNum: _stackNum,
      maxWidth: width,
      maxHeight: height,
      minWidth: width * 0.9,
      minHeight: height * 0.9,
      cardBuilder: (context, index) => _buildProfileCard(_profiles[index]),
      cardController: _cardController,
      swipeCompleteCallback: _handleSwipe,
    );
  }

  Widget _buildProfileCard(Map<String, dynamic> profile) {
    final name = profile['name'] as String;
    final imageUrl = profile['imageUrl'] as String?;
    final age = _calculateAge(profile['dob'] as DateTime?);
    final gender = profile['gender'] as String?;
    final showOnProfile = profile['showOnProfile'] as bool?;

    return Stack(
      children: [
        _buildProfileImage(imageUrl),
        Positioned(
          bottom: 20,
          left: 20,
          child: Text(
            "$name, ${age ?? 'N/A'}",
            style: _profileTextStyle,
          ),
        ),
        if (showOnProfile ?? false)
          Positioned(
            bottom: 50,
            left: 20,
            child: Text(
              gender ?? '',
              style: _profileTextStyle.copyWith(fontSize: 22, fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileImage(String? imageUrl) {
    return ClipRRect(
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
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'No more profiles to show',
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSwipeButton(
            icon: Icons.close,
            color: Colors.red,
            onPressed: () => _cardController.triggerLeft(),
          ),
          _buildSwipeButton(
            icon: Icons.star,
            color: Colors.blue,
            onPressed: () => _cardController.triggerUp(),
          ),
          _buildSwipeButton(
            icon: Icons.favorite,
            color: Colors.green,
            onPressed: () => _cardController.triggerRight(),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withAlpha(_buttonShadowAlpha),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(128),
            blurRadius: _buttonShadowBlur,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: color),
        iconSize: _buttonIconSize,
        onPressed: onPressed,
      ),
    );
  }

  TextStyle get _profileTextStyle => const TextStyle(
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
  );
}