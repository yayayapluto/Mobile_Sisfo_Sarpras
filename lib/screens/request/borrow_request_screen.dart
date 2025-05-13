import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class BorrowRequestScreen extends StatefulWidget {
  final String? itemId;
  final String? unitId;

  const BorrowRequestScreen({
    Key? key,
    this.itemId,
    this.unitId,
  }) : super(key: key);

  @override
  State<BorrowRequestScreen> createState() => _BorrowRequestScreenState();
}

class _BorrowRequestScreenState extends State<BorrowRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSubmitting = false;

  String? _selectedItemId;
  String? _selectedUnitId;
  final TextEditingController _quantityController =
      TextEditingController(text: '1');
  final TextEditingController _purposeController = TextEditingController();
  final TextEditingController _returnDateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> _units = [];
  DateTime _returnDate = DateTime.now().add(const Duration(days: 7));

  @override
  void initState() {
    super.initState();
    _returnDateController.text = DateFormat('dd/MM/yyyy').format(_returnDate);
    _fetchFormData();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _purposeController.dispose();
    _returnDateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _fetchFormData() async {
    await Future.delayed(const Duration(seconds: 1));

    final List<Map<String, dynamic>> items = [
      {'id': '1', 'name': 'Laptop HP Pavilion', 'available': 8},
      {'id': '2', 'name': 'Proyektor Epson EB-E01', 'available': 5},
      {'id': '3', 'name': 'Papan Tulis', 'available': 12},
      {'id': '4', 'name': 'Kursi Siswa', 'available': 25},
    ];

    final List<Map<String, dynamic>> allUnits = [
      {'id': 'UNIT-1', 'code': 'HP-PAV-1001', 'itemId': '1'},
      {'id': 'UNIT-2', 'code': 'HP-PAV-1002', 'itemId': '1'},
      {'id': 'UNIT-3', 'code': 'HP-PAV-1003', 'itemId': '1'},
      {'id': 'UNIT-4', 'code': 'EPP-EB-2001', 'itemId': '2'},
      {'id': 'UNIT-5', 'code': 'EPP-EB-2002', 'itemId': '2'},
    ];

    setState(() {
      _items = items;

      if (widget.itemId != null) {
        _selectedItemId = widget.itemId;
        _updateUnits(widget.itemId!);

        if (widget.unitId != null) {
          _selectedUnitId = widget.unitId;
        }
      }

      _isLoading = false;
    });

    _units = allUnits;
  }

  void _updateUnits(String itemId) {
    setState(() {
      _units = _units.where((unit) => unit['itemId'] == itemId).toList();

      if (_selectedUnitId != null) {
        bool unitExists = _units.any((unit) => unit['id'] == _selectedUnitId);
        if (!unitExists) {
          _selectedUnitId = null;
        }
      }
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _returnDate,
        firstDate: DateTime.now().add(const Duration(days: 1)),
        lastDate: DateTime.now().add(const Duration(days: 90)),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Colors.blue,
              ),
            ),
            child: child!,
          );
        });

    if (picked != null) {
      setState(() {
        _returnDate = picked;
        _returnDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
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
            'Permintaan peminjaman Anda telah berhasil terkirim. Admin akan segera memproses permintaan Anda.',
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
          'Request Peminjaman',
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
                      'Informasi Peminjaman',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedItemId,
                      decoration: InputDecoration(
                        labelText: 'Pilih Barang',
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
                          return 'Silakan pilih barang';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          _selectedItemId = value;
                          _selectedUnitId = null;
                          if (value != null) {
                            _updateUnits(value);
                          }
                        });
                      },
                      items: _items
                          .map((item) => DropdownMenuItem<String>(
                                value: item['id'],
                                child: Text(
                                    '${item['name']} (${item['available']} tersedia)'),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    if (_selectedItemId != null && _units.isNotEmpty)
                      DropdownButtonFormField<String>(
                        value: _selectedUnitId,
                        decoration: InputDecoration(
                          labelText: 'Pilih Unit',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _selectedUnitId = value;
                          });
                        },
                        items: _units
                            .map((unit) => DropdownMenuItem<String>(
                                  value: unit['id'],
                                  child: Text(unit['code']),
                                ))
                            .toList(),
                      ),
                    if (_selectedItemId != null && _units.isNotEmpty)
                      const SizedBox(height: 16),
                    TextFormField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        labelText: 'Jumlah',
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
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _purposeController,
                      decoration: InputDecoration(
                        labelText: 'Tujuan Peminjaman',
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
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Silakan masukkan tujuan peminjaman';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _selectDate,
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: _returnDateController,
                          decoration: InputDecoration(
                            labelText: 'Tanggal Pengembalian',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                  color: Colors.black.withOpacity(0.3)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                  color: Colors.black.withOpacity(0.3)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.blue),
                            ),
                            fillColor: Colors.white,
                            filled: true,
                            suffixIcon: const Icon(Icons.calendar_today,
                                color: Colors.blue),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Silakan masukkan tanggal pengembalian';
                            }
                            return null;
                          },
                        ),
                      ),
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
