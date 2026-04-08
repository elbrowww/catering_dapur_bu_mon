import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'header_admin.dart'; // ✅

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

class _StatItem {
  final String imageUrl;
  final String label;
  final String count;

  const _StatItem({
    required this.imageUrl,
    required this.label,
    required this.count,
  });
}

class _MenuItem {
  final String imageUrl;
  final String name;
  final String price;
  final String orderCount;

  const _MenuItem({
    required this.imageUrl,
    required this.name,
    required this.price,
    required this.orderCount,
  });
}

const _statItems = [
  _StatItem(
    imageUrl: 'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SONxcLGhX9Sc4jqH3qj%2Ff8c525fa-ed93-4df9-be04-32c52a23f9c2.png',
    label: 'Total Pesanan',
    count: '300',
  ),
  _StatItem(
    imageUrl: 'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SONxcLGhX9Sc4jqH3qj%2Fb9b676eb-0125-45fe-aa14-63414f221fd6.png',
    label: 'Menu Ready',
    count: '300',
  ),
  _StatItem(
    imageUrl: 'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SONxcLGhX9Sc4jqH3qj%2Fc460e23d-1e4a-4e1a-a75d-9c20a1c5c5bf.png',
    label: 'Pesanan Diproses',
    count: '300',
  ),
  _StatItem(
    imageUrl: 'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SONxcLGhX9Sc4jqH3qj%2F1c21c4be-8470-4fab-b337-f6e80fd71212.png',
    label: 'Total Pemesanan',
    count: '300',
  ),
];

const _menuItems = [
  _MenuItem(
    imageUrl: 'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SONxcLGhX9Sc4jqH3qj%2F523acacd6359d74640c5b9f05994ae4793dcf28fimage%206.png?alt=media&token=42837d15-6a84-4f7e-9555-5842157df2d8',
    name: 'Ayam Panggang',
    price: 'Rp. 120.000',
    orderCount: '45x Pesanan',
  ),
  _MenuItem(
    imageUrl: 'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SONxcLGhX9Sc4jqH3qj%2F523acacd6359d74640c5b9f05994ae4793dcf28fimage%206.png?alt=media&token=76cde69a-f9a0-4efe-bbef-2c8bbdfbfb63',
    name: 'Paketan Nasi',
    price: 'Rp. 120.000',
    orderCount: '37x Pesanan',
  ),
  _MenuItem(
    imageUrl: 'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SONxcLGhX9Sc4jqH3qj%2F523acacd6359d74640c5b9f05994ae4793dcf28fimage%206.png?alt=media&token=a4d9d42a-3c51-4659-a950-e7515d7d2d24',
    name: 'Paketan Nasi',
    price: 'Rp. 120.000',
    orderCount: '37x Pesanan',
  ),
];

class DashboardAdmin extends StatelessWidget {
  const DashboardAdmin({super.key});

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
                    const _IncomeCard(),
                    const SizedBox(height: 16),
                    const _StatsGrid(),
                    const SizedBox(height: 16),
                    _sectionTitle('Grafik Penjualan'),
                    const SizedBox(height: 8),
                    const _SalesChart(),
                    const SizedBox(height: 16),
                    _sectionTitle('Paling banyak di Beli'),
                    const SizedBox(height: 8),
                    ..._menuItems.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _MenuItemCard(item: item),
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
}

class _IncomeCard extends StatelessWidget {
  const _IncomeCard();

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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Opacity(
                      opacity: 0.8,
                      child: Text(
                        '22-03-2026',
                        style: GoogleFonts.alexandria(
                          color: const Color(0xFF1A1818),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Image.network(
                      'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SONxcLGhX9Sc4jqH3qj%2F6da7411d-aadd-4489-8787-f0ad6c2b5bed.png',
                      width: 9,
                      height: 5,
                      fit: BoxFit.contain,
                    ),
                  ],
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
            'Rp. 120.000.000',
            style: GoogleFonts.alexandria(
              color: Colors.black,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 170 / 55,
      children: _statItems.map((item) => _StatCard(item: item)).toList(),
    );
  }
}

class _StatCard extends StatelessWidget {
  final _StatItem item;
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
          Image.network(item.imageUrl, width: 25, height: 25, fit: BoxFit.contain),
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
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      item.count,
                      style: GoogleFonts.alexandria(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      'Pesanan',
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

class _SalesChart extends StatelessWidget {
  const _SalesChart();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 156,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        image: const DecorationImage(
          image: NetworkImage(
            'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SONxcLGhX9Sc4jqH3qj%2F3bbce52ac089f632353829edf46e9a218b3a6d94Cuplikan%20layar%202026-03-09%20140026%201.png?alt=media&token=d71a2fc9-cb15-45d2-bb0f-5e656ef9a2c9',
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  final _MenuItem item;
  const _MenuItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
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
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: const Color(0xFFF79F36),
              borderRadius: BorderRadius.circular(5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image.network(
                item.imageUrl,
                width: 65,
                height: 65,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: GoogleFonts.alexandria(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.price,
                  style: GoogleFonts.alexandria(
                    color: const Color(0xFFDC6727),
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Opacity(
            opacity: 0.8,
            child: Text(
              item.orderCount,
              style: GoogleFonts.alexandria(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}