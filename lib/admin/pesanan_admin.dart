import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'header_admin.dart'; // ✅

const _gradientColors = [
  Color(0xFFD05122),
  Color(0xFFEE8B2E),
  Color(0xFFFBA839),
];
const _gradientStops = [0.17, 0.47, 0.60];
const _borderOrange = Color(0xFFDB6626);

const _cardShadow = [
  BoxShadow(
    color: Color(0x3F000000),
    spreadRadius: 0,
    offset: Offset(0, 4),
    blurRadius: 4,
  ),
];

const _listShadow = [
  BoxShadow(
    color: Color(0x3F000000),
    spreadRadius: 3,
    offset: Offset(0, 1.7),
    blurRadius: 3,
  ),
];

enum OrderStatus { pending, proses, selesai, batal }

class _OrderItem {
  final String customerName;
  final String address;
  final String amount;
  final String date;
  final String itemCount;
  final OrderStatus status;

  const _OrderItem({
    required this.customerName,
    required this.address,
    required this.amount,
    required this.date,
    required this.itemCount,
    required this.status,
  });
}

const _statCards = [
  {'label': 'Total Pesanan', 'value': '17'},
  {'label': 'Pending', 'value': '3'},
  {'label': 'Batal', 'value': '8'},
  {'label': 'Selesai', 'value': '911'},
];

const _orders = [
  _OrderItem(
    customerName: 'Linswel',
    address: 'Ds Rompal, Kec Mrempul',
    amount: '250.000',
    date: '📅 05/03/2026 08:48',
    itemCount: '1 Item',
    status: OrderStatus.pending,
  ),
  _OrderItem(
    customerName: 'Linswel',
    address: 'Ds Rompal, Kec Mrempul',
    amount: '250.000',
    date: '📅 05/03/2026 08:48',
    itemCount: '1 Item',
    status: OrderStatus.selesai,
  ),
  _OrderItem(
    customerName: 'Linswel',
    address: '',
    amount: '250.000',
    date: '📅 05/03/2026 08:48',
    itemCount: '',
    status: OrderStatus.pending,
  ),
];

const _filterLabels = ['Semua', 'Pending', 'Proses', 'Selesai', 'Batal'];

class PesananAdminPage extends StatefulWidget {
  const PesananAdminPage({super.key});

  @override
  State<PesananAdminPage> createState() => _PesananAdminPageState();
}

class _PesananAdminPageState extends State<PesananAdminPage> {
  int _selectedFilter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const HeaderAdmin(), // ✅
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StatsCard(),
                    const SizedBox(height: 20),
                    Text(
                      'Daftar Pesanan',
                      style: GoogleFonts.alexandria(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _FilterRow(
                      selected: _selectedFilter,
                      onSelected: (i) => setState(() => _selectedFilter = i),
                    ),
                    const SizedBox(height: 12),
                    ..._orders.map((order) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _OrderCard(order: order),
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

class _StatsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: _cardShadow,
        gradient: const LinearGradient(
          colors: _gradientColors,
          stops: _gradientStops,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.network(
                'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SONxcLGhX9Sc4jqH3qj%2Fa3d8a44b-5926-4100-a7cc-2ee17e3d4cf7.png',
                width: 24,
                height: 22,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 8),
              Text(
                'Pesanan',
                style: GoogleFonts.alexandria(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(width: 1.5),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    Text(
                      '📅 Semua Waktu',
                      style: GoogleFonts.lora(
                        color: Colors.black,
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Image.network(
                      'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SONxcLGhX9Sc4jqH3qj%2F9d4baca5-5ab4-4807-8d44-cd09f6737510.png',
                      width: 11,
                      height: 6,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
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
            children: _statCards
                .map((s) => _MiniStatCard(
                      label: s['label']!,
                      value: s['value']!,
                    ))
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
        boxShadow: _cardShadow,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.alexandria(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.alexandria(
              color: Colors.black,
              fontSize: 35,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

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
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: i == selected
                      ? const Color(0xFFEE8B2E)
                      : Colors.transparent,
                  border: Border.all(width: 1.5, color: _borderOrange),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(
                  _filterLabels[i],
                  style: GoogleFonts.lora(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: i == selected
                        ? FontWeight.bold
                        : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final _OrderItem order;
  const _OrderCard({required this.order});

  Color get _statusColor {
    switch (order.status) {
      case OrderStatus.pending:
        return const Color(0xFF92A098);
      case OrderStatus.proses:
        return const Color(0xFFEE8B2E);
      case OrderStatus.selesai:
        return const Color(0xFF0FBC5F);
      case OrderStatus.batal:
        return const Color(0xFFE74C3C);
    }
  }

  String get _statusLabel {
    switch (order.status) {
      case OrderStatus.pending: return 'Pending';
      case OrderStatus.proses:  return 'Proses';
      case OrderStatus.selesai: return 'Selesai';
      case OrderStatus.batal:   return 'Batal';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        boxShadow: _listShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.customerName,
                style: GoogleFonts.alexandria(
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusColor,
                  border: Border.all(width: 1.5, color: _borderOrange),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(
                  _statusLabel,
                  style: GoogleFonts.lora(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (order.address.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              order.address,
              style: GoogleFonts.alexandria(
                color: Colors.black,
                fontSize: 10,
              ),
            ),
          ],
          const SizedBox(height: 6),
          Row(
            children: [
              _Chip(label: order.date),
              if (order.itemCount.isNotEmpty) ...[
                const SizedBox(width: 8),
                _Chip(label: order.itemCount),
              ],
              const Spacer(),
              Text(
                order.amount,
                style: GoogleFonts.alexandria(
                  color: Colors.black,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _Chip(
            label: 'Detail',
            backgroundColor: const Color(0xFFA7ECFF),
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final FontWeight fontWeight;
  final double fontSize;

  const _Chip({
    required this.label,
    this.backgroundColor,
    this.fontWeight = FontWeight.w500,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        border: Border.all(width: 1.3, color: _borderOrange),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(
        label,
        style: GoogleFonts.lora(
          color: Colors.black,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
    );
  }
}