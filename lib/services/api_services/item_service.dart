import 'package:dio/dio.dart';
import '../../models/item.dart';
import '../../models/paginate_response.dart';
import '../dio_service.dart';

///// //// Service for handling Item API requests
class ItemService {
  final DioService _dioService;
  static const String endpoint = '/items';

  ItemService(this._dioService);

  ///// Get all items with optional filtering and sorting
  Future<List<Item>> getAll({
    String? search,
    String? type,
    String? sortBy,
    String? sortDir,
    bool withCategory = true,
  }) async {
    try {
      Map<String, dynamic> queryParams = {};
      
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      
      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }
      
      if (sortBy != null && sortBy.isNotEmpty) {
        queryParams['sortBy'] = sortBy;
      }
      
      if (sortDir != null && sortDir.isNotEmpty) {
        queryParams['sortDir'] = sortDir;
      }
      
      if (withCategory) {
        queryParams['with'] = 'category';
      }

      final response = await _dioService.get<Map<String, dynamic>>(
        endpoint: endpoint,
        queryParameters: queryParams,
      );

      if (response['success'] == true && response['content'] != null) {
        final content = response['content'] as Map<String, dynamic>;
        final itemsData = content['data'] as List<dynamic>;
        
        return itemsData
            .map((json) => Item.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ApiException(response['message'] ?? 'Failed to fetch items');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw ApiException('An error occurred: $e');
    }
  }

  ///// Get a specific item by ID
  Future<Item> getById(int id) async {
    try {
      final response = await _dioService.get<Map<String, dynamic>>(
        endpoint: '$endpoint/$id',
      );

      if (response['success'] == true && response['content'] != null) {
        return Item.fromJson(response['content'] as Map<String, dynamic>);
      } else {
        throw ApiException(response['message'] ?? 'Failed to fetch item');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw ApiException('An error occurred: $e');
    }
  }

  ///// Get items by category ID
  Future<List<Item>> getByCategoryId(int categoryId) async {
    try {
      return await getAll(
        sortBy: 'name',
        sortDir: 'asc',
        withCategory: true,
      ).then((items) => items.where((item) => item.categoryId == categoryId).toList());
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw ApiException('An error occurred: $e');
    }
  }

  Future<Item> create(Map<String, dynamic> data) async {
    final response = await _dioService.post<Map<String, dynamic>>(
      endpoint: endpoint,
      data: data,
    );
    return Item.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<Item> update(int id, Map<String, dynamic> data) async {
    final response = await _dioService.put<Map<String, dynamic>>(
      endpoint: '$endpoint/$id',
      data: data,
    );
    return Item.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    await _dioService.delete<Map<String, dynamic>>(
      endpoint: '$endpoint/$id',
    );
  }

  ///// Search items by name
  Future<List<Item>> searchByName(String name) async {
    return getAll(search: name);
  }
  
  ///// Filter items by category
  Future<List<Item>> filterByCategory(int categoryId) async {
    return getAll(withCategory: false, sortBy: 'name', sortDir: 'asc').then((items) => items.where((item) => item.categoryId == categoryId).toList());
  }
} 
