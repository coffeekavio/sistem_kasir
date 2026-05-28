import 'package:flutter/material.dart';
import 'package:kasir/services/member_service.dart';

/// Helper class untuk member-related operations dengan error handling
class MemberOperationHelper {
  /// Validasi input member
  static String? validateMemberInput({
    required String name,
    required String phone,
  }) {
    if (name.isEmpty) return 'Nama member harus diisi';
    if (phone.isEmpty) return 'Nomor HP harus diisi';
    if (name.length < 3) return 'Nama minimal 3 karakter';
    if (phone.length < 10) return 'Nomor HP minimal 10 digit';
    return null;
  }

  /// Create member dengan error handling
  static Future<Map<String, dynamic>?> createMember({
    required String name,
    required String phone,
  }) async {
    try {
      await MemberService.createMember(name: name, phone: phone, points: 0);
      return {'success': true, 'message': 'Member berhasil ditambahkan'};
    } catch (e) {
      return {'success': false, 'message': 'Gagal menambah member: $e'};
    }
  }

  /// Show snackbar dengan safe context check
  static void showSnackBar({
    required BuildContext context,
    required String message,
    required bool isSuccess,
    Duration duration = const Duration(seconds: 2),
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        duration: duration,
      ),
    );
  }

  /// Show validation error snackbar
  static void showValidationError({
    required BuildContext context,
    required String? error,
  }) {
    if (error == null || !context.mounted) return;
    showSnackBar(context: context, message: error, isSuccess: false);
  }

  /// Format phone number
  static String formatPhoneNumber(String phone) {
    if (phone.startsWith('0')) {
      return phone;
    }
    return '0$phone';
  }

  /// Check if phone number is valid format
  static bool isValidPhoneNumber(String phone) {
    final phoneRegex = RegExp(r'^(0|62)[0-9]{9,12}$');
    return phoneRegex.hasMatch(phone);
  }
}
