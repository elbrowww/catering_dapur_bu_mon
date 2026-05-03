import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:catering_dapur_bu_mon/features/auth/login.dart';
import 'package:catering_dapur_bu_mon/services/api_service.dart';

class VerifikasiOtpRegister extends StatefulWidget {
  final String nama;
  final String email;
  final String phone;
  final String alamat;
  final String password;

  const VerifikasiOtpRegister({
    super.key,
    required this.nama,
    required this.email,
    required this.phone,
    required this.alamat,
    required this.password,
  });

  @override
  State<VerifikasiOtpRegister> createState() => _VerifikasiOtpRegisterState();
}

class _VerifikasiOtpRegisterState extends State<VerifikasiOtpRegister> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(6, (_) => FocusNode());

  bool _isLoading   = false;
  bool _isResending = false;
  int  _countdown   = 60;
  Timer? _timer;

  static const _gradientColors = [
    Color(0xFFD05122),
    Color(0xFFEE8B2E),
    Color(0xFFFBA839),
  ];

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _otpControllers) c.dispose();
    for (final f in _focusNodes)     f.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _countdown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown == 0) {
        t.cancel();
      } else {
        setState(() => _countdown--);
      }
    });
  }

  String get _otpCode => _otpControllers.map((c) => c.text).join();

  Future<void> _daftar() async {
    final kode = _otpCode;
    if (kode.length < 6) {
      _showSnackbar('Masukkan 6 digit kode OTP');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ApiService.registerWithOtp(
        nama:     widget.nama,
        email:    widget.email,
        noTelp:   widget.phone,
        alamat:   widget.alamat,
        password: widget.password,
        otpCode:  kode,
      );

      if (mounted) {
        _showSnackbar('Registrasi berhasil! Silakan login.', isError: false);
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const Login()),
              (route) => false,
            );
          }
        });
      }
    } on ApiException catch (e) {
      _showSnackbar(e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOtp() async {
    if (_countdown > 0) return;
    setState(() => _isResending = true);
    try {
      await ApiService.sendOtpRegister(noTelp: widget.phone);
      _startCountdown();
      _showSnackbar('OTP baru telah dikirim!', isError: false);
    } on ApiException catch (e) {
      _showSnackbar(e.message);
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  void _clearOtp() {
    for (final c in _otpControllers) c.clear();
  }

  void _kembali() {
    _clearOtp();
    Navigator.pop(context);
  }

  void _showSnackbar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: sw,
        height: sh,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: _gradientColors,
            stops: [0.17, 0.47, 0.60],
          ),
        ),
        child: Stack(
          children: [
            // Panel putih bawah
            Positioned(
              left: 0,
              top: sh * 0.30,
              child: Container(
                width: sw,
                height: sh,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(46),
                ),
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: sh * 0.03),

                    // Icon
                    const Icon(
                      Icons.phone_android,
                      size: 70,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),

                    Text(
                      'Konfirmasi Pendaftaran',
                      style: GoogleFonts.alexandria(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'OTP dikirim ke ${widget.phone}',
                      style: GoogleFonts.alexandria(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                      ),
                    ),

                    SizedBox(height: sh * 0.04),

                    // Preview Data
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: sw * 0.08),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1F000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Data Pendaftaran',
                            style: GoogleFonts.alexandria(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFD05122),
                            ),
                          ),
                          const Divider(),
                          _buildPreviewRow('Nama',     widget.nama),
                          _buildPreviewRow('Email',    widget.email),
                          _buildPreviewRow('No. Telp', widget.phone),
                          _buildPreviewRow('Alamat',   widget.alamat),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Input OTP
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: sw * 0.08),
                      child: Text(
                        'Masukkan Kode OTP',
                        style: GoogleFonts.alexandria(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: sw * 0.06),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(6, (i) => _buildOtpBox(i)),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Kirim ulang OTP
                    _isResending
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : GestureDetector(
                            onTap: _countdown == 0 ? _resendOtp : null,
                            child: Text(
                              _countdown > 0
                                  ? 'Kirim ulang OTP dalam $_countdown detik'
                                  : 'Kirim Ulang OTP',
                              style: GoogleFonts.alexandria(
                                color: _countdown == 0
                                    ? const Color(0xFFD05122)
                                    : Colors.grey,
                                fontSize: 12,
                                fontWeight: _countdown == 0
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                decoration: _countdown == 0
                                    ? TextDecoration.underline
                                    : TextDecoration.none,
                              ),
                            ),
                          ),

                    const SizedBox(height: 24),

                    // 2 Tombol: Kembali & Daftar
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: sw * 0.08),
                      child: Row(
                        children: [
                          // Tombol Kembali
                          Expanded(
                            child: GestureDetector(
                              onTap: _isLoading ? null : _kembali,
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: const Color(0xFFD05122),
                                    width: 1.5,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x1FD05122),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    'Kembali',
                                    style: GoogleFonts.alexandria(
                                      color: const Color(0xFFD05122),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Tombol Daftar
                          Expanded(
                            child: GestureDetector(
                              onTap: _isLoading ? null : _daftar,
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: _gradientColors,
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x4FD05122),
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : Text(
                                          'Daftar',
                                          style: GoogleFonts.alexandria(
                                            color: Colors.white,
                                            fontSize: 16,
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
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: GoogleFonts.alexandria(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          const Text(' : '),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.alexandria(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 45,
      height: 55,
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: GoogleFonts.alexandria(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFD05122),
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD05122), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        onChanged: (val) {
          if (val.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (val.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }
}