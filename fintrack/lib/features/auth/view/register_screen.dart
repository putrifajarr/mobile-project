import 'package:fintrack/core/supabase_config.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'otp_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  bool isLoading = false;

  // 1. Tambahkan state untuk visibilitas kedua kolom password
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  Future<void> _register() async {
    print("DEBUG: Register button pressed");
    if (isLoading) {
      print("DEBUG: Register ignored (loading)");
      return;
    }

    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirm = confirmController.text.trim();

    print("DEBUG: Attempting register with Email: $email");

    if (email.isEmpty || password.isEmpty || confirm.isEmpty) {
      print("DEBUG: Register failed - Empty fields");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Semua kolom harus diisi"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (password != confirm) {
      print("DEBUG: Register failed - Password mismatch");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Konfirmasi password tidak cocok"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      print("DEBUG: Calling Supabase signUp...");
      final response = await SupabaseConfig.client.auth.signUp(
        email: email,
        password: password,
      );
      print("DEBUG: Supabase signUp returned. User: ${response.user?.id}");

      if (!mounted) return;

      if (response.user == null) {
        throw const AuthException("Pendaftaran gagal");
      }

      // User sdh daftar, tapi belum terverifikasi emailnya
      final identities = response.user!.identities;
      if (identities == null || identities.isEmpty) {
        // Kasus ini biasanya terjadi jika user sudah terdaftar.
        // Logika aslinya sudah menangani ini dengan AuthException.
      }

      // Navigasi ke halaman Verifikasi OTP
      if (response.user != null) {
        print("DEBUG: Registration success. Navigating to OTP verification.");
        // Success notification
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registrasi berhasil! Cek email untuk kode verifikasi."),
            backgroundColor: Color(0xFF9CFF57),
          ),
        );
        // PUSH KE HALAMAN OTP
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpVerificationScreen(email: email),
          ),
        );
      } else {
        print(
          "DEBUG: Response user is null (maybe email confirmation required?)",
        );
      }
    } on AuthException catch (e) {
      print(
        "DEBUG: Supabase AuthException: ${e.message} (Code: ${e.statusCode})",
      );
      if (!mounted) return;

      String message = e.message;
      bool isDuplicate = false;

      if (e.message.contains("User already registered") ||
          e.message.contains("already registered") ||
          e.message.contains("sudah terdaftar")) {
        message = "Akun sudah terdaftar, mengarahkan ke login...";
        isDuplicate = true;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );

      if (isDuplicate) {
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    } catch (e) {
      print("DEBUG: Generic Error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Terjadi kesalahan sistem"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      print("DEBUG: Register finished. Loading = false");
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 26),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                    image: const DecorationImage(
                      image: AssetImage('assets/logo-app.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // title
                Text(
                  "Daftar Akun",
                  style: GoogleFonts.ubuntu(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Buat akun untuk mulai mengelola keuangan",
                  style: GoogleFonts.ubuntu(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 40),

                // form
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                  ),
                  child: Column(
                    children: [
                      _input("Email", emailController, Icons.email_outlined),
                      const SizedBox(height: 16),

                      // Input Password
                      _input(
                        "Password",
                        passwordController,
                        Icons.lock_outline,
                        // Kontrol visibilitas dengan state _isPasswordVisible
                        obscure: !_isPasswordVisible,
                        isPassword: true, // Tambahkan flag
                      ),
                      const SizedBox(height: 16),

                      // Input Konfirmasi Password
                      _input(
                        "Konfirmasi Password",
                        confirmController,
                        Icons.lock_reset,
                        // Kontrol visibilitas dengan state _isConfirmPasswordVisible
                        obscure: !_isConfirmPasswordVisible,
                        isPassword: true, // Tambahkan flag
                      ),
                      const SizedBox(height: 28),

                      // button
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
                          ),
                          onPressed: isLoading ? null : _register,
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
                                  "Daftar",
                                  style: GoogleFonts.ubuntu(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 17,
                                  ),
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

  // Perbarui metode _input untuk mendukung Password Visibility Toggle
  Widget _input(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool obscure = false,
    bool isPassword = false, // Parameter baru
  }) {
    // Tentukan status visibility saat ini berdasarkan label
    bool isCurrentlyVisible = false;
    if (label == "Password") {
      isCurrentlyVisible = _isPasswordVisible;
    } else if (label == "Konfirmasi Password") {
      isCurrentlyVisible = _isConfirmPasswordVisible;
    }

    return TextField(
      controller: controller,
      // Gunakan nilai 'obscure' yang sudah dikontrol oleh state
      obscureText: obscure, 
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.09),
        // Tambahkan tombol toggle jika ini adalah input password
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isCurrentlyVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white70,
                ),
                onPressed: () {
                  // Toggle state yang sesuai saat tombol diklik
                  setState(() {
                    if (label == "Password") {
                      _isPasswordVisible = !_isPasswordVisible;
                    } else if (label == "Konfirmasi Password") {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    }
                  });
                },
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF9CFF57), width: 1.2),
        ),
      ),
    );
  }
}