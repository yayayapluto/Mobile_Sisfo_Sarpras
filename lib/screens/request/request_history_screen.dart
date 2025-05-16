import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/borrow_request.dart';
import '../../models/return_request.dart';
import '../../services/api_services/borrow_request_service.dart';
import '../../services/api_services/return_request_service.dart';
import '../../services/dio_service.dart';
import '../../providers/auth_provider.dart';

class RequestHistoryScreen extends StatefulWidget {
  const RequestHistoryScreen({Key? key}) : super(key: key);

  @override
  State<RequestHistoryScreen> createState() => _RequestHistoryScreenState();
}

class _RequestHistoryScreenState extends State<RequestHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _errorMessage;
  
  late BorrowRequestService _borrowRequestService;
  late ReturnRequestService _returnRequestService;
  
  List<BorrowRequest> _borrowRequests = [];
  List<ReturnRequest> _returnRequests = [];
  
  // Currently selected tab
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    // Services will be initialized in didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get the shared DioService from the provider
    final dioService = ProviderScope.containerOf(context).read(dioServiceProvider);
    _borrowRequestService = BorrowRequestService(dioService);
    _returnRequestService = ReturnRequestService(dioService);
    
    _fetchRequests();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        _currentTab = _tabController.index;
      });
    }
  }

  Future<void> _fetchRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Fetch both borrow and return requests
      final borrowRequests = await _borrowRequestService.getAll();
      final returnRequests = await _returnRequestService.getAll();
      
      setState(() {
        _borrowRequests = borrowRequests;
        _returnRequests = returnRequests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load requests: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Riwayat Request',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchRequests,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          tabs: const [
            Tab(text: 'Semua'),
            Tab(text: 'Peminjaman'),
            Tab(text: 'Pengembalian'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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
                        onPressed: _fetchRequests,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAllRequestsList(),
                    _buildBorrowRequestsList(),
                    _buildReturnRequestsList(),
                  ],
                ),
    );
  }

  Widget _buildAllRequestsList() {
    if (_borrowRequests.isEmpty && _returnRequests.isEmpty) {
      return _buildEmptyState('Tidak ada riwayat request');
    }

    return RefreshIndicator(
      onRefresh: _fetchRequests,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ..._borrowRequests.map((request) => _buildBorrowRequestCard(request)),
          ..._returnRequests.map((request) => _buildReturnRequestCard(request)),
        ],
      ),
    );
  }

  Widget _buildBorrowRequestsList() {
    if (_borrowRequests.isEmpty) {
      return _buildEmptyState('Tidak ada riwayat peminjaman');
    }

    return RefreshIndicator(
      onRefresh: _fetchRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _borrowRequests.length,
        itemBuilder: (context, index) {
          final request = _borrowRequests[index];
          return _buildBorrowRequestCard(request);
        },
      ),
    );
  }

  Widget _buildReturnRequestsList() {
    if (_returnRequests.isEmpty) {
      return _buildEmptyState('Tidak ada riwayat pengembalian');
    }

    return RefreshIndicator(
      onRefresh: _fetchRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _returnRequests.length,
        itemBuilder: (context, index) {
          final request = _returnRequests[index];
          return _buildReturnRequestCard(request);
        },
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildBorrowRequestCard(BorrowRequest request) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: Colors.white,
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
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Peminjaman #${request.id}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        request.borrowLocation ?? 'Tidak ada lokasi',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(request.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    request.status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(request.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Request: ${_formatDate(request.createdAt)}',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  'Jatuh Tempo: ${request.returnDateExpected}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            if (request.borrowDetails != null && request.borrowDetails!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Items:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...request.borrowDetails!.map((detail) => 
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                detail.itemUnit?.item?.name ?? detail.itemUnit?.sku ?? 'Unknown Item',
                                style: const TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              'x${detail.quantity}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            if (request.returnRequest == null && request.status == 'approved')
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  children: [
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.push('/return-request/${request.id}');
                      },
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
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReturnRequestCard(ReturnRequest request) {
    // Try to get the borrow request linked to this return request
    BorrowRequest? linkedBorrow;
    if (request.borrowRequestId != null) {
      try {
        linkedBorrow = _borrowRequests.firstWhere((b) => b.id == request.borrowRequestId);
      } catch (_) {
        // No matching borrow request found
      }
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: Colors.white,
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
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.inbox,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pengembalian #${request.id}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (linkedBorrow != null)
                        Text(
                          'Untuk Peminjaman #${linkedBorrow.id}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(request.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    request.status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(request.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Request: ${_formatDate(request.createdAt)}',
                  style: const TextStyle(fontSize: 14),
                ),
                if (linkedBorrow != null)
                  Text(
                    'Due: ${linkedBorrow.returnDateExpected}',
                    style: const TextStyle(fontSize: 14),
                  ),
              ],
            ),
            
            if (linkedBorrow?.borrowDetails != null && linkedBorrow!.borrowDetails!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Items:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...linkedBorrow.borrowDetails!.map((detail) => 
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                detail.itemUnit?.item?.name ?? detail.itemUnit?.sku ?? 'Unknown Item',
                                style: const TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              'x${detail.quantity}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
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
}
