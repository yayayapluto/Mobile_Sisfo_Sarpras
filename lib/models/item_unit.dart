import 'mandatory.dart';
import 'warehouse.dart';
import 'item.dart';
import 'borrow_detail.dart';
import 'return_detail.dart';

class ItemUnit extends Mandatory {
  final String sku;
  final String condition;
  final String? notes;
  final String acquisitionSource;
  final DateTime acquisitionDate;
  final String? acquisitionNotes;
  final String status; 
  final int quantity;
  final String qrImageUrl;
  final int itemId;
  final int warehouseId;
  final Item? item;
  final Warehouse? warehouse;
  final List<BorrowDetail>? borrowDetails;
  final List<ReturnDetail>? returnDetails;

  ItemUnit({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
    required this.sku,
    required this.condition,
    this.notes,
    required this.acquisitionSource,
    required this.acquisitionDate,
    this.acquisitionNotes,
    required this.status,
    required this.quantity,
    required this.qrImageUrl,
    required this.itemId,
    required this.warehouseId,
    this.item,
    this.warehouse,
    this.borrowDetails,
    this.returnDetails,
  });

  factory ItemUnit.fromJson(Map<String, dynamic> json) {
    return ItemUnit(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at'] as String) : null,
      sku: json['sku'] as String,
      condition: json['condition'] as String,
      notes: json['notes'] as String?,
      acquisitionSource: json['acquisition_source'] as String,
      acquisitionDate: DateTime.parse(json['acquisition_date'] as String),
      acquisitionNotes: json['acquisition_notes'] as String?,
      status: json['status'] as String,
      quantity: json['quantity'] as int,
      qrImageUrl: json['qr_image_url'] as String,
      itemId: json['item_id'] as int,
      warehouseId: json['warehouse_id'] as int,
      item: json['item'] != null ? Item.fromJson(json['item'] as Map<String, dynamic>) : null,
      warehouse: json['warehouse'] != null ? Warehouse.fromJson(json['warehouse'] as Map<String, dynamic>) : null,
      borrowDetails: json['borrow_details'] != null
          ? (json['borrow_details'] as List<dynamic>)
              .map((e) => BorrowDetail.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      returnDetails: json['return_details'] != null
          ? (json['return_details'] as List<dynamic>)
              .map((e) => ReturnDetail.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
}
