import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_verification_controller.dart';

class AuthVerificationPage extends StatefulWidget {
  const AuthVerificationPage({super.key});

  @override
  State<AuthVerificationPage> createState() => _AuthVerificationPageState();
}

class _AuthVerificationPageState extends State<AuthVerificationPage> {
  late AuthVerificationController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(AuthVerificationController());
  }

  @override
  void dispose() {
    Get.delete<AuthVerificationController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        toolbarHeight: 62, // Sedikit lebih tinggi agar nyaman
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            // BACK BUTTON
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white24,
                      width: 1,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // TITLE
            const Text(
              "Autentikasi Akun",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Isi data di bawah untuk verifikasi akun",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 20),

            // ========= CARD FORM =========
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // EMAIL
                  const Text(
                    "Email",
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),

                  TextField(
                    style: const TextStyle(color: Colors.white),
                    onChanged: (v) => controller.email.value = v,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.07),
                      hintText: 'Masukkan email',
                      hintStyle: const TextStyle(color: Colors.white38),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // PHONE
                  const Text(
                    "Nomor Telepon",
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),

                  TextField(
                    style: const TextStyle(color: Colors.white),
                    onChanged: (v) => controller.phone.value = v,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.07),
                      hintText: '08xxxxxxxxxx',
                      hintStyle: const TextStyle(color: Colors.white38),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ========= BUTTON KECIL & RAPIH =========
                  Obx(() {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.verifyAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.blueGrey,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          minimumSize: const Size(0, 38), // button kecil & rapi
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: controller.isLoading.value
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                "Verifikasi",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
