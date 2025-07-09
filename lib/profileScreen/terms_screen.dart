import 'package:flutter/material.dart';

class TermsAndConditionScreen extends StatelessWidget {
  const TermsAndConditionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Terms & Conditions",
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
                  color: Colors.purple[50],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.description_outlined,
                  size: 32,
                  color: Colors.purpleAccent,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Introduction
            _buildSection(
              title: "Welcome to PairFect",
              content: "By accessing or using our app, you agree to be bound by these Terms and Conditions. Please read them carefully before using our services.",
            ),

            const SizedBox(height: 28),

            // Eligibility
            _buildTermCard(
              title: "1. Eligibility Requirements",
              icon: Icons.verified_user_outlined,
              content: "You must be at least 18 years old to use this app. By registering, you confirm that you meet this age requirement and all other eligibility criteria.",
            ),

            const SizedBox(height: 16),

            // User Conduct
            _buildTermCard(
              title: "2. User Conduct & Responsibilities",
              icon: Icons.groups_outlined,
              points: const [
                "Treat all users with respect and courtesy",
                "No harassment, hate speech, or abusive content",
                "Do not impersonate others or create fake profiles",
                "No illegal activities or prohibited content",
                "Comply with all applicable laws and regulations"
              ],
            ),

            const SizedBox(height: 16),

            // Account Security
            _buildTermCard(
              title: "3. Account Security",
              icon: Icons.lock_outline,
              content: "You are solely responsible for maintaining the confidentiality of your login credentials. Notify us immediately of any unauthorized account access or security breaches.",
            ),

            const SizedBox(height: 16),

            // Content Ownership
            _buildTermCard(
              title: "4. Content & Intellectual Property",
              icon: Icons.copyright_outlined,
              points: const [
                "You retain ownership of your user-generated content",
                "You grant PairFect a license to display and distribute your content",
                "No commercial use of others' content without permission",
                "Report copyright infringement through proper channels"
              ],
            ),

            const SizedBox(height: 16),

            // Termination
            _buildTermCard(
              title: "5. Account Termination",
              icon: Icons.block_outlined,
              content: "We reserve the right to suspend or terminate accounts that violate these terms. You may delete your account at any time through the app settings.",
            ),

            const SizedBox(height: 16),

            // Modifications
            _buildTermCard(
              title: "6. Changes to Terms",
              icon: Icons.update_outlined,
              content: "We may update these terms periodically. Continued use after changes constitutes acceptance. We'll notify you of significant modifications.",
            ),

            const SizedBox(height: 24),

            // Agreement Notice
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple[100]!),
              ),
              child: const Text(
                "By using PairFect, you acknowledge that you have read, understood, and agreed to these Terms and Conditions.",
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

  Widget _buildTermCard({
    required String title,
    required IconData icon,
    String? content,
    List<String>? points,
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
              Icon(icon, size: 22, color: Colors.purpleAccent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (content != null)
            Text(
              content,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.grey[800],
              ),
            ),
          if (points != null)
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
                      color: Colors.purpleAccent,
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
            )),
        ],
      ),
    );
  }
}