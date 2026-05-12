import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:catering_dapur_bu_mon/services/api_service.dart';

/// Halaman verifikasi OTP sebelum menyimpan perubahan nama / no_telp profil.
///
/// Menerima data baru dari [EditProfilPage] sebagai argumen,
/// lalu menyimpan ke backend hanya setelah OTP valid.
class OtpVerifikasiProfilPage extends StatefulWidget {
  final String noTelpLama;  // Nomor yang sudah terverifikasi (tujuan OTP)
  final String namaBaru;
  final String noTelpBaru;
  final String alamatBaru;

  const OtpVerifikasiProfilPage({
    super.key,
    required this.noTelpLama,
    required this.namaBaru,
    required this.noTelpBaru,
    required this.alamatBaru,
  });

  @override
  State<OtpVerifikasiProfilPage> createState() =>
      _OtpVerifikasiProfilPageState();
}

class _OtpVerifikasiProfilPageState extends State<OtpVerifikasiProfilPage> {
  // 6 controller untuk 6 kotak OTP
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(6, (_) => FocusNode());

  bool _isVerifying = false;
  bool _isResending = false;

  // Countdown resend OTP (60 detik)
  int _countdown = 60;
  Timer? _timer;

  static const _gradientStops = [0.17, 0.47, 0.60];

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _countdown = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown <= 0) {
        t.cancel();
      } else {
        setState(() => _countdown--);
      }
    });
  }

  String get _otpCode =>
      _controllers.map((c) => c.text).join();

  bool get _otpLengkap => _otpCode.length == 6;

  // ── Verifikasi OTP lalu simpan profil ────────────────────────────────────
  Future<void> _verifikasiDanSimpan() async {
    if (!_otpLengkap) return;

    setState(() => _isVerifying = true);
    try {
      // 1. Verifikasi OTP menggunakan nomor HP lama
      await ApiService.verifyPhoneOtp(
        phone: widget.noTelpLama,
        otpCode: _otpCode,
      );

      // 2. Jika OTP valid, simpan perubahan profil
      await ApiService.editProfil(
        nama:   widget.namaBaru,
        noTelp: widget.noTelpBaru,
        alamat: widget.alamatBaru,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui!'),
            backgroundColor: Colors.green,
          ),
        );
        // Kembalikan true agar EditProfilPage tahu update berhasil
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$e'),
            backgroundColor: Colors.red,
          ),
        );
        // Kosongkan kotak OTP agar user bisa coba lagi
        for (final c in _controllers) c.clear();
        _focusNodes.first.requestFocus();
      }
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  // ── Kirim ulang OTP ───────────────────────────────────────────────────────
  Future<void> _kirimUlang() async {
    if (_countdown > 0 || _isResending) return;

    setState(() => _isResending = true);
    try {
      await ApiService.resendOtp(
        target: widget.noTelpLama,
        type: 'whatsapp',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP baru telah dikirim ke WhatsApp Anda.'),
            backgroundColor: Colors.green,
          ),
        );
        _startCountdown();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal kirim OTP: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  // ── Satu kotak OTP ────────────────────────────────────────────────────────
  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 44,
      height: 54,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: GoogleFonts.alexandria(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: _controllers[index].text.isNotEmpty
                  ? const Color(0xFFD05122)
                  : const Color(0xFFE0E0E0),
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Color(0xFFD05122),
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (val) {
          setState(() {});
          if (val.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          }
          if (val.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          // Auto submit jika 6 digit sudah terisi
          if (_otpLengkap) _verifikasiDanSimpan();
        },
      ),
    );
  }

  // ── Nomor telepon yang ditampilkan (sensor sebagian) ─────────────────────
  String get _noTelpSensor {
    final n = widget.noTelpLama;
    if (n.length <= 6) return n;
    return '${n.substring(0, 4)}****${n.substring(n.length - 3)}';
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final double sh = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: SizedBox(
          width: sw,
          height: sh,
          child: Container(
            width: sw,
            height: sh,
            clipBehavior: Clip.hardEdge,
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
              clipBehavior: Clip.none,
              children: [

                // Panel putih bawah
                Positioned(
                  left: 0,
                  top: sh * 0.38,
                  child: Container(
                    width: sw,
                    height: sh,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(46),
                    ),
                  ),
                ),

                // ── Header area (oranye) ──
                Positioned(
                  top: sh * 0.055,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      // Tombol kembali
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: sh * 0.025),

                      // Ikon kunci / verifikasi
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.verified_user_rounded,
                          color: Color(0xFFD05122),
                          size: 48,
                        ),
                      ),
                      SizedBox(height: sh * 0.018),

                      Text(
                        'Verifikasi OTP',
                        style: GoogleFonts.alexandria(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: sh * 0.008),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          'Kode OTP dikirim ke WhatsApp\n$_noTelpSensor',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.alexandria(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Konten form (panel putih) ──
                Positioned(
                  top: sh * 0.41,
                  left: sw * 0.06,
                  right: sw * 0.06,
                  bottom: 16,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 24),

                        // Info ringkasan perubahan
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3EE),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFEE8B2E).withOpacity(0.4),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Perubahan yang akan disimpan:',
                                style: GoogleFonts.alexandria(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFFAC3715),
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildRingkasanBaris(
                                  Icons.person_outline, 'Nama', widget.namaBaru),
                              const SizedBox(height: 4),
                              _buildRingkasanBaris(
                                  Icons.phone_outlined, 'No Telepon', widget.noTelpBaru),
                              if (widget.alamatBaru.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                _buildRingkasanBaris(
                                    Icons.location_on_outlined, 'Alamat', widget.alamatBaru),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        Text(
                          'Masukkan kode 6 digit',
                          style: GoogleFonts.alexandria(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Kotak OTP
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            6,
                            (i) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: _buildOtpBox(i),
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Tombol Verifikasi
                        GestureDetector(
                          onTap: (_otpLengkap && !_isVerifying)
                              ? _verifikasiDanSimpan
                              : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: double.infinity,
                            height: 50,
                            decoration: ShapeDecoration(
                              gradient: LinearGradient(
                                colors: _otpLengkap && !_isVerifying
                                    ? const [
                                        Color(0xFFD05122),
                                        Color(0xFFEE8B2E),
                                        Color(0xFFFBA839),
                                      ]
                                    : [
                                        const Color(0xFFD05122).withOpacity(0.4),
                                        const Color(0xFFEE8B2E).withOpacity(0.4),
                                        const Color(0xFFFBA839).withOpacity(0.4),
                                      ],
                                stops: _gradientStops,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              shadows: _otpLengkap
                                  ? const [
                                      BoxShadow(
                                        color: Color(0x4FD05122),
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Center(
                              child: _isVerifying
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Text(
                                      'Verifikasi & Simpan',
                                      style: GoogleFonts.alexandria(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Kirim ulang OTP
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Tidak menerima kode? ',
                              style: GoogleFonts.alexandria(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            GestureDetector(
                              onTap: _countdown == 0 ? _kirimUlang : null,
                              child: _isResending
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFFD05122),
                                      ),
                                    )
                                  : Text(
                                      _countdown > 0
                                          ? 'Kirim ulang ($_countdown)'
                                          : 'Kirim ulang',
                                      style: GoogleFonts.alexandria(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: _countdown > 0
                                            ? Colors.black38
                                            : const Color(0xFFD05122),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRingkasanBaris(IconData icon, String label, String nilai) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFFD05122)),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: GoogleFonts.alexandria(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
        Expanded(
          child: Text(
            nilai,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.alexandria(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}