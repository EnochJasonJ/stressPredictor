import 'package:flutter/material.dart';
import 'package:stresspredictor/core/theme/app_colors.dart';
import 'dart:async';

class WorkoutDetailScreen extends StatefulWidget {
  final String name;
  final String duration;
  final String difficulty;

  const WorkoutDetailScreen({
    super.key,
    required this.name,
    required this.duration,
    required this.difficulty,
  });

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  bool _isPlaying = false;
  int _secondsPassed = 0;
  Timer? _timer;

  void _toggleTimer() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _secondsPassed++;
          });
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  String get _formattedTime {
    final minutes = (_secondsPassed / 60).floor().toString().padLeft(2, '0');
    final seconds = (_secondsPassed % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Animation/Image placeholder
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: const Icon(
                Icons.self_improvement_rounded,
                size: 100,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 32),
            
            // Details Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildInfoBadge(Icons.timer_outlined, widget.duration),
                _buildInfoBadge(Icons.fitness_center_outlined, widget.difficulty),
              ],
            ),
            const SizedBox(height: 48),

            // Timer Display
            Text(
              _formattedTime,
              style: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.w200,
                
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 32),

            // Play/Pause Button
            GestureDetector(
              onTap: _toggleTimer,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isPlaying ? AppColors.error : AppColors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: (_isPlaying ? AppColors.error : AppColors.primary)
                          .withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: Icon(
                  _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Instructions
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Instructions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildStep(1, 'Find a comfortable and quiet place.'),
            _buildStep(2, 'Follow the breathing rhythm shown above.'),
            _buildStep(3, 'Keep your focus entirely on the exercise.'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(int step, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
            alignment: Alignment.center,
            child: Text(
              step.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
