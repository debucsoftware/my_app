import 'package:istakibim/core/enums/app_enums.dart';

class Project {
  const Project({
    required this.id,
    required this.name,
    required this.companyName,
    required this.address,
    required this.city,
    required this.buildingNumber,
    this.startDate,
    this.endDate,
    this.status = ProjectStatus.active,
    this.progress = 0,
    this.createdAt,
  });

  final String id;
  final String name;
  final String companyName;
  final String address;
  final String city;
  final String buildingNumber;
  final DateTime? startDate;
  final DateTime? endDate;
  final ProjectStatus status;
  final double progress;
  final DateTime? createdAt;

  factory Project.fromMap(String id, Map<String, dynamic> data) {
    return Project(
      id: id,
      name: data['name'] as String? ?? '',
      companyName: data['companyName'] as String? ?? '',
      address: data['address'] as String? ?? '',
      city: data['city'] as String? ?? '',
      buildingNumber: data['buildingNumber'] as String? ?? '',
      startDate: (data['startDate'] as dynamic)?.toDate(),
      endDate: (data['endDate'] as dynamic)?.toDate(),
      status: ProjectStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ProjectStatus.active,
      ),
      progress: (data['progress'] as num?)?.toDouble() ?? 0,
      createdAt: (data['createdAt'] as dynamic)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'companyName': companyName,
        'address': address,
        'city': city,
        'buildingNumber': buildingNumber,
        'startDate': startDate,
        'endDate': endDate,
        'status': status.name,
        'progress': progress,
        'createdAt': createdAt,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Project && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
