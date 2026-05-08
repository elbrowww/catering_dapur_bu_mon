import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:catering_dapur_bu_mon/admin/shared/header_admin.dart';
import 'package:catering_dapur_bu_mon/services/api_service.dart';
import 'package:catering_dapur_bu_mon/services/dio_helper.dart';

// ── Konstanta warna & shadow ────────────────────────────────────
const _gradientColors = [
  Color(0xFFD05122),
  Color(0xFFEE8B2E),
  Color(0xFFFBA839),
];
const _gradientStops  = [0.17, 0.47, 0.60];
const _borderOrange   = Color(0xFFDB6626);
const _cardShadow     = [
  BoxShadow(
      color: Color(0x3F000000),
      spreadRadius: 0,
      offset: Offset(0, 4),
      blurRadius: 4),
];
const _listShadow = [
  BoxShadow(
      color: Color(0x3F000000),
      spreadRadius: 3,
      offset: Offset(0, 1.7),
      blurRadius: 3),
];

const _filterLabels = ['Semua', 'Pending', 'Proses', 'Selesai', 'Batal'];
const _filterValues = ['', 'pending', 'diproses', 'selesai', 'batal'];

// ── Base URL gambar diambil dari DioHelper agar tidak hardcode IP
//    File PHP disimpan relatif dari folder /api/, misal:
//    'uploads/bukti_transfer/bukti_30_xxx.png'
//    → http://192.168.1.8/dapur_bu_mon/api/uploads/bukti_transfer/bukti_30_xxx.png

// ── Helpers URL gambar ──────────────────────────────────────────
// baseUrl diambil dari DioHelper agar tidak perlu hardcode IP
String _buildImageUrl(String? raw) {
  if (raw == null || raw.isEmpty) return '';
  if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
  final base = DioHelper.baseUrl.endsWith('/')
      ? DioHelper.baseUrl
      : '${DioHelper.baseUrl}/';
  final path = raw.startsWith('/') ? raw.substring(1) : raw;
  return '$base$path';
}

// ── Status helpers ──────────────────────────────────────────────
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

// ── Page ────────────────────────────────────────────────────────
class PesananAdminPage extends StatefulWidget {
  const PesananAdminPage({super.key});

  @override
  State<PesananAdminPage> createState() => _PesananAdminPageState();
}

