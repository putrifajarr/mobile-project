// File: fintrack/lib/features/auth/view/otp_verification_screen.dart

import 'package:fintrack/core/constants/constants.dart';
import 'package:fintrack/core/supabase_config.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OtpVerificationScreen extends StatefulWidget {
  // Terima email dari halaman registrasi
  final String email; 

  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final otpController = TextEditingController();
  bool isLoading = false;
  bool isResending = false;

  Future<void> _verifyOtp() async {
    if (isLoading) return;

    final otp = otpController.text.trim();

    // Validasi harus 6 digit
    if (otp.isEmpty || otp.length != 6) { 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Kode OTP harus 6 digit"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // 1. Verifikasi kode OTP ke Supabase
      final response = await SupabaseConfig.client.auth.verifyOTP(
        email: widget.email,
        token: otp,
        type: OtpType.signup,
      );

      if (!mounted) return;

      if (response.session != null && response.user != null) {
        // 2. Jika verifikasi sukses, masukkan data pengguna ke tabel 'users'
        final userId = response.user!.id;
        final name = widget.email.split('@')[0]; 

        try {
          // Lakukan penyisipan data pengguna
          await SupabaseConfig.client.from('users').insert({
            'id': userId,
            'email': widget.email,
            'name': name,
            'created_at': DateTime.now().toIso8601String(),
          });
        } catch (e) {
          print("DEBUG: Insert into users table failed after OTP: $e");
        }

        // Navigasi ke main app
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Verifikasi berhasil! Selamat datang."),
            backgroundColor: Color(0xFF9CFF57),
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Menggunakan pushNamedAndRemoveUntil agar tidak bisa kembali ke register
        Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false); 
      } else {
        throw const AuthException("Verifikasi gagal. Kode salah atau kadaluarsa.");
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Terjadi kesalahan sistem"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _resendOtp() async {
    if (isResending) return;
    setState(() => isResending = true);
    
    try {
      // Kirim ulang OTP signup ke email pengguna
      await SupabaseConfig.client.auth.resend(
        type: OtpType.signup,
        email: widget.email,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Kode OTP baru telah dikirim!"),
          backgroundColor: Color(0xFF9CFF57),
        ),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal mengirim ulang kode"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Logo section (Consistent with RegisterScreen)
                Container(
                  width: 140,
                  height: 140,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                    image: DecorationImage(
                      image: AssetImage('assets/logo-app.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Title
                Text(
                  "Verifikasi Akun",
                  style: GoogleFonts.ubuntu(
                    color: ColorPallete.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                // Subtitle
                Text(
                  "Masukkan kode OTP 6 digit yang dikirim ke:", 
                  textAlign: TextAlign.center,
                  style: GoogleFonts.ubuntu(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
                Text(
                  widget.email,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.ubuntu(
                    color: ColorPallete.green,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 40),

                // Form Container (Consistent with RegisterScreen)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white.withOpacity(0.08),
                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // OTP Input Field
                      TextField(
                        controller: otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 6, 
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: ColorPallete.white,
                          fontSize: 24,
                          letterSpacing: 24, 
                        ),
                        decoration: InputDecoration(
                          hintText: "", 
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                            letterSpacing: 24, 
                          ),
                          counterText: "", 
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.09),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFF9CFF57),
                              width: 1.2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // VERIFY BUTTON
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF9CFF57),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 6,
                            shadowColor: const Color(0xFF9CFF57).withOpacity(0.5),
                          ),
                          onPressed: isLoading ? null : _verifyOtp,
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                              : Text(
                                  "Verifikasi",
                                  style: GoogleFonts.ubuntu(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 17,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // RESEND BUTTON
                      TextButton(
                        onPressed: isResending ? null : _resendOtp,
                        child: isResending
                            ? const Text(
                                "Mengirim ulang...",
                                style: TextStyle(color: Colors.white70),
                              )
                            : Text(
                                "Kirim ulang kode",
                                style: GoogleFonts.ubuntu(
                                  color: ColorPallete.white,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}