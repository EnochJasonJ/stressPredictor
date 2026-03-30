import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stresspredictor/core/constants/app_constants.dart';
import 'package:stresspredictor/core/theme/app_colors.dart';

/// Workout screen - displays stress-relief exercise suggestions.
/// Placeholder screen with categories: Breathing, Stretching, Cardio.
class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Stress Relief Exercises',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose exercises to help manage your stress',
              style: TextStyle(
                fontSize: 14,
                
              ),
            ),
            const SizedBox(height: 24),
            // Breathing category
            _buildCategorySection(
              'Breathing',
              Icons.air,
              AppColors.primary,
              [
                _ExerciseCard(
                  title: 'Deep Breathing',
                  duration: '5 min',
                  difficulty: 'Beginner',
                  onTap: () => _showExerciseDetails(context, 'Deep Breathing', '5 min', 'Beginner'),
                ),
                _ExerciseCard(
                  title: 'Box Breathing',
                  duration: '4 min',
                  difficulty: 'Beginner',
                  onTap: () => _showExerciseDetails(context, 'Box Breathing', '4 min', 'Beginner'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Stretching category
            _buildCategorySection(
              'Stretching',
              Icons.self_improvement,
              AppColors.secondary,
              [
                _ExerciseCard(
                  title: 'Neck & Shoulders',
                  duration: '8 min',
                  difficulty: 'Beginner',
                  onTap: () => _showExerciseDetails(context, 'Neck & Shoulders', '8 min', 'Beginner'),
                ),
                _ExerciseCard(
                  title: 'Full Body Stretch',
                  duration: '15 min',
                  difficulty: 'Intermediate',
                  onTap: () => _showExerciseDetails(context, 'Full Body Stretch', '15 min', 'Intermediate'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Cardio category
            _buildCategorySection(
              'Cardio',
              Icons.directions_run,
              AppColors.accent,
              [
                _ExerciseCard(
                  title: 'Quick Walk',
                  duration: '10 min',
                  difficulty: 'Beginner',
                  onTap: () => _showExerciseDetails(context, 'Quick Walk', '10 min', 'Beginner'),
                ),
                _ExerciseCard(
                  title: 'Dance Break',
                  duration: '5 min',
                  difficulty: 'Fun',
                  onTap: () => _showExerciseDetails(context, 'Dance Break', '5 min', 'Fun'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(
    String title,
    IconData icon,
    Color color,
    List<Widget> exercises,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...exercises,
      ],
    );
  }

  void _showExerciseDetails(BuildContext context, String exerciseName, String duration, String difficulty) {
    context.push(
      AppConstants.workoutDetailPath,
      extra: {
        'name': exerciseName,
        'duration': duration,
        'difficulty': difficulty,
      },
    );
  }
}

/// Exercise card widget for displaying individual exercises.
class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.title,
    required this.duration,
    required this.difficulty,
    required this.onTap,
  });

  final String title;
  final String duration;
  final String difficulty;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Color difficultyColor;
    switch (difficulty) {
      case 'Beginner':
        difficultyColor = AppColors.stressLow;
        break;
      case 'Intermediate':
        difficultyColor = AppColors.stressMedium;
        break;
      default:
        difficultyColor = AppColors.primary;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.play_arrow_rounded,
            color: AppColors.primary,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            
          ),
        ),
        subtitle: Row(
          children: [
            Text(
              duration,
              style: const TextStyle(
                fontSize: 12,
                
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: difficultyColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                difficulty,
                style: TextStyle(
                  fontSize: 11,
                  color: difficultyColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        trailing: const Icon(
          Icons.chevron_right,
          
        ),
      ),
    );
  }
}