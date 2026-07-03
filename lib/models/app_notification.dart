class AppNotification {
  const AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.taskId,
    this.read = false,
    this.createdAt,
  });

  final String id;
  final String userId;
  final String title;
  final String body;
  final String type;
  final String? taskId;
  final bool read;
  final DateTime? createdAt;

  factory AppNotification.fromMap(String id, Map<String, dynamic> data) {
    return AppNotification(
      id: id,
      userId: data['userId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      type: data['type'] as String? ?? '',
      taskId: data['taskId'] as String?,
      read: data['read'] as bool? ?? false,
      createdAt: (data['createdAt'] as dynamic)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'title': title,
        'body': body,
        'type': type,
        'taskId': taskId,
        'read': read,
        'createdAt': createdAt,
      };
}
