import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EE),
      appBar: AppBar(
        title: const Text('Terms of Service'),
        backgroundColor: const Color(0xFFB86E45),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'OROUD – Terms of Service',
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
            'By using Oroud, you agree to the following terms.',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 24),
          
          _buildSection(
            '1. Platform Description',
            [
              const Text(
                'Oroud is a local marketplace platform that allows:',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 8),
              _buildBulletList([
                'Shops to publish promotional offers',
                'Users to browse and claim offers',
                'Users to earn engagement-based points',
                'Participation in promotional prize systems',
              ]),
            ],
          ),
          
          _buildSection(
            '2. User Accounts',
            [
              const Text(
                'You may:',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 8),
              _buildBulletList([
                'Browse as a guest',
                'Register for a personal account',
                'Create a shop account',
              ]),
              const SizedBox(height: 8),
              const Text(
                'You are responsible for keeping your login credentials secure.',
                style: TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          
          _buildSection(
            '3. Shop Responsibilities',
            [
              const Text(
                'Shops must:',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 8),
              _buildBulletList([
                'Provide accurate offer details',
                'Honor advertised promotions',
                'Comply with local business laws',
                'Avoid misleading or fraudulent content',
              ]),
              const SizedBox(height: 8),
              const Text(
                'Oroud reserves the right to remove shops at its discretion.',
                style: TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          
          _buildSection(
            '4. Offer Claims',
            [
              const Text(
                'When you claim an offer:',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 8),
              _buildBulletList([
                'You agree to the shop\'s terms',
                'Availability may be limited',
                'Oroud does not guarantee fulfillment',
                'Disputes must be resolved between user and shop',
              ]),
            ],
          ),
          
          _buildSection(
            '5. Points & Leaderboard System',
            [
              const Text(
                'Points:',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 8),
              _buildBulletList([
                'Are promotional only',
                'Have no cash value',
                'May expire or reset',
                'Can be revoked for abuse',
              ]),
              const SizedBox(height: 8),
              const Text(
                'Prize systems are subject to separate rules announced by Oroud. Oroud may modify or discontinue rewards at any time.',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
          
          _buildSection(
            '6. Payments',
            [
              const Text(
                'Some features may require payments (e.g., shop promotions). Payments are processed by third-party providers. Oroud does not store full payment details.',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
          
          _buildSection(
            '7. Prohibited Activities',
            [
              const Text(
                'You may not:',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 8),
              _buildBulletList([
                'Abuse the points system',
                'Use bots or automation',
                'Upload illegal or harmful content',
                'Attempt to hack or exploit the system',
                'Impersonate others',
              ]),
              const SizedBox(height: 8),
              const Text(
                'Violations may result in account suspension.',
                style: TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          
          _buildSection(
            '8. Limitation of Liability',
            [
              const Text(
                'Oroud is not liable for:',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 8),
              _buildBulletList([
                'Shop fulfillment failures',
                'User-generated content',
                'Indirect or consequential damages',
                'Prize availability changes',
              ]),
              const SizedBox(height: 8),
              const Text(
                'Use of the app is at your own risk.',
                style: TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          
          _buildSection(
            '9. Termination',
            [
              const Text(
                'We may suspend or terminate accounts at our discretion.',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
          
          _buildSection(
            '10. Governing Law',
            [
              const Text(
                'These Terms are governed by the laws of Jordan.',
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
