/// Konstanta global aplikasi
class AppConstants {
  static const String appName = 'TugasKu Pro';
  static const String appTagline = 'Enterprise Task Management & Productivity';
  static const String appVersion = 'v1.0.0-enterprise';

  // Storage Keys
  static const String tasksStorageKey = 'enterprise_todo_tasks_v3';
  static const String themeStorageKey = 'enterprise_todo_theme_mode';
  static const String userStorageKey = 'enterprise_auth_user_v1';
  static const String streakStorageKey = 'enterprise_user_streak_days';

  // Default Categories
  static const List<String> defaultCategories = [
    'Sekolah',
    'Coding',
    'Personal',
    'Kerja',
    'Lainnya',
  ];
}
