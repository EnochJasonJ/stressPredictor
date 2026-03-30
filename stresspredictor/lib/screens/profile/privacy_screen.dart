import 'package:flutter/material.dart';
import 'package:stresspredictor/core/theme/app_colors.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Security'),
        
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(
                Icons.security_rounded,
                size: 80,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Your Data Stays Yours',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'We believe your health data is deeply personal. Our architecture is designed with a privacy-first approach.',
              style: TextStyle(
                fontSize: 16,
                
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            _buildSection(
              context,
              'Local Processing',
              'All machine learning predictions and data correlations are processed locally on your device or over secure local networks. We do not sell your data.',
              Icons.memory_rounded,
            ),
            _buildSection(
              context,
              'Health Connect',
              'We only read the basic vital signs needed for stress prediction (Heart Rate, Respiratory Rate, Sleep). You can revoke these permissions at any time via Android Settings.',
              Icons.health_and_safety_rounded,
            ),
            _buildSection(
              context,
              'Secure Storage',
              'Your passwords and credentials use SHA-256 cryptographic hashing. They cannot be read in plaintext.',
              Icons.lock_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String body, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 14,
                    
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
