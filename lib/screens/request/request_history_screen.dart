import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class RequestItem {
  final String id;
  final String type;
  final String itemName;
  final String itemCode;
  final DateTime requestDate;
  final DateTime? dueDate;
  final String status;
  final int quantity;

  RequestItem({
    required this.id,
    required this.type,
    required this.itemName,
    required this.itemCode,
    required this.requestDate,
    this.dueDate,
    required this.status,
    required this.quantity,
  });

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      case 'returned':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData get typeIcon {
    switch (type.toLowerCase()) {
      case 'borrow':
        return Icons.outbox;
      case 'return':
        return Icons.inbox;
      default:
        return Icons.swap_horiz;
    }
  }
}

class RequestHistoryScreen extends StatefulWidget {
  const RequestHistoryScreen({Key? key}) : super(key: key);

  @override
  State<RequestHistoryScreen> createState() => _RequestHistoryScreenState();
}

class _RequestHistoryScreenState extends State<RequestHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<RequestItem> _requests = [];
  List<RequestItem> _filteredRequests = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
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
      _filterRequestsByTab();
    }
  }

  void _filterRequestsByTab() {
    setState(() {
      switch (_tabController.index) {
        case 0:
          _filteredRequests = _requests;
          break;
        case 1:
          _filteredRequests =
              _requests.where((req) => req.type == 'borrow').toList();
          break;
        case 2:
          _filteredRequests =
              _requests.where((req) => req.type == 'return').toList();
          break;
      }
    });
  }

  Future<void> _fetchRequests() async {
    await Future.delayed(const Duration(seconds: 1));

    final List<RequestItem> requests = [
      RequestItem(
        id: 'REQ-001',
        type: 'borrow',
        itemName: 'Laptop HP Pavilion',
        itemCode: 'HP-PAV-1001',
        requestDate: DateTime.now().subtract(const Duration(days: 7)),
        dueDate: DateTime.now().add(const Duration(days: 14)),
        status: 'approved',
        quantity: 1,
      ),
      RequestItem(
        id: 'REQ-002',
        type: 'borrow',
        itemName: 'Proyektor Epson EB-E01',
        itemCode: 'EPP-EB-2001',
        requestDate: DateTime.now().subtract(const Duration(days: 3)),
        dueDate: DateTime.now().add(const Duration(days: 7)),
        status: 'pending',
        quantity: 1,
      ),
      RequestItem(
        id: 'REQ-003',
        type: 'return',
        itemName: 'Kursi Siswa',
        itemCode: 'KS-001-025',
        requestDate: DateTime.now().subtract(const Duration(days: 1)),
        status: 'pending',
        quantity: 25,
      ),
      RequestItem(
        id: 'REQ-004',
        type: 'borrow',
        itemName: 'Papan Tulis',
        itemCode: 'PT-001',
        requestDate: DateTime.now().subtract(const Duration(days: 10)),
        dueDate: DateTime.now().subtract(const Duration(days: 3)),
        status: 'returned',
        quantity: 2,
      ),
      RequestItem(
        id: 'REQ-005',
        type: 'borrow',
        itemName: 'Meja Guru',
        itemCode: 'MG-001',
        requestDate: DateTime.now().subtract(const Duration(days: 5)),
        status: 'rejected',
        quantity: 1,
      ),
    ];

    setState(() {
      _requests = requests;
      _filteredRequests = requests;
      _isLoading = false;
    });
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
          : TabBarView(
              controller: _tabController,
              children: [
                _buildRequestList(_filteredRequests),
                _buildRequestList(_filteredRequests),
                _buildRequestList(_filteredRequests),
              ],
            ),
    );
  }

  Widget _buildRequestList(List<RequestItem> requests) {
    if (requests.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ada riwayat request',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
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
                        color: request.type == 'borrow'
                            ? Colors.blue.withOpacity(0.1)
                            : Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        request.typeIcon,
                        color: request.type == 'borrow'
                            ? Colors.blue
                            : Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.itemName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            request.itemCode,
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
                        color: request.statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        request.status,
                        style: TextStyle(
                          color: request.statusColor,
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
                      'Request: ${_formatDate(request.requestDate)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    if (request.dueDate != null)
                      Text(
                        'Jatuh Tempo: ${_formatDate(request.dueDate!)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Jumlah: ${request.quantity}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      'ID: ${request.id}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                if (request.status == 'pending')
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Batalkan'),
                          ),
                        ),
                        if (request.type == 'borrow')
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                context.push('/return-request',
                                    extra: {'borrowId': request.id});
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Kembalikan'),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
