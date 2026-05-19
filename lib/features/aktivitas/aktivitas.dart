import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:catering_dapur_bu_mon/services/api_service.dart';
import 'package:catering_dapur_bu_mon/services/dio_helper.dart';
import 'package:catering_dapur_bu_mon/features/shared/navbar.dart';

// ── Helper functions ─────────────────────────────────────────────
String _formattedPrice(dynamic harga) {
  final h = (double.tryParse(harga.toString()) ?? 0).toInt();
  final s = h.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return 'Rp $buf';
}

String _formattedDate(dynamic tgl) {
  try {
    final dt = DateTime.parse(tgl.toString());
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}  '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  } catch (_) {
    return tgl?.toString() ?? '-';
  }
}

String _formatTglAntar(dynamic tgl) {
  if (tgl == null || tgl.toString().isEmpty) return 'Belum dijadwalkan';
  try {
    final dt = DateTime.parse(tgl.toString());
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  } catch (_) {
    return tgl.toString();
  }
}

String _formatJamAntar(dynamic jam) {
  if (jam == null || jam.toString().isEmpty) return '';
  final s = jam.toString();
  return s.length >= 5 ? s.substring(0, 5) : s;
}

Color _statusColor(String? status) {
  switch (status) {
    case 'pending':  return const Color(0xFFF39C12);
    case 'diterima': return const Color(0xFF3498DB);
    case 'diproses': return const Color(0xFFEE8B2E);
    case 'selesai':  return const Color(0xFF0FBC5F);
    case 'batal':    return const Color(0xFFE74C3C);
    default:         return Colors.grey;
  }
}

String _statusLabel(String? status) {
  switch (status) {
    case 'pending':  return 'Pending';
    case 'diterima': return 'Diterima';
    case 'diproses': return 'Proses';
    case 'selesai':  return 'Selesai';
    case 'batal':    return 'Batal';
    default:         return status ?? '-';
  }
}

IconData _statusIcon(String? status) {
  switch (status) {
    case 'pending':  return Icons.hourglass_empty_rounded;
    case 'diterima': return Icons.thumb_up_rounded;
    case 'diproses': return Icons.local_fire_department_rounded;
    case 'selesai':  return Icons.check_circle_rounded;
    case 'batal':    return Icons.cancel_rounded;
    default:         return Icons.help_outline;
  }
}

// ── Main Page ────────────────────────────────────────────────────
class AktivitasPage extends StatefulWidget {
  final Key? key;
  const AktivitasPage({this.key}) : super(key: key);

  @override
  AktivitasPageState createState() => AktivitasPageState();
}

