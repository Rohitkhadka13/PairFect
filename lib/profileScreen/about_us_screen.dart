import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "About PairFect",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.pink[50],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite,
                    size: 40,
                    color: Colors.pinkAccent,
                  )),
            ),
            const SizedBox(height: 24),

            // Welcome section
            _buildSection(
              title: "Welcome to PairFect!",
              content: "PairFect is a modern dating and social connection platform designed to help people find meaningful relationships. Whether you're looking for love, friendship, or just someone to talk to, PairFect connects you with people who match your interests and values.",
              icon: Icons.celebration,
            ),

            const SizedBox(height: 32),

            // Mission section
            _buildSection(
              title: "Our Mission",
              content: "To create a safe, user-friendly, and fun platform that empowers users to meet genuine people and build real connections.",
              icon: Icons.flag,
            ),

            const SizedBox(height: 32),

            // Features section
            const Text(
              "Why Choose PairFect?",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _buildFeatureItem(Icons.verified_user, "Verified Profiles"),
            _buildFeatureItem(Icons.psychology, "Smart Matching"),
            _buildFeatureItem(Icons.lock, "Privacy Protection"),
            _buildFeatureItem(Icons.chat_bubble, "Real-time Chat"),
            _buildFeatureItem(Icons.thumb_up, "Easy-to-Use Interface"),

            const SizedBox(height: 32),

            // Team section
            _buildSection(
              title: "Our Team",
              content: "PairFect was created by a passionate team of developers, designers, and relationship experts who believe in the power of meaningful connections.",
              icon: Icons.people,
            ),

            const SizedBox(height: 32),

            // Thank you section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.pink[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Thank you for being part of the PairFect community! ❤️",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content, required IconData icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 24, color: Colors.pinkAccent),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: TextStyle(
            fontSize: 16,
            height: 1.6,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.pinkAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}