import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:catering_dapur_bu_mon/admin/shared/header_admin.dart';
import 'package:catering_dapur_bu_mon/services/api_service.dart';

// ══════════════════════════════════════════════════════════════
//  KONSTANTA DESAIN
// ══════════════════════════════════════════════════════════════
const _gradientColors = [
  Color(0xFFD05122),
  Color(0xFFEE8B2E),
  Color(0xFFFBA839),
];
const _gradientStops = [0.18, 0.61, 0.85];
const _shadowDefault = [
  BoxShadow(
    color: Color(0x3F000000),
    spreadRadius: 3,
    offset: Offset(0, 4),
    blurRadius: 4,
  ),
];

// ══════════════════════════════════════════════════════════════
//  DASHBOARD ADMIN
// ══════════════════════════════════════════════════════════════
class DashboardAdmin extends StatefulWidget {
  const DashboardAdmin({super.key});

  @override
  State<DashboardAdmin> createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<DashboardAdmin> {
  Map<String, dynamic>? _data;
  bool _isLoading = true;
  String? _error;

  // Filter bulan/tahun
  late int _bulan;
  late int _tahun;

  static const _namaBulan = [
    '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _bulan = now.month;
    _tahun = now.year;
    _fetchDashboard();
  }

  Future<void> _fetchDashboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final result = await ApiService.getDashboardAdmin(
        bulan: _bulan,
        tahun: _tahun,
      );
      setState(() {
        _data = result;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Gagal memuat data dashboard.';
        _isLoading = false;
      });
    }
  }

  String _formatRupiah(double nominal) {
    if (nominal >= 1000000000) {
      return 'Rp ${(nominal / 1000000000).toStringAsFixed(1)}M';
    } else if (nominal >= 1000000) {
      return 'Rp ${(nominal / 1000000).toStringAsFixed(1)}Jt';
    } else if (nominal >= 1000) {
      return 'Rp ${(nominal / 1000).toStringAsFixed(0)}Rb';
    }
    return 'Rp ${nominal.toStringAsFixed(0)}';
  }

  String _formatRupiahFull(double nominal) {
    final s = nominal.toStringAsFixed(0);
    final result = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) result.write('.');
      result.write(s[i]);
      count++;
    }
    return 'Rp. ${result.toString().split('').reversed.join()}';
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
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFFD05122)))
                  : _error != null
                      ? _buildError()
                      : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded,
              color: Colors.grey.shade400, size: 48),
          const SizedBox(height: 12),
          Text(_error!,
              textAlign: TextAlign.center,
              style: GoogleFonts.alexandria(
                  color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _fetchDashboard,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                    colors: [Color(0xFFD05122), Color(0xFFEE8B2E)]),
              ),
              child: Text('Coba Lagi',
                  style: GoogleFonts.alexandria(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final d = _data!;
    final pemasukan   = (d['pemasukan']     as num?)?.toDouble() ?? 0;
    final totalPesan  = (d['total_pesanan'] as num?)?.toInt()    ?? 0;
    final menuReady   = (d['menu_ready']    as num?)?.toInt()    ?? 0;
    final diproses    = (d['diproses']      as num?)?.toInt()    ?? 0;
    final masuk       = (d['pesanan_masuk'] as num?)?.toInt()    ?? 0;
    final grafik      = (d['grafik']        as List?) ?? [];
    final terlaris    = (d['menu_terlaris'] as List?) ?? [];

    return RefreshIndicator(
      color: const Color(0xFFD05122),
      onRefresh: _fetchDashboard,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Income Card ──────────────────────────────────────
            _IncomeCard(
              pemasukan: pemasukan,
              formattedFull: _formatRupiahFull(pemasukan),
              bulanLabel:
                  '${_namaBulan[_bulan]} $_tahun',
              onPilihBulan: _showBulanPicker,
            ),
            const SizedBox(height: 16),

            // ── Stats Grid ───────────────────────────────────────
            _StatsGrid(
              totalPesanan : totalPesan,
              menuReady    : menuReady,
              diproses     : diproses,
              pesananMasuk : masuk,
            ),
            const SizedBox(height: 16),

            // ── Grafik Penjualan ─────────────────────────────────
            _sectionTitle('Grafik Penjualan'),
            const SizedBox(height: 8),
            _SalesChart(
              grafik: grafik,
              formatRupiah: _formatRupiah,
            ),
            const SizedBox(height: 16),

            // ── Menu Terlaris ────────────────────────────────────
            _sectionTitle('Paling Banyak Dibeli'),
            const SizedBox(height: 8),
            if (terlaris.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text('Belum ada data penjualan.',
                      style: GoogleFonts.alexandria(
                          color: Colors.grey, fontSize: 13)),
                ),
              )
            else
              ...terlaris.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _MenuItemCard(
                      item: item as Map<String, dynamic>,
                      formatRupiah: _formatRupiahFull,
                    ),
                  )),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.alexandria(
        color: Colors.black,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // ── Picker bulan/tahun ───────────────────────────────────────────────────
  Future<void> _showBulanPicker() async {
    int tmpBulan = _bulan;
    int tmpTahun = _tahun;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 16),
              Text('Pilih Bulan & Tahun',
                  style: GoogleFonts.alexandria(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              // Tahun
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => setModal(() => tmpTahun--),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Text('$tmpTahun',
                      style: GoogleFonts.alexandria(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    onPressed: () => setModal(
                        () => tmpTahun = tmpTahun < DateTime.now().year
                            ? tmpTahun + 1
                            : tmpTahun),
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Grid bulan
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: 12,
                itemBuilder: (_, i) {
                  final b = i + 1;
                  final isSelected = b == tmpBulan;
                  return GestureDetector(
                    onTap: () => setModal(() => tmpBulan = b),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: isSelected
                            ? const LinearGradient(
                                colors: [
                                  Color(0xFFD05122),
                                  Color(0xFFEE8B2E)
                                ],
                              )
                            : null,
                        color: isSelected ? null : Colors.grey.shade100,
                      ),
                      child: Text(
                        _DashboardAdminState._namaBulan[b]
                            .substring(0, 3),
                        style: GoogleFonts.alexandria(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _bulan = tmpBulan;
                      _tahun = tmpTahun;
                    });
                    _fetchDashboard();
                  },
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                          colors: [Color(0xFFD05122), Color(0xFFEE8B2E)]),
                    ),
                    child: Center(
                      child: Text('Terapkan',
                          style: GoogleFonts.alexandria(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
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

// ══════════════════════════════════════════════════════════════
//  INCOME CARD
// ══════════════════════════════════════════════════════════════
class _IncomeCard extends StatelessWidget {
  final double pemasukan;
  final String formattedFull;
  final String bulanLabel;
  final VoidCallback onPilihBulan;

  const _IncomeCard({
    required this.pemasukan,
    required this.formattedFull,
    required this.bulanLabel,
    required this.onPilihBulan,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: _shadowDefault,
        gradient: const LinearGradient(
          colors: _gradientColors,
          stops: _gradientStops,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0x19FFFFFF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Opacity(
                  opacity: 0.8,
                  child: Text(
                    'Pemasukan Bulan ini',
                    style: GoogleFonts.alexandria(
                      color: const Color(0xFF1A1818),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              // Tombol filter bulan
              GestureDetector(
                onTap: onPilihBulan,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Opacity(
                        opacity: 0.8,
                        child: Text(
                          bulanLabel,
                          style: GoogleFonts.alexandria(
                            color: const Color(0xFF1A1818),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down,
                          size: 14, color: Color(0xFF1A1818)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Opacity(
            opacity: 0.8,
            child: Text(
              'Total Pemasukan',
              style: GoogleFonts.lora(
                color: const Color(0xFF1A1818),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            formattedFull,
            style: GoogleFonts.alexandria(
              color: Colors.black,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  STATS GRID
// ══════════════════════════════════════════════════════════════
class _StatsGrid extends StatelessWidget {
  final int totalPesanan;
  final int menuReady;
  final int diproses;
  final int pesananMasuk;

  const _StatsGrid({
    required this.totalPesanan,
    required this.menuReady,
    required this.diproses,
    required this.pesananMasuk,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatData(
        icon: Icons.receipt_long_rounded,
        label: 'Total Pesanan',
        count: '$totalPesanan',
      ),
      _StatData(
        icon: Icons.restaurant_menu_rounded,
        label: 'Menu Ready',
        count: '$menuReady',
      ),
      _StatData(
        icon: Icons.soup_kitchen_rounded,
        label: 'Pesanan Diproses',
        count: '$diproses',
      ),
      _StatData(
        icon: Icons.inbox_rounded,
        label: 'Pesanan Masuk',
        count: '$pesananMasuk',
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 170 / 55,
      children: items.map((item) => _StatCard(item: item)).toList(),
    );
  }
}

class _StatData {
  final IconData icon;
  final String label;
  final String count;
  const _StatData(
      {required this.icon, required this.label, required this.count});
}

class _StatCard extends StatelessWidget {
  final _StatData item;
  const _StatCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: _shadowDefault,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD05122), Color(0xFFEE8B2E)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(item.icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.label,
                  style: GoogleFonts.alexandria(
                    color: const Color(0xFF1A1919),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      item.count,
                      style: GoogleFonts.alexandria(
                        color: const Color(0xFFD05122),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      item.label == 'Menu Ready' ? 'Menu' : 'Pesanan',
                      style: GoogleFonts.alice(
                        color: const Color(0xFF1A1919),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  SALES CHART — fl_chart (LineChart)
// ══════════════════════════════════════════════════════════════
class _SalesChart extends StatelessWidget {
  final List grafik;
  final String Function(double) formatRupiah;

  const _SalesChart({required this.grafik, required this.formatRupiah});

  @override
  Widget build(BuildContext context) {
    if (grafik.isEmpty) {
      return Container(
        height: 160,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Text('Belum ada data grafik',
            style: GoogleFonts.alexandria(
                color: Colors.grey, fontSize: 13)),
      );
    }

    // Ambil hanya hari yang ada pesanan (jumlah_pesanan > 0)
    final spots = <FlSpot>[];
    double maxY = 0;
    for (final row in grafik) {
      final hari  = (row['hari']           as num).toDouble();
      final total = (row['jumlah_pesanan'] as num).toDouble();
      spots.add(FlSpot(hari, total));
      if (total > maxY) maxY = total;
    }
    if (maxY == 0) maxY = 5;

    return Container(
      width: double.infinity,
      height: 180,
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: _shadowDefault,
      ),
      child: LineChart(
        LineChartData(
          minX: 1,
          maxX: grafik.length.toDouble(),
          minY: 0,
          maxY: maxY + 2,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: Colors.grey.shade200,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: maxY > 4 ? (maxY / 4).ceilToDouble() : 1,
                getTitlesWidget: (val, _) => Text(
                  val.toInt().toString(),
                  style: GoogleFonts.alexandria(
                      fontSize: 9, color: Colors.grey),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                interval: grafik.length > 20 ? 5 : 3,
                getTitlesWidget: (val, _) => Text(
                  val.toInt().toString(),
                  style: GoogleFonts.alexandria(
                      fontSize: 9, color: Colors.grey),
                ),
              ),
            ),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: const Color(0xFFD05122),
              barWidth: 2.5,
              dotData: FlDotData(
                show: true,
                getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                  radius: 3,
                  color: const Color(0xFFD05122),
                  strokeColor: Colors.white,
                  strokeWidth: 1.5,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFEE8B2E).withOpacity(0.25),
                    const Color(0xFFD05122).withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => spots.map((s) {
                return LineTooltipItem(
                  'Hari ${s.x.toInt()}\n${s.y.toInt()} pesanan',
                  GoogleFonts.alexandria(
                      color: Colors.white, fontSize: 11),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  MENU ITEM CARD
// ══════════════════════════════════════════════════════════════
class _MenuItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final String Function(double) formatRupiah;

  const _MenuItemCard(
      {required this.item, required this.formatRupiah});

  String get _imageUrl {
    final foto = item['foto']?.toString() ?? '';
    if (foto.isEmpty) return '';
    // Sesuaikan base URL dengan server kamu
    return 'http://10.0.2.2/dapur_bu_mon/uploads/menu/$foto';
  }

  @override
  Widget build(BuildContext context) {
    final nama         = item['nama']?.toString()        ?? '-';
    final harga        = (item['harga'] as num?)?.toDouble() ?? 0;
    final totalTerjual = (item['total_terjual'] as num?)?.toInt() ?? 0;

    return Container(
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
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          // Gambar menu
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: const Color(0xFFF79F36),
              borderRadius: BorderRadius.circular(5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: _imageUrl.isNotEmpty
                  ? Image.network(
                      _imageUrl,
                      width: 65,
                      height: 65,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama,
                  style: GoogleFonts.alexandria(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  formatRupiah(harga),
                  style: GoogleFonts.alexandria(
                    color: const Color(0xFFDC6727),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${totalTerjual}x',
                style: GoogleFonts.alexandria(
                  color: const Color(0xFFD05122),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Terjual',
                style: GoogleFonts.alexandria(
                  color: Colors.grey,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
        color: const Color(0xFFF79F36),
        child: const Icon(Icons.fastfood_rounded,
            color: Colors.white, size: 32),
      );
}