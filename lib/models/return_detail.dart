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
    print("ReturnDetail.fromJson - Input json: $json");
    try {
      return ReturnDetail(
        id: json['id'] as int? ?? 0,
        createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : DateTime.now(),
        updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : DateTime.now(),
        deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at'] as String) : null,
        itemUnitId: json['item_unit_id'] as int? ?? 0,
        returnRequestId: json['return_request_id'] as int? ?? 0,
        itemUnit: json['item_unit'] != null ? ItemUnit.fromJson(json['item_unit'] as Map<String, dynamic>) : null,
      );
    } catch (e) {
      print("ReturnDetail.fromJson - Error parsing JSON: $e");
      print("ReturnDetail.fromJson - JSON that caused error: $json");
      
      // Return a minimal valid object when parsing fails
      return ReturnDetail(
        id: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        itemUnitId: 0,
        returnRequestId: 0,
      );
    }
  }
}
