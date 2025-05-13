import '../../models/borrow_request.dart';
import '../../models/paginate_response.dart';
import '../dio_service.dart';

class BorrowRequestService {
  final DioService _dioService;
  static const String _endpoint = '/borrow-requests';

  BorrowRequestService(this._dioService);

  Future<List<BorrowRequest>> getAll(
      {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dioService.get<Map<String, dynamic>>(
        endpoint: _endpoint,
        queryParameters: queryParameters,
      );

      if (response == null) {
        return [];
      }

      final paginatedResponse = PaginateResponse.fromJson(
        response["content"],
        (json) => BorrowRequest.fromJson(json as Map<String, dynamic>),
      );

      return paginatedResponse.data;
    } catch (e) {
      print('Error in BorrowRequestService.getAll: $e');
      return [];
    }
  }

  Future<BorrowRequest> getById(int id) async {
    final response = await _dioService.get<Map<String, dynamic>>(
      endpoint: '$_endpoint/$id',
    );
    return BorrowRequest.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<BorrowRequest> create(Map<String, dynamic> data) async {
    final response = await _dioService.post<Map<String, dynamic>>(
      endpoint: _endpoint,
      data: data,
    );
    return BorrowRequest.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<BorrowRequest> update(int id, Map<String, dynamic> data) async {
    final response = await _dioService.put<Map<String, dynamic>>(
      endpoint: '$_endpoint/$id',
      data: data,
    );
    return BorrowRequest.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    await _dioService.delete<Map<String, dynamic>>(
      endpoint: '$_endpoint/$id',
    );
  }

  Future<BorrowRequest> approve(int id) async {
    final response = await _dioService.patch<Map<String, dynamic>>(
      endpoint: '$_endpoint/$id/approve',
    );
    return BorrowRequest.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<BorrowRequest> reject(int id) async {
    final response = await _dioService.patch<Map<String, dynamic>>(
      endpoint: '$_endpoint/$id/reject',
    );
    return BorrowRequest.fromJson(response['data'] as Map<String, dynamic>);
  }
}
