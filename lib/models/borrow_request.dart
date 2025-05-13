import 'mandatory.dart';
import 'user.dart';
import 'borrow_detail.dart';
import 'return_request.dart';

class BorrowRequest extends Mandatory {
  final String returnDateExpected;
  final String status; 
  final String? notes;
  final int userId;
  final int approvedBy;
  final User? user;
  final User? handler;
  final List<BorrowDetail>? borrowDetails;
  final ReturnRequest? returnRequest;

  BorrowRequest({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
    required this.returnDateExpected,
    required this.status,
    this.notes,
    required this.userId,
    required this.approvedBy,
    this.user,
    this.handler,
    this.borrowDetails,
    this.returnRequest,
  });

  factory BorrowRequest.fromJson(Map<String, dynamic> json) {
    return BorrowRequest(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at'] as String) : null,
      returnDateExpected: json['return_date_expected'] as String,
      status: json['status'] as String,
      notes: json['notes'] as String?,
      userId: json['user_id'] as int,
      approvedBy: json['approved_by'] as int,
      user: json['user'] != null ? User.fromJson(json['user'] as Map<String, dynamic>) : null,
      handler: json['handler'] != null ? User.fromJson(json['handler'] as Map<String, dynamic>) : null,
      borrowDetails: json['borrow_details'] != null
          ? (json['borrow_details'] as List<dynamic>)
              .map((e) => BorrowDetail.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      returnRequest: json['return_request'] != null
          ? ReturnRequest.fromJson(json['return_request'] as Map<String, dynamic>)
          : null,
    );
  }
}
