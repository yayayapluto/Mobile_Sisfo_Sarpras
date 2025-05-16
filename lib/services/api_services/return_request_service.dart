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
        (json) => ReturnRequest.fromJson(json as Map<String, dynamic>),
      );

      return paginatedResponse.data;
    } catch (e, stackTrace) {
      // print('DEBUG - GetAll Error: $e'); // Debug log
      // print('DEBUG - GetAll Stack Trace: $stackTrace'); // Debug log
      return [];
    }
  }

  Future<ReturnRequest> getById(int id) async {
    try {
      final response = await _dioService.get<Map<String, dynamic>>(
        endpoint: '$_endpoint/$id',
      );
      
      // print('DEBUG - GetById Raw Response: $response'); // Debug log
      
      // Try different response structures
      Map<String, dynamic>? returnData;
      
      if (response['content']?['data'] is Map<String, dynamic>) {
        returnData = response['content']['data'] as Map<String, dynamic>;
      } else if (response['data'] is Map<String, dynamic>) {
        returnData = response['data'] as Map<String, dynamic>;
      } else if (response['content'] is Map<String, dynamic>) {
        returnData = response['content'] as Map<String, dynamic>;
      } else if (response is Map<String, dynamic> && 
                 response.containsKey('id') && 
                 response.containsKey('status')) {
        returnData = response;
      }
      
      if (returnData == null) {
        // print('DEBUG - GetById: No valid data found in response structure: $response'); // Debug log
        throw Exception('Could not find return request data in response');
      }
      
      // print('DEBUG - GetById Data: $returnData'); // Debug log
      return ReturnRequest.fromJson(returnData);
      
    } catch (e, stackTrace) {
      // print('DEBUG - GetById Error: $e'); // Debug log
      // print('DEBUG - GetById Stack Trace: $stackTrace'); // Debug log
      if (e is Exception) {
        rethrow;
      }
      throw Exception(e.toString());
    }
  }

  Future<ReturnRequest> create(Map<String, dynamic> data) async {
    try {
      print("ReturnRequestService.create - Data being sent: $data");
      
      final response = await _dioService.post<Map<String, dynamic>>(
        endpoint: _endpoint,
        data: data,
      );
      
      print("ReturnRequestService.create - Raw Response: $response");
      print("ReturnRequestService.create - Response type: ${response.runtimeType}");
      print("ReturnRequestService.create - Response keys: ${response.keys}");
      
      // Check for validation errors in the response
      if (response['errors'] != null) {
        print("ReturnRequestService.create - Validation errors found: ${response['errors']}");
        final errors = response['errors'];
        print("ReturnRequestService.create - Errors type: ${errors.runtimeType}");
        String errorMessage = errors?.toString() ?? 'Unknown validation error';
        print("ReturnRequestService.create - Error message created: $errorMessage");
        throw Exception(errorMessage);
      }
      
      // If the response indicates success but has no data, return a minimal ReturnRequest
      if (response['success'] == true || response['status'] == 'success') {
        print("ReturnRequestService.create - Success response detected");
        // Try to get data from different response structures
        Map<String, dynamic>? responseData;
        
        print("ReturnRequestService.create - Examining response structure options");
        
        if (response['content'] != null) {
          print("ReturnRequestService.create - Content field exists: ${response['content']}");
          print("ReturnRequestService.create - Content type: ${response['content'].runtimeType}");
          
          var content = response['content'];
          if (content is Map<String, dynamic>) {
            print("ReturnRequestService.create - Content is a Map");
            if (content.containsKey('data')) {
              print("ReturnRequestService.create - Content has data key");
              responseData = content['data'] as Map<String, dynamic>?;
            } else {
              print("ReturnRequestService.create - Using content directly");
              responseData = content;
            }
          } else if (content is List && content.isNotEmpty && content[0] is Map<String, dynamic>) {
            print("ReturnRequestService.create - Content is a List, taking first item");
            responseData = content[0] as Map<String, dynamic>;
          }
        }
        
        if (responseData == null && response['data'] is Map<String, dynamic>) {
          print("ReturnRequestService.create - Using data field");
          responseData = response['data'] as Map<String, dynamic>;
        }
        
        if (responseData == null && response.containsKey('id') && response.containsKey('status')) {
          print("ReturnRequestService.create - Using response itself as data");
          responseData = response;
        }
        
        if (responseData == null || responseData.isEmpty) {
          print("ReturnRequestService.create - No valid responseData, creating minimal ReturnRequest");
          // Create a minimal response with current timestamp
          final now = DateTime.now();
          return ReturnRequest(
            id: response['id'] as int? ?? 0,
            createdAt: now,
            updatedAt: now,
            status: 'pending',
            borrowRequestId: data['borrow_request_id'] as int? ?? 0,
          );
        }
        
        print("ReturnRequestService.create - Creating ReturnRequest from responseData: $responseData");
        return ReturnRequest.fromJson(responseData);
      }
      
      print("ReturnRequestService.create - Response doesn't indicate success, throwing exception");
      throw Exception(response['message'] ?? 'Failed to create return request');
    } catch (e, stackTrace) {
      print("ReturnRequestService.create - Exception caught: $e");
      print("ReturnRequestService.create - Exception type: ${e.runtimeType}");
      print("ReturnRequestService.create - Stack trace: $stackTrace");
      
      if (e is Exception) {
        print("ReturnRequestService.create - Rethrowing Exception");
        rethrow;
      }
      print("ReturnRequestService.create - Creating new Exception with toString()");
      final errorMessage = e?.toString() ?? 'Unknown error occurred';
      print("ReturnRequestService.create - Error message created: $errorMessage");
      throw Exception(errorMessage);
    }
  }

  Future<ReturnRequest> update(int id, Map<String, dynamic> data) async {
    try {
      print("ReturnRequestService.update - Data being sent: $data");
      final response = await _dioService.put<Map<String, dynamic>>(
        endpoint: '$_endpoint/$id',
        data: data,
      );
      
      print("ReturnRequestService.update - Raw Response: $response");
      
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
        print("ReturnRequestService.update - Invalid response format: $response");
        throw Exception('Invalid response format');
      }
      
      return ReturnRequest.fromJson(responseData);
    } catch (e, stackTrace) {
      print("ReturnRequestService.update - Exception caught: $e");
      print("ReturnRequestService.update - Stack trace: $stackTrace");
      if (e is Exception) {
        rethrow;
      }
      throw Exception(e?.toString() ?? 'Unknown error occurred');
    }
  }

  Future<void> delete(int id) async {
    try {
      print("ReturnRequestService.delete - Deleting ID: $id");
      await _dioService.delete<Map<String, dynamic>>(
        endpoint: '$_endpoint/$id',
      );
    } catch (e, stackTrace) {
      print("ReturnRequestService.delete - Exception caught: $e");
      print("ReturnRequestService.delete - Stack trace: $stackTrace");
      throw Exception(e?.toString() ?? 'Unknown error occurred');
    }
  }

  Future<ReturnRequest> approve(int id) async {
    try {
      print("ReturnRequestService.approve - Approving ID: $id");
      final response = await _dioService.patch<Map<String, dynamic>>(
        endpoint: '$_endpoint/$id/approve',
      );
      
      print("ReturnRequestService.approve - Raw Response: $response");
      
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
        print("ReturnRequestService.approve - Invalid response format: $response");
        throw Exception('Invalid response format');
      }
      
      return ReturnRequest.fromJson(responseData);
    } catch (e, stackTrace) {
      print("ReturnRequestService.approve - Exception caught: $e");
      print("ReturnRequestService.approve - Stack trace: $stackTrace");
      if (e is Exception) {
        rethrow;
      }
      throw Exception(e?.toString() ?? 'Unknown error occurred');
    }
  }

  Future<ReturnRequest> reject(int id) async {
    try {
      print("ReturnRequestService.reject - Rejecting ID: $id");
      final response = await _dioService.patch<Map<String, dynamic>>(
        endpoint: '$_endpoint/$id/reject',
      );
      
      print("ReturnRequestService.reject - Raw Response: $response");
      
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
        print("ReturnRequestService.reject - Invalid response format: $response");
        throw Exception('Invalid response format');
      }
      
      return ReturnRequest.fromJson(responseData);
    } catch (e, stackTrace) {
      print("ReturnRequestService.reject - Exception caught: $e");
      print("ReturnRequestService.reject - Stack trace: $stackTrace");
      if (e is Exception) {
        rethrow;
      }
      throw Exception(e?.toString() ?? 'Unknown error occurred');
    }
  }
} 
