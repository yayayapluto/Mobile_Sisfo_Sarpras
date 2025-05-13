import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../services/dio_service.dart';
import '../../services/api_services/item_service.dart';
import '../../services/api_services/item_unit_service.dart';
import '../../models/item.dart';
import '../../models/item_unit.dart';

class ItemDetailScreen extends StatefulWidget {
  final String itemId;

  const ItemDetailScreen({
    Key? key,
    required this.itemId,
  }) : super(key: key);

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen>
    with SingleTickerProviderStateMixin {
  final ItemService _itemService = ItemService(DioService());
  final ItemUnitService _itemUnitService = ItemUnitService(DioService());

  bool _isLoading = true;
  String? _error;
  late TabController _tabController;

  Item? _item;

  List<ItemUnit> _units = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchItemDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchItemDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final item = await _itemService.getById(int.parse(widget.itemId));

      List<ItemUnit> units = [];
      try {
        units = await _itemUnitService.getByItemId(item.id);
      } catch (e) {
        print('Error fetching item units: $e');
      }

      if (mounted) {
        setState(() {
          _item = item;
          _units = units;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  int get _available =>
      _units.where((unit) => unit.status == 'available').length;
  int get _quantity => _units.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Detail Barang',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Error: $_error',
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchItemDetails,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : _item == null
                  ? const Center(child: Text('Item tidak ditemukan'))
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: Colors.blue.shade50),
                                        ),
                                        child: _buildItemImage(_item!),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _item!.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            if (_item!.category != null)
                                              Row(
                                                children: [
                                                  const Icon(Icons.category,
                                                      size: 16,
                                                      color: Colors.blue),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      _item!.category!.name,
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(Icons.info_outline,
                                                    size: 16,
                                                    color: Colors.blue),
                                                const SizedBox(width: 4),
                                                Text(
                                                  _item!.type == 'consumable'
                                                      ? 'Consumable'
                                                      : 'Non-Consumable',
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(Icons.inventory_2,
                                                    size: 16,
                                                    color: Colors.blue),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Tersedia: $_available dari $_quantity unit',
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Deskripsi',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _item!.description,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 16),
                                  if (_available > 0)
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey[300],
                                          foregroundColor: Colors.black54,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text('Request Peminjaman (Nonaktif)'),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        TabBar(
                          controller: _tabController,
                          labelColor: Colors.blue,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: Colors.blue,
                          tabs: const [
                            Tab(text: 'Daftar Unit'),
                            Tab(text: 'Riwayat Peminjaman'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildUnitsTab(),
                              _buildHistoryTab(),
                            ],
                          ),
                        ),
                      ],
                    ),
    );
  }

  IconData _getIconForItem(Item item) {
    if (item.type == 'consumable') {
      return Icons.inventory;
    } else {
      final name = item.name.toLowerCase();
      if (name.contains('laptop')) return Icons.laptop;
      if (name.contains('komputer')) return Icons.computer;
      if (name.contains('proyektor')) return Icons.videocam;
      if (name.contains('meja')) return Icons.table_bar;
      if (name.contains('kursi')) return Icons.chair;
      return Icons.devices;
    }
  }

  Widget _buildItemImage(Item item) {
    if (item.imageUrl == null || item.imageUrl.isEmpty || item.imageUrl == 'placeholder') {
      print('Using fallback icon: image URL is empty or placeholder');
      return Center(
        child: Icon(
          _getIconForItem(item),
          size: 60,
          color: Colors.grey,
        ),
      );
    }
    
    print('Attempting to load image from URL: ${item.imageUrl}');
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        item.imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            print('Image loaded successfully');
            return child;
          }
          
          print('Image loading: ${loadingProgress.expectedTotalBytes != null 
              ? '${(loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! * 100).toStringAsFixed(1)}%'
              : 'Unknown progress'}');
              
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print('Error loading image: $error');
          return Center(
            child: Icon(
              _getIconForItem(item),
              size: 60,
              color: Colors.grey,
            ),
          );
        },
      ),
    );
  }

  Widget _buildUnitsTab() {
    if (_units.isEmpty) {
      return const Center(
        child: Text('Belum ada unit untuk barang ini'),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchItemDetails,
      color: Colors.blue,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _units.length,
        itemBuilder: (context, index) {
          final unit = _units[index];
          final isAvailable = unit.status == 'available';
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 1,
            color: Colors.white,
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(
                unit.sku,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('Kondisi: ${unit.condition}'),
                  if (unit.notes != null && unit.notes!.isNotEmpty)
                    Text('Catatan: ${unit.notes}'),
                ],
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isAvailable ? Colors.green[50] : Colors.orange[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isAvailable ? 'Tersedia' : 'Dipinjam',
                  style: TextStyle(
                    color: isAvailable ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onTap: null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryTab() {
    return const Center(
      child: Text('Tidak ada riwayat peminjaman'),
    );
  }
}
