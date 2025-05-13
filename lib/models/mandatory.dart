class Mandatory {
  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  Mandatory({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Mandatory.fromJson(Map<String, dynamic> json) {
    return Mandatory(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at'] as String) : null,
    );
  }
}
