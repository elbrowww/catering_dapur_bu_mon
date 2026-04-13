import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:catering_dapur_bu_mon/page/mulai.dart';

class HeaderAdmin extends StatelessWidget {
  const HeaderAdmin({super.key});

  void _konfirmasiLogout(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: _LogoutDialog(
          onYa: () {
            Navigator.pop(context); // tutup dialog
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const Mulai()),
              (route) => false,
            );
          },
          onTidak: () => Navigator.pop(context), // tutup dialog saja
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
          // Notifikasi
          Image.network(
            'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SONxcLGhX9Sc4jqH3qj%2Fd154b179abf9d4a6058e12e77678299644c82914Notification.png?alt=media&token=b1c8e70d-f4d6-447c-bb57-5cc8f38783ef',
            width: 25,
            height: 25,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 12),
          // Logo pintu → tampilkan popup logout
          GestureDetector(
            onTap: () => _konfirmasiLogout(context),
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

// ── Dialog Logout ─────────────────────────────────────────────
class _LogoutDialog extends StatelessWidget {
  final VoidCallback onYa;
  final VoidCallback onTidak;

  const _LogoutDialog({
    required this.onYa,
    required this.onTidak,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      height: 320,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background putih
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),

          // Header oranye
          Positioned(
            left: 0,
            top: 0,
            right: 0,
            child: Container(
              height: 57,
              decoration: const BoxDecoration(
                color: Color(0xFFE8891A),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
              ),
              child: Center(
                child: Text(
                  'LOG OUT',
                  style: GoogleFonts.alexandria(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Ikon warning
          Positioned(
            left: 115,
            top: 82,
            child: Image.network(
              'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SMpkHR7SLEvor999HjP%2F5caf00cadf9098c502dbfb760ef03f80e756b367warning-sign%201.png?alt=media&token=29e8863e-989a-4160-ad3f-7ecc6221de42',
              width: 90,
              height: 90,
              fit: BoxFit.cover,
            ),
          ),

          // Teks konfirmasi
          Positioned(
            left: 47,
            top: 184,
            child: SizedBox(
              width: 226,
              height: 50,
              child: Text(
                'Yakin ingin logout dari halaman admin?',
                textAlign: TextAlign.center,
                style: GoogleFonts.lora(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          // Tombol Tidak
          Positioned(
            left: 23,
            top: 258,
            child: GestureDetector(
              onTap: onTidak,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SMpkHR7SLEvor999HjP%2F2bcbecc0-f930-4ece-b426-5929fe193f63.png',
                      width: 130,
                      height: 40,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Text(
                    'Tidak',
                    style: GoogleFonts.alexandria(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tombol Ya
          Positioned(
            left: 167,
            top: 258,
            child: GestureDetector(
              onTap: onYa,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SMpkHR7SLEvor999HjP%2F1022fa5b-9e1d-40b0-bf04-c509f9e8daa3.png',
                      width: 130,
                      height: 40,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Text(
                    'Ya',
                    style: GoogleFonts.alexandria(
                      color: Colors.white,
                      fontSize: 14,
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
}