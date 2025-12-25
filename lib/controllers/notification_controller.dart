import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sia_nessly/services/api_services.dart';

class NotificationController extends GetxController {
  var notifications = <dynamic>[].obs;
  var loading = true.obs;

  Worker? _intervalWorker;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();

    // 🔥 Auto refresh aman
    _intervalWorker = interval(
      notifications,
      (_) => fetchNotifications(silent: true),
      time: const Duration(seconds: 5),
    );
  }

  @override
  void onClose() {
    _intervalWorker?.dispose();
    super.onClose();
  }

  Future<void> fetchNotifications({bool silent = false}) async {
    if (!silent) loading.value = true;

    try {
      final data = await ApiService.getNotifications();
      notifications.assignAll(data);
    } catch (e) {
      debugPrint("❌ Notif error: $e");
    } finally {
      loading.value = false;
    }
  }
}
