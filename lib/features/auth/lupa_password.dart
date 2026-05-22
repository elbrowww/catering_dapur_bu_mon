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
  final TextEditingController _noTelpController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _noTelpController.dispose();
    super.dispose();
  }

  // ── LOGIKA TIDAK DIUBAH ────────────────────────────────────
  Future<void> _kirimOtp() async {
    if (_noTelpController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nomor HP wajib diisi')),
      );
      return;
    }
    try {
      setState(() => _loading = true);
      await ApiService.forgotPassword(phone: _noTelpController.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP berhasil dikirim')),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
                child: const Icon(Icons.lock_reset_rounded,
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
                        _StepIndicator(currentStep: 1),
                        const SizedBox(height: 8),

                        Text(
                          'Langkah 1 dari 3 — Nomor WhatsApp',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.alexandria(
                              fontSize: 11, color: Colors.black45),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Kode OTP akan dikirim\nmelalui WhatsApp kamu',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.alexandria(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),

                        // Input
                        _FPLabel('Nomor WhatsApp'),
                        const SizedBox(height: 6),
                        _FPInputField(
                          controller: _noTelpController,
                          hint: '08xx-xxxx-xxxx',
                          keyboardType: TextInputType.phone,
                          prefixIcon: Icons.phone_android_rounded,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pastikan nomor aktif dan terhubung WhatsApp',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.alexandria(
                              fontSize: 10, color: Colors.black38),
                        ),
                        const SizedBox(height: 24),

                        _FPButton(
                          label: 'Kirim Kode Verifikasi',
                          onTap: _loading ? null : _kirimOtp,
                          isLoading: _loading,
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

// ═══════════════════════════════════════════════════════════════
//  SHARED WIDGETS (dipakai di 3 halaman)
// ═══════════════════════════════════════════════════════════════

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _circle(1),
        _line(),
        _circle(2),
        _line(),
        _circle(3),
      ],
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
            fontWeight:
                isActive ? FontWeight.bold : FontWeight.normal,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _line() => Expanded(
        child: Container(height: 2, color: const Color(0xFFE0DDD9)),
      );
}

class _FPLabel extends StatelessWidget {
  final String text;
  const _FPLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.alexandria(fontSize: 13, color: Colors.black87),
    );
  }
}

class _FPInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final VoidCallback? onToggleObscure;
  final TextInputType keyboardType;
  final IconData? prefixIcon;

  const _FPInputField({
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.onToggleObscure,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
              color: Color(0x28000000),
              spreadRadius: 1,
              blurRadius: 8,
              offset: Offset(0, 2))
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        textAlignVertical: TextAlignVertical.center,
        style: GoogleFonts.alexandria(fontSize: 14, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.alexandria(
              color: Colors.black26, fontSize: 13),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14),
          border: InputBorder.none,
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: const Color(0xFFD05122), size: 18)
              : null,
          suffixIcon: onToggleObscure != null
              ? GestureDetector(
                  onTap: onToggleObscure,
                  child: Icon(
                    obscure ? Icons.visibility_off : Icons.visibility,
                    color: Colors.black26,
                    size: 18,
                  ),
                )
              : null,
        ),
      ),
    );
  }
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
                ? const [
                    Color(0xFFAC3715),
                    Color(0xFFD05122),
                    Color(0xFFAC3715)
                  ]
                : const [
                    Color(0xFFD05122),
                    Color(0xFFEE8B2E),
                    Color(0xFFFBA839)
                  ],
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
                      color: Colors.white, strokeWidth: 2.5),
                )
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