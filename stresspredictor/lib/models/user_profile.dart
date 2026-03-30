/// User profile model for storing editable user information.
class UserProfile {
  final String name;
  final String email;
  final bool notificationsEnabled;
  final DateTime memberSince;

  const UserProfile({
    required this.name,
    required this.email,
    required this.notificationsEnabled,
    required this.memberSince,
  });

  factory UserProfile.defaultProfile() => UserProfile(
        name: 'User',
        email: 'user@example.com',
        notificationsEnabled: true,
        memberSince: DateTime.now(),
      );

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        name: json['name'] as String? ?? 'User',
        email: json['email'] as String? ?? 'user@example.com',
        notificationsEnabled:
            json['notifications_enabled'] as bool? ?? true,
        memberSince: json['member_since'] != null
            ? DateTime.parse(json['member_since'] as String)
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'notifications_enabled': notificationsEnabled,
        'member_since': memberSince.toIso8601String(),
      };

  UserProfile copyWith({
    String? name,
    String? email,
    bool? notificationsEnabled,
    DateTime? memberSince,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      memberSince: memberSince ?? this.memberSince,
    );
  }
}
