import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:catering_dapur_bu_mon/services/api_service.dart';

class AktivitasPage extends StatefulWidget {
  const AktivitasPage({super.key});

  @override
  AktivitasPageState createState() => AktivitasPageState();
}

class AktivitasPageState extends State<AktivitasPage> {
  String _filterAktif = 'Semua';
  List<Map<String, dynamic>> _semuaPesanan = [];
  bool _isLoading = true;
  String? _error;

  int? _expandedId;
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _itemKeys = {};

  // ============================================================
  // 🔥 HELPER: Safe type conversion
  // ============================================================
  
  int _toInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    if (value is double) return value.toInt();
    return defaultValue;
  }

  double _toDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  String _toString(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    return value.toString();
  }

  // ============================================================
  // 🔥 Konversi data pesanan dari API ke format yang aman
  // ============================================================
  
  Map<String, dynamic> _safePesanan(Map<String, dynamic> raw) {
    return {
      'id_pesanan': _toInt(raw['id_pesanan']),
      'status': _toString(raw['status'], defaultValue: 'pending'),
      'total_harga': _toDouble(raw['total_harga']),
      'tgl_pesan': _toString(raw['tgl_pesan']),
      'tgl_antar': _toString(raw['tgl_antar']),
      'jam_antar': _toString(raw['jam_antar']),
      'tipe_pengiriman': _toString(raw['tipe_pengiriman'], defaultValue: 'ambil'),
      'metode_bayar': _toString(raw['metode_bayar']),
      'catatan': _toString(raw['catatan']),
      'item_count': _toInt(raw['item_count'], defaultValue: _toInt(raw['items']?.length ?? 0)),
      'items': raw['items'] ?? [],
    };
  }

  List<Map<String, dynamic>> _safePesananList(List<dynamic> rawList) {
    return rawList.map((item) {
      if (item is Map<String, dynamic>) {
        return _safePesanan(item);
      }
      return <String, dynamic>{};
    }).where((item) => item.isNotEmpty).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadPesanan();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void bukaDetail(int? idPesanan) {
    if (idPesanan == null) return;
    setState(() => _expandedId = idPesanan);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToExpanded(idPesanan);
    });
  }

  void _scrollToExpanded(int id) {
    final key = _itemKeys[id];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        alignment: 0.1,
      );
    }
  }

  Future<void> _loadPesanan() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final raw = await ApiService.getPesanan();
      setState(() {
        _semuaPesanan = _safePesananList(raw);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // ── Filter ─────────────────────────────────────────────────
  List<Map<String, dynamic>> get _terfilter {
    switch (_filterAktif) {
      case 'Bulan ini':
        final now = DateTime.now();
        return _semuaPesanan.where((p) {
          try {
            final dt = DateTime.parse(p['tgl_pesan'].toString());
            return dt.month == now.month && dt.year == now.year;
          } catch (_) {
            return false;
          }
        }).toList();
      case 'Bulan Lalu':
        final now = DateTime.now();
        final bulan = now.month == 1 ? 12 : now.month - 1;
        final tahun = now.month == 1 ? now.year - 1 : now.year;
        return _semuaPesanan.where((p) {
          try {
            final dt = DateTime.parse(p['tgl_pesan'].toString());
            return dt.month == bulan && dt.year == tahun;
          } catch (_) {
            return false;
          }
        }).toList();
      default:
        return _semuaPesanan;
    }
  }

  Map<String, List<Map<String, dynamic>>> get _perTanggal {
    final Map<String, List<Map<String, dynamic>>> result = {};
    for (final item in _terfilter) {
      final label = _labelTanggal(item['tgl_pesan']);
      result.putIfAbsent(label, () => []).add(item);
    }
    return result;
  }

  String _labelTanggal(dynamic tgl) {
    try {
      final dt = DateTime.parse(tgl.toString());
      const bulanNama = [
        '',
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      return '${dt.day} ${bulanNama[dt.month]} ${dt.year}';
    } catch (_) {
      return tgl?.toString() ?? '-';
    }
  }

  String _formatHarga(dynamic harga) {
    final h = _toDouble(harga).toInt();
    final s = h.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return 'Rp. $buf';
  }

  String _metodeBayar(Map<String, dynamic> p) {
    final raw = _toString(p['metode_bayar']).toLowerCase();
    if (raw.contains('transfer')) return 'Transfer Bank';
    if (raw.contains('cod') || raw.contains('cash')) return 'Cash';
    if (raw.contains('ewallet')) return 'E-Wallet';
    return raw.isEmpty ? '-' : raw;
  }

  int _resolveItemCount(Map<String, dynamic> p) {
    // 🔥 Coba dari item_count dulu
    final fromField = _toInt(p['item_count']);
    if (fromField > 0) return fromField;
    
    // Fallback ke items array
    final items = p['items'];
    if (items is List) return items.length;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFAC3715), Color(0xFFD05122), Color(0xFFEE8B2E)],
          stops: [0.21, 0.56, 0.83],
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(23, 14 + statusBarHeight, 23, 0),
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(46),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF3F1F0C),
                    Color(0xFFAC3715),
                    Color(0xFFD05122),
                    Color(0xFF66270F),
                  ],
                  stops: [0.13, 0.36, 0.61, 0.82],
                ),
              ),
              child: Center(
                child: Text(
                  'Aktivitas',
                  style: GoogleFonts.alexandria(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(34, 18, 34, 12),
                    child: Row(
                      children: ['Semua', 'Bulan ini', 'Bulan Lalu']
                          .map((f) => Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: _FilterChip(
                                  label: f,
                                  aktif: _filterAktif == f,
                                  onTap: () =>
                                      setState(() => _filterAktif = f),
                                ),
                              ))
                          .toList(),
                    ),
                  ),

                  Expanded(
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFFD05122)))
                        : _error != null
                            ? _buildError()
                            : _terfilter.isEmpty
                                ? _buildEmpty()
                                : RefreshIndicator(
                                    onRefresh: _loadPesanan,
                                    color: const Color(0xFFD05122),
                                    child: ListView.builder(
                                      controller: _scrollController,
                                      padding: const EdgeInsets.fromLTRB(
                                          32, 0, 32, 100),
                                      itemCount: _perTanggal.keys.length,
                                      itemBuilder: (_, i) {
                                        final tgl = _perTanggal.keys
                                            .elementAt(i);
                                        final items = _perTanggal[tgl]!;
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(
                                                      bottom: 6, top: 4),
                                              child: Opacity(
                                                opacity: 0.5,
                                                child: Text(
                                                  tgl,
                                                  style: GoogleFonts
                                                      .alexandria(
                                                    color: const Color(
                                                        0xFF1A1818),
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            ...items.map((item) {
                                              final id = _toInt(
                                                  item['id_pesanan']);
                                              final isExpanded =
                                                  _expandedId != null &&
                                                      _expandedId == id;

                                              if (id > 0) {
                                                _itemKeys.putIfAbsent(
                                                    id, () => GlobalKey());
                                              }

                                              return Padding(
                                                key: id > 0
                                                    ? _itemKeys[id]
                                                    : null,
                                                padding:
                                                    const EdgeInsets.only(
                                                        bottom: 10),
                                                child: _AktivitasItem(
                                                  pesanan: item,
                                                  formatHarga:
                                                      _formatHarga,
                                                  metodeBayar:
                                                      _metodeBayar(item),
                                                  itemCount:
                                                      _resolveItemCount(
                                                          item),
                                                  isExpanded: isExpanded,
                                                  onToggleDetail: () {
                                                    setState(() {
                                                      _expandedId =
                                                          isExpanded
                                                              ? null
                                                              : id;
                                                    });
                                                    if (!isExpanded &&
                                                        id > 0) {
                                                      WidgetsBinding
                                                          .instance
                                                          .addPostFrameCallback(
                                                              (_) {
                                                        _scrollToExpanded(
                                                            id);
                                                      });
                                                    }
                                                  },
                                                ),
                                              );
                                            }),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                  ),
                ],
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
          Icon(Icons.wifi_off_rounded,
              color: Colors.grey.shade400, size: 40),
          const SizedBox(height: 8),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style:
                GoogleFonts.alexandria(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _loadPesanan,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                    colors: [Color(0xFFD05122), Color(0xFFEE8B2E)]),
              ),
              child: Text(
                'Coba Lagi',
                style: GoogleFonts.alexandria(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'Belum ada aktivitas',
            style: GoogleFonts.alexandria(
                color: Colors.grey, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  _AktivitasItem (sudah diperbaiki)
// ════════════════════════════════════════════════════════════════
class _AktivitasItem extends StatefulWidget {
  final Map<String, dynamic> pesanan;
  final String Function(dynamic) formatHarga;
  final String metodeBayar;
  final int itemCount;
  final bool isExpanded;
  final VoidCallback onToggleDetail;

  const _AktivitasItem({
    required this.pesanan,
    required this.formatHarga,
    required this.metodeBayar,
    required this.itemCount,
    required this.isExpanded,
    required this.onToggleDetail,
  });

  @override
  State<_AktivitasItem> createState() => _AktivitasItemState();
}

class _AktivitasItemState extends State<_AktivitasItem> {
  Map<String, dynamic>? _detail;
  bool _loadingDetail = false;

  int _toInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    if (value is double) return value.toInt();
    return defaultValue;
  }

  Color _dotColor(String? s) {
    switch (s) {
      case 'pending':
        return const Color(0xFFF39C12);
      case 'diterima':
        return const Color(0xFF3498DB);
      case 'diproses':
        return const Color(0xFFEE8B2E);
      case 'selesai':
        return const Color(0xFF0FBC5F);
      case 'batal':
        return const Color(0xFFE74C3C);
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String? s) {
    switch (s) {
      case 'pending':
        return 'Menunggu';
      case 'diterima':
        return 'Diterima';
      case 'diproses':
        return 'Diproses';
      case 'selesai':
        return 'Selesai';
      case 'batal':
        return 'Batal';
      default:
        return s ?? '-';
    }
  }

  Future<void> _loadDetail() async {
    if (_detail != null) return;
    setState(() => _loadingDetail = true);
    try {
      final idPesanan = _toInt(widget.pesanan['id_pesanan']);
      final d = await ApiService.getDetailPesanan(idPesanan);
      setState(() {
        _detail = d;
        _loadingDetail = false;
      });
    } catch (_) {
      setState(() {
        _detail = widget.pesanan;
        _loadingDetail = false;
      });
    }
  }

  @override
  void didUpdateWidget(_AktivitasItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded && !oldWidget.isExpanded) {
      _loadDetail();
    }
  }

  String _formatTglLengkap(dynamic tgl, dynamic jam) {
    if (tgl == null || tgl.toString().isEmpty) return 'Belum dijadwalkan';
    try {
      final dt = DateTime.parse(tgl.toString());
      const days = [
        'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
      ];
      final hari = days[dt.weekday - 1];
      final d = dt.day.toString().padLeft(2, '0');
      final m = dt.month.toString().padLeft(2, '0');
      final jamStr = jam?.toString() ?? '';
      final jamFmt =
          jamStr.length >= 5 ? ' • ${jamStr.substring(0, 5)}' : '';
      return '$hari, $d/$m/${dt.year}$jamFmt';
    } catch (_) {
      return tgl.toString();
    }
  }

  String _formatTglPesan(dynamic tgl) {
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

  int _stepIndex(String? s) {
    switch (s) {
      case 'pending':
        return 0;
      case 'diterima':
        return 1;
      case 'diproses':
        return 2;
      case 'selesai':
        return 3;
      default:
        return -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.pesanan['status'] as String?;
    final itemCount = widget.itemCount;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: widget.isExpanded
                ? const BorderRadius.only(
                    topLeft: Radius.circular(9),
                    topRight: Radius.circular(9),
                  )
                : BorderRadius.circular(9),
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
              Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  color: const Color(0xFFF79F36),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Icon(Icons.fastfood,
                    color: Colors.white, size: 32),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      itemCount > 0
                          ? '$itemCount item pesanan'
                          : 'Pesanan aktif',
                      style: GoogleFonts.alexandria(
                          color: Colors.black, fontSize: 14),
                    ),
                    Text(
                      widget.formatHarga(
                          widget.pesanan['total_harga'] ?? 0),
                      style: GoogleFonts.alexandria(
                        color: const Color(0xFFDC6727),
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Opacity(
                          opacity: 0.7,
                          child: Text(
                            widget.metodeBayar,
                            style: GoogleFonts.alexandria(
                                color: Colors.black, fontSize: 13),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _dotColor(status),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _statusLabel(status),
                          style: GoogleFonts.alexandria(
                            fontSize: 11,
                            color: _dotColor(status),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              GestureDetector(
                onTap: () {
                  if (!widget.isExpanded) _loadDetail();
                  widget.onToggleDetail();
                },
                child: Opacity(
                  opacity: 0.6,
                  child: Text(
                    widget.isExpanded ? 'Tutup' : 'Lihat Detail',
                    style: GoogleFonts.alexandria(
                      color: const Color(0xFF1A1818),
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        if (widget.isExpanded)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(9),
                bottomRight: Radius.circular(9),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x3F000000),
                  spreadRadius: 3,
                  offset: Offset(0, 3),
                  blurRadius: 3,
                ),
              ],
            ),
            child: _loadingDetail
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFFD05122), strokeWidth: 2),
                    ),
                  )
                : _buildDetailPanel(status),
          ),
      ],
    );
  }

  Widget _buildDetailPanel(String? status) {
    final p = _detail ?? widget.pesanan;
    final isBatal = status == 'batal';
    final tglAntar = p['tgl_antar'];
    final jamAntar = p['jam_antar'];
    final tipe = (p['tipe_pengiriman'] ?? 'ambil').toString();
    final catatan = (p['catatan'] ?? '').toString();
    final items = (p['items'] as List<dynamic>?) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isBatal) ...[
          _sectionLabel('Status Pesanan'),
          const SizedBox(height: 8),
          _TimelineWidget(currentStep: _stepIndex(status)),
          const SizedBox(height: 14),
        ],

        _sectionLabel('Info Pesanan'),
        const SizedBox(height: 8),
        _infoRow(
          icon: Icons.calendar_today_rounded,
          label: 'Dipesan',
          value: _formatTglPesan(p['tgl_pesan']),
        ),
        const SizedBox(height: 5),
        _infoRow(
          icon: tipe == 'antar'
              ? Icons.local_shipping_rounded
              : Icons.store_rounded,
          label: tipe == 'antar' ? 'Jadwal Antar' : 'Jadwal Ambil',
          value: tglAntar != null && tglAntar.toString().isNotEmpty
              ? _formatTglLengkap(tglAntar, jamAntar)
              : 'Belum dijadwalkan',
          valueColor: tglAntar != null && tglAntar.toString().isNotEmpty
              ? const Color(0xFFD05122)
              : null,
        ),
        const SizedBox(height: 5),
        _infoRow(
          icon: Icons.payment_rounded,
          label: 'Pembayaran',
          value: widget.metodeBayar,
        ),

        if (catatan.isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFFCC02)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.sticky_note_2_outlined,
                    size: 13, color: Color(0xFFF39C12)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    catatan,
                    style: GoogleFonts.alexandria(
                        fontSize: 11,
                        color: const Color(0xFF7D5A00)),
                  ),
                ),
              ],
            ),
          ),
        ],

        if (items.isNotEmpty) ...[
          const SizedBox(height: 14),
          _sectionLabel('Item Pesanan'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                ...items.asMap().entries.map((e) {
                  final item = e.value;
                  final isLast = e.key == items.length - 1;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      border: isLast
                          ? null
                          : Border(
                              bottom: BorderSide(
                                  color: Colors.grey.shade200)),
                    ),
                    child: Row(children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0E8),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Center(
                          child: Text(
                            '${item['jumlah']}x',
                            style: GoogleFonts.alexandria(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFD05122),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item['nama'] ?? '-',
                          style: GoogleFonts.alexandria(fontSize: 11),
                        ),
                      ),
                      Text(
                        widget.formatHarga(item['harga_satuan'] ?? 0),
                        style: GoogleFonts.alexandria(
                            fontSize: 10, color: Colors.grey[600]),
                      ),
                    ]),
                  );
                }),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(8)),
                    border: Border(
                        top: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: GoogleFonts.alexandria(
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        widget.formatHarga(p['total_harga'] ??
                            widget.pesanan['total_harga'] ??
                            0),
                        style: GoogleFonts.alexandria(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFD05122),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.alexandria(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: Colors.grey[500],
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 13, color: Colors.grey[400]),
        const SizedBox(width: 6),
        SizedBox(
          width: 85,
          child: Text(
            label,
            style: GoogleFonts.alexandria(
                fontSize: 10, color: Colors.grey[500]),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.alexandria(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  _TimelineWidget
// ════════════════════════════════════════════════════════════════
class _TimelineWidget extends StatelessWidget {
  final int currentStep;
  const _TimelineWidget({required this.currentStep});
  static const _steps = ['Pending', 'Diterima', 'Proses', 'Selesai'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(4, (i) {
        final isDone = i < currentStep;
        final isActive = i == currentStep;
        final isLast = i == 3;
        final color = isDone
            ? const Color(0xFF0FBC5F)
            : isActive
                ? const Color(0xFFD05122)
                : Colors.grey.shade300;

        return Expanded(
          child: Row(children: [
            Expanded(
              child: Column(children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone
                        ? const Color(0xFF0FBC5F)
                        : isActive
                            ? const Color(0xFFD05122)
                            : Colors.grey.shade200,
                  ),
                  child: Icon(
                    isDone
                        ? Icons.check_rounded
                        : isActive
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_unchecked_rounded,
                    size: 12,
                    color: isDone || isActive
                        ? Colors.white
                        : Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _steps[i],
                  style: GoogleFonts.alexandria(
                    fontSize: 8,
                    fontWeight:
                        isActive ? FontWeight.bold : FontWeight.normal,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ]),
            ),
            if (!isLast)
              Expanded(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  color: i < currentStep
                      ? const Color(0xFF0FBC5F)
                      : Colors.grey.shade200,
                ),
              ),
          ]),
        );
      }),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  _FilterChip
// ════════════════════════════════════════════════════════════════
class _FilterChip extends StatelessWidget {
  final String label;
  final bool aktif;
  final VoidCallback onTap;

  const _FilterChip(
      {required this.label, required this.aktif, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 25,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: aktif ? const Color(0xFFEE8B2E) : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(width: 1.5, color: const Color(0xFFDB6626)),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.lora(
              color: Colors.black,
              fontSize: 12,
              fontWeight: aktif ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}