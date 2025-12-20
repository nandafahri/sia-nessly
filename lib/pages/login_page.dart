import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';
import '../pages/change_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginController loginC = Get.put(LoginController());
  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // penting agar keyboard tidak overflow
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              reverse: true, // agar TextField yang fokus terlihat
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 40),

                        // ================= LOGO =================
                        Image.asset(
                          'assets/logo_sma.png',
                          height: 100,
                        ),
                        const SizedBox(height: 12),

                        // ================= TITLE =================
                        const Text(
                          'Portal Siswa',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Silakan login untuk melanjutkan',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // ================= NISN =================
                        TextField(
                          onChanged: loginC.setNisn,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration(
                            hint: 'Nomor Induk (NISN)',
                            icon: Icons.badge_outlined,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ================= PASSWORD =================
                        TextField(
                          onChanged: loginC.setPassword,
                          obscureText: !isPasswordVisible,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration(
                            hint: 'Password',
                            icon: Icons.lock_outline,
                            suffix: IconButton(
                              icon: Icon(
                                isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.white54,
                              ),
                              onPressed: () {
                                setState(() {
                                  isPasswordVisible = !isPasswordVisible;
                                });
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),
                        // ================= GANTI PASSWORD =================
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              Get.to(() => const ChangePasswordPage());
                            },
                            child: const Text(
                              'Ganti Password?',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 13,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 26),

                        // ================= BUTTON LOGIN =================
                        Obx(() {
                          return SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed:
                                  loginC.loading.value ? null : loginC.login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: loginC.loading.value
                                    ? Colors.white24
                                    : Colors.white,
                                foregroundColor: Colors.black,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: loginC.loading.value
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.black,
                                      ),
                                    )
                                  : const Text(
                                      'LOGIN',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          );
                        }),

                        const Spacer(),

                        // ================= FOOTER =================
                        const Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Text(
                            'Portal Siswa Nessly',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ================= INPUT DECORATION =================
  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: Colors.white12,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      prefixIcon: Icon(icon, color: Colors.white54),
      suffixIcon: suffix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white70, width: 1.2),
      ),
    );
  }
}
