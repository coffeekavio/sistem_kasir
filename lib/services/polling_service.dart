import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kasir/services/member_service.dart';

class PollingService {
  static Timer? _fastTimer;
  static Timer? _slowTimer;
  static VoidCallback? _onMenuSync;
  static VoidCallback? _onCategorySync;
  static VoidCallback? _onMemberSync;

  static void start({
    required VoidCallback onMenuSync,
    VoidCallback? onCategorySync,
    VoidCallback? onMemberSync,
  }) {
    _onMenuSync = onMenuSync;
    _onCategorySync = onCategorySync;
    _onMemberSync = onMemberSync;

    final fastActive = _fastTimer != null && _fastTimer!.isActive;
    final slowActive = _slowTimer != null && _slowTimer!.isActive;
    if (fastActive && slowActive) {
      return;
    }

    if (kDebugMode) {
      print('Polling Service Dinyalakan dengan Smart Schedule!');
    }

    if (!fastActive) {
      _fastTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
        if (kDebugMode) {
          print('Memeriksa update menu di background...');
        }

        _onMenuSync?.call();
      });
    }

    if (!slowActive) {
      _slowTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
        if (kDebugMode) {
          print('Memeriksa update kategori dan member di background...');
        }

        Future.delayed(const Duration(seconds: 1), () {
          _onCategorySync?.call();
          _syncMemberData();
          _onMemberSync?.call();
        });
      });
    }
  }

  /// Fetch member data dari API dan update local state
  static Future<void> _syncMemberData() async {
    try {
      await MemberService.fetchMembers();
      if (kDebugMode) {
        print('Member data berhasil di-sync dari API');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Gagal sync member data: $e');
      }
    }
  }

  static void stop() {
    _fastTimer?.cancel();
    _fastTimer = null;

    _slowTimer?.cancel();
    _slowTimer = null;

    if (kDebugMode) {
      print('Semua Polling Service Dimatikan.');
    }
  }
}
