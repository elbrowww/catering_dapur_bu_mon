import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:catering_dapur_bu_mon/features/auth/verifikasi_kode.dart';
import 'package:catering_dapur_bu_mon/services/api_service.dart';

class LupaPasswordPage extends StatefulWidget {
  const LupaPasswordPage({super.key});

  @override
  State<LupaPasswordPage> createState() => _LupaPasswordPageState();
}

class _LupaPasswordPageState extends State<LupaPasswordPage> {
  final TextEditingController _noTelpController =
      TextEditingController();

  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight =
        MediaQuery.of(context).padding.top;

    final double screenWidth =
        MediaQuery.of(context).size.width;

    final double screenHeight =
        MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFAC3715),
              Color(0xFFD05122),
              Color(0xFFEE8B2E),
            ],
            stops: [0.21, 0.56, 0.83],
          ),
        ),
        child: Stack(
          children: [

            // PANEL PUTIH
            Positioned(
              left: 0,
              top: statusBarHeight + 251,
              child: Container(
                width: screenWidth,
                height: screenHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(46),
                ),
              ),
            ),

            // ICON GEMBOK
            Positioned(
              left: screenWidth * 0.313,
              top: statusBarHeight + 30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(75),
                ),
                child: const Icon(
                  Icons.lock_reset,
                  size: 80,
                  color: Color(0xFFD05122),
                ),
              ),
            ),

            // JUDUL
            Positioned(
              left: 0,
              right: 0,
              top: statusBarHeight + 194,
              child: Text(
                'Lupa Password',
                textAlign: TextAlign.center,
                style: GoogleFonts.alexandria(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // SUBTITLE
            Positioned(
              left: screenWidth * 0.08,
              right: screenWidth * 0.08,
              top: statusBarHeight + 222,
              child: Text(
                'Masukkan nomor WhatsApp untuk menerima kode OTP',
                textAlign: TextAlign.center,
                style: GoogleFonts.alexandria(
                  color: Colors.black,
                  fontSize: 12,
                ),
              ),
            ),

            // STEP
            Positioned(
              left: screenWidth * 0.15,
              right: screenWidth * 0.15,
              top: statusBarHeight + 280,
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFCE0A),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        '1',
                        style: GoogleFonts.alexandria(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: Container(
                      height: 2,
                      color: Colors.grey.shade300,
                    ),
                  ),

                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F4EE),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        '2',
                        style: GoogleFonts.alexandria(
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: Container(
                      height: 2,
                      color: Colors.grey.shade300,
                    ),
                  ),

                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F4EE),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        '3',
                        style: GoogleFonts.alexandria(
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // LABEL STEP
            Positioned(
              left: 0,
              right: 0,
              top: statusBarHeight + 328,
              child: Text(
                'Langkah 1 dari 3',
                textAlign: TextAlign.center,
                style: GoogleFonts.alexandria(
                  color: Colors.black.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ),

            // DESKRIPSI
            Positioned(
              left: screenWidth * 0.1,
              right: screenWidth * 0.1,
              top: statusBarHeight + 360,
              child: Text(
                'Kode OTP akan dikirim melalui WhatsApp',
                textAlign: TextAlign.center,
                style: GoogleFonts.alexandria(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // INPUT NOMOR HP
            Positioned(
              left: screenWidth * 0.1,
              right: screenWidth * 0.1,
              top: statusBarHeight + 430,
              child: TextField(
                controller: _noTelpController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Masukkan nomor WhatsApp',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

            // BUTTON KIRIM OTP
            Positioned(
              left: screenWidth * 0.144,
              right: screenWidth * 0.144,
              top: statusBarHeight + 560,
              child: GestureDetector(
                onTap: () async {

                  if (_noTelpController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Nomor HP wajib diisi'),
                      ),
                    );
                    return;
                  }

                  try {
                    setState(() => _loading = true);

                    await ApiService.forgotPassword(
                      phone:
                          _noTelpController.text.trim(),
                    );

                    if (!mounted) return;

                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content:
                            Text('OTP berhasil dikirim'),
                      ),
                    );

                    Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => VerifikasiKodePage(
      metode: 'telp',
      noTelp: _noTelpController.text.trim(),
    ),
  ),
);

                  } catch (e) {

                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                      ),
                    );

                  } finally {

                    if (mounted) {
                      setState(
                          () => _loading = false);
                    }
                  }
                },
                child: Container(
                  height: 47,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(18),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFD05122),
                        Color(0xFFEE8B2E),
                        Color(0xFFFBA839),
                      ],
                    ),
                  ),
                  child: Center(
                    child: _loading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Text(
                            'Kirim Kode Verifikasi',
                            style:
                                GoogleFonts.alexandria(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                          ),
                  ),
                ),
              ),
            ),

            // BUTTON BATAL
            Positioned(
              left: screenWidth * 0.144,
              right: screenWidth * 0.144,
              top: statusBarHeight + 625,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 47,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(18),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFAC3715),
                        Color(0xFFD05122),
                        Color(0xFFAC3715),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Batal',
                      style: GoogleFonts.alexandria(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
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