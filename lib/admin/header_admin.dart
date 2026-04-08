import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:catering_dapur_bu_mon/page/mulai.dart';

class HeaderAdmin extends StatelessWidget {
  const HeaderAdmin({super.key});

  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const Mulai()),
      (route) => false,
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
          // ✅ Notifikasi
          Image.network(
            'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SONxcLGhX9Sc4jqH3qj%2Fd154b179abf9d4a6058e12e77678299644c82914Notification.png?alt=media&token=b1c8e70d-f4d6-447c-bb57-5cc8f38783ef',
            width: 25,
            height: 25,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 12),
          // ✅ Logo pintu — klik untuk logout ke Mulai
          GestureDetector(
            onTap: () => _logout(context),
            child: Image.network(
              'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SONxcLGhX9Sc4jqH3qj%2Ffcef66b1-c3f8-4048-86cf-8a67ffaacf4f.png',
              width: 20,
              height: 24,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}