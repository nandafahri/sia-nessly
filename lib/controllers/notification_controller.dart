import 'dart:async';
import 'package:get/get.dart';
import 'package:sia_nessly/services/api_services.dart';

class NotificationController extends GetxController {
  var notifications = <dynamic>[].obs;
  var loading = true.obs;

  final ApiService api = ApiService();
  Timer? autoRefreshTimer;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();

    // Auto refresh setiap 5 detik
    autoRefreshTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => fetchNotifications(silent: true),
    );
  }

  @override
  void onClose() {
    autoRefreshTimer?.cancel();
    super.onClose();
  }

  Future<void> fetchNotifications({bool silent = false}) async {
    if (!silent) loading.value = true;

    try {
      final data = await ApiService.getNotifications();
      notifications.value = data;
    } catch (e) {
      print("Notif error: $e");
    } finally {
      loading.value = false;
    }
  }
}
