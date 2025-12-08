import 'package:fintrack/core/constants/constants.dart';
import 'package:fintrack/features/auth/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void showEditUsernameDialog(BuildContext context) {
  final TextEditingController usernameController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      bool isLoading = false;
      bool isValid = false;

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: ColorPallete.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: ColorPallete.grey.withOpacity(0.6),
                width: 1,
              ),
            ),
            title: const Text(
              "Ubah Username",
              style: TextStyle(
                color: ColorPallete.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Masukkan username baru Anda.",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: usernameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Username Baru",
                        labelStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: Colors.black.withOpacity(0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: ColorPallete.green,
                            width: 0.8,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 255, 141, 141),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Username tidak boleh kosong';
                        }
                        if (value.trim().length < 3) {
                          return 'Minimal 3 karakter';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          isValid = formKey.currentState?.validate() ?? false;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: isLoading
                          ? null
                          : () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 39, 39, 39),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Batal",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (isValid && !isLoading)
                          ? () async {
                              if (formKey.currentState!.validate()) {
                                setState(() => isLoading = true);

                                if (context.mounted) {
                                  try {
                                    await Provider.of<UserProvider>(
                                      context,
                                      listen: false,
                                    ).updateUsername(usernameController.text);

                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Username berhasil diperbarui!",
                                            style: TextStyle(
                                              color: ColorPallete.black,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          backgroundColor: Color.fromARGB(
                                            255,
                                            164,
                                            252,
                                            116,
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Gagal memperbarui username",
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      setState(() => isLoading = false);
                                    }
                                  }
                                }
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorPallete.green,
                        foregroundColor: Colors.black,
                        disabledBackgroundColor: ColorPallete.green.withOpacity(
                          0.3,
                        ),
                        disabledForegroundColor: Colors.black.withOpacity(0.5),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.black,
                                ),
                              ),
                            )
                          : const Text(
                              "Simpan",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      );
    },
  );
}
