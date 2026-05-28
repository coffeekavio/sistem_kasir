import 'package:flutter/material.dart';

class MemberDialogField {
  /// Build reusable TextField untuk Member Dialog
  static Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool autofocus = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      autofocus: autofocus,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(
          color: Color(0xFF3E2723),
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFF1E88E5), width: 2),
        ),
        prefixIcon: Icon(icon, color: Color(0xFF1E88E5), size: 18),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      style: TextStyle(fontSize: 13, color: Color(0xFF3E2723)),
    );
  }

  /// Build dialog title dengan icon
  static Widget buildDialogTitle({
    required String title,
    required IconData icon,
    Color? iconBackgroundColor,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconBackgroundColor ?? Color(0xFF1E88E5).withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: Color(0xFF1E88E5), size: 18),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3E2723),
            ),
          ),
        ),
      ],
    );
  }

  /// Build dialog action buttons
  static Widget buildActionButtons({
    required VoidCallback onCancel,
    required VoidCallback onConfirm,
    required String confirmLabel,
    bool isLoading = false,
    Color? confirmColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: isLoading ? null : onCancel,
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          child: Text(
            'Batal',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor ?? Color(0xFF1E88E5),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          onPressed: isLoading ? null : onConfirm,
          child: Text(
            confirmLabel,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
