import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:catering_dapur_bu_mon/features/beranda/mulai.dart';

class HeaderAdmin extends StatelessWidget {
  const HeaderAdmin({super.key});

  void _konfirmasiLogout(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72, height: 72,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFAC3715),
                      Color(0xFFD05122),
                      Color(0xFFEE8B2E),
                    ],
                    stops: [0.21, 0.56, 0.83],
                  ),
                ),
                child: const Icon(Icons.logout_rounded,
                    color: Colors.white, size: 36),
              ),
              const SizedBox(height: 20),
              Text(
                'Yakin mau Logout?',
                style: GoogleFonts.alexandria(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1818),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Kamu akan keluar dari halaman admin.\nSampai jumpa lagi di Dapur Bu Mon! 👋',
                style: GoogleFonts.alexandria(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.6),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const Mulai()),
                    (route) => false,
                  );
                },
                child: Container(
                  width: double.infinity, height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFD05122),
                        Color(0xFFEE8B2E),
                        Color(0xFFFBA839),
                      ],
                      stops: [0.17, 0.55, 0.85],
                    ),
                  ),
                  child: Center(
                    child: Text('Ya, Logout',
                        style: GoogleFonts.alexandria(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity, height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: const Color(0xFFD05122), width: 1.5),
                    color: Colors.white,
                  ),
                  child: Center(
                    child: Text('Batal',
                        style: GoogleFonts.alexandria(
                          color: const Color(0xFFD05122),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SONxcLGhX9Sc4jqH3qj%2F594b96019dd7bc1bd79b0d47333b044729a2f6f0Desain%20tanpa%20judul%20(16)%204.png?alt=media&token=fbf829f1-1e47-47d7-8021-cb4008a3dd41',
              width: 52,
              height: 52,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Opacity(
                  opacity: 0.8,
                  child: Text(
                    'Dashboard Admin',
                    style: GoogleFonts.alexandria(
                      color: const Color(0xFF1A1818),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  'Dapur Bu Mon',
                  style: GoogleFonts.alexandria(
                    color: const Color(0xFF1A1818),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Tombol logout
          GestureDetector(
            onTap: () => _konfirmasiLogout(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFD05122).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Color(0xFFD05122),
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}