import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class BorrowedItem {
  final String id;
  final String name;
  final String code;
  final String category;
  final DateTime borrowDate;
  final DateTime dueDate;
  final int quantity;

  BorrowedItem({
    required this.id,
    required this.name,
    required this.code,
    required this.category,
    required this.borrowDate,
    required this.dueDate,
    required this.quantity,
  });
}

class ReturnRequestScreen extends StatefulWidget {
  final String? borrowId;

  const ReturnRequestScreen({
    Key? key,
    this.borrowId,
  }) : super(key: key);

  @override
  State<ReturnRequestScreen> createState() => _ReturnRequestScreenState();
}

class _ReturnRequestScreenState extends State<ReturnRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSubmitting = false;

  String? _selectedBorrowId;
  final TextEditingController _quantityController =
      TextEditingController(text: '1');
  final TextEditingController _conditionController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  List<BorrowedItem> _borrowedItems = [];
  BorrowedItem? _selectedBorrow;

  @override
  void initState() {
    super.initState();
    _fetchBorrowedItems();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _conditionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _fetchBorrowedItems() async {
    await Future.delayed(const Duration(seconds: 1));

    final List<BorrowedItem> borrowedItems = [
      BorrowedItem(
        id: 'BRW-001',
        name: 'Laptop HP Pavilion',
        code: 'HP-PAV-1001',
        category: 'Elektronik',
        borrowDate: DateTime.now().subtract(const Duration(days: 5)),
        dueDate: DateTime.now().add(const Duration(days: 2)),
        quantity: 1,
      ),
      BorrowedItem(
        id: 'BRW-002',
        name: 'Proyektor Epson EB-E01',
        code: 'EPP-EB-2001',
        category: 'Elektronik',
        borrowDate: DateTime.now().subtract(const Duration(days: 10)),
        dueDate: DateTime.now().subtract(const Duration(days: 3)),
        quantity: 1,
      ),
      BorrowedItem(
        id: 'BRW-003',
        name: 'Kursi Siswa',
        code: 'KS-001-025',
        category: 'Furnitur',
        borrowDate: DateTime.now().subtract(const Duration(days: 7)),
        dueDate: DateTime.now().add(const Duration(days: 8)),
        quantity: 25,
      ),
    ];

    setState(() {
      _borrowedItems = borrowedItems;

      if (widget.borrowId != null) {
        _selectedBorrowId = widget.borrowId;
        _selectedBorrow = _borrowedItems.firstWhere(
          (item) => item.id == widget.borrowId,
          orElse: () => _borrowedItems.first,
        );
        _quantityController.text = _selectedBorrow!.quantity.toString();
      }

      _isLoading = false;
    });
  }

  void _updateSelectedBorrow(String borrowId) {
    setState(() {
      _selectedBorrowId = borrowId;
      _selectedBorrow = _borrowedItems.firstWhere(
        (item) => item.id == borrowId,
      );
      _quantityController.text = _selectedBorrow!.quantity.toString();
    });
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  bool _isOverdue(DateTime dueDate) {
    return dueDate.isBefore(DateTime.now());
  }

  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        _showSuccessDialog();
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permintaan Terkirim'),
          content: const Text(
            'Permintaan pengembalian Anda telah berhasil terkirim. Admin akan segera memproses permintaan Anda.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Lihat Status'),
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/history');
              },
            ),
            TextButton(
              child: const Text('Kembali ke Home'),
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/home');
              },
            ),
          ],
        );
      },
    );
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informasi Pengembalian',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedBorrowId,
                      decoration: InputDecoration(
                        labelText: 'Pilih Barang yang Dipinjam',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: Colors.black.withOpacity(0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: Colors.black.withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Silakan pilih barang yang dipinjam';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        if (value != null) {
                          _updateSelectedBorrow(value);
                        }
                      },
                      items: _borrowedItems
                          .map((item) => DropdownMenuItem<String>(
                                value: item.id,
                                child: Text('${item.name} (${item.code})'),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    if (_selectedBorrow != null)
                      Card(
                        elevation: 1,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side:
                              BorderSide(color: Colors.black.withOpacity(0.1)),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Kategori: ${_selectedBorrow!.category}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          _isOverdue(_selectedBorrow!.dueDate)
                                              ? Colors.red[50]
                                              : Colors.green[50],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      _isOverdue(_selectedBorrow!.dueDate)
                                          ? 'Terlambat'
                                          : 'Dalam Masa Peminjaman',
                                      style: TextStyle(
                                        color:
                                            _isOverdue(_selectedBorrow!.dueDate)
                                                ? Colors.red
                                                : Colors.green,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Tanggal Pinjam: ${_formatDate(_selectedBorrow!.borrowDate)}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Jatuh Tempo: ${_formatDate(_selectedBorrow!.dueDate)}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        labelText: 'Jumlah yang Dikembalikan',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: Colors.black.withOpacity(0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: Colors.black.withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Silakan masukkan jumlah';
                        }
                        if (int.tryParse(value) == null ||
                            int.parse(value) <= 0) {
                          return 'Jumlah harus berupa angka positif';
                        }
                        if (_selectedBorrow != null &&
                            int.parse(value) > _selectedBorrow!.quantity) {
                          return 'Jumlah tidak boleh melebihi jumlah yang dipinjam (${_selectedBorrow!.quantity})';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _conditionController,
                      decoration: InputDecoration(
                        labelText: 'Kondisi Barang',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: Colors.black.withOpacity(0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: Colors.black.withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Silakan masukkan kondisi barang';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        labelText: 'Catatan (opsional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: Colors.black.withOpacity(0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: Colors.black.withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                        hintText:
                            'Tambahkan catatan jika ada kerusakan atau masalah',
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Kirim Permintaan',
                                style: TextStyle(fontSize: 16),
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
