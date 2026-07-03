import 'package:istakibim/core/enums/app_enums.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.teamId,
    this.active = true,
    this.fcmToken,
    this.createdAt,
  });

  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String? teamId;
  final bool active;
  final String? fcmToken;
  final DateTime? createdAt;

  bool get isAdmin => role == UserRole.admin;

  factory AppUser.fromMap(String id, Map<String, dynamic> data) {
    return AppUser(
      id: id,
      email: data['email'] as String? ?? '',
      name: data['name'] as String? ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == data['role'],
        orElse: () => UserRole.worker,
      ),
      teamId: data['teamId'] as String?,
      active: data['active'] as bool? ?? true,
      fcmToken: data['fcmToken'] as String?,
      createdAt: (data['createdAt'] as dynamic)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'email': email,
        'name': name,
        'role': role.name,
        'teamId': teamId,
        'active': active,
        'fcmToken': fcmToken,
        'createdAt': createdAt,
      };

  AppUser copyWith({
    String? name,
    UserRole? role,
    String? teamId,
    bool? active,
    String? fcmToken,
  }) {
    return AppUser(
      id: id,
      email: email,
      name: name ?? this.name,
      role: role ?? this.role,
      teamId: teamId ?? this.teamId,
      active: active ?? this.active,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt,
    );
  }
}
