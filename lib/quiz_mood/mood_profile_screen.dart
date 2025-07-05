import 'package:flutter/material.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:geocoding/geocoding.dart';
import '../controllers/auth_controllers.dart';

class MoodProfileScreen extends StatefulWidget {
  final ParseUser user;

   const MoodProfileScreen({required this.user, super.key});

  @override
  State<MoodProfileScreen> createState() => _MoodProfileScreenState();
}

class _MoodProfileScreenState extends State<MoodProfileScreen> {
  List<String> imageUrls = [];
  String bio = '';
  String gender = '';
  String location = 'Searching location...';
  String religion = '';
  String zodiac = '';
  String name = '';
  int? age;
  bool _isLoading = true;
  bool _liked = false;
  bool _isProcessingLike = false;

  @override
  void initState() {
    super.initState();
    loadProfileData();
  }

  Future<void> loadProfileData() async {
    try {
      final userPointer = widget.user;

      final userLoginQuery = QueryBuilder<ParseObject>(ParseObject('UserLogin'))
        ..whereEqualTo('userPointer', userPointer);
      final userLoginResult = await userLoginQuery.query();

      if (userLoginResult.success &&
          userLoginResult.results != null &&
          userLoginResult.results!.isNotEmpty) {
        final obj = userLoginResult.results!.first;

        final profileImage = obj.get<ParseFile>('imageProfile')?.url;
        final geo = obj.get<ParseGeoPoint>('location');
        name = obj.get<String>('name') ?? '';

        if (profileImage != null) imageUrls.add(profileImage);

        final dob = obj.get<DateTime>('dob');
        if (dob != null) {
          final now = DateTime.now();
          int calculatedAge = (now.year - dob.year).toInt();
          if (now.month < dob.month ||
              (now.month == dob.month && now.day < dob.day)) {
            calculatedAge--;
          }
          age = calculatedAge;
        }

        if (geo != null) {
          try {
            final placemarks =
            await placemarkFromCoordinates(geo.latitude, geo.longitude);
            if (placemarks.isNotEmpty) {
              final place = placemarks.first;
              location =
              '${place.locality ?? ''}${place.locality != null && place.country != null ? ', ' : ''}${place.country ?? ''}';
            }
          } catch (_) {
            location = 'Nearby area';
          }
        } else {
          location = 'Location not shared';
        }
      }

      final imageQuery = QueryBuilder<ParseObject>(ParseObject('UserImage'))
        ..whereEqualTo('userPointer', userPointer);
      final imageResult = await imageQuery.query();
      if (imageResult.success && imageResult.results != null) {
        for (final imageObj in imageResult.results!) {
          for (int i = 1; i <= 6; i++) {
            final file = imageObj.get<ParseFile>('Image$i');
            if (file?.url != null) imageUrls.add(file!.url!);
          }
        }
      }

      final aboutQuery = QueryBuilder<ParseObject>(ParseObject('aboutYou'))
        ..whereEqualTo('userPointer', userPointer);
      final aboutResult = await aboutQuery.query();
      if (aboutResult.success &&
          aboutResult.results != null &&
          aboutResult.results!.isNotEmpty) {
        bio = aboutResult.results!.first.get<String>('bio') ?? '';
        religion = aboutResult.results!.first.get<String>('Religion') ?? '';
        zodiac = aboutResult.results!.first.get<String>('Zodiac') ?? '';
      }

      final basicQuery = QueryBuilder<ParseObject>(ParseObject('Basic'))
        ..whereEqualTo('userPointer', userPointer);
      final basicResult = await basicQuery.query();
      if (basicResult.success &&
          basicResult.results != null &&
          basicResult.results!.isNotEmpty) {
        final basic = basicResult.results!.first;
        gender = basic.get<String>('Gender') ?? '';
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(name,
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(color: Colors.black54, blurRadius: 10)])),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.pink))
          : Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.pink.shade100.withOpacity(0.8),
                  Colors.purple.shade100.withOpacity(0.8),
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 450,
                  child: Stack(
                    children: [
                      Swiper(
                        itemCount: imageUrls.length,
                        itemBuilder: (context, index) => Container(
                          margin: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.pink.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 2,
                              )
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              imageUrls[index],
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  color: Colors.pink.shade100,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value: progress
                                          .expectedTotalBytes !=
                                          null
                                          ? progress
                                          .cumulativeBytesLoaded /
                                          progress.expectedTotalBytes!
                                          : null,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        pagination: SwiperPagination(
                          builder: DotSwiperPaginationBuilder(
                            color: Colors.white.withOpacity(0.5),
                            activeColor: Colors.pink,
                            size: 8,
                            activeSize: 10,
                          ),
                        ),
                        control: SwiperControl(color: Colors.pink),
                        loop: false,
                        viewportFraction: 0.85,
                        scale: 0.9,
                      ),
                      Positioned(
                        bottom: 20,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.pink.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Swipe to see more',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    color: Colors.white.withOpacity(0.9),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.favorite, color: Colors.pink),
                              SizedBox(width: 8),
                              Text(
                                "Heart's Story",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.pinkAccent,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            bio.isNotEmpty
                                ? bio
                                : 'This romantic soul prefers to let their heart do the talking...',
                            style: TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                color: Colors.grey.shade800),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            name.isNotEmpty
                                ? '$name${age != null ? ', $age' : ''}'
                                : 'Mystery Person',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.pink.shade700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                              icon: Icons.person,
                              title: 'Gender',
                              value: gender.isNotEmpty
                                  ? gender
                                  : 'Mysterious'),
                          _buildDetailRow(
                              icon: Icons.location_on,
                              title: 'Location',
                              value: location),
                          _buildDetailRow(
                              icon: Icons.account_balance,
                              title: 'Religion',
                              value: religion.isNotEmpty
                                  ? religion
                                  : 'Unknown'),
                          _buildDetailRow(
                              icon: Icons.star,
                              title: 'Zodiac',
                              value:
                              zodiac.isNotEmpty ? zodiac : 'Unknown'),
                          const SizedBox(height: 20),
                          Center(
                            child: _liked
                                ? Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.pink.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.check,
                                      color: Colors.pink),
                                  SizedBox(width: 8),
                                  Text(
                                    'You liked this profile',
                                    style: TextStyle(
                                      color: Colors.pink,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            )
                                : _buildActionButton(
                              icon: Icons.favorite,
                              label: 'Like',
                              color: Colors.pink,
                              onPressed: _isProcessingLike
                                  ? null
                                  : () async {
                                setState(() {
                                  _isProcessingLike = true;
                                });

                                final currentUser =
                                await ParseUser.currentUser()
                                as ParseUser?;
                                if (currentUser == null) {
                                  setState(() {
                                    _isProcessingLike = false;
                                  });
                                  return;
                                }

                                final authController =
                                AuthController();
                                final isMutual =
                                await authController
                                    .saveInteraction(
                                  fromUser: currentUser,
                                  toUser: widget.user,
                                  interactionType: 'like',
                                );

                                if (mounted) {
                                  setState(() {
                                    _liked = true;
                                    _isProcessingLike = false;
                                  });
                                }

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  SnackBar(
                                    content: Text(isMutual
                                        ? 'It\'s a match! 💖'
                                        : 'You liked this profile!'),
                                    backgroundColor:
                                    Colors.pink.shade300,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
      {required IconData icon, required String title, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.pink.shade400, size: 22),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
              const SizedBox(height: 2),
              Text(value,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade800)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                color.withOpacity(onPressed == null ? 0.1 : 0.3),
                color.withOpacity(onPressed == null ? 0.3 : 1.0),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                  color: color.withOpacity(onPressed == null ? 0.1 : 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: IconButton(
            icon: Icon(icon,
                color: onPressed == null
                    ? Colors.white.withOpacity(0.5)
                    : Colors.white),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                color: onPressed == null
                    ? color.withOpacity(0.5)
                    : color,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}