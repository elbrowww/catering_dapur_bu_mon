import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'header_admin.dart'; // ✅

const _gradientColors = [
  Color(0xFFD05122),
  Color(0xFFEE8B2E),
  Color(0xFFFBA839),
];
const _gradientStops = [0.18, 0.61, 0.85];
const _borderOrange = Color(0xFFDB6626);

const _listShadow = [
  BoxShadow(
    color: Color(0x3F000000),
    spreadRadius: 3,
    offset: Offset(0, 1.7),
    blurRadius: 3,
  ),
];

class _MenuData {
  final String name;
  final String price;
  final String imageUrl;

  const _MenuData({
    required this.name,
    required this.price,
    required this.imageUrl,
  });
}

const _imageUrl =
    'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SONxcLGhX9Sc4jqH3qj%2Fb611dcd57e8a8124c09e46eb95298a801a223e17image%203.png?alt=media&token=274a3b20-6268-4ae8-80a1-410fb38711f3';

final _menuList = List.generate(
  7,
  (_) => const _MenuData(
    name: 'Tumpeng',
    price: 'Rp. 250.000',
    imageUrl: _imageUrl,
  ),
);

const _filterLabels = ['Semua', 'Paket Nasi', 'Olahan Ayam', 'Jajanan'];

class KelolaMenuPage extends StatefulWidget {
  const KelolaMenuPage({super.key});

  @override
  State<KelolaMenuPage> createState() => _KelolaMenuPageState();
}

class _KelolaMenuPageState extends State<KelolaMenuPage> {
  int _selectedFilter = 0;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
                    _SearchBar(controller: _searchController),
                    const SizedBox(height: 10),
                    _TambahMenuButton(onTap: () {}),
                    const SizedBox(height: 10),
                    _FilterRow(
                      selected: _selectedFilter,
                      onSelected: (i) => setState(() => _selectedFilter = i),
                    ),
                    const SizedBox(height: 12),
                    ..._menuList.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _MenuItemCard(item: item),
                      ),
                    ),
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

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SONxcLGhX9Sc4jqH3qj%2F1b9c73ec-6782-4b31-808d-6b3269237049.png',
              height: 45,
              fit: BoxFit.contain,
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
              colors: _gradientColors,
              stops: _gradientStops,
            ),
          ),
          child: Center(
            child: Image.network(
              'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SONxcLGhX9Sc4jqH3qj%2F404dc9f9-a237-4b20-bbb2-c805bfaff268.png',
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

class _TambahMenuButton extends StatelessWidget {
  final VoidCallback onTap;
  const _TambahMenuButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFFE8891A),
          borderRadius: BorderRadius.circular(15),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SONxcLGhX9Sc4jqH3qj%2Ffe80fd8b-4116-4353-990c-07e18f6b21b6.png',
              width: 19,
              height: 18,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            Text(
              'TAMBAH MENU',
              style: GoogleFonts.alexandria(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
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

class _MenuItemCard extends StatelessWidget {
  final _MenuData item;
  const _MenuItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        boxShadow: _listShadow,
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
          Column(
            children: [
              _ActionButton(
                color: const Color(0xFFFD4141),
                iconUrl: 'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SONxcLGhX9Sc4jqH3qj%2Fed786f6d-10b1-4bfb-8dc7-658ed3877c73.png',
                onTap: () {},
              ),
              const SizedBox(height: 4),
              _ActionButton(
                color: const Color(0xFF0FBC5F),
                iconUrl: 'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SONxcLGhX9Sc4jqH3qj%2F4201a3cd-540d-4e5f-ade7-22dd16fb4eb1.png',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final Color color;
  final String iconUrl;
  final VoidCallback onTap;

  const _ActionButton({
    required this.color,
    required this.iconUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Opacity(
            opacity: 0.85,
            child: Image.network(
              iconUrl,
              width: 13,
              height: 13,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}