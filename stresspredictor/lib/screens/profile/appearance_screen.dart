import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stresspredictor/core/theme/app_colors.dart';
import 'package:stresspredictor/providers/theme_provider.dart';

class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance'),
        
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              const Text(
                'Theme Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  
                ),
              ),
              const SizedBox(height: 16),
              _buildThemeOption(
                  context, themeProvider, 'System Default', Icons.brightness_auto_rounded),
              _buildThemeOption(context, themeProvider, 'Light', Icons.wb_sunny_rounded),
              _buildThemeOption(context, themeProvider, 'Dark', Icons.nights_stay_rounded),
              const SizedBox(height: 48),
              const Text(
                'A system-wide ThemeProvider has been attached. Enjoy your personalized stress-relief environment!',
                style: TextStyle(
                  fontSize: 14,
                  
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildThemeOption(
      BuildContext context, ThemeProvider themeProvider, String title, IconData icon) {
    final isSelected = themeProvider.themeModeName == title;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? AppColors.primary : Theme.of(context).textTheme.bodyMedium?.color),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppColors.primary : Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
            : null,
        onTap: () {
          themeProvider.setTheme(title);
        },
      ),
    );
  }
}
