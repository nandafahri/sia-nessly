import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/notification_controller.dart';

class NotificationPage extends StatelessWidget {
  final bool showBack; // true = tampilkan tombol back

  NotificationPage({super.key, this.showBack = true});

  final notifC = Get.put(NotificationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        toolbarHeight: 62,
        automaticallyImplyLeading: false,
        titleSpacing: 10,
        title: Row(
          children: [
            // SLOT BACK BUTTON / PLACEHOLDER
            SizedBox(
              child: showBack
                  ? GestureDetector(
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
                    )
                  : null, // placeholder kosong
            ),

            const SizedBox(width: 16),

            // TITLE
            const Text(
              "Notifikasi",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
      body: Obx(() {
        if (notifC.loading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (notifC.notifications.isEmpty) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.notifications_none, color: Colors.white24, size: 80),
              SizedBox(height: 10),
              Text(
                "Tidak ada notifikasi",
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
            ],
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: notifC.notifications.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = notifC.notifications[index];

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF161616),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['emoji'] ?? '🔔',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      item['teks'] ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
