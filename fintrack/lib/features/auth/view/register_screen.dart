import 'package:fintrack/core/supabase_config.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

      // CEK EMAIL SUDAH ADA (User Recommendation)
      final identities = response.user!.identities;
      if (identities == null || identities.isEmpty) {
        throw const AuthException("Email sudah terdaftar, silakan login");
      }

      if (response.user != null) {
        final userId = response.user!.id;
        final name = email.split('@')[0];

        print("DEBUG: Inserting into users table...");
        try {
          await SupabaseConfig.client.from('users').insert({
            'id': userId,
            'email': email,
            'name': name,
            'created_at': DateTime.now().toIso8601String(),
          });
          print("DEBUG: Insert into users table success");
        } catch (e) {
          print("DEBUG: Insert into users table failed: $e");
          // Continue anyway as auth succeeded
        }

        print("DEBUG: Registration success. Navigating to login.");
        // Success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registrasi berhasil! Silakan masuk."),
            backgroundColor: Color(0xFF9CFF57),
          ),
        );
        Navigator.pushReplacementNamed(context, '/login');
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

      // Check for both my custom error and Supabase's original error
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
                    gradient: const LinearGradient(
                      colors: [Color(0xFF9CFF57), Color(0xFF76C63A)],
                    ),
                    image: const DecorationImage(
                      image: AssetImage('assets/logo.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // TITLE
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

                // CARD
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

                      _input(
                        "Password",
                        passwordController,
                        Icons.lock_outline,
                        obscure: true,
                      ),
                      const SizedBox(height: 16),

                      _input(
                        "Konfirmasi Password",
                        confirmController,
                        Icons.lock_reset,
                        obscure: true,
                      ),
                      const SizedBox(height: 28),

                      // BUTTON
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

  Widget _input(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.09),
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
