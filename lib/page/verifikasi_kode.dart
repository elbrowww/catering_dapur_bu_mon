import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'buat_password_baru.dart'; // ← langkah 3 (nanti dibuat)

class VerifikasiKodePage extends StatefulWidget {
  final String metode; // 'telp' atau 'email'
  const VerifikasiKodePage({super.key, required this.metode});

  @override
  State<VerifikasiKodePage> createState() => _VerifikasiKodePageState();
}

class _VerifikasiKodePageState extends State<VerifikasiKodePage> {
  // ── 6 controller untuk 6 kotak OTP ────────────────────────
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(6, (_) => FocusNode());

  // ── Timer countdown ────────────────────────────────────────
  int _secondsLeft = 299; // 4 menit 59 detik
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        timer.cancel();
      }
    });
  }

  String get _timerText {
    final m = (_secondsLeft ~/ 60).toString().padLeft(1, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m.$s';
  }

  void _verifikasi() {
    final kode = _controllers.map((c) => c.text).join();
    if (kode.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Masukkan 6 digit kode OTP!',
            style: GoogleFonts.alexandria(color: Colors.white),
          ),
          backgroundColor: const Color(0xFFD05122),
        ),
      );
      return;
    }
    // ← navigasi ke langkah 3
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BuatPasswordBaruPage()),
    );
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        clipBehavior: Clip.hardEdge,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFAC3715), Color(0xFFD05122), Color(0xFFEE8B2E)],
            stops: [0.21, 0.56, 0.83],
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          child: Stack(
            clipBehavior: Clip.none,
            children: [

              /// Panel putih bawah
              Positioned(
                left: 0,
                top: statusBarHeight + 251,
                child: Container(
                  width: screenWidth,
                  height: screenHeight,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(46),
                  ),
                ),
              ),

              /// Ikon gembok
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
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 15,
                        top: 15,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(46),
                          clipBehavior: Clip.hardEdge,
                          child: SizedBox.square(
                            dimension: 120,
                            child: Stack(
                              children: [
                                Positioned(
                                  left: 8,
                                  top: 8,
                                  width: 120,
                                  height: 120,
                                  child: Image.network(
                                    'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SMpkHR7SLEvor999HjP%2Fd9a301e2d64a9171618781d7bcf96f3b5983ca8fpadlock%201.png?alt=media&token=eb230f17-8780-4501-9022-120425e8be3f',
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.none,
                                    scale: 4.267,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// Judul "Lupa Password"
              Positioned(
                left: 0,
                right: 0,
                top: statusBarHeight + 10,
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

              /// Sub judul
              Positioned(
                left: screenWidth * 0.097,
                right: screenWidth * 0.097,
                top: statusBarHeight + 36,
                child: Text(
                  'Ikuti Langkah Untuk membuat Password Baru',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.alexandria(
                    color: Colors.black,
                    fontSize: 12,
                  ),
                ),
              ),

              /// "Ubah Password" di panel putih
              Positioned(
                left: 0,
                right: 0,
                top: statusBarHeight + 270,
                child: Text(
                  'Ubah Password',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.alexandria(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              /// Indikator langkah (1, 2, 3)
              Positioned(
                left: screenWidth * 0.15,
                right: screenWidth * 0.15,
                top: statusBarHeight + 300,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Step 1 (sudah selesai - abu)
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F4EE),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          '1',
                          style: GoogleFonts.alexandria(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    // Garis
                    Expanded(
                      child: Container(height: 2, color: Colors.grey.shade300),
                    ),
                    // Step 2 (aktif - kuning)
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFCE0A),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          '2',
                          style: GoogleFonts.alexandria(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // Garis
                    Expanded(
                      child: Container(height: 2, color: Colors.grey.shade300),
                    ),
                    // Step 3
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F4EE),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          '3',
                          style: GoogleFonts.alexandria(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// Label langkah
              Positioned(
                left: 0,
                right: 0,
                top: statusBarHeight + 360,
                child: Opacity(
                  opacity: 0.8,
                  child: Text(
                    'Langkah 2 dari 3 — Kode OTP',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.alexandria(
                      color: Colors.black,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),

              /// Deskripsi
              Positioned(
                left: screenWidth * 0.107,
                right: screenWidth * 0.107,
                top: statusBarHeight + 382,
                child: Text(
                  'Kode 6-digit telah dikirim ke ${widget.metode == 'telp' ? 'No Telp kamu 0821*******' : 'Email kamu'}. Masukkan dalam 5 menit.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.alexandria(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              /// 6 Kotak OTP
              Positioned(
                left: screenWidth * 0.1,
                right: screenWidth * 0.1,
                top: statusBarHeight + 450,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (i) {
                    return Container(
                      width: 42,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x3F000000),
                            spreadRadius: 0,
                            offset: Offset(0, 4),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _controllers[i],
                        focusNode: _focusNodes[i],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: GoogleFonts.alexandria(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (val) {
                          if (val.isNotEmpty && i < 5) {
                            FocusScope.of(context)
                                .requestFocus(_focusNodes[i + 1]);
                          } else if (val.isEmpty && i > 0) {
                            FocusScope.of(context)
                                .requestFocus(_focusNodes[i - 1]);
                          }
                        },
                      ),
                    );
                  }),
                ),
              ),

              /// Timer countdown
              Positioned(
                left: 0,
                right: 0,
                top: statusBarHeight + 518,
                child: Opacity(
                  opacity: 0.8,
                  child: Text(
                    _secondsLeft > 0
                        ? 'Kirim ulang dalam $_timerText'
                        : 'Kode sudah kadaluarsa',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.alexandria(
                      color: Colors.black,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),

              /// Kirim ulang (muncul kalau timer habis)
              if (_secondsLeft == 0)
                Positioned(
                  left: 0,
                  right: 0,
                  top: statusBarHeight + 540,
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _secondsLeft = 299);
                      _startTimer();
                    },
                    child: Text(
                      'Kirim Ulang Kode',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.alexandria(
                        color: const Color(0xFFD05122),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        decorationColor: const Color(0xFFD05122),
                      ),
                    ),
                  ),
                ),

              /// Tombol Verifikasi Kode
              Positioned(
                left: screenWidth * 0.144,
                right: screenWidth * 0.144,
                top: statusBarHeight + 580,
                child: GestureDetector(
                  onTap: _verifikasi,
                  child: Container(
                    height: 47,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x3F000000),
                          spreadRadius: 3,
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFD05122),
                          Color(0xFFEE8B2E),
                          Color(0xFFFBA839),
                        ],
                        stops: [0.17, 0.47, 0.60],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Verifikasi Kode',
                        style: GoogleFonts.alexandria(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              /// Tombol Batal
              Positioned(
                left: screenWidth * 0.144,
                right: screenWidth * 0.144,
                top: statusBarHeight + 640,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 47,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x3F000000),
                          spreadRadius: 3,
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFAC3715),
                          Color(0xFFD05122),
                          Color(0xFFAC3715),
                        ],
                        stops: [0.17, 0.43, 0.61],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Batal',
                        style: GoogleFonts.alexandria(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
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