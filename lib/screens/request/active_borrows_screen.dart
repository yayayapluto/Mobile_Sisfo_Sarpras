import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/borrow_request.dart';
import '../../services/api_services/borrow_request_service.dart';
import '../../services/dio_service.dart';
import '../../providers/auth_provider.dart';
import 'return_request_screen.dart';

class ActiveBorrowsScreen extends StatefulWidget {
  const ActiveBorrowsScreen({Key? key}) : super(key: key);

  @override
  State<ActiveBorrowsScreen> createState() => _ActiveBorrowsScreenState();
}

class _ActiveBorrowsScreenState extends State<ActiveBorrowsScreen> {
  late BorrowRequestService _borrowRequestService;
  
  List<BorrowRequest> _activeBorrows = [];
  bool _isLoading = true;
  String? _errorMessage;

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
    
    _loadActiveBorrows();
  }

  Future<void> _loadActiveBorrows() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get only approved borrows without return requests
      final allBorrows = await _borrowRequestService.getAll();
      
      setState(() {
        // Filter for approved borrows that don't have return requests
        _activeBorrows = allBorrows.where((borrow) {
          return borrow.status == 'approved' && borrow.returnRequest == null;
        }).toList();
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load active borrows: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToReturnRequest(BorrowRequest borrow) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReturnRequestScreen(
          borrowRequestId: borrow.id,
        ),
      ),
    );

    // Refresh the list if return was created
    if (result == true) {
      _loadActiveBorrows();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Peminjaman Aktif',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadActiveBorrows,
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.blue))
        : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadActiveBorrows,
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
          : _activeBorrows.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'Tidak ada peminjaman aktif',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Semua barang telah dikembalikan',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadActiveBorrows,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _activeBorrows.length,
                  itemBuilder: (context, index) {
                    final borrow = _activeBorrows[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                      child: InkWell(
                        onTap: () => _navigateToReturnRequest(borrow),
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
                                      Icons.outbox,
                                      color: Colors.blue,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Peminjaman #${borrow.id}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(borrow.status).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      borrow.status.toUpperCase(),
                                      style: TextStyle(
                                        color: _getStatusColor(borrow.status),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildInfoRow('Lokasi', borrow.borrowLocation ?? 'Tidak ditentukan'),
                              _buildInfoRow('Tanggal Pengembalian', borrow.returnDateExpected),
                              _buildInfoRow('Tanggal Pengajuan', _formatDate(borrow.createdAt)),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  const Spacer(),
                                  ElevatedButton.icon(
                                    onPressed: () => _navigateToReturnRequest(borrow),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    label: const Text('Ajukan Pengembalian'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
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
  
  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
} 