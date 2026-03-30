import 'package:flutter/material.dart';
import 'package:stresspredictor/core/theme/app_colors.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & FAQ'),
        
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildFaqItem(
            context,
            'How is my stress calculated?',
            'The app uses a Random Forest Machine Learning model trained on the SaYoPillow dataset. It analyzes 8 key physiological markers (like heart rate, sleep duration, and blood oxygen) to classify your stress natively between Very Low and Very High.',
          ),
          _buildFaqItem(
            context,
            'Why does the model say "Very High" stress?',
            'The predictive model considers factors such as very low sleep (0-2 hours), high continuous respiration, and low oxygen levels as signs of excessive bodily strain. Logging healthier vitals will stabilize predictions.',
          ),
          _buildFaqItem(
            context,
            'Health Data isn\'t syncing?',
            'Ensure you have installed the "Health Connect by Android" app from the Play Store. Also, confirm you have granted Stress Predictor the permission to read Heart Rate and Sleep data.',
          ),
          _buildFaqItem(
            context,
            'How do the workouts help?',
            'The workout module provides timed, structured exercises like Box Breathing and Full Body Stretching that are clinically proven to activate the parasympathetic nervous system, lowering your acute heart rate.',
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(BuildContext context, String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            
          ),
        ),
        iconColor: AppColors.primary,
        collapsedIconColor: Theme.of(context).textTheme.bodyMedium?.color,
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Text(
            answer,
            style: const TextStyle(
              fontSize: 14,
              
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
