import 'mandatory.dart';
import 'user.dart';
import 'return_detail.dart';
import 'borrow_request.dart';

class ReturnRequest extends Mandatory {
  final String status; 
  final String? notes;
  final int borrowRequestId;
  final int? handledBy;
  final BorrowRequest? borrowRequest;
  final List<ReturnDetail>? returnDetails;
  final User? handler;

  ReturnRequest({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
    required this.status,
    this.notes,
    required this.borrowRequestId,
    this.handledBy,
    this.borrowRequest,
    this.returnDetails,
    this.handler,
  });

  factory ReturnRequest.fromJson(Map<String, dynamic> json) {
    return ReturnRequest(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at'] as String) : null,
      status: json['status'] as String,
      notes: json['notes'] as String?,
      borrowRequestId: json['borrow_request_id'] as int,
      handledBy: json['handled_by'] as int?,
      borrowRequest: json['borrow_request'] != null
          ? BorrowRequest.fromJson(json['borrow_request'] as Map<String, dynamic>)
          : null,
      returnDetails: json['return_details'] != null
          ? (json['return_details'] as List<dynamic>)
              .map((e) => ReturnDetail.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      handler: json['handler'] != null ? User.fromJson(json['handler'] as Map<String, dynamic>) : null,
    );
  }
}
