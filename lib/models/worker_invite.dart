class WorkerInvite {
  const WorkerInvite({
    required this.id,
    required this.email,
    required this.name,
    this.teamId,
    this.active = true,
    this.createdAt,
  });

  final String id;
  final String email;
  final String name;
  final String? teamId;
  final bool active;
  final DateTime? createdAt;

  factory WorkerInvite.fromMap(String id, Map<String, dynamic> data) {
    return WorkerInvite(
      id: id,
      email: data['email'] as String? ?? '',
      name: data['name'] as String? ?? '',
      teamId: data['teamId'] as String?,
      active: data['active'] as bool? ?? true,
      createdAt: (data['createdAt'] as dynamic)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'email': email,
        'name': name,
        'teamId': teamId,
        'active': active,
        'createdAt': createdAt,
      };
}
