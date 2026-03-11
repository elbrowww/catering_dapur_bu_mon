import 'package:flutter/material.dart';
import 'login.dart';

class Daftar extends StatefulWidget {
  const Daftar({super.key});

  @override
  State<Daftar> createState() => _DaftarState();
}

class _DaftarState extends State<Daftar> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _konfirmasiController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureKonfirmasi = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _konfirmasiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Container(
            width: 402,
            height: 874,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(0.45, 1.25),
                end: Alignment(0.45, -0.64),
                colors: [const Color(0xFFD05122), const Color(0xFFEE8B2E), const Color(0xFFFBA839)],
              ),
            ),
            child: Stack(
              children: [
                /// Background putih bawah
                Positioned(
                  left: 0,
                  top: 325,
                  child: Container(
                    width: 402,
                    height: 595,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(46),
                      ),
                    ),
                  ),
                ),

                /// Logo
                Positioned(
                  left: 111,
                  top: 70,
                  child: Image.asset(
                    "assets/icons/LOGO BU MON.png",
                    width: 180,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),

                /// Tab Masuk & Daftar
                Positioned(
                  left: 35,
                  top: 347,
                  child: Container(
                    width: 332,
                    height: 53,
                    padding: const EdgeInsets.only(top: 4, left: 3, right: 3, bottom: 3),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFFFF0D8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      shadows: [
                        BoxShadow(
                          color: Color(0x3F000000),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                          spreadRadius: 0,
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        /// Tab Masuk (tidak aktif)
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const Login()),
                              );
                            },
                            child: Center(
                              child: Opacity(
                                opacity: 0.50,
                                child: Text(
                                  'Masuk',
                                  style: TextStyle(
                                    color: const Color(0xFFD9D9D9),
                                    fontSize: 24,
                                    fontFamily: 'Alexandria',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        /// Tab Daftar (aktif)
                        Expanded(
                          child: Container(
                            height: 45.54,
                            decoration: ShapeDecoration(
                              gradient: LinearGradient(
                                begin: Alignment(0.45, 1.25),
                                end: Alignment(0.45, -0.64),
                                colors: [const Color(0xFFD05122), const Color(0xFFEE8B2E), const Color(0xFFFBA839)],
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Daftar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontFamily: 'Alexandria',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                /// Label No Telp / Email
                Positioned(
                  left: 57,
                  top: 437,
                  child: Text(
                    'Masukkan No Telp / Email',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: 'Alexandria',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),

                /// Input No Telp / Email
                Positioned(
                  left: 56.99,
                  top: 458,
                  child: Container(
                    width: 287.01,
                    height: 48,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      shadows: [
                        BoxShadow(
                          color: Color(0x3F000000),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                          spreadRadius: 3,
                        )
                      ],
                    ),
                    child: Center(
                      child: TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontFamily: 'Alexandria',
                        ),
                        decoration: InputDecoration(
                          hintText: 'No Telp / Email',
                          hintStyle: TextStyle(
                            color: Colors.black.withOpacity(0.3),
                            fontSize: 15,
                            fontFamily: 'Alexandria',
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ),
                ),

                /// Label Password
                Positioned(
                  left: 57,
                  top: 511,
                  child: Text(
                    'Masukkan Password',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: 'Alexandria',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),

                /// Input Password
                Positioned(
                  left: 56.99,
                  top: 531,
                  child: Container(
                    width: 287.01,
                    height: 48,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      shadows: [
                        BoxShadow(
                          color: Color(0x3F000000),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                          spreadRadius: 3,
                        )
                      ],
                    ),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontFamily: 'Alexandria',
                      ),
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: TextStyle(
                          color: Colors.black.withOpacity(0.3),
                          fontSize: 15,
                          fontFamily: 'Alexandria',
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        border: InputBorder.none,
                        isDense: false,
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          child: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.black26,
                            size: 18,
                          ),
                        ),
                        suffixIconConstraints: BoxConstraints(
                          minWidth: 36,
                          minHeight: 48,
                        ),
                      ),
                    ),
                  ),
                ),

                /// Label Masukkan Ulang Password
                Positioned(
                  left: 57,
                  top: 582,
                  child: Text(
                    'Masukkan Ulang Password',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: 'Alexandria',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),

                /// Input Konfirmasi Password
                Positioned(
                  left: 56.99,
                  top: 602,
                  child: Container(
                    width: 287.01,
                    height: 48,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      shadows: [
                        BoxShadow(
                          color: Color(0x3F000000),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                          spreadRadius: 3,
                        )
                      ],
                    ),
                    child: TextField(
                      controller: _konfirmasiController,
                      obscureText: _obscureKonfirmasi,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontFamily: 'Alexandria',
                      ),
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: TextStyle(
                          color: Colors.black.withOpacity(0.3),
                          fontSize: 15,
                          fontFamily: 'Alexandria',
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        border: InputBorder.none,
                        isDense: false,
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _obscureKonfirmasi = !_obscureKonfirmasi;
                            });
                          },
                          child: Icon(
                            _obscureKonfirmasi ? Icons.visibility_off : Icons.visibility,
                            color: Colors.black26,
                            size: 18,
                          ),
                        ),
                        suffixIconConstraints: BoxConstraints(
                          minWidth: 36,
                          minHeight: 48,
                        ),
                      ),
                    ),
                  ),
                ),

                /// Tombol Konfirmasi
                Positioned(
                  left: 91,
                  top: 660,
                  child: GestureDetector(
                    onTap: () {
                      // TODO: logika daftar
                    },
                    child: Container(
                      width: 219.67,
                      height: 45.54,
                      decoration: ShapeDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(0.45, 1.25),
                          end: Alignment(0.45, -0.64),
                          colors: [const Color(0xFFD05122), const Color(0xFFEE8B2E), const Color(0xFFFBA839)],
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Konfirmasi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: 'Alexandria',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
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