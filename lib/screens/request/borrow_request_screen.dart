import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/item_unit.dart';
import '../../services/api_services/item_unit_service.dart';
import '../../services/api_services/borrow_request_service.dart';
import '../../services/dio_service.dart';
import '../../providers/auth_provider.dart';

class BorrowRequestScreen extends StatefulWidget {
  const BorrowRequestScreen({Key? key}) : super(key: key);

  @override
  State<BorrowRequestScreen> createState() => _BorrowRequestScreenState();
}

class _BorrowRequestScreenState extends State<BorrowRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _borrowLocationController = TextEditingController();
  final TextEditingController _returnDateController = TextEditingController();
  
  late ItemUnitService _itemUnitService;
  late BorrowRequestService _borrowRequestService;
  
  List<ItemUnit> _availableItemUnits = [];
  List<Map<String, dynamic>> _selectedItems = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    
    // Set default return date (1 week from now)
    final DateTime nextWeek = DateTime.now().add(const Duration(days: 7));
    _returnDateController.text = DateFormat('yyyy-MM-dd').format(nextWeek);
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get the shared DioService from the provider
    final dioService = ProviderScope.containerOf(context).read(dioServiceProvider);
    _itemUnitService = ItemUnitService(dioService);
    _borrowRequestService = BorrowRequestService(dioService);
    
    _loadItemUnits();
  }

  Future<void> _loadItemUnits() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Only load available items
      final itemUnits = await _itemUnitService.getAll(
        status: 'available'
      );
      
      setState(() {
        _availableItemUnits = itemUnits;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load items: ${e.toString()}';
        _isLoading = false;
      });
      
      // Show error in SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage!),
            action: SnackBarAction(
              label: 'Coba Lagi',
              onPressed: _loadItemUnits,
            ),
          ),
        );
      }
    }
  }

  void _addItemToSelection(ItemUnit itemUnit) {
    // Check if item already exists in selection
    final existingIndex = _selectedItems.indexWhere(
      (item) => item['sku'] == itemUnit.sku
    );

    if (existingIndex >= 0) {
      // Update quantity if already in the list
      setState(() {
        _selectedItems[existingIndex]['quantity'] += 1;
      });
    } else {
      // Add as new item if not in the list
      setState(() {
        _selectedItems.add({
          'sku': itemUnit.sku,
          'name': itemUnit.item?.name ?? 'Unknown Item',
          'quantity': 1,
          'maxQuantity': itemUnit.quantity,
        });
      });
    }
  }

  void _removeItem(int index) {
    setState(() {
      _selectedItems.removeAt(index);
    });
  }

  void _updateItemQuantity(int index, int quantity) {
    if (quantity <= 0) {
      _removeItem(index);
      return;
    }

    final maxQuantity = _selectedItems[index]['maxQuantity'] as int;
    if (quantity > maxQuantity) {
      quantity = maxQuantity;
    }

    setState(() {
      _selectedItems[index]['quantity'] = quantity;
    });
  }

  Future<void> _submitRequest() async {
    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one item'))
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      print("BorrowRequestScreen - Starting to prepare request data");
      // Prepare the data for the API request
      final requestData = {
        'return_date_expected': _returnDateController.text,
        'borrow_location': _borrowLocationController.text,
        'sku_list': _selectedItems.map((item) => item['sku'].toString()).join(','),
        'quantity_list': _selectedItems.map((item) => item['quantity'].toString()).join(','),
      };
      
      print("BorrowRequestScreen - Request data prepared: $requestData");
      print("BorrowRequestScreen - Selected items: $_selectedItems");
      print("BorrowRequestScreen - About to call borrowRequestService.create()");

      final response = await _borrowRequestService.create(requestData);
      print("BorrowRequestScreen - Response received: $response");

      setState(() {
        _isSubmitting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Borrow request submitted successfully'))
        );
        Navigator.pop(context, true); // Return with refresh flag
      }
    } catch (e) {
      print("BorrowRequestScreen - Exception caught: $e");
      print("BorrowRequestScreen - Exception type: ${e.runtimeType}");
      
      if (e is Exception) {
        print("BorrowRequestScreen - Processing Exception type");
        setState(() {
          _isSubmitting = false;
          _errorMessage = e.toString();
          print("BorrowRequestScreen - Set error message: $_errorMessage");
        });
    
        if (mounted) {
          print("BorrowRequestScreen - Showing SnackBar for Exception");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Dismiss',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
        }
      } else {
        print("BorrowRequestScreen - Processing non-Exception type");
        final errorMsg = e?.toString() ?? 'Unknown error occurred';
        print("BorrowRequestScreen - Created error message: $errorMsg");
        
        setState(() {
          _isSubmitting = false;
          _errorMessage = errorMsg;
          print("BorrowRequestScreen - Set error message: $_errorMessage");
        });
        
        if (mounted) {
          print("BorrowRequestScreen - Showing SnackBar for non-Exception");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_errorMessage ?? 'Unknown error occurred'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Dismiss',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
        }
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        _returnDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Request Peminjaman',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.blue))
        : _availableItemUnits.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Tidak ada barang tersedia',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadItemUnits,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Form fields
                    TextFormField(
                      controller: _borrowLocationController,
                      decoration: InputDecoration(
                        labelText: 'Lokasi Peminjaman',
                        hintText: 'Dimana barang akan digunakan?',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blue.shade100),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blue.shade100),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.location_on_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lokasi peminjaman harus diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: _returnDateController,
                          decoration: InputDecoration(
                            labelText: 'Tanggal Pengembalian',
                            hintText: 'Kapan barang akan dikembalikan?',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.blue.shade100),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.blue.shade100),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const Icon(Icons.calendar_today),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Tanggal pengembalian harus diisi';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Barang Dipilih:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_selectedItems.isNotEmpty)
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _selectedItems.clear();
                              });
                            },
                            icon: const Icon(Icons.clear, size: 16, color: Colors.red),
                            label: const Text('Hapus Semua', style: TextStyle(color: Colors.red)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Selected items list
                    _selectedItems.isEmpty
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: const Center(
                            child: Text(
                              'Belum ada barang dipilih',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _selectedItems.length,
                          itemBuilder: (context, index) {
                            final item = _selectedItems[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.inventory_2, color: Colors.blue, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['name'],
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            'SKU: ${item['sku']}',
                                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
                                            onPressed: () => _updateItemQuantity(
                                              index, 
                                              item['quantity'] - 1
                                            ),
                                          ),
                                          Text(
                                            '${item['quantity']}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
                                            onPressed: () => _updateItemQuantity(
                                              index, 
                                              item['quantity'] + 1
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _removeItem(index),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                    
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Barang Tersedia:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.blue),
                          onPressed: _loadItemUnits,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Available items list
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _availableItemUnits.length,
                      itemBuilder: (context, index) {
                        final itemUnit = _availableItemUnits[index];
                        return Card(
                          color: Colors.white,
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 6,
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.inventory_2, color: Colors.blue, size: 20),
                            ),
                            title: Text(
                              itemUnit.item?.name ?? 'Unknown Item',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'SKU: ${itemUnit.sku} • Tersedia: ${itemUnit.quantity}',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                            trailing: ElevatedButton(
                              onPressed: () => _addItemToSelection(itemUnit),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Tambah'),
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _submitRequest,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          disabledBackgroundColor: Colors.grey.shade300,
                        ),
                        label: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ) 
                          : const Text(
                              'Kirim Request Peminjaman',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 