import '../dio_service.dart';

class AuthService {
  final DioService _dioService;
  static const String _endpoint = '/auth';

  AuthService(this._dioService);

  
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _dioService.post<Map<String, dynamic>>(
        endpoint: '$_endpoint/login',
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response['content']['token'] != null) {
        _dioService.setToken(response['content']['token']);
      }

      
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
        'data': null
      };
    }
  }

  Future<void> logout() async {
    try {
      await _dioService.post<Map<String, dynamic>>(
        endpoint: '$_endpoint/logout',
      );
    } catch (e) {
      print('Error during logout: $e');
    }
    
    
    _dioService.setToken('');
  }
} 
