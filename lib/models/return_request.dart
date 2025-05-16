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
    print("ReturnRequest.fromJson - Input json: $json");
    try {
      return ReturnRequest(
        id: json['id'] as int? ?? 0,
        createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : DateTime.now(),
        updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : DateTime.now(),
        deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at'] as String) : null,
        status: json['status'] as String? ?? 'pending',
        notes: json['notes'] as String?,
        borrowRequestId: json['borrow_request_id'] as int? ?? 0,
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
    } catch (e) {
      print("ReturnRequest.fromJson - Error parsing JSON: $e");
      print("ReturnRequest.fromJson - JSON that caused error: $json");
      
      // Return a minimal valid object when parsing fails
      return ReturnRequest(
        id: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        status: 'pending',
        borrowRequestId: json['borrow_request_id'] as int? ?? 0,
      );
    }
  }
}
