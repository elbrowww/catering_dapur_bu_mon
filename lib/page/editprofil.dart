import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProfilPage extends StatelessWidget {
  const EditProfilPage({super.key});

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
                top: statusBarHeight + 237,
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

              /// Foto profil
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
                        left: 10,
                        top: 10,
                        child: Image.network(
                          'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SMpkHR7SLEvor999HjP%2F988b443c-cf48-42ae-9b9d-4ea1a53dfaa5.png',
                          width: 130,
                          height: 130,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// Ikon edit foto
              Positioned(
                left: screenWidth * 0.572,
                top: statusBarHeight + 144,
                child: Image.network(
                  'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SMpkHR7SLEvor999HjP%2Fc6f7abf4-bbd0-4265-9843-7332090b758c.png',
                  width: 50,
                  height: 50,
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                left: screenWidth * 0.585,
                top: statusBarHeight + 149,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(200),
                  clipBehavior: Clip.hardEdge,
                  child: Image.network(
                    'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SMpkHR7SLEvor999HjP%2Fdbc746d275f5080798ce1a4d831e54481b78d1c4Create%20profile%20-%20empty.png?alt=media&token=d572421f-71e8-4990-b603-9eb3f8d1352b',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              /// Nama pengguna
              Positioned(
                left: screenWidth * 0.184,
                top: statusBarHeight + 195,
                child: Text(
                  'Christoper Colombus',
                  style: GoogleFonts.getFont(
                    'Alexandria',
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              /// Ikon edit nama
              Positioned(
                left: screenWidth * 0.749,
                top: statusBarHeight + 196,
                child: Image.network(
                  'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SMpkHR7SLEvor999HjP%2Fc8432e24-d6e6-4750-9ced-866efb2e7b4e.png',
                  width: 20,
                  height: 20,
                  fit: BoxFit.contain,
                ),
              ),

              /// Label No Telp
              Positioned(
                left: screenWidth * 0.147,
                top: statusBarHeight + 286,
                child: Text(
                  'No Telp',
                  style: GoogleFonts.getFont(
                    'Alexandria',
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),

              /// Input No Telp
              Positioned(
                left: screenWidth * 0.144,
                top: statusBarHeight + 311,
                child: Container(
                  width: screenWidth * 0.714,
                  height: 35,
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
                  child: Row(
                    children: [
                      const SizedBox(width: 11),
                      Expanded(
                        child: Opacity(
                          opacity: 0.5,
                          child: Text(
                            '08123456789',
                            style: GoogleFonts.getFont(
                              'Alexandria',
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      Opacity(
                        opacity: 0.5,
                        child: Image.network(
                          'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SMpkHR7SLEvor999HjP%2F6c33dc80-d572-463a-b3b5-c4d7829cf22e.png',
                          width: 15,
                          height: 15,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),

              /// Label Email
              Positioned(
                left: screenWidth * 0.147,
                top: statusBarHeight + 374,
                child: Text(
                  'Email',
                  style: GoogleFonts.getFont(
                    'Alexandria',
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),

              /// Input Email
              Positioned(
                left: screenWidth * 0.144,
                top: statusBarHeight + 399,
                child: Container(
                  width: screenWidth * 0.714,
                  height: 35,
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
                  child: Row(
                    children: [
                      const SizedBox(width: 11),
                      Expanded(
                        child: Opacity(
                          opacity: 0.5,
                          child: Text(
                            '-',
                            style: GoogleFonts.getFont(
                              'Alexandria',
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      Opacity(
                        opacity: 0.5,
                        child: Image.network(
                          'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SMpkHR7SLEvor999HjP%2F86cb95fe-5de0-4a4e-a4cc-402c92289760.png',
                          width: 15,
                          height: 15,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),

              /// Label Alamat
              Positioned(
                left: screenWidth * 0.147,
                top: statusBarHeight + 468,
                child: Text(
                  'Alamat',
                  style: GoogleFonts.getFont(
                    'Alexandria',
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),

              /// Input Alamat
              Positioned(
                left: screenWidth * 0.144,
                top: statusBarHeight + 493,
                child: Container(
                  width: screenWidth * 0.714,
                  height: 90,
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
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 11,
                        top: 8,
                        child: Opacity(
                          opacity: 0.5,
                          child: Text(
                            'Jalan Asoy, Kelurahan Cibnak',
                            style: GoogleFonts.getFont(
                              'Alexandria',
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Opacity(
                          opacity: 0.5,
                          child: Image.network(
                            'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SMpkHR7SLEvor999HjP%2F17911c14-43ec-45d8-88f1-6ffc73b77fe5.png',
                            width: 15,
                            height: 15,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// Tombol Konfirmasi
              Positioned(
                left: screenWidth * 0.144,
                top: statusBarHeight + 618,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: screenWidth * 0.714,
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
                        'Konfirmasi',
                        style: GoogleFonts.getFont(
                          'Alexandria',
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
                top: statusBarHeight + 679,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: screenWidth * 0.714,
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
                        style: GoogleFonts.getFont(
                          'Alexandria',
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