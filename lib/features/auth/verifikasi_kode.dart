import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:catering_dapur_bu_mon/features/auth/buat_password_baru.dart';

class VerifikasiKodePage extends StatefulWidget {
  final String metode;
  final String? noTelp;

  const VerifikasiKodePage({
    super.key,
    required this.metode,
    this.noTelp,
  });

  @override
  State<VerifikasiKodePage> createState() => _VerifikasiKodePageState();
}

class _VerifikasiKodePageState extends State<VerifikasiKodePage> {
  // ── LOGIKA TIDAK DIUBAH ────────────────────────────────────
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _secondsLeft = 299;
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
          content: Text('Masukkan 6 digit kode OTP!',
              style: GoogleFonts.alexandria(color: Colors.white)),
          backgroundColor: const Color(0xFFD05122),
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BuatPasswordBaruPage(
          noTelp: widget.noTelp ?? '',
          otpCode: kode,
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    _timer?.cancel();
    super.dispose();
  }
  // ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFAC3715), Color(0xFFD05122), Color(0xFFEE8B2E)],
            stops: [0.21, 0.56, 0.83],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ── Bagian atas (gradient) ──────────────────────
              const SizedBox(height: 24),
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Color(0x30000000),
                        blurRadius: 12,
                        offset: Offset(0, 4))
                  ],
                ),
                child: const Icon(Icons.shield_rounded,
                    size: 50, color: Color(0xFFD05122)),
              ),
              const SizedBox(height: 14),
              Text(
                'Lupa Password',
                style: GoogleFonts.alexandria(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Ikuti langkah untuk membuat password baru',
                style: GoogleFonts.alexandria(
                    color: Colors.white70, fontSize: 11),
              ),
              const SizedBox(height: 24),

              // ── Panel putih ─────────────────────────────────
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(36),
                      topRight: Radius.circular(36),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Ubah Password',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.alexandria(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),

                        // Step indicator
                        _StepIndicator(currentStep: 2),
                        const SizedBox(height: 8),

                        Text(
                          'Langkah 2 dari 3 — Kode OTP',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.alexandria(
                              fontSize: 11, color: Colors.black45),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Kode 6-digit telah dikirim ke\n'
                          '${widget.metode == 'telp' ? 'No. WA kamu 0821*******' : 'Email kamu'}.\n'
                          'Masukkan dalam 5 menit.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.alexandria(
                              fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),

                        // 6 Kotak OTP
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(6, (i) {
                            return _OtpBox(
                              controller: _controllers[i],
                              focusNode: _focusNodes[i],
                              onChanged: (val) {
                                if (val.isNotEmpty && i < 5) {
                                  FocusScope.of(context)
                                      .requestFocus(_focusNodes[i + 1]);
                                } else if (val.isEmpty && i > 0) {
                                  FocusScope.of(context)
                                      .requestFocus(_focusNodes[i - 1]);
                                }
                              },
                            );
                          }),
                        ),
                        const SizedBox(height: 16),

                        // Timer
                        Text(
                          _secondsLeft > 0
                              ? 'Kirim ulang dalam $_timerText'
                              : 'Kode sudah kadaluarsa',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.alexandria(
                              fontSize: 12, color: Colors.black45),
                        ),

                        if (_secondsLeft == 0) ...[
                          const SizedBox(height: 6),
                          GestureDetector(
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
                        ],

                        const SizedBox(height: 28),

                        _FPButton(
                          label: 'Verifikasi Kode',
                          onTap: _verifikasi,
                        ),
                        const SizedBox(height: 10),
                        _FPButton(
                          label: 'Batal',
                          isSecondary: true,
                          onTap: () => Navigator.pop(context),
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
    );
  }
}

// ── OTP Box ────────────────────────────────────────────────────
class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
              color: Color(0x28000000),
              blurRadius: 10,
              offset: Offset(0, 3))
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: GoogleFonts.alexandria(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: onChanged,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  SHARED WIDGETS
// ═══════════════════════════════════════════════════════════════

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [_circle(1), _line(), _circle(2), _line(), _circle(3)],
    );
  }

  Widget _circle(int n) {
    final isActive = n == currentStep;
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFFFCE0A) : const Color(0xFFF0EDE8),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$n',
          style: GoogleFonts.alexandria(
            fontSize: 16,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _line() =>
      Expanded(child: Container(height: 2, color: const Color(0xFFE0DDD9)));
}

class _FPButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isSecondary;
  final bool isLoading;

  const _FPButton({
    required this.label,
    this.onTap,
    this.isSecondary = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: isSecondary
                ? const [Color(0xFFAC3715), Color(0xFFD05122), Color(0xFFAC3715)]
                : const [Color(0xFFD05122), Color(0xFFEE8B2E), Color(0xFFFBA839)],
            stops: const [0.17, 0.50, 0.85],
          ),
          boxShadow: const [
            BoxShadow(
                color: Color(0x30000000),
                blurRadius: 6,
                offset: Offset(0, 3))
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5))
              : Text(
                  label,
                  style: GoogleFonts.alexandria(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
        ),
      ),
    );
  }
}