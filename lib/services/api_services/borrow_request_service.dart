import '../../models/borrow_request.dart';
import '../../models/paginate_response.dart';
import '../dio_service.dart';

class BorrowRequestService {
  final DioService _dioService;
  static const String _endpoint = '/borrow-requests';

  BorrowRequestService(this._dioService);

  Future<List<BorrowRequest>> getAll({Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dioService.get<Map<String, dynamic>>(
        endpoint: _endpoint,
        queryParameters: queryParameters,
      );

      // print('DEBUG - GetAll Raw Response: $response'); // Debug log

      if (response == null) {
        // print('DEBUG - GetAll: Response is null'); // Debug log
        return [];
      }

      // Handle different response structures
      Map<String, dynamic>? content = response;
      if (response['content'] != null) {
        content = response['content'] as Map<String, dynamic>;
      }

      final paginatedResponse = PaginateResponse.fromJson(
        content,
        (json) => BorrowRequest.fromJson(json as Map<String, dynamic>),
      );

      return paginatedResponse.data;
    } catch (e, stackTrace) {
      // print('DEBUG - GetAll Error: $e'); // Debug log
      // print('DEBUG - GetAll Stack Trace: $stackTrace'); // Debug log
      return [];
    }
  }

  Future<BorrowRequest> getById(int id) async {
    try {
      final response = await _dioService.get<Map<String, dynamic>>(
        endpoint: '$_endpoint/$id',
      );
      
      // print('DEBUG - GetById Raw Response: $response'); // Debug log
      
      // Try different response structures
      Map<String, dynamic>? borrowData;
      
      if (response['content']?['data'] is Map<String, dynamic>) {
        borrowData = response['content']['data'] as Map<String, dynamic>;
      } else if (response['data'] is Map<String, dynamic>) {
        borrowData = response['data'] as Map<String, dynamic>;
      } else if (response['content'] is Map<String, dynamic>) {
        borrowData = response['content'] as Map<String, dynamic>;
      } else if (response is Map<String, dynamic> && 
                 response.containsKey('id') && 
                 response.containsKey('status')) {
        borrowData = response;
      }
      
      if (borrowData == null) {
        // print('DEBUG - GetById: No valid data found in response structure: $response'); // Debug log
        throw Exception('Could not find borrow request data in response');
      }
      
      // print('DEBUG - GetById Data: $borrowData'); // Debug log
      return BorrowRequest.fromJson(borrowData);
      
    } catch (e, stackTrace) {
      // print('DEBUG - GetById Error: $e'); // Debug log
      // print('DEBUG - GetById Stack Trace: $stackTrace'); // Debug log
      if (e is Exception) {
        rethrow;
      }
      throw Exception(e.toString());
    }
  }

  Future<BorrowRequest> create(Map<String, dynamic> data) async {
    try {
      print("BorrowRequestService.create - Data being sent: $data");
      final response = await _dioService.post<Map<String, dynamic>>(
        endpoint: _endpoint,
        data: data,
      );
      
      print("BorrowRequestService.create - Raw Response: $response");
      print("BorrowRequestService.create - Response type: ${response.runtimeType}");
      print("BorrowRequestService.create - Response keys: ${response.keys}");

      // Check for validation errors in the response
      if (response['error'] != null) {
        print("BorrowRequestService.create - Error found in response: ${response['error']}");
        final errors = response['error'];
        print("BorrowRequestService.create - Error type: ${errors.runtimeType}");
        String errorMessage = errors?.toString() ?? 'Unknown error';
        print("BorrowRequestService.create - Error message: $errorMessage");
        throw Exception(errorMessage);
      }
      
      // If the response indicates success but has no data, return a minimal BorrowRequest
      if (response['success'] == true || response['status'] == 'success') {
        print("BorrowRequestService.create - Success response detected");
        // Try to get data from different response structures
        Map<String, dynamic>? responseData;
        
        print("BorrowRequestService.create - Response content: ${response['content']}");
        print("BorrowRequestService.create - Response content type: ${response['content']?.runtimeType}");
        
        if (response['content'] != null) {
          var content = response['content'];
          print("BorrowRequestService.create - Content type: ${content.runtimeType}");
          
          if (content is Map<String, dynamic>) {
            responseData = content;
          } else if (content is List && content.isNotEmpty && content[0] is Map<String, dynamic>) {
            // If content is a list, take the first item
            responseData = content[0] as Map<String, dynamic>;
          } else {
            // If content is not a map or a list of maps, try to use the entire response
            print("BorrowRequestService.create - Content is not a map, using response as fallback");
            responseData = response;
          }
        } else {
          // If no content field, try to use the entire response
          print("BorrowRequestService.create - No content field, using response as fallback");
          responseData = response;
        }
        
        if (responseData == null || responseData.isEmpty) {
          print("BorrowRequestService.create - No valid responseData, creating minimal BorrowRequest");
          // Create a minimal response with current timestamp
          final now = DateTime.now();
          return BorrowRequest(
            id: response['id'] as int? ?? 0,
            createdAt: now,
            updatedAt: now,
            returnDateExpected: data['return_date_expected'] as String? ?? '',
            status: 'pending',
            userId: 0,
            borrowLocation: data['borrow_location'] as String?,
          );
        }
        
        print("BorrowRequestService.create - Creating BorrowRequest from responseData: $responseData");
        return BorrowRequest.fromJson(responseData);
      }
      
      print("BorrowRequestService.create - Response doesn't indicate success, throwing exception");
      throw Exception(response['message'] ?? 'Failed to create borrow request');
    } catch (e) {
      print("BorrowRequestService.create - Exception caught: $e");
      print("BorrowRequestService.create - Exception type: ${e.runtimeType}");
      if (e is Exception) {
        print("BorrowRequestService.create - Rethrowing Exception");
        rethrow;
      }
      print("BorrowRequestService.create - Creating new Exception with toString()");
      final errorMessage = e?.toString() ?? 'Unknown error occurred';
      print("BorrowRequestService.create - Error message created: $errorMessage");
      throw Exception(errorMessage);
    }
  }

  Future<BorrowRequest> update(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dioService.put<Map<String, dynamic>>(
        endpoint: '$_endpoint/$id',
        data: data,
      );
      
      // print('DEBUG - Update Raw Response: $response'); // Debug log
      
      // Try different response structures
      Map<String, dynamic>? responseData;
      
      if (response['content']?['data'] is Map<String, dynamic>) {
        responseData = response['content']['data'] as Map<String, dynamic>;
      } else if (response['data'] is Map<String, dynamic>) {
        responseData = response['data'] as Map<String, dynamic>;
      } else if (response['content'] is Map<String, dynamic>) {
        responseData = response['content'] as Map<String, dynamic>;
      }
      
      if (responseData == null) {
        // print('DEBUG - Update: Invalid response format: $response'); // Debug log
        throw Exception('Invalid response format');
      }
      
      return BorrowRequest.fromJson(responseData);
    } catch (e, stackTrace) {
      // print('DEBUG - Update Error: $e'); // Debug log
      // print('DEBUG - Update Stack Trace: $stackTrace'); // Debug log
      if (e is Exception) {
        rethrow;
      }
      throw Exception(e?.toString() ?? 'Unknown error occurred');
    }
  }

  Future<void> delete(int id) async {
    try {
      await _dioService.delete<Map<String, dynamic>>(
        endpoint: '$_endpoint/$id',
      );
    } catch (e, stackTrace) {
      // print('DEBUG - Delete Error: $e'); // Debug log
      // print('DEBUG - Delete Stack Trace: $stackTrace'); // Debug log
      throw Exception(e?.toString() ?? 'Unknown error occurred');
    }
  }

  Future<BorrowRequest> approve(int id) async {
    try {
      final response = await _dioService.patch<Map<String, dynamic>>(
        endpoint: '$_endpoint/$id/approve',
      );
      
      // print('DEBUG - Approve Raw Response: $response'); // Debug log
      
      // Try different response structures
      Map<String, dynamic>? responseData;
      
      if (response['content']?['data'] is Map<String, dynamic>) {
        responseData = response['content']['data'] as Map<String, dynamic>;
      } else if (response['data'] is Map<String, dynamic>) {
        responseData = response['data'] as Map<String, dynamic>;
      } else if (response['content'] is Map<String, dynamic>) {
        responseData = response['content'] as Map<String, dynamic>;
      }
      
      if (responseData == null) {
        // print('DEBUG - Approve: Invalid response format: $response'); // Debug log
        throw Exception('Invalid response format');
      }
      
      return BorrowRequest.fromJson(responseData);
    } catch (e, stackTrace) {
      // print('DEBUG - Approve Error: $e'); // Debug log
      // print('DEBUG - Approve Stack Trace: $stackTrace'); // Debug log
      if (e is Exception) {
        rethrow;
      }
      throw Exception(e?.toString() ?? 'Unknown error occurred');
    }
  }

  Future<BorrowRequest> reject(int id) async {
    try {
      final response = await _dioService.patch<Map<String, dynamic>>(
        endpoint: '$_endpoint/$id/reject',
      );
      
      // print('DEBUG - Reject Raw Response: $response'); // Debug log
      
      // Try different response structures
      Map<String, dynamic>? responseData;
      
      if (response['content']?['data'] is Map<String, dynamic>) {
        responseData = response['content']['data'] as Map<String, dynamic>;
      } else if (response['data'] is Map<String, dynamic>) {
        responseData = response['data'] as Map<String, dynamic>;
      } else if (response['content'] is Map<String, dynamic>) {
        responseData = response['content'] as Map<String, dynamic>;
      }
      
      if (responseData == null) {
        // print('DEBUG - Reject: Invalid response format: $response'); // Debug log
        throw Exception('Invalid response format');
      }
      
      return BorrowRequest.fromJson(responseData);
    } catch (e, stackTrace) {
      // print('DEBUG - Reject Error: $e'); // Debug log
      // print('DEBUG - Reject Stack Trace: $stackTrace'); // Debug log
      if (e is Exception) {
        rethrow;
      }
      throw Exception(e?.toString() ?? 'Unknown error occurred');
    }
  }
}

