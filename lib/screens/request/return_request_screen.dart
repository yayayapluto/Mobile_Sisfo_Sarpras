import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/borrow_request.dart';
import '../../services/api_services/borrow_request_service.dart';
import '../../services/api_services/return_request_service.dart';
import '../../services/dio_service.dart';
import '../../providers/auth_provider.dart';

class ReturnRequestScreen extends StatefulWidget {
  final int borrowRequestId;
  
  const ReturnRequestScreen({
    Key? key, 
    required this.borrowRequestId,
  }) : super(key: key);

  @override
  State<ReturnRequestScreen> createState() => _ReturnRequestScreenState();
}

class _ReturnRequestScreenState extends State<ReturnRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _returnLocationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  late BorrowRequestService _borrowRequestService;
  late ReturnRequestService _returnRequestService;
  
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  BorrowRequest? _borrowRequest;

  @override
  void initState() {
    super.initState();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get the shared DioService from the provider
    final dioService = ProviderScope.containerOf(context).read(dioServiceProvider);
    _borrowRequestService = BorrowRequestService(dioService);
    _returnRequestService = ReturnRequestService(dioService);
    
    _loadBorrowRequest();
  }

  Future<void> _loadBorrowRequest() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print("ReturnRequestScreen - Loading borrow request ID: ${widget.borrowRequestId}");
      final borrowRequest = await _borrowRequestService.getById(widget.borrowRequestId);
      
      print("ReturnRequestScreen - Borrow request loaded: $borrowRequest");
      
      setState(() {
        _borrowRequest = borrowRequest;
        _isLoading = false;
      });
    } catch (e) {
      print("ReturnRequestScreen - Error loading borrow request: $e");
      print("ReturnRequestScreen - Error type: ${e.runtimeType}");
      
      setState(() {
        _errorMessage = 'Failed to load borrow request: ${e?.toString() ?? 'Unknown error'}';
        _isLoading = false;
      });
      
      // Show error in SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage!),
            action: SnackBarAction(
              label: 'Coba Lagi',
              onPressed: _loadBorrowRequest,
            ),
          ),
        );
      }
    }
  }

  Future<void> _submitReturnRequest() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      print("ReturnRequestScreen - Starting to prepare return request data");
      // Prepare the data for the API request - only send borrow_request_id
      final requestData = {
        'borrow_request_id': widget.borrowRequestId,
      };

      print("ReturnRequestScreen - Return request data prepared: $requestData");
      print("ReturnRequestScreen - About to call returnRequestService.create()");

      // Submit the request
      final response = await _returnRequestService.create(requestData);
      print("ReturnRequestScreen - Response received: $response");

      setState(() {
        _isSubmitting = false;
        print("ReturnRequestScreen - Set isSubmitting to false after successful request");
      });

      if (mounted) {
        print("ReturnRequestScreen - Showing success SnackBar and popping screen");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Return request submitted successfully'))
        );
        Navigator.pop(context, true); // Return with refresh flag
      }
    } catch (e) {
      print("ReturnRequestScreen - Exception caught in _submitReturnRequest: $e");
      print("ReturnRequestScreen - Exception type: ${e.runtimeType}");
      
      final errorMsg = e?.toString() ?? 'Unknown error occurred';
      print("ReturnRequestScreen - Error message: $errorMsg");
      
      setState(() {
        _isSubmitting = false;
        _errorMessage = errorMsg;
        print("ReturnRequestScreen - Set state with errorMessage: $_errorMessage");
      });
      
      if (mounted) {
        print("ReturnRequestScreen - Showing error SnackBar");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Request Pengembalian',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.blue))
        : _borrowRequest == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Peminjaman tidak ditemukan',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadBorrowRequest,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Borrow request details card
                  Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.assignment_outlined,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Peminjaman #${_borrowRequest!.id}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(_borrowRequest!.status).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _borrowRequest!.status.toUpperCase(),
                                  style: TextStyle(
                                    color: _getStatusColor(_borrowRequest!.status),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow('Lokasi', _borrowRequest!.borrowLocation ?? 'Tidak ditentukan'),
                          _buildInfoRow('Tanggal Pengembalian', _borrowRequest!.returnDateExpected),
                          _buildInfoRow('Tanggal Pengajuan', _formatDate(_borrowRequest!.createdAt)),
                        ],
                      ),
                    ),
                  ),
                  
                  // Borrowed items section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Barang yang Dipinjam:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_borrowRequest!.borrowDetails != null && _borrowRequest!.borrowDetails!.isNotEmpty)
                        Text(
                          '${_borrowRequest!.borrowDetails!.length} item',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  if (_borrowRequest!.borrowDetails == null || _borrowRequest!.borrowDetails!.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: const Center(
                        child: Text(
                          'Tidak ada barang pada permintaan ini',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _borrowRequest!.borrowDetails!.length,
                      itemBuilder: (context, index) {
                        final detail = _borrowRequest!.borrowDetails![index];
                        final itemUnit = detail.itemUnit;
                        
                        if (itemUnit == null) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 1,
                            child: const ListTile(
                              title: Text('Item Tidak Diketahui'),
                              subtitle: Text('Detail item tidak tersedia'),
                            ),
                          );
                        }
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 1,
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.inventory_2,
                                color: Colors.blue,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              itemUnit.item?.name ?? 'Item Tidak Diketahui',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'SKU: ${itemUnit.sku}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'x${detail.quantity}',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Return request already exists check
                  if (_borrowRequest!.returnRequest != null)
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Permintaan pengembalian sudah ada untuk peminjaman ini (Status: ${_borrowRequest!.returnRequest!.status.toUpperCase()})',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (_borrowRequest!.status != 'approved')
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Text(
                        'Tidak dapat membuat permintaan pengembalian untuk peminjaman yang belum disetujui (Status saat ini: ${_borrowRequest!.status.toUpperCase()})',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _submitReturnRequest,
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
                              'Ajukan Pengembalian',
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
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
} 