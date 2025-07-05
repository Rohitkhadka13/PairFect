import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pairfect/quiz_mood/quiz_matching.dart';
import 'mood_matching.dart';

class MatchingHomeScreen extends StatefulWidget {
  @override
  State<MatchingHomeScreen> createState() => _MatchingHomeScreenState();
}

class _MatchingHomeScreenState extends State<MatchingHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<Offset> _slide1;
  late Animation<Offset> _slide2;

  @override
  void initState() {
    super.initState();
    _fadeController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 1200));
    _slideController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800));

    _slide1 = Tween<Offset>(
      begin: Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _slide2 = Tween<Offset>(
      begin: Offset(0, 0.6),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        title: Text('Find Your Match',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.pink.shade400,
        centerTitle: true,
        elevation: 4,
      ),
      body: FadeTransition(
        opacity: _fadeController,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SlideTransition(
                position: _slide1,
                child: _buildMatchingOption(
                  icon: Icons.favorite,
                  title: 'Mood Matching',
                  subtitle: 'Connect with others sharing your vibe 💖',
                  gradient: LinearGradient(
                    colors: [Colors.pink.shade300, Colors.purple.shade200],
                  ),
                  delay: 100,
                  onTap: () => Get.to(() => MoodMatchingScreen()),
                ),
              ),
              SizedBox(height: 30),
              SlideTransition(
                position: _slide2,
                child: _buildMatchingOption(
                  icon: Icons.quiz,
                  title: 'Quiz Matching',
                  subtitle: 'Let your answers find the one 🧠✨',
                  gradient: LinearGradient(
                    colors: [Colors.indigo.shade300, Colors.blue.shade200],
                  ),
                  delay: 300,
                  onTap: () => Get.to(() => QuizMatchingScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatchingOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required LinearGradient gradient,
    required VoidCallback onTap,
    int delay = 0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1),
      duration: Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) => Transform.scale(
        scale: scale,
        child: child,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.last.withOpacity(0.4),
                blurRadius: 8,
                offset: Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white.withOpacity(0.9),
                child: Icon(icon, size: 30, color: gradient.colors.first),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.white, size: 30),
            ],
          ),
        ),
      ),
    );

  }
}
