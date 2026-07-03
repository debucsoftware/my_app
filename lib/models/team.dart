class Team {
  const Team({
    required this.id,
    required this.name,
    this.memberIds = const [],
    this.createdAt,
  });

  final String id;
  final String name;
  final List<String> memberIds;
  final DateTime? createdAt;

  factory Team.fromMap(String id, Map<String, dynamic> data) {
    return Team(
      id: id,
      name: data['name'] as String? ?? '',
      memberIds: List<String>.from(data['memberIds'] as List? ?? []),
      createdAt: (data['createdAt'] as dynamic)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'memberIds': memberIds,
        'createdAt': createdAt,
      };
}