class _PesananAdminPageState extends State<PesananAdminPage> {
  int    _selectedFilter = 0;
  bool   _isLoading      = true;
  List<Map<String, dynamic>> _allPesanan = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPesanan();
  }

  Future<void> _loadPesanan() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await ApiService.getPesanan();
      setState(() => _allPesanan = data.cast<Map<String, dynamic>>());
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filtered {
    final status = _filterValues[_selectedFilter];
    if (status.isEmpty) return _allPesanan;
    return _allPesanan.where((p) => p['status'] == status).toList();
  }

  Map<String, int> get _stats => {
    'Total Pesanan': _allPesanan.length,
    'Pending': _allPesanan.where((p) => p['status'] == 'pending').length,
    'Batal':   _allPesanan.where((p) => p['status'] == 'batal').length,
    'Selesai': _allPesanan.where((p) => p['status'] == 'selesai').length,
  };

  Future<void> _updateStatus(int idPesanan, String status) async {
    try {
      await ApiService.updateStatusPesanan(idPesanan: idPesanan, status: status);
      await _loadPesanan();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Status diperbarui ke $status',
              style: GoogleFonts.alexandria(color: Colors.white)),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal update status: $e',
              style: GoogleFonts.alexandria(color: Colors.white)),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    }
  }

  void _showDetail(Map<String, dynamic> pesanan) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => _DetailDialog(
        pesanan: pesanan,
        onUpdateStatus: (status) {
          Navigator.pop(context);
          _updateStatus(pesanan['id_pesanan'], status);
        },
      ),
    );
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
              child: RefreshIndicator(
                onRefresh: _loadPesanan,
                color: const Color(0xFFD05122),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFD05122)))
                    : _error != null
                        ? _ErrorView(error: _error!, onRetry: _loadPesanan)
                        : SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _StatsCard(stats: _stats),
                                const SizedBox(height: 20),
                                Text('Daftar Pesanan',
                                    style: GoogleFonts.alexandria(
                                        fontSize: 20, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 10),
                                _FilterRow(
                                  selected: _selectedFilter,
                                  onSelected: (i) => setState(() => _selectedFilter = i),
                                ),
                                const SizedBox(height: 12),
                                if (_filtered.isEmpty)
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 40),
                                      child: Column(
                                        children: [
                                          Icon(Icons.receipt_long_outlined,
                                              size: 48, color: Colors.grey[300]),
                                          const SizedBox(height: 8),
                                          Text('Tidak ada pesanan',
                                              style: GoogleFonts.alexandria(color: Colors.grey)),
                                        ],
                                      ),
                                    ),
                                  )
                                else
                                  ..._filtered.map((p) => Padding(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: _OrderCard(
                                          pesanan: p,
                                          onDetail: () => _showDetail(p),
                                        ),
                                      )),
                                const SizedBox(height: 80),
                              ],
                            ),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error View ──────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(error,
              style: GoogleFonts.alexandria(color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD05122),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Coba Lagi', style: GoogleFonts.alexandria(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── Stats Card ──────────────────────────────────────────────────
class _StatsCard extends StatelessWidget {
  final Map<String, int> stats;
  const _StatsCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: _cardShadow,
        gradient: const LinearGradient(colors: _gradientColors, stops: _gradientStops),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long, color: Colors.black, size: 24),
              const SizedBox(width: 8),
              Text('Pesanan',
                  style: GoogleFonts.alexandria(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 140 / 100,
            children: stats.entries
                .map((e) => _MiniStatCard(label: e.key, value: '${e.value}'))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: _cardShadow),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label,
              style: GoogleFonts.alexandria(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value,
              style: GoogleFonts.alexandria(fontSize: 35, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ── Filter Row ──────────────────────────────────────────────────
class _FilterRow extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelected;
  const _FilterRow({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          _filterLabels.length,
          (i) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelected(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: i == selected ? const Color(0xFFEE8B2E) : Colors.transparent,
                  border: Border.all(width: 1.5, color: _borderOrange),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(_filterLabels[i],
                    style: GoogleFonts.lora(
                        fontSize: 12,
                        fontWeight: i == selected ? FontWeight.bold : FontWeight.w500)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Order Card ──────────────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> pesanan;
  final VoidCallback onDetail;
  const _OrderCard({required this.pesanan, required this.onDetail});

  int get _progressStep {
    switch (pesanan['status']) {
      case 'pending':  return 1;
      case 'diterima': return 2;
      case 'diproses': return 3;
      case 'selesai':  return 4;
      default:         return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status    = pesanan['status'] as String?;
    final nama      = pesanan['customer_name'] ?? 'Customer #${pesanan['id_customer']}';
    final itemCount = pesanan['item_count'];
    final isBatal   = status == 'batal';
    final isSelesai = status == 'selesai';
    final color     = _statusColor(status);
    final step      = _progressStep;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: _listShadow,
      ),
      child: Column(
        children: [
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('#${pesanan['id_pesanan']}',
                          style: GoogleFonts.alexandria(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(nama,
                          style: GoogleFonts.alexandria(
                              fontSize: 14, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_statusIcon(status), size: 12, color: color),
                          const SizedBox(width: 4),
                          Text(_statusLabel(status),
                              style: GoogleFonts.lora(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: color)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 13, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(_formattedDate(pesanan['tgl_pesan']),
                        style: GoogleFonts.alexandria(fontSize: 12, color: Colors.grey[600])),
                    if (itemCount != null) ...[
                      const SizedBox(width: 12),
                      const Icon(Icons.shopping_bag_outlined, size: 13, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('$itemCount item',
                          style: GoogleFonts.alexandria(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total',
                            style: GoogleFonts.alexandria(fontSize: 11, color: Colors.grey)),
                        Text(_formattedPrice(pesanan['total_harga']),
                            style: GoogleFonts.alexandria(
                                fontSize: 17, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    GestureDetector(
                      onTap: onDetail,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD05122),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.visibility_rounded, size: 14, color: Colors.white),
                            const SizedBox(width: 5),
                            Text('Detail',
                                style: GoogleFonts.alexandria(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (!isBatal) ...[
                  const SizedBox(height: 12),
                  _ProgressBar(step: step, isSelesai: isSelesai),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Progress Bar ────────────────────────────────────────────────
class _ProgressBar extends StatelessWidget {
  final int step;
  final bool isSelesai;
  const _ProgressBar({required this.step, required this.isSelesai});

  static const _labels = ['Pending', 'Diterima', 'Proses', 'Selesai'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List.generate(4, (i) {
            final active = i < step;
            return Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 4,
                      decoration: BoxDecoration(
                        color: active
                            ? (isSelesai ? const Color(0xFF0FBC5F) : const Color(0xFFD05122))
                            : const Color(0xFFEEEEEE),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  if (i < 3) const SizedBox(width: 3),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 5),
        Row(
          children: List.generate(4, (i) {
            final active = i < step;
            return Expanded(
              child: Text(
                _labels[i],
                style: GoogleFonts.alexandria(
                  fontSize: 9,
                  color: active
                      ? (isSelesai ? const Color(0xFF0FBC5F) : const Color(0xFFD05122))
                      : Colors.grey[400],
                  fontWeight: i == step - 1 ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ── Detail Dialog ───────────────────────────────────────────────
class _DetailDialog extends StatefulWidget {
  final Map<String, dynamic> pesanan;
  final ValueChanged<String> onUpdateStatus;
  const _DetailDialog({required this.pesanan, required this.onUpdateStatus});

  @override
  State<_DetailDialog> createState() => _DetailDialogState();
}

class _DetailDialogState extends State<_DetailDialog> {
  bool _loadingDetail = true;
  Map<String, dynamic>? _detail;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final d = await ApiService.getDetailPesanan(widget.pesanan['id_pesanan']);
      debugPrint('=== DETAIL PESANAN KEYS ===');
      debugPrint(d.keys.toString());
      debugPrint('bukti_bayar: ${d['bukti_bayar']}');
      debugPrint('bukti_transfer: ${d['bukti_transfer']}');
      debugPrint('foto_bukti: ${d['foto_bukti']}');
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

  // Field dari PHP: pb.bukti_transfer (tabel pembayaran)
  String get _buktiBayarUrl {
    if (_detail == null) return '';
    final raw = _detail!['bukti_transfer'] ?? // ← nama field di DB & query PHP
        _detail!['bukti_bayar']           ??
        _detail!['foto_bukti']            ??
        _detail!['payment_proof']         ??
        _detail!['foto_transfer']         ??
        '';
    return _buildImageUrl(raw?.toString());
  }

  // PHP menyimpan metode sebagai 'transfer' atau 'cod'
  // Query owner: pb.metode AS metode_bayar
  bool get _isTransfer {
    final metode = (_detail?['metode_bayar'] ?? 
                    widget.pesanan['metode_bayar'] ?? '')
        .toString()
        .toLowerCase();
    return metode == 'transfer' || metode.contains('transfer');
  }

  static const _nextStatus = {
    'pending':  ['diterima', 'batal'],
    'diterima': ['diproses', 'batal'],
    'diproses': ['selesai', 'batal'],
  };

  static const _btnLabel = {
    'diterima': 'Terima Pesanan',
    'diproses': 'Mulai Proses',
    'selesai':  'Tandai Selesai',
    'batal':    'Batalkan',
  };

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
    final status      = widget.pesanan['status'] as String?;
    final actions     = _nextStatus[status] ?? [];
    final nama        = widget.pesanan['customer_name'] ??
        'Customer #${widget.pesanan['id_customer']}';
    final isBatal     = status == 'batal';
    final isSelesai   = status == 'selesai';
    final currentStep = _currentStepIndex(status);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header gradient ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: _gradientColors, stops: _gradientStops),
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
                      Text('#${widget.pesanan['id_pesanan']} · $nama',
                          style: GoogleFonts.alexandria(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // ── Body scrollable ──
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.65,
            ),
            child: _loadingDetail
                ? const SizedBox(
                    height: 120,
                    child: Center(
                      child: CircularProgressIndicator(color: Color(0xFFD05122)),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Timeline status
                        if (!isBatal) ...[
                          const _SectionLabel(label: 'Status Pesanan'),
                          const SizedBox(height: 10),
                          _TimelineWidget(
                            steps: _timelineSteps,
                            currentStep: currentStep,
                            isBatal: isBatal,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Info grid
                        const _SectionLabel(label: 'Info Pesanan'),
                        const SizedBox(height: 10),
                        _InfoGrid(items: [
                          _InfoItem(
                            icon: Icons.payment_rounded,
                            label: 'Metode Bayar',
                            value: _detail?['metode_bayar'] ?? '-',
                          ),
                          _InfoItem(
                            icon: Icons.calendar_today_rounded,
                            label: 'Tanggal',
                            value: _formattedDate(
                                _detail?['tgl_pesan'] ?? widget.pesanan['tgl_pesan']),
                          ),
                          _InfoItem(
                            icon: Icons.info_outline_rounded,
                            label: 'Status',
                            value: _statusLabel(status),
                            valueColor: _statusColor(status),
                          ),
                          _InfoItem(
                            icon: Icons.person_outline_rounded,
                            label: 'Customer',
                            value: _detail?['customer_name'] ?? nama,
                          ),
                        ]),

                        // Catatan
                        if ((_detail?['catatan'] ?? '').toString().isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8E1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: const Color(0xFFFFCC02), width: 1),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.sticky_note_2_outlined,
                                    size: 16, color: Color(0xFFF39C12)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _detail!['catatan'].toString(),
                                    style: GoogleFonts.alexandria(
                                        fontSize: 12, color: const Color(0xFF7D5A00)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // ── BUKTI TRANSFER ──────────────────────────────
                        if (_isTransfer) ...[
                          const SizedBox(height: 16),
                          const _SectionLabel(label: 'Bukti Transfer'),
                          const SizedBox(height: 10),
                          _BuktiTransferWidget(url: _buktiBayarUrl),
                        ],

                        // Daftar item
                        const SizedBox(height: 16),
                        const _SectionLabel(label: 'Item Pesanan'),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              ...(_detail?['items'] as List<dynamic>? ?? [])
                                  .asMap()
                                  .entries
                                  .map((e) => _ItemRow(
                                        item: e.value,
                                        isLast: e.key ==
                                            ((_detail?['items'] as List<dynamic>?)?.length ?? 0) - 1,
                                      )),
                              // Total row
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFAFAFA),
                                  borderRadius: const BorderRadius.vertical(
                                      bottom: Radius.circular(10)),
                                  border: Border(
                                      top: BorderSide(color: Colors.grey.shade200)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Total',
                                        style: GoogleFonts.alexandria(
                                            fontSize: 13, fontWeight: FontWeight.bold)),
                                    Text(
                                      _formattedPrice(_detail?['total_harga'] ?? 0),
                                      style: GoogleFonts.alexandria(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFFD05122)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),

          // ── Action buttons ──
          if (actions.isNotEmpty)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              decoration:
                  BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.shade200))),
              child: Row(
                children: actions.map((s) {
                  final isBatalBtn = s == 'batal';
                  return Expanded(
                    flex: isBatalBtn ? 1 : 2,
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: isBatalBtn ? 8 : 0,
                          right: isBatalBtn ? 0 : 8),
                      child: ElevatedButton(
                        onPressed: () => widget.onUpdateStatus(s),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isBatalBtn
                              ? const Color(0xFFFFEBEB)
                              : const Color(0xFFD05122),
                          foregroundColor:
                              isBatalBtn ? Colors.red : Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          side: isBatalBtn
                              ? const BorderSide(color: Colors.red, width: 1)
                              : BorderSide.none,
                        ),
                        child: Text(
                          _btnLabel[s] ?? s,
                          style: GoogleFonts.alexandria(
                              fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            )
          else if (isSelesai)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
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
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            )
          else if (isBatal)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cancel_rounded, color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Text('Pesanan telah dibatalkan',
                        style: GoogleFonts.alexandria(
                            fontSize: 13,
                            color: Colors.red,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Section Label ───────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: GoogleFonts.alexandria(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[500],
            letterSpacing: 0.5));
  }
}

// ── Info Grid ───────────────────────────────────────────────────
class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  const _InfoItem(
      {required this.icon,
      required this.label,
      required this.value,
      this.valueColor});
}

class _InfoGrid extends StatelessWidget {
  final List<_InfoItem> items;
  const _InfoGrid({required this.items});

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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                                  fontSize: 10, color: Colors.grey[500]),
                              overflow: TextOverflow.ellipsis),
                          Text(item.value,
                              style: GoogleFonts.alexandria(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: item.valueColor ?? Colors.black87),
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

// ── Timeline Widget ─────────────────────────────────────────────
class _TimelineWidget extends StatelessWidget {
  final List<Map<String, String?>> steps;
  final int currentStep;
  final bool isBatal;
  const _TimelineWidget(
      {required this.steps, required this.currentStep, required this.isBatal});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: steps.asMap().entries.map((e) {
        final i        = e.key;
        final step     = e.value;
        final isDone   = i < currentStep;
        final isActive = i == currentStep;
        final isLast   = i == steps.length - 1;

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 24, height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone
                            ? const Color(0xFF0FBC5F)
                            : isActive
                                ? const Color(0xFFD05122)
                                : Colors.grey.shade200,
                        border: isActive
                            ? Border.all(color: const Color(0xFFD05122), width: 2)
                            : null,
                      ),
                      child: Icon(
                        isDone
                            ? Icons.check_rounded
                            : isActive
                                ? Icons.radio_button_checked_rounded
                                : Icons.radio_button_unchecked_rounded,
                        size: 14,
                        color: isDone || isActive ? Colors.white : Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step['label'] ?? '',
                      style: GoogleFonts.alexandria(
                        fontSize: 9,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
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
                    color: i < currentStep ? const Color(0xFF0FBC5F) : Colors.grey.shade200,
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── Item Row ────────────────────────────────────────────────────
class _ItemRow extends StatelessWidget {
  final dynamic item;
  final bool isLast;
  const _ItemRow({required this.item, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0E8),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text('${item['jumlah']}x',
                  style: GoogleFonts.alexandria(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFD05122))),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(item['nama'] ?? '-',
                style: GoogleFonts.alexandria(fontSize: 13)),
          ),
          Text(
            _formattedPrice(item['harga_satuan'] ?? 0),
            style: GoogleFonts.alexandria(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

// ── Bukti Transfer Widget ───────────────────────────────────────
class _BuktiTransferWidget extends StatelessWidget {
  final String url;
  const _BuktiTransferWidget({required this.url});

  void _showFullscreen(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      height: 300,
                      color: Colors.black54,
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => Container(
                    height: 200,
                    color: Colors.black54,
                    child: const Center(
                      child: Icon(Icons.broken_image_outlined,
                          color: Colors.white54, size: 48),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8, right: 8,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.close_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Kosong — belum ada file atau belum transfer
    if (url.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(Icons.image_not_supported_outlined,
                color: Colors.grey[400], size: 32),
            const SizedBox(height: 8),
            Text('Bukti transfer belum diunggah',
                style: GoogleFonts.alexandria(
                    fontSize: 12, color: Colors.grey[500])),
          ],
        ),
      );
    }

    // Ada URL — tampilkan gambar
    return GestureDetector(
      onTap: () => _showFullscreen(context),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              url,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, progress) {
                if (progress == null) return child;
                return Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(color: Color(0xFFD05122)),
                  ),
                );
              },
              errorBuilder: (_, __, ___) => Container(
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image_outlined,
                        color: Colors.grey[400], size: 28),
                    const SizedBox(height: 6),
                    Text('Gagal memuat gambar',
                        style: GoogleFonts.alexandria(
                            fontSize: 12, color: Colors.grey[500])),
                    const SizedBox(height: 4),
                    // Tampilkan URL mentah agar mudah debug
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(url,
                          style: GoogleFonts.alexandria(
                              fontSize: 9, color: Colors.grey[400]),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Badge "Tap untuk perbesar"
          Positioned(
            bottom: 8, right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.zoom_in_rounded,
                      color: Colors.white, size: 13),
                  const SizedBox(width: 4),
                  Text('Tap untuk perbesar',
                      style: GoogleFonts.alexandria(
                          fontSize: 10, color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}