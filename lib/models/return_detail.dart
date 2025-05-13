import 'mandatory.dart';
import 'item_unit.dart';

class ReturnDetail extends Mandatory {
  final int itemUnitId;
  final int returnRequestId;
  final ItemUnit? itemUnit;

  ReturnDetail({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
    required this.itemUnitId,
    required this.returnRequestId,
    this.itemUnit,
  });

  factory ReturnDetail.fromJson(Map<String, dynamic> json) {
    return ReturnDetail(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at'] as String) : null,
      itemUnitId: json['item_unit_id'] as int,
      returnRequestId: json['return_request_id'] as int,
      itemUnit: json['item_unit'] != null ? ItemUnit.fromJson(json['item_unit'] as Map<String, dynamic>) : null,
    );
  }
}
