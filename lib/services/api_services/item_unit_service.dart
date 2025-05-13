import 'package:dio/dio.dart';
import '../../models/item_unit.dart';
import '../dio_service.dart';

class ItemUnitService {
  final DioService _dioService;
  static const String endpoint = '/itemUnits';

  ItemUnitService(this._dioService);

  Future<List<ItemUnit>> getAll({
    String? condition,
    String? acquisitionSource,
    String? acquisitionDate,
    String? status,
    int? quantity,
    int? itemId,
    int? warehouseId,
    bool withRelations = true,
  }) async {
    try {
      Map<String, dynamic> queryParams = {};
      
      if (condition != null && condition.isNotEmpty) {
        queryParams['condition'] = condition;
      }
      
      if (acquisitionSource != null && acquisitionSource.isNotEmpty) {
        queryParams['acquisition_source'] = acquisitionSource;
      }
      
      if (acquisitionDate != null && acquisitionDate.isNotEmpty) {
        queryParams['acquisition_date'] = acquisitionDate;
      }
      
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      
      if (quantity != null) {
        queryParams['quantity'] = quantity.toString();
      }
      
      if (itemId != null) {
        queryParams['item_id'] = itemId.toString();
      }
      
      if (warehouseId != null) {
        queryParams['warehouse_id'] = warehouseId.toString();
      }
      
      if (withRelations) {
        queryParams['with'] = 'item,warehouse';
      }

      final response = await _dioService.get<Map<String, dynamic>>(
        endpoint: endpoint,
        queryParameters: queryParams,
      );

      if (response['success'] == true && response['content'] != null) {
        final content = response['content'] as Map<String, dynamic>;
        final itemUnitsData = content['data'] as List<dynamic>;
        
        return itemUnitsData
            .map((json) => ItemUnit.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ApiException(response['message'] ?? 'Failed to fetch item units');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw ApiException('An error occurred: $e');
    }
  }

  Future<ItemUnit> getBySku(String sku) async {
    try {
      final response = await _dioService.get<Map<String, dynamic>>(
        endpoint: '$endpoint/$sku',
      );

      if (response['success'] == true && response['content'] != null) {
        return ItemUnit.fromJson(response['content'] as Map<String, dynamic>);
      } else {
        throw ApiException(response['message'] ?? 'Failed to fetch item unit');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw ApiException('An error occurred: $e');
    }
  }

  Future<List<ItemUnit>> getByItemId(int itemId) async {
    return getAll(itemId: itemId, withRelations: true);
  }

  Future<List<ItemUnit>> getByWarehouseId(int warehouseId) async {
    return getAll(warehouseId: warehouseId, withRelations: true);
  }

  Future<ItemUnit> create(Map<String, dynamic> data) async {
    final response = await _dioService.post<Map<String, dynamic>>(
      endpoint: endpoint,
      data: data,
    );
    return ItemUnit.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<ItemUnit> update(int id, Map<String, dynamic> data) async {
    final response = await _dioService.put<Map<String, dynamic>>(
      endpoint: '$endpoint/$id',
      data: data,
    );
    return ItemUnit.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    await _dioService.delete<Map<String, dynamic>>(
      endpoint: '$endpoint/$id',
    );
  }
} 
