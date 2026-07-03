class Unit {
  const Unit({
    required this.id,
    required this.projectId,
    required this.houseNumber,
    required this.apartmentNumber,
    this.floor,
    this.block,
    this.createdAt,
  });

  final String id;
  final String projectId;
  final String houseNumber;
  final String apartmentNumber;
  final String? floor;
  final String? block;
  final DateTime? createdAt;

  String get displayLabel => '$houseNumber / $apartmentNumber';

  factory Unit.fromMap(String id, Map<String, dynamic> data) {
    return Unit(
      id: id,
      projectId: data['projectId'] as String? ?? '',
      houseNumber: data['houseNumber'] as String? ?? '',
      apartmentNumber: data['apartmentNumber'] as String? ?? '',
      floor: data['floor'] as String?,
      block: data['block'] as String?,
      createdAt: (data['createdAt'] as dynamic)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'projectId': projectId,
        'houseNumber': houseNumber,
        'apartmentNumber': apartmentNumber,
        'floor': floor,
        'block': block,
        'createdAt': createdAt,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Unit && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
