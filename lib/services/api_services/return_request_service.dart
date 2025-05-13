import '../../models/return_request.dart';
import '../../models/paginate_response.dart';
import '../dio_service.dart';

class ReturnRequestService {
  final DioService _dioService;
  static const String _endpoint = '/return-requests';

  ReturnRequestService(this._dioService);

  Future<List<ReturnRequest>> getAll({Map<String, dynamic>? queryParameters}) async {
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
        (json) => ReturnRequest.fromJson(json as Map<String, dynamic>),
      );

      return paginatedResponse.data;
    } catch (e) {
      // Error in ReturnRequestService.getAll
      return [];
    }
  }

  Future<ReturnRequest> getById(int id) async {
    final response = await _dioService.get<Map<String, dynamic>>(
      endpoint: '$_endpoint/$id',
    );
    return ReturnRequest.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<ReturnRequest> create(Map<String, dynamic> data) async {
    final response = await _dioService.post<Map<String, dynamic>>(
      endpoint: _endpoint,
      data: data,
    );
    return ReturnRequest.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<ReturnRequest> update(int id, Map<String, dynamic> data) async {
    final response = await _dioService.put<Map<String, dynamic>>(
      endpoint: '$_endpoint/$id',
      data: data,
    );
    return ReturnRequest.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    await _dioService.delete<Map<String, dynamic>>(
      endpoint: '$_endpoint/$id',
    );
  }

  Future<ReturnRequest> approve(int id) async {
    final response = await _dioService.patch<Map<String, dynamic>>(
      endpoint: '$_endpoint/$id/approve',
    );
    return ReturnRequest.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<ReturnRequest> reject(int id) async {
    final response = await _dioService.patch<Map<String, dynamic>>(
      endpoint: '$_endpoint/$id/reject',
    );
    return ReturnRequest.fromJson(response['data'] as Map<String, dynamic>);
  }
} 
