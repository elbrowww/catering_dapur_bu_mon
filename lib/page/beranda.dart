import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ============================================================
// BERANDA PAGE
// PENTING: Tidak pakai Scaffold & tidak pakai CustomNavbar
// Navbar sudah dihandle oleh MainScreen di main.dart
// ============================================================
class BerandaPage extends StatelessWidget {
  const BerandaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header oranye ──────────────────────────────
            _HeaderBanner(),
            const SizedBox(height: 16),

            // ── Search bar ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SearchBar(),
            ),
            const SizedBox(height: 24),

            // ── Tracking Pesanan ───────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SectionTitle('Tracking Pesanan'),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _TrackingCard(),
            ),
            const SizedBox(height: 24),

            // ── Menu Terlaris ──────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SectionTitle('Menu Terlaris'),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 5,
                itemBuilder: (_, i) => const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: _MenuTerlarisCard(
                    nama: 'Ayam Panggang',
                    harga: 'Rp 120.000',
                    rating: '5.0',
                    terjual: '50 Terjual',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Menu Tersedia ──────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SectionTitle('Menu Tersedia'),
                  Text(
                    'Lihat semua',
                    style: GoogleFonts.alexandria(
                      color: Colors.black54,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: 6,
              itemBuilder: (_, i) => const _MenuGridCard(
                nama: 'Ayam Panggang',
                harga: 'Rp 120.000',
              ),
            ),
            const SizedBox(height: 24),

            // ── Ulasan ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SectionTitle('Ulasan'),
                  Text(
                    'Lihat semua',
                    style: GoogleFonts.alexandria(
                      color: Colors.black54,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _UlasanCard(
                username: 'Username',
                tanggal: '15 Maret 2026',
                isi: 'Rasanya Mantap, Ga pernah Gagal! Rekomen banget buat yang mau makan enak.',
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _UlasanCard(
                username: 'Username',
                tanggal: '10 Maret 2026',
                isi: 'Pelayanan cepat dan makanannya lezat. Pasti balik lagi!',
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── Widgets Beranda ────────────────────────────────────────────

class _HeaderBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 130,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-0.04, 0.80),
          end: Alignment(0.98, -0.49),
          colors: [Color(0xFFEE8B2E), Color(0xFFD05122), Color(0xFFAC3715)],
        ),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.white, size: 22),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Jl. Asbdhainjshnsjaian',
              style: GoogleFonts.lora(
                color: const Color(0xFFFFF8EF),
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFD05122),
                  Color(0xFFEE8B2E),
                  Color(0xFFFBA839),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.search, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Mau Menu apa hari ini?',
              style: GoogleFonts.lora(
                color: const Color(0xFF1A1818),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _SectionTitle(String title) {
  return Text(
    title,
    style: GoogleFonts.alexandria(
      color: const Color(0xFF1A1818),
      fontSize: 16,
      fontWeight: FontWeight.w700,
    ),
  );
}

class _TrackingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment(0.65, 1.06),
          end: Alignment(0.47, -0.19),
          colors: [Color(0xFFD05122), Color(0xFFEE8B2E), Color(0xFFFBA839)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.fastfood, color: Colors.white, size: 40),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _InfoRow(label: 'Nama Menu', value: 'Ayam Panggang'),
                SizedBox(height: 4),
                _InfoRow(label: 'Status Pesanan', value: 'Di Proses'),
                SizedBox(height: 4),
                _InfoRow(label: 'Estimasi Pengerjaan', value: '2 Jam'),
              ],
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 40),
              Text(
                'Lihat Detail',
                style: GoogleFonts.alexandria(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.alexandria(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.alexandria(
            color: Colors.white.withOpacity(0.75),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _MenuTerlarisCard extends StatelessWidget {
  final String nama, harga, rating, terjual;
  const _MenuTerlarisCard({
    required this.nama,
    required this.harga,
    required this.rating,
    required this.terjual,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 155,
            decoration: BoxDecoration(
              color: const Color(0xFFF79F36),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.fastfood, size: 60, color: Colors.white),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            nama,
            style: GoogleFonts.alexandria(
              color: const Color(0xFF1A1818),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            children: [
              const Icon(Icons.star, size: 12, color: Color(0xFFF79F36)),
              const SizedBox(width: 2),
              Text(
                rating,
                style: GoogleFonts.alexandria(
                  color: const Color(0xFF1A1818),
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                terjual,
                style: GoogleFonts.alexandria(
                  color: Colors.grey,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          Text(
            harga,
            style: GoogleFonts.alexandria(
              color: const Color(0xFFD05122),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuGridCard extends StatelessWidget {
  final String nama, harga;
  const _MenuGridCard({required this.nama, required this.harga});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFF79F36),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.fastfood, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 6),
          Text(
            nama,
            textAlign: TextAlign.center,
            style: GoogleFonts.alexandria(
              color: const Color(0xFF1A1818),
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            harga,
            style: GoogleFonts.alexandria(
              color: const Color(0xFFD05122),
              fontSize: 8,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _UlasanCard extends StatelessWidget {
  final String username, tanggal, isi;
  const _UlasanCard({
    required this.username,
    required this.tanggal,
    required this.isi,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE6E4E4),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.person, color: Color(0xFFD05122), size: 26),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      username,
                      style: GoogleFonts.alexandria(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      tanggal,
                      style: GoogleFonts.alexandria(
                        color: Colors.black54,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isi,
                  style: GoogleFonts.alexandria(
                    color: Colors.black87,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}