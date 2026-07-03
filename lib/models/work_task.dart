import 'package:istakibim/core/enums/app_enums.dart';
import 'package:istakibim/models/checklist_item.dart';

class WorkTask {
  const WorkTask({
    required this.id,
    required this.projectId,
    required this.unitId,
    required this.title,
    this.description,
    this.assignedWorkerIds = const [],
    this.dueDate,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.pending,
    this.room,
    this.checklist = const [],
    this.photoUrls = const [],
    this.workerNote,
    this.approvalStatus = ApprovalStatus.pending,
    this.completedAt,
    this.durationHours,
    this.createdAt,
    this.archived = false,
  });

  final String id;
  final String projectId;
  final String unitId;
  final String title;
  final String? description;
  final List<String> assignedWorkerIds;
  final DateTime? dueDate;
  final TaskPriority priority;
  final TaskStatus status;
  final String? room;
  final List<ChecklistItem> checklist;
  final List<String> photoUrls;
  final String? workerNote;
  final ApprovalStatus approvalStatus;
  final DateTime? completedAt;
  final double? durationHours;
  final DateTime? createdAt;
  final bool archived;

  bool isAssignedTo(String workerId) => assignedWorkerIds.contains(workerId);

  bool get isOverdue {
    if (dueDate == null) return false;
    if (status == TaskStatus.completed || status == TaskStatus.approved) {
      return false;
    }
    return DateTime.now().isAfter(dueDate!);
  }

  factory WorkTask.fromMap(String id, Map<String, dynamic> data) {
    return WorkTask(
      id: id,
      projectId: data['projectId'] as String? ?? '',
      unitId: data['unitId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String?,
      assignedWorkerIds:
          List<String>.from(data['assignedWorkerIds'] as List? ?? []),
      dueDate: (data['dueDate'] as dynamic)?.toDate(),
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == data['priority'],
        orElse: () => TaskPriority.medium,
      ),
      status: TaskStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => TaskStatus.pending,
      ),
      room: data['room'] as String?,
      checklist: (data['checklist'] as List? ?? [])
          .map((e) => ChecklistItem.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      photoUrls: List<String>.from(data['photoUrls'] as List? ?? []),
      workerNote: data['workerNote'] as String?,
      approvalStatus: ApprovalStatus.values.firstWhere(
        (e) => e.name == data['approvalStatus'],
        orElse: () => ApprovalStatus.pending,
      ),
      completedAt: (data['completedAt'] as dynamic)?.toDate(),
      durationHours: (data['durationHours'] as num?)?.toDouble(),
      createdAt: (data['createdAt'] as dynamic)?.toDate(),
      archived: data['archived'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'projectId': projectId,
        'unitId': unitId,
        'title': title,
        'description': description,
        'assignedWorkerIds': assignedWorkerIds,
        'dueDate': dueDate,
        'priority': priority.name,
        'status': status.name,
        'room': room,
        'checklist': checklist.map((e) => e.toMap()).toList(),
        'photoUrls': photoUrls,
        'workerNote': workerNote,
        'approvalStatus': approvalStatus.name,
        'completedAt': completedAt,
        'durationHours': durationHours,
        'createdAt': createdAt,
        'archived': archived,
      };

  WorkTask copyWith({
    String? title,
    String? description,
    List<String>? assignedWorkerIds,
    DateTime? dueDate,
    TaskPriority? priority,
    TaskStatus? status,
    String? room,
    List<ChecklistItem>? checklist,
    List<String>? photoUrls,
    String? workerNote,
    ApprovalStatus? approvalStatus,
    DateTime? completedAt,
    double? durationHours,
    bool? archived,
  }) {
    return WorkTask(
      id: id,
      projectId: projectId,
      unitId: unitId,
      title: title ?? this.title,
      description: description ?? this.description,
      assignedWorkerIds: assignedWorkerIds ?? this.assignedWorkerIds,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      room: room ?? this.room,
      checklist: checklist ?? this.checklist,
      photoUrls: photoUrls ?? this.photoUrls,
      workerNote: workerNote ?? this.workerNote,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      completedAt: completedAt ?? this.completedAt,
      durationHours: durationHours ?? this.durationHours,
      createdAt: createdAt,
      archived: archived ?? this.archived,
    );
  }
}
