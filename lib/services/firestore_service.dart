import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:istakibim/core/enums/app_enums.dart';
import 'package:istakibim/models/app_notification.dart';
import 'package:istakibim/models/app_user.dart';
import 'package:istakibim/models/project.dart';
import 'package:istakibim/models/team.dart';
import 'package:istakibim/models/unit.dart';
import 'package:istakibim/models/work_task.dart';
import 'package:istakibim/models/worker_invite.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  // --- Uygulama kilidi (Firebase Console'dan yönetilir) ---
  static const String licenseCollection = 'app_config';
  static const String licenseDocId = 'license';

  Future<bool> fetchLicenseFromServer() async {
    try {
      final snap = await _db
          .collection(licenseCollection)
          .doc(licenseDocId)
          .get(const GetOptions(source: Source.server));
      return _licenseEnabledFromSnap(snap);
    } catch (_) {
      return false;
    }
  }

  Stream<bool> watchAppLicenseEnabled() {
    final docRef = _db.collection(licenseCollection).doc(licenseDocId);
    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? sub;
    final controller = StreamController<bool>();

    Future<void> start() async {
      try {
        final snap = await docRef.get(const GetOptions(source: Source.server));
        if (!controller.isClosed) {
          controller.add(_licenseEnabledFromSnap(snap));
        }
      } catch (_) {
        if (!controller.isClosed) controller.add(false);
      }

      sub = docRef.snapshots().listen(
        (snap) {
          if (snap.metadata.isFromCache) return;
          if (!controller.isClosed) {
            controller.add(_licenseEnabledFromSnap(snap));
          }
        },
        onError: (_) {
          if (!controller.isClosed) controller.add(false);
        },
      );
    }

    start();
    controller.onCancel = () => sub?.cancel();
    return controller.stream;
  }

  bool _licenseEnabledFromSnap(DocumentSnapshot<Map<String, dynamic>> snap) {
    if (!snap.exists) return false;
    final data = snap.data();
    if (data == null) return false;
    final value = data['aktif'] ?? data['active'] ?? data['enabled'] ?? data['anahtar'];
    return _parseLicenseActive(value);
  }

  bool _parseLicenseActive(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
    }
    if (value is int) return value != 0;
    return false;
  }

  // --- Users ---
  Stream<List<AppUser>> watchWorkers() {
    return _db
        .collection('users')
        .where('role', isEqualTo: UserRole.worker.name)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => AppUser.fromMap(d.id, d.data())).toList());
  }

  Stream<List<WorkerInvite>> watchWorkerInvites() {
    return _db.collection('worker_invites').orderBy('email').snapshots().map(
          (snap) => snap.docs
              .map((d) => WorkerInvite.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  Future<void> updateUser(AppUser user) {
    return _db.collection('users').doc(user.id).update(user.toMap());
  }

  Future<void> deleteUser(String userId) {
    return _db.collection('users').doc(userId).delete();
  }

  // --- Teams ---
  Stream<List<Team>> watchTeams() {
    return _db.collection('teams').orderBy('name').snapshots().map(
          (snap) => snap.docs.map((d) => Team.fromMap(d.id, d.data())).toList(),
        );
  }

  Future<String> saveTeam(Team team) async {
    final data = {
      ...team.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    };
    if (team.id.isEmpty) {
      final ref = await _db.collection('teams').add(data);
      return ref.id;
    }
    await _db.collection('teams').doc(team.id).set(data, SetOptions(merge: true));
    return team.id;
  }

  Future<void> deleteTeam(String teamId) {
    return _db.collection('teams').doc(teamId).delete();
  }

  // --- Projects ---
  Stream<List<Project>> watchProjects() {
    return _db.collection('projects').snapshots().map((snap) {
      final projects =
          snap.docs.map((d) => Project.fromMap(d.id, d.data())).toList();
      projects.sort((a, b) {
        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });
      return projects;
    });
  }

  Future<String> saveProject(Project project) async {
    final data = {
      ...project.toMap(),
      'createdAt': project.createdAt ?? FieldValue.serverTimestamp(),
    };
    if (project.id.isEmpty) {
      final ref = await _db.collection('projects').add(data);
      return ref.id;
    }
    await _db.collection('projects').doc(project.id).set(data, SetOptions(merge: true));
    return project.id;
  }

  Future<void> deleteProject(String projectId) {
    return _db.collection('projects').doc(projectId).delete();
  }

  // --- Units ---
  Stream<List<Unit>> watchUnits(String projectId) {
    return _db
        .collection('units')
        .where('projectId', isEqualTo: projectId)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Unit.fromMap(d.id, d.data())).toList());
  }

  Future<String> saveUnit(Unit unit) async {
    final data = {
      ...unit.toMap(),
      'createdAt': unit.createdAt ?? FieldValue.serverTimestamp(),
    };
    if (unit.id.isEmpty) {
      final ref = await _db.collection('units').add(data);
      return ref.id;
    }
    await _db.collection('units').doc(unit.id).set(data, SetOptions(merge: true));
    return unit.id;
  }

  Future<void> deleteUnit(String unitId) {
    return _db.collection('units').doc(unitId).delete();
  }

  // --- Tasks ---
  Stream<List<WorkTask>> watchAllTasks() {
    return _db.collection('tasks').snapshots().map((snap) {
      final tasks = snap.docs
          .map((d) => WorkTask.fromMap(d.id, d.data()))
          .where((t) => !t.archived)
          .toList();
      tasks.sort((a, b) {
        final aDate = a.dueDate ?? DateTime(2100);
        final bDate = b.dueDate ?? DateTime(2100);
        return aDate.compareTo(bDate);
      });
      return tasks;
    });
  }

  Stream<List<WorkTask>> watchWorkerTasks(String workerId) {
    return _db
        .collection('tasks')
        .where('assignedWorkerIds', arrayContains: workerId)
        .snapshots()
        .map((snap) {
      final tasks = snap.docs
          .map((d) => WorkTask.fromMap(d.id, d.data()))
          .where((t) => !t.archived)
          .toList();
      tasks.sort((a, b) {
        final aDate = a.dueDate ?? DateTime(2100);
        final bDate = b.dueDate ?? DateTime(2100);
        return aDate.compareTo(bDate);
      });
      return tasks;
    });
  }

  Stream<List<WorkTask>> watchArchivedTasks() {
    return _db
        .collection('tasks')
        .where('archived', isEqualTo: true)
        .orderBy('completedAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => WorkTask.fromMap(d.id, d.data())).toList());
  }

  Future<String> saveTask(WorkTask task) async {
    final data = {
      ...task.toMap(),
      'assignedWorkerIds': task.assignedWorkerIds,
      'archived': task.archived,
      'createdAt': task.createdAt ?? FieldValue.serverTimestamp(),
    };
    if (task.id.isEmpty) {
      final ref = await _db.collection('tasks').add(data);
      return ref.id;
    }
    await _db.collection('tasks').doc(task.id).set(data, SetOptions(merge: true));
    return task.id;
  }

  Future<void> saveTasksBatch(List<WorkTask> tasks) async {
    final batch = _db.batch();
    for (final task in tasks) {
      final ref = task.id.isEmpty
          ? _db.collection('tasks').doc()
          : _db.collection('tasks').doc(task.id);
      batch.set(ref, {
        ...task.toMap(),
        'createdAt': task.createdAt ?? FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  Future<void> deleteTask(String taskId) {
    return _db.collection('tasks').doc(taskId).delete();
  }

  Future<void> approveTask(String taskId) async {
    final doc = await _db.collection('tasks').doc(taskId).get();
    if (!doc.exists) return;
    final task = WorkTask.fromMap(doc.id, doc.data()!);
    await _db.collection('tasks').doc(taskId).update({
      'approvalStatus': ApprovalStatus.approved.name,
      'status': TaskStatus.approved.name,
      'archived': true,
    });
    await _updateProjectProgress(task.projectId);
  }

  Future<void> _updateProjectProgress(String projectId) async {
    final snap = await _db
        .collection('tasks')
        .where('projectId', isEqualTo: projectId)
        .get();
    if (snap.docs.isEmpty) return;
    final total = snap.docs.length;
    final done = snap.docs.where((d) {
      final s = d.data()['status'] as String?;
      return s == TaskStatus.approved.name || d.data()['archived'] == true;
    }).length;
    await _db.collection('projects').doc(projectId).update({
      'progress': (done / total) * 100,
    });
  }

  Future<void> syncOverdueTasks() async {
    final snap = await _db
        .collection('tasks')
        .where('archived', isEqualTo: false)
        .get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      final task = WorkTask.fromMap(doc.id, doc.data());
      if (task.isOverdue &&
          task.status != TaskStatus.overdue &&
          task.status != TaskStatus.completed) {
        batch.update(doc.reference, {'status': TaskStatus.overdue.name});
        for (final workerId in task.assignedWorkerIds) {
          await sendNotification(AppNotification(
            id: '',
            userId: workerId,
            title: 'Geciken görev',
            body: task.title,
            type: 'task_overdue',
            taskId: task.id,
          ));
        }
      }
    }
    await batch.commit();
  }

  Future<Map<String, dynamic>> getWorkerAnalytics() async {
    final snap = await _db.collection('tasks').get();
    final tasks = snap.docs.map((d) => WorkTask.fromMap(d.id, d.data())).toList();
    final workerCompleted = <String, int>{};
    final workerOverdue = <String, int>{};
    final workerHours = <String, List<double>>{};

    for (final t in tasks) {
      for (final wId in t.assignedWorkerIds) {
        if (t.status == TaskStatus.approved || t.status == TaskStatus.completed) {
          workerCompleted[wId] = (workerCompleted[wId] ?? 0) + 1;
          if (t.durationHours != null) {
            workerHours.putIfAbsent(wId, () => []).add(t.durationHours!);
          }
        }
        if (t.isOverdue) {
          workerOverdue[wId] = (workerOverdue[wId] ?? 0) + 1;
        }
      }
    }

    String? fastestId;
    double? fastestAvg;
    workerHours.forEach((id, hours) {
      final avg = hours.reduce((a, b) => a + b) / hours.length;
      if (fastestAvg == null || avg < fastestAvg!) {
        fastestAvg = avg;
        fastestId = id;
      }
    });

    String? mostDelayedId;
    int maxOverdue = 0;
    workerOverdue.forEach((id, overdueCount) {
      if (overdueCount > maxOverdue) {
        maxOverdue = overdueCount;
        mostDelayedId = id;
      }
    });

    return {
      'fastestWorkerId': fastestId,
      'mostDelayedWorkerId': mostDelayedId,
      'workerCompleted': workerCompleted,
    };
  }

  Future<void> rejectTask(String taskId, {String? note}) {
    return _db.collection('tasks').doc(taskId).update({
      'approvalStatus': ApprovalStatus.rejected.name,
      'status': TaskStatus.rejected.name,
      'workerNote': note,
    });
  }

  // --- Notifications ---
  Future<void> sendNotification(AppNotification notification) {
    return _db.collection('notifications').add({
      ...notification.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<AppNotification>> watchUserNotifications(String userId) {
    return _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => AppNotification.fromMap(d.id, d.data()))
            .toList());
  }

  // --- Search ---
  Future<List<Project>> searchProjects(String query) async {
    final snap = await _db.collection('projects').get();
    final q = query.toLowerCase();
    return snap.docs
        .map((d) => Project.fromMap(d.id, d.data()))
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.city.toLowerCase().contains(q) ||
            p.buildingNumber.toLowerCase().contains(q))
        .toList();
  }

  Future<List<AppUser>> searchWorkers(String query) async {
    final snap = await _db
        .collection('users')
        .where('role', isEqualTo: UserRole.worker.name)
        .get();
    final q = query.toLowerCase();
    return snap.docs
        .map((d) => AppUser.fromMap(d.id, d.data()))
        .where((u) =>
            u.name.toLowerCase().contains(q) ||
            u.email.toLowerCase().contains(q))
        .toList();
  }

  Future<List<WorkTask>> searchTasks(String query) async {
    final snap = await _db.collection('tasks').get();
    final q = query.toLowerCase();
    return snap.docs
        .map((d) => WorkTask.fromMap(d.id, d.data()))
        .where((t) => t.title.toLowerCase().contains(q))
        .toList();
  }

  // --- Dashboard stats ---
  Future<Map<String, int>> getDashboardStats() async {
    final snap = await _db
        .collection('tasks')
        .where('archived', isEqualTo: false)
        .get();
    final tasks = snap.docs.map((d) => WorkTask.fromMap(d.id, d.data())).toList();
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = todayStart.subtract(Duration(days: now.weekday - 1));

    int daily = 0, weekly = 0, completed = 0, pending = 0, overdue = 0;
    for (final t in tasks) {
      if (t.dueDate != null && !t.dueDate!.isBefore(todayStart) &&
          t.dueDate!.isBefore(todayStart.add(const Duration(days: 1)))) {
        daily++;
      }
      if (t.dueDate != null && !t.dueDate!.isBefore(weekStart)) weekly++;
      if (t.status == TaskStatus.completed || t.status == TaskStatus.approved) {
        completed++;
      } else if (t.isOverdue) {
        overdue++;
      } else {
        pending++;
      }
    }
    return {
      'daily': daily,
      'weekly': weekly,
      'completed': completed,
      'pending': pending,
      'overdue': overdue,
      'total': tasks.length,
    };
  }
}
