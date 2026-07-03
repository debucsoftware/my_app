import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:istakibim/core/enums/app_enums.dart';
import 'package:istakibim/l10n/app_localizations.dart';
import 'package:istakibim/models/app_notification.dart';
import 'package:istakibim/models/app_user.dart';
import 'package:istakibim/models/work_task.dart';
import 'package:istakibim/services/firestore_service.dart';
import 'package:istakibim/services/storage_service.dart';

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({super.key, required this.task, required this.user});

  final WorkTask task;
  final AppUser user;

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late List<bool> _checked;
  final _noteCtrl = TextEditingController(text: '');
  final _firestore = FirestoreService();
  final _storage = StorageService();
  final _photos = <String>[];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _checked = widget.task.checklist.map((e) => e.completed).toList();
    _noteCtrl.text = widget.task.workerNote ?? '';
    _photos.addAll(widget.task.photoUrls);
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.camera);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    final url = await _storage.uploadTaskPhoto(
      taskId: widget.task.id,
      fileName: file.name,
      bytes: bytes,
    );
    setState(() => _photos.add(url));
  }

  Future<void> _complete() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _saving = true);
    final checklist = List.generate(widget.task.checklist.length, (i) {
      return widget.task.checklist[i].copyWith(completed: _checked[i]);
    });
    final updated = widget.task.copyWith(
      checklist: checklist,
      workerNote: _noteCtrl.text,
      photoUrls: _photos,
      status: TaskStatus.completed,
      completedAt: DateTime.now(),
    );
    await _firestore.saveTask(updated);
    final adminSnap = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: UserRole.admin.name)
        .get();
    for (final doc in adminSnap.docs) {
      await _firestore.sendNotification(AppNotification(
        id: '',
        userId: doc.id,
        title: l10n.markComplete,
        body: widget.task.title,
        type: 'task_completed',
        taskId: widget.task.id,
      ));
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(widget.task.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...List.generate(widget.task.checklist.length, (i) {
            return CheckboxListTile(
              title: Text(widget.task.checklist[i].title),
              value: _checked[i],
              onChanged: (v) => setState(() => _checked[i] = v ?? false),
            );
          }),
          TextField(
            controller: _noteCtrl,
            decoration: InputDecoration(labelText: l10n.addNote),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _pickPhoto,
            icon: const Icon(Icons.camera_alt),
            label: Text(l10n.addPhoto),
          ),
          if (_photos.isNotEmpty) Text('${_photos.length} fotoğraf'),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _complete,
            child: Text(l10n.markComplete),
          ),
        ],
      ),
    );
  }
}
