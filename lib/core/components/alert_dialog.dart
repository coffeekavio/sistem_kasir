import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class AlertDialogHelper {
  /// Alert Sukses
  static void showSuccess({
    required BuildContext context,
    required String title,
    required String desc,
    VoidCallback? onOkPress,
  }) {
    Alert(
      context: context,
      type: AlertType.success,
      title: title,
      desc: desc,
      buttons: [
        DialogButton(
          onPressed: onOkPress ?? () => Navigator.pop(context),
          width: 140,
          color: Colors.green,
          child: const Text(
            "TUTUP",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ).show();
  }

  /// Alert Error
  static void showError({
    required BuildContext context,
    required String title,
    required String desc,
    VoidCallback? onOkPress,
  }) {
    Alert(
      context: context,
      type: AlertType.error,
      title: title,
      desc: desc,
      buttons: [
        DialogButton(
          onPressed: onOkPress ?? () => Navigator.pop(context),
          width: 140,
          color: Colors.red,
          child: const Text(
            "TUTUP",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ).show();
  }

  /// Alert Warning
  static void showWarning({
    required BuildContext context,
    required String title,
    required String desc,
    VoidCallback? onOkPress,
  }) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: title,
      desc: desc,
      buttons: [
        DialogButton(
          onPressed: onOkPress ?? () => Navigator.pop(context),
          width: 140,
          color: Colors.orange,
          child: const Text(
            "TUTUP",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ).show();
  }

  /// Alert Info
  static void showInfo({
    required BuildContext context,
    required String title,
    required String desc,
    VoidCallback? onOkPress,
  }) {
    Alert(
      context: context,
      type: AlertType.info,
      title: title,
      desc: desc,
      buttons: [
        DialogButton(
          onPressed: onOkPress ?? () => Navigator.pop(context),
          width: 140,
          color: Colors.blue,
          child: const Text(
            "TUTUP",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ).show();
  }

  /// Alert Konfirmasi (Yes/No)
  static void showConfirmation({
    required BuildContext context,
    required String title,
    required String desc,
    required VoidCallback onYesPress,
    VoidCallback? onNoPress,
  }) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: title,
      desc: desc,
      buttons: [
        DialogButton(
          onPressed: onYesPress,
          width: 120,
          color: Colors.green,
          child: const Text(
            "YA",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        DialogButton(
          onPressed: onNoPress ?? () => Navigator.pop(context),
          width: 120,
          color: Colors.red,
          child: const Text(
            "TIDAK",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ).show();
  }
}