class AktivitasPageState extends State<AktivitasPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _pesananList = [];
  String? _error;
  int _selectedFilter = 0;

  final List<String> _filterLabels = ['Semua', 'Pending', 'Proses', 'Selesai', 'Batal'];
  final List<String> _filterValues = ['', 'pending', 'diproses', 'selesai', 'batal'];

  @override
  void initState() {
    super.initState();
    _loadPesanan();
  }

  void bukaDetail(int? idPesanan) {
    if (idPesanan != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final pesanan = _pesananList.firstWhere(
          (p) => p['id_pesanan'] == idPesanan,
          orElse: () => {},
        );
        if (pesanan.isNotEmpty) {
          _showDetail(pesanan);
        }
      });
    }
  }

  Future<void> _loadPesanan() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await ApiService.getPesanan();
      setState(() {
        _pesananList = data.map((e) {
          final rawId = e['id_pesanan'];
          final rawTotal = e['total_harga'];
          return {
            'id_pesanan': rawId is int
                ? rawId
                : int.tryParse(rawId.toString()) ?? 0,
            'customer_name': e['customer_name']?.toString() ?? 'Customer',
            'customer_alamat': e['customer_alamat']?.toString() ?? 'Alamat tidak tersedia',
            'status': e['status']?.toString() ?? 'pending',
            'tgl_pesan': e['tgl_pesan']?.toString() ?? DateTime.now().toIso8601String(),
            'tgl_antar': e['tgl_antar']?.toString(),
            'jam_antar': e['jam_antar']?.toString(),
            'total_harga': rawTotal is num
                ? rawTotal.toDouble()
                : double.tryParse(rawTotal.toString()) ?? 0,
            'item_count': e['item_count'] is int
                ? e['item_count']
                : int.tryParse(e['item_count'].toString()) ?? 0,
            'metode_bayar': e['metode_bayar']?.toString() ?? '',
            'catatan': e['catatan']?.toString() ?? '',
          };
        }).toList();
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredList {
    final status = _filterValues[_selectedFilter];
    if (status.isEmpty) return _pesananList;
    return _pesananList.where((p) => p['status'] == status).toList();
  }

  void _showDetail(Map<String, dynamic> pesanan) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => _CustomerDetailDialog(pesanan: pesanan),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom +
        kBottomNavigationBarHeight;

    return Scaffold(
      backgroundColor: Colors.white,
      // ════════════════════════════════════════════════
      //  Struktur: Column
      //    ├── _buildHeader()       ← STICKY
      //    ├── _buildTitleFilter()  ← STICKY
      //    └── Expanded → konten scroll
      // ════════════════════════════════════════════════
      body: Column(
        children: [
          // ── Header gradient — STICKY ────────────────
          _buildHeader(),

          // ── Judul + Filter — STICKY ─────────────────
          _buildTitleFilter(),

          // ── Konten pesanan — SCROLLABLE ─────────────
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadPesanan,
              color: const Color(0xFFD05122),
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFFD05122)))
                  : _error != null
                      ? _buildError()
                      : _filteredList.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              padding: EdgeInsets.fromLTRB(
                                  16, 16, 16, bottomPad),
                              itemCount: _filteredList.length,
                              itemBuilder: (_, i) => Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 12),
                                child: _CustomerOrderCard(
                                  pesanan: _filteredList[i],
                                  onTap: () =>
                                      _showDetail(_filteredList[i]),
                                ),
                              ),
                            ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header gradient ──────────────────────────────────────────
  Widget _buildHeader() {
    final statusBarH = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(20, statusBarH + 16, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFD05122), Color(0xFFEE8B2E), Color(0xFFFBA839)],
          stops: [0.17, 0.47, 0.60],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.receipt_long_rounded,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Aktivitas Saya',
                    style: GoogleFonts.alexandria(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Text('Lihat riwayat pesanan Anda',
                    style: GoogleFonts.alexandria(
                        fontSize: 12, color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Judul + Filter row — ikut sticky ────────────────────────
  Widget _buildTitleFilter() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Aktivitas Pesanan',
              style: GoogleFonts.alexandria(
                  fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                _filterLabels.length,
                (i) => GestureDetector(
                  onTap: () => setState(() => _selectedFilter = i),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: i == _selectedFilter
                          ? const Color(0xFFEE8B2E)
                          : Colors.transparent,
                      border: Border.all(
                          width: 1.5, color: const Color(0xFFDB6626)),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Text(
                      _filterLabels[i],
                      style: GoogleFonts.lora(
                        fontSize: 12,
                        fontWeight: i == _selectedFilter
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: i == _selectedFilter
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(_error!,
              style: GoogleFonts.alexandria(
                  color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadPesanan,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD05122),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Coba Lagi',
                style: GoogleFonts.alexandria(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('Tidak ada pesanan',
                style: GoogleFonts.alexandria(
                    fontSize: 16, color: Colors.grey[500])),
            const SizedBox(height: 8),
            Text('Belum ada pesanan yang dibuat',
                style: GoogleFonts.alexandria(
                    fontSize: 12, color: Colors.grey[400])),
          ],
        ),
      ),
    );
  }
}

// ── Customer Order Card ─────────────────────────────────────────
class _CustomerOrderCard extends StatelessWidget {
  final Map<String, dynamic> pesanan;
  final VoidCallback onTap;
  const _CustomerOrderCard({required this.pesanan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final status = pesanan['status'] as String?;
    final color = _statusColor(status);
    final isBatal = status == 'batal';
    final alamat = pesanan['customer_alamat'] ?? 'Alamat tidak tersedia';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: color,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('#${pesanan['id_pesanan']}',
                            style: GoogleFonts.alexandria(
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                            _formattedDate(pesanan['tgl_pesan']),
                            style: GoogleFonts.alexandria(
                                fontSize: 11,
                                color: Colors.grey[600])),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_statusIcon(status),
                                size: 12, color: color),
                            const SizedBox(width: 4),
                            Text(_statusLabel(status),
                                style: GoogleFonts.alexandria(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: color)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on_rounded,
                          size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(alamat,
                            style: GoogleFonts.alexandria(
                                fontSize: 11, color: Colors.grey[700]),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (pesanan['tgl_antar'] != null &&
                      pesanan['tgl_antar'].toString().isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 12, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                            'Antar: ${_formatTglAntar(pesanan['tgl_antar'])}',
                            style: GoogleFonts.alexandria(
                                fontSize: 11,
                                color: Colors.grey[600])),
                        if (pesanan['jam_antar'] != null &&
                            pesanan['jam_antar'].toString().isNotEmpty)
                          Text(
                              ' pukul ${_formatJamAntar(pesanan['jam_antar'])}',
                              style: GoogleFonts.alexandria(
                                  fontSize: 11,
                                  color: const Color(0xFFD05122),
                                  fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total',
                              style: GoogleFonts.alexandria(
                                  fontSize: 11,
                                  color: Colors.grey[600])),
                          Text(
                              _formattedPrice(pesanan['total_harga']),
                              style: GoogleFonts.alexandria(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFD05122))),
                        ],
                      ),
                      if (!isBatal)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD05122).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Text('Lihat Detail',
                                  style: GoogleFonts.alexandria(
                                      fontSize: 11,
                                      color: const Color(0xFFD05122),
                                      fontWeight: FontWeight.w600)),
                              const Icon(Icons.arrow_forward_ios,
                                  size: 10, color: Color(0xFFD05122)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Customer Detail Dialog ──────────────────────────────────────
class _CustomerDetailDialog extends StatelessWidget {
  final Map<String, dynamic> pesanan;
  const _CustomerDetailDialog({required this.pesanan});

  static const _timelineSteps = [
    {'key': 'pending',  'label': 'Pending'},
    {'key': 'diterima', 'label': 'Diterima'},
    {'key': 'diproses', 'label': 'Diproses'},
    {'key': 'selesai',  'label': 'Selesai'},
  ];

  int _currentStepIndex(String? status) {
    switch (status) {
      case 'pending':  return 0;
      case 'diterima': return 1;
      case 'diproses': return 2;
      case 'selesai':  return 3;
      default:         return -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = pesanan['status'] as String?;
    final color = _statusColor(status);
    final currentStep = _currentStepIndex(status);
    final isBatal = status == 'batal';
    final alamat = pesanan['customer_alamat'] ?? 'Alamat tidak tersedia';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFD05122),
                  Color(0xFFEE8B2E),
                  Color(0xFFFBA839)
                ],
                stops: [0.17, 0.47, 0.60],
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Detail Pesanan',
                          style: GoogleFonts.alexandria(
                              fontSize: 12, color: Colors.white70)),
                      Text('#${pesanan['id_pesanan']}',
                          style: GoogleFonts.alexandria(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isBatal) ...[
                  const Text('Status Pesanan',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey)),
                  const SizedBox(height: 10),
                  _CustomerTimeline(
                      steps: _timelineSteps, currentStep: currentStep),
                  const SizedBox(height: 20),
                ],
                const Text('Info Pesanan',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey)),
                const SizedBox(height: 10),
                _CustomerInfoGrid(items: [
                  _InfoItem(
                      icon: Icons.payment_rounded,
                      label: 'Metode Bayar',
                      value: pesanan['metode_bayar']?.toString() ?? '-'),
                  _InfoItem(
                      icon: Icons.calendar_today_rounded,
                      label: 'Tanggal',
                      value: _formattedDate(pesanan['tgl_pesan'])),
                  _InfoItem(
                      icon: Icons.info_outline_rounded,
                      label: 'Status',
                      value: _statusLabel(status),
                      valueColor: color),
                  _InfoItem(
                      icon: Icons.location_on_rounded,
                      label: 'Alamat',
                      value: alamat,
                      valueColor: const Color(0xFFD05122)),
                  _InfoItem(
                      icon: Icons.event_available_rounded,
                      label: 'Tgl Antar',
                      value: _formatTglAntar(pesanan['tgl_antar'])),
                  _InfoItem(
                      icon: Icons.access_time_rounded,
                      label: 'Jam Antar',
                      value: _formatJamAntar(pesanan['jam_antar'])
                              .isNotEmpty
                          ? _formatJamAntar(pesanan['jam_antar'])
                          : '-'),
                ]),
                if (pesanan['catatan'] != null &&
                    pesanan['catatan'].toString().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(10),
                      border:
                          Border.all(color: const Color(0xFFFFCC02)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.sticky_note_2_outlined,
                            size: 16, color: Color(0xFFF39C12)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                              pesanan['catatan'].toString(),
                              style: GoogleFonts.alexandria(
                                  fontSize: 12,
                                  color: const Color(0xFF7D5A00))),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Pesanan',
                          style: GoogleFonts.alexandria(
                              fontSize: 14,
                              fontWeight: FontWeight.bold)),
                      Text(_formattedPrice(pesanan['total_harga']),
                          style: GoogleFonts.alexandria(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFD05122))),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (status == 'selesai')
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F8EF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            color: Color(0xFF0FBC5F), size: 18),
                        const SizedBox(width: 8),
                        Text('Pesanan telah selesai',
                            style: GoogleFonts.alexandria(
                                fontSize: 13,
                                color: const Color(0xFF0FBC5F),
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  )
                else if (status == 'batal')
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cancel_rounded,
                            color: Colors.red, size: 18),
                        const SizedBox(width: 8),
                        Text('Pesanan telah dibatalkan',
                            style: GoogleFonts.alexandria(
                                fontSize: 13,
                                color: Colors.red,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Close button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD05122),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Tutup',
                    style: GoogleFonts.alexandria(
                        fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Customer Timeline ───────────────────────────────────────────
class _CustomerTimeline extends StatelessWidget {
  final List<Map<String, String?>> steps;
  final int currentStep;
  const _CustomerTimeline(
      {required this.steps, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: steps.asMap().entries.map((e) {
        final i = e.key;
        final step = e.value;
        final isDone = i < currentStep;
        final isActive = i == currentStep;
        final isLast = i == steps.length - 1;

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone
                            ? const Color(0xFF0FBC5F)
                            : isActive
                                ? const Color(0xFFD05122)
                                : Colors.grey.shade200,
                        border: isActive
                            ? Border.all(
                                color: const Color(0xFFD05122), width: 2)
                            : null,
                      ),
                      child: Icon(
                        isDone
                            ? Icons.check_rounded
                            : isActive
                                ? Icons.radio_button_checked_rounded
                                : Icons.radio_button_unchecked_rounded,
                        size: 14,
                        color: isDone || isActive
                            ? Colors.white
                            : Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step['label'] ?? '',
                      style: GoogleFonts.alexandria(
                        fontSize: 9,
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isDone
                            ? const Color(0xFF0FBC5F)
                            : isActive
                                ? const Color(0xFFD05122)
                                : Colors.grey.shade400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 18),
                    color: i < currentStep
                        ? const Color(0xFF0FBC5F)
                        : Colors.grey.shade200,
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── Customer Info Grid ──────────────────────────────────────────
class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });
}

class _CustomerInfoGrid extends StatelessWidget {
  final List<_InfoItem> items;
  const _CustomerInfoGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 2.2,
      children: items
          .map((item) => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Icon(item.icon, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(item.label,
                              style: GoogleFonts.alexandria(
                                  fontSize: 10,
                                  color: Colors.grey[500]),
                              overflow: TextOverflow.ellipsis),
                          Text(item.value,
                              style: GoogleFonts.alexandria(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      item.valueColor ?? Colors.black87),
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}