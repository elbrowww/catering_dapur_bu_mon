import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Mulai(),
    );
  }
}

class Mulai extends StatelessWidget {
  const Mulai({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(0.45, 1.25),
              end: Alignment(0.45, -0.64),
              colors: [
                Color(0xFFD05122),
                Color(0xFFEE8B2E),
                Color(0xFFFBA839)
              ],
            ),
          ),
          child: Stack(
            children: [

              /// Gambar
              Positioned(
                top: 90,
                left: 0,
                right: 0,
                child: Center(
                  child: Image.asset(
                    "assets/icons/LOGO BU MON.png",
                    width: 293,
                    height: 293,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              /// Text Welcome
              const Positioned(
                top: 455,
                left: 40,
                right: 40,
                child: Text(
                  'Selamat Datang di Catering Dapur Bu Mon!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              /// Tombol Lanjut
              Positioned(
                bottom: 40,
                left: 40,
                right: 40,
                child: GestureDetector(
                  onTap: () {
                    print("Tombol ditekan");
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFCF5021),
                          Color(0xFFEE8B2E),
                          Color(0xFFFBA839),
                          Color(0xFFFFF8EF)
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFDB6626),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        "Lanjut",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
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