import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EE),
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: const Color(0xFFB86E45),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'OROUD – Privacy Policy',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Effective Date: ${DateTime.now().year}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Welcome to Oroud. Your privacy matters to us.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          const Text(
            'This Privacy Policy explains how Oroud ("we", "our", "us") collects, uses, and protects your information when you use our mobile application and services.',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 24),
          
          _buildSection(
            '1. Information We Collect',
            [
              _buildSubSection('A. Information You Provide', [
                'Name',
                'Email address',
                'Phone number (if provided)',
                'Profile details',
                'Shop information (for business accounts)',
                'Uploaded images and offer content',
              ]),
              _buildSubSection('B. Automatically Collected Information', [
                'Device information (model, OS version)',
                'App usage activity',
                'IP address',
                'Location (if you allow location access)',
                'Push notification tokens (Firebase)',
              ]),
              _buildSubSection('C. Advertising & Analytics Data', [
                'Ad engagement data',
                'Offer interactions',
                'Points earned from activities',
              ]),
            ],
          ),
          
          _buildSection(
            '2. How We Use Your Information',
            [
              const Text(
                'We use your information to:',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 8),
              _buildBulletList([
                'Provide and improve our services',
                'Show relevant offers',
                'Allow users to claim offers',
                'Manage shop accounts',
                'Send push notifications',
                'Prevent fraud and abuse',
                'Operate leaderboard and prize systems',
                'Comply with legal obligations',
              ]),
            ],
          ),
          
          _buildSection(
            '3. Guest Users',
            [
              const Text(
                'You can browse offers without registering. However, some features (claiming offers, earning points, saving offers) require an account.',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
          
          _buildSection(
            '4. Points & Rewards System',
            [
              const Text(
                'Oroud may offer a points-based engagement system. Points:',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 8),
              _buildBulletList([
                'Have no monetary value',
                'Cannot be exchanged for cash',
                'May be used for promotional prizes',
                'Can be modified, reset, or discontinued at any time',
              ]),
              const SizedBox(height: 8),
              const Text(
                'We reserve the right to prevent abuse of the points system.',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
          
          _buildSection(
            '5. Shop Accounts',
            [
              const Text(
                'Anyone may create a shop account. Shops are responsible for:',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 8),
              _buildBulletList([
                'Accuracy of their offers',
                'Compliance with local laws',
                'Fulfillment of advertised promotions',
              ]),
              const SizedBox(height: 8),
              const Text(
                'Oroud is not responsible for disputes between users and shops.',
                style: TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          
          _buildSection(
            '6. Image & Media Uploads',
            [
              const Text(
                'Images uploaded by shops are stored securely via third-party cloud services (e.g., Cloudinary). We reserve the right to remove content that violates our policies.',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
          
          _buildSection(
            '7. Third-Party Services',
            [
              const Text(
                'We use third-party services including:',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 8),
              _buildBulletList([
                'Firebase (push notifications)',
                'Cloudinary (image storage)',
                'Payment providers (e.g., Tap Payments)',
                'Advertising networks',
              ]),
              const SizedBox(height: 8),
              const Text(
                'These services may collect data under their own privacy policies.',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
          
          _buildSection(
            '8. Data Security',
            [
              const Text(
                'We implement reasonable security measures to protect your data. However, no system is 100% secure.',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
          
          _buildSection(
            '9. Data Retention',
            [
              const Text(
                'We retain your data as long as your account remains active or as needed for legal compliance. You may request deletion of your account at any time.',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
          
          _buildSection(
            '10. Children\'s Privacy',
            [
              const Text(
                'Oroud is not intended for children under 13 years old.',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
          
          _buildSection(
            '11. Changes to This Policy',
            [
              const Text(
                'We may update this Privacy Policy at any time. Continued use of the app means you accept the updated version.',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Company: Oroud',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...content,
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSubSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        _buildBulletList(items),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildBulletList(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4, left: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ', style: TextStyle(fontSize: 14)),
              Expanded(
                child: Text(
                  item,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
