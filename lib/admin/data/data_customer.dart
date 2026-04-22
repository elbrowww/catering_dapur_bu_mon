import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:catering_dapur_bu_mon/admin/shared/header_admin.dart';
import 'package:catering_dapur_bu_mon/services/api_service.dart';
import 'package:catering_dapur_bu_mon/services/session_manager.dart';

class _CustomerData {
  final String nama;
  final String email;
  final String alamat;

  const _CustomerData({
    required this.nama,
    required this.email,
    required this.alamat,
  });

  factory _CustomerData.fromJson(Map<String, dynamic> json) {
    return _CustomerData(
      nama: json['nama'] ?? '',
      email: json['email'] ?? '',
      alamat: json['alamat'] ?? '',
    );
  }
}

const _ulasanNama = 'Dayat';
const _ulasanIsi =
    'terlalu rumit, ngel, ruet mbuh wes terserah sak2 e penak , penting nilaine A, ojo dibatin to, jalanin aja dulu, TITIK NADIR';

class DataCustomerPage extends StatefulWidget {
  const DataCustomerPage({super.key});

  @override
  State<DataCustomerPage> createState() => _DataCustomerPageState();
}

class _DataCustomerPageState extends State<DataCustomerPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  List<_CustomerData> _customers = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchCustomers() async {
    // DEBUG: cek token dan user
    final token = await SessionManager.getToken();
    final user = await SessionManager.getUser();
    print('🔍 Token: $token');
    print('🔍 User: $user');

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final rawList = await ApiService.getDataCustomer();
      setState(() {
        _customers = rawList
            .map((item) => _CustomerData.fromJson(item as Map<String, dynamic>))
            .toList();
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    }
  }

  List<_CustomerData> get _filtered {
    if (_searchQuery.isEmpty) return _customers;
    return _customers
        .where((c) =>
            c.nama.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            c.email.contains(_searchQuery))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const HeaderAdmin(),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _UlasanCard(),
                    const SizedBox(height: 20),
                    Text(
                      'Data Customer',
                      style: GoogleFonts.alexandria(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _SearchBar(
                      controller: _searchController,
                      onChanged: (val) =>
                          setState(() => _searchQuery = val),
                    ),
                    const SizedBox(height: 12),
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(
                            color: Color(0xFFD05122),
                          ),
                        ),
                      )
                    else if (_errorMessage != null)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Text(
                                _errorMessage!,
                                style: GoogleFonts.alexandria(
                                    color: Colors.red, fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: _fetchCustomers,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD05122),
                                ),
                                child: Text('Coba Lagi',
                                    style: GoogleFonts.alexandria(
                                        color: Colors.white)),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (_filtered.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            'Tidak ada customer ditemukan.',
                            style: GoogleFonts.alexandria(
                                color: Colors.black54, fontSize: 14),
                          ),
                        ),
                      )
                    else
                      ..._filtered.map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _CustomerCard(customer: c),
                          )),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UlasanCard extends StatelessWidget {
  const _UlasanCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3F000000),
            spreadRadius: 0,
            offset: Offset(0, 4),
            blurRadius: 4,
          ),
        ],
        gradient: const LinearGradient(
          colors: [Color(0xFFD05122), Color(0xFFEE8B2E), Color(0xFFFBA839)],
          stops: [0.17, 0.47, 0.60],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.network(
                'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SMpkHR7SLEvor999HjP%2F33ebd0d8-c586-482a-8c11-26e8d5a85039.png',
                width: 23,
                height: 22,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 8),
              Text(
                'Ulasan',
                style: GoogleFonts.alexandria(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x3F000000),
                  spreadRadius: 0,
                  offset: Offset(0, 4),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SMpkHR7SLEvor999HjP%2F4f807618-0077-4bbf-9909-c82007923f7a.png',
                  width: 7,
                  height: 11,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _ulasanNama,
                        style: GoogleFonts.alexandria(
                          color: Colors.black,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Opacity(
                        opacity: 0.8,
                        child: Text(
                          _ulasanIsi,
                          style: GoogleFonts.alexandria(
                            color: Colors.black,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Image.network(
                  'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SMpkHR7SLEvor999HjP%2F94c4c749-0859-4ba0-ae6a-67a835f73a8e.png',
                  width: 7,
                  height: 11,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 45,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x3F000000),
                  spreadRadius: 0,
                  offset: Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textAlignVertical: TextAlignVertical.center,
              style: GoogleFonts.lora(
                  color: const Color(0xFF1A1818), fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Cari Nama atau Nomor HP',
                hintStyle: GoogleFonts.lora(
                  color: const Color(0xFF1A1818).withOpacity(0.5),
                  fontSize: 14,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: const LinearGradient(
              colors: [Color(0xFFD05122), Color(0xFFEE8B2E), Color(0xFFFBA839)],
              stops: [0.18, 0.61, 0.85],
            ),
          ),
          child: Center(
            child: Image.network(
              'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SMpkHR7SLEvor999HjP%2Fabbdda7c-5508-4ff4-a21b-ee815edb8318.png',
              width: 20,
              height: 20,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
}

class _CustomerCard extends StatelessWidget {
  final _CustomerData customer;
  const _CustomerCard({required this.customer});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3F000000),
            spreadRadius: 3,
            offset: Offset(0, 1.7),
            blurRadius: 3,
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: const Color(0xFFF79F36),
            child: Text(
              customer.nama.isNotEmpty
                  ? customer.nama[0].toUpperCase()
                  : '?',
              style: GoogleFonts.alexandria(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(customer.nama,
                    style: GoogleFonts.alexandria(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(customer.email,
                    style: GoogleFonts.alexandria(
                        color: const Color(0xFFC98C63),
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
                Text(customer.alamat,
                    style: GoogleFonts.alexandria(
                        color: const Color(0xFFC98C63),
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.black45),
        ],
      ),
    );
  }
}