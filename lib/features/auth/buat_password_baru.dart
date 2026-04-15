import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:catering_dapur_bu_mon/features/auth/login.dart'; // ← setelah berhasil, kembali ke login

class BuatPasswordBaruPage extends StatefulWidget {
  const BuatPasswordBaruPage({super.key});

  @override
  State<BuatPasswordBaruPage> createState() => _BuatPasswordBaruPageState();
}

class _BuatPasswordBaruPageState extends State<BuatPasswordBaruPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _konfirmasiController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureKonfirmasi = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _konfirmasiController.dispose();
    super.dispose();
  }

  void _buatPasswordBaru() {
    final password = _passwordController.text.trim();
    final konfirmasi = _konfirmasiController.text.trim();

    if (password.isEmpty || konfirmasi.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Semua kolom harus diisi!',
            style: GoogleFonts.alexandria(color: Colors.white),
          ),
          backgroundColor: const Color(0xFFD05122),
        ),
      );
      return;
    }

    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Password minimal 8 karakter!',
            style: GoogleFonts.alexandria(color: Colors.white),
          ),
          backgroundColor: const Color(0xFFD05122),
        ),
      );
      return;
    }

    if (password != konfirmasi) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Password tidak cocok!',
            style: GoogleFonts.alexandria(color: Colors.white),
          ),
          backgroundColor: const Color(0xFFD05122),
        ),
      );
      return;
    }

    // Berhasil → kembali ke login
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Password berhasil diubah!',
          style: GoogleFonts.alexandria(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const Login()),
      (route) => false,
    );
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
                                    'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SMpkHR7SLEvor999HjP%2Fd9a301e2d64a9171618781d7bcf96f3b5983ca8fpadlock%201.png?alt=media&token=cee5584c-673b-44d5-aa33-e0292fbb28c8',
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
                    // Step 1 (selesai - abu)
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
                    // Step 2 (selesai - abu)
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F4EE),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          '2',
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
                    // Step 3 (aktif - kuning)
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFCE0A),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          '3',
                          style: GoogleFonts.alexandria(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
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
                    'Langkah 3 dari 3 — Password Baru',
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
                left: screenWidth * 0.1,
                right: screenWidth * 0.1,
                top: statusBarHeight + 382,
                child: Text(
                  'Buat kata sandi baru yang\nkuat untuk akun kamu.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.alexandria(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              /// Label Password Baru
              Positioned(
                left: screenWidth * 0.142,
                top: statusBarHeight + 450,
                child: Text(
                  'Masukkan Password Baru',
                  style: GoogleFonts.alexandria(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              ),

              /// Input Password Baru
              Positioned(
                left: screenWidth * 0.142,
                top: statusBarHeight + 474,
                child: Container(
                  width: screenWidth * 0.714,
                  height: 48,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x3F000000),
                        spreadRadius: 3,
                        offset: Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textAlignVertical: TextAlignVertical.center,
                    style: GoogleFonts.alexandria(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Masukkan Password Baru',
                      hintStyle: GoogleFonts.alexandria(
                        color: Colors.black.withOpacity(0.2),
                        fontSize: 15,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      border: InputBorder.none,
                      suffixIcon: GestureDetector(
                        onTap: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                        child: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.black26,
                          size: 18,
                        ),
                      ),
                      suffixIconConstraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 48,
                      ),
                    ),
                  ),
                ),
              ),

              /// Label Konfirmasi Password Baru
              Positioned(
                left: screenWidth * 0.142,
                top: statusBarHeight + 538,
                child: Text(
                  'Konfirmasi Password Baru',
                  style: GoogleFonts.alexandria(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              ),

              /// Input Konfirmasi Password Baru
              Positioned(
                left: screenWidth * 0.142,
                top: statusBarHeight + 562,
                child: Container(
                  width: screenWidth * 0.714,
                  height: 48,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x3F000000),
                        spreadRadius: 3,
                        offset: Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _konfirmasiController,
                    obscureText: _obscureKonfirmasi,
                    textAlignVertical: TextAlignVertical.center,
                    style: GoogleFonts.alexandria(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Konfirmasi Password Baru',
                      hintStyle: GoogleFonts.alexandria(
                        color: Colors.black.withOpacity(0.2),
                        fontSize: 15,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      border: InputBorder.none,
                      suffixIcon: GestureDetector(
                        onTap: () => setState(
                            () => _obscureKonfirmasi = !_obscureKonfirmasi),
                        child: Icon(
                          _obscureKonfirmasi
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.black26,
                          size: 18,
                        ),
                      ),
                      suffixIconConstraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 48,
                      ),
                    ),
                  ),
                ),
              ),

              /// Tips password
              Positioned(
                left: screenWidth * 0.1,
                right: screenWidth * 0.1,
                top: statusBarHeight + 626,
                child: Opacity(
                  opacity: 0.8,
                  child: Text(
                    '✅ Minimal 8 karakter  ·  ✅ Gunakan huruf & angka  ·  ✅ Hindari password lama',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.alexandria(
                      color: Colors.black,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),

              /// Tombol Buat Password Baru
              Positioned(
                left: screenWidth * 0.144,
                right: screenWidth * 0.144,
                top: statusBarHeight + 686,
                child: GestureDetector(
                  onTap: _buatPasswordBaru,
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
                        'Buat Password Baru',
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