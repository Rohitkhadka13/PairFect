import 'package:flutter/material.dart';

class PrivacyAndPolicyScreen extends StatelessWidget {
  const PrivacyAndPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Privacy Policy",
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline,
                  size: 32,
                  color: Colors.blueAccent,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Introduction
            _buildSection(
              title: "Your Privacy Matters",
              content: "At PairFect, we're committed to protecting your personal information. This policy explains how we collect, use, and safeguard your data when you use our services.",
            ),

            const SizedBox(height: 28),

            // Information Collection
            _buildSectionCard(
              title: "1. Information We Collect",
              points: const [
                "Personal details (name, email, date of birth)",
                "Profile information including images",
                "Messages and interactions between users",
                "Device and location data (with your permission)",
                "Usage data and preferences",
              ],
              icon: Icons.collections_bookmark,
            ),

            const SizedBox(height: 24),

            // Data Usage
            _buildSectionCard(
              title: "2. How We Use Your Information",
              points: const [
                "To create and manage your account",
                "To match you with compatible users",
                "To improve and personalize our services",
                "To communicate important updates",
                "To ensure platform security and prevent fraud",
              ],
              icon: Icons.data_usage,
            ),

            const SizedBox(height: 24),

            // Data Protection
            _buildSection(
              title: "3. Data Protection",
              content: "We implement industry-standard security measures including encryption, secure servers, and regular audits to protect your information. We never sell your personal data to third parties.",
            ),

            const SizedBox(height: 28),

            // User Rights
            _buildSectionCard(
              title: "4. Your Rights & Choices",
              points: const [
                "Access and download your data anytime",
                "Request corrections to inaccurate information",
                "Delete your account and associated data",
                "Opt-out of marketing communications",
                "Withdraw previously given consents",
              ],
              icon: Icons.manage_accounts,
            ),

            const SizedBox(height: 28),

            // Agreement Notice
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: const Text(
                "By using PairFect, you acknowledge that you have read and understood this Privacy Policy.",
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 20),

            // Last Updated
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Last updated: June 17, 2025",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          content,
          style: TextStyle(
            fontSize: 15,
            height: 1.6,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<String> points,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 22, color: Colors.blueAccent),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...points.map((point) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 4, right: 8),
                  child: Icon(
                    Icons.circle,
                    size: 6,
                    color: Colors.blueAccent,
                  ),
                ),
                Expanded(
                  child: Text(
                    point,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }
}