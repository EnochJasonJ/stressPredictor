class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'Stress Predictor';
  static const String appVersion = '1.0.0';

  // Animation durations
  static const Duration introAnimationDuration = Duration(seconds: 2);
  static const Duration introDelay = Duration(seconds: 3);

  // Route paths
  static const String introPath = '/';
  static const String loginPath = '/login';
  static const String signupPath = '/signup';
  static const String homePath = '/home';
  static const String workoutPath = '/workout';
  static const String workoutDetailPath = '/workout/detail';
  static const String profilePath = '/profile';
  static const String predictPath = '/predict';
  static const String appearancePath = '/profile/appearance';
  static const String privacyPath = '/profile/privacy';
  static const String helpPath = '/profile/help';
  static const String dataViewPath = '/data-view';
  static const String healthDataPath = '/health-data';

  // Stress levels
  static const double stressLevelLow = 33.0;
  static const double stressLevelMedium = 66.0;
  static const double stressLevelHigh = 100.0;

  // Days of the week
  static const List<String> weekDays = ['M', 'T', 'W', 'Th', 'F', 'S', 'S'];

  // Default sleep hours
  static const List<int> defaultSleepHours = [7, 9, 6, 8, 5, 8, 10];
}
