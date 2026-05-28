import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:kasir/providers/menu_provider.dart';

class PollingService {
  static Timer? _timer;

  static void start(BuildContext context) {
    if (_timer != null && _timer!.isActive) {
      return;
    }

    if (kDebugMode) {
      print('Polling Service Dinyalakan!');
    }

    _timer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (kDebugMode) {
        print('Memeriksa update data di background...');
      }

      context.read<MenuProvider>().fetchMenusFromApi(showLoading: false);
    });
  }

  static void stop() {
    _timer?.cancel();
    _timer = null;

    if (kDebugMode) {
      print('Polling Service Dimatikan.');
    }
  }
}
