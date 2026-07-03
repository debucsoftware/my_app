class ChecklistItem {
  const ChecklistItem({
    required this.title,
    this.completed = false,
    this.note,
    this.photoUrl,
  });

  final String title;
  final bool completed;
  final String? note;
  final String? photoUrl;

  factory ChecklistItem.fromMap(Map<String, dynamic> data) {
    return ChecklistItem(
      title: data['title'] as String? ?? '',
      completed: data['completed'] as bool? ?? false,
      note: data['note'] as String?,
      photoUrl: data['photoUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'completed': completed,
        'note': note,
        'photoUrl': photoUrl,
      };

  ChecklistItem copyWith({
    bool? completed,
    String? note,
    String? photoUrl,
  }) {
    return ChecklistItem(
      title: title,
      completed: completed ?? this.completed,
      note: note ?? this.note,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
