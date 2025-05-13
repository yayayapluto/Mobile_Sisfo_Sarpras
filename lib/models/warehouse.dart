import 'mandatory.dart';
import 'item_unit.dart';

class Warehouse extends Mandatory {
  final String name;
  final String location;
  final int capacity;
  final List<ItemUnit>? itemUnits;

  Warehouse({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
    required this.name,
    required this.location,
    required this.capacity,
    this.itemUnits,
  });

  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at'] as String) : null,
      name: json['name'] as String,
      location: json['location'] as String,
      capacity: json['capacity'] as int,
      itemUnits: json['item_units'] != null
          ? (json['item_units'] as List<dynamic>)
              .map((e) => ItemUnit.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
}
