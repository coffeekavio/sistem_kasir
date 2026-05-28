import 'package:flutter/material.dart';

/// Member-related UI constants dan colors
class MemberUIConstants {
  // Color palette
  static const Color primaryColor = Color(0xFF1E88E5);
  static const Color textPrimaryColor = Color(0xFF3E2723);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFF44336);
  static const Color warningColor = Color(0xFFFFC107);
  static const Color backgroundColor = Color.fromARGB(255, 252, 250, 245);
  static const Color cardBackground = Color.fromARGB(255, 248, 248, 248);

  // Border radius
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 12.0;
  static const double borderRadiusSmall = 6.0;

  // Font sizes
  static const double fontSizeXSmall = 8.0;
  static const double fontSizeSmall = 10.0;
  static const double fontSizeRegular = 12.0;
  static const double fontSizeMedium = 13.0;
  static const double fontSizeLarge = 15.0;

  // Spacing
  static const double spacingXSmall = 2.0;
  static const double spacingSmall = 6.0;
  static const double spacingMedium = 12.0;
  static const double spacingLarge = 24.0;

  // Icon sizes
  static const double iconSizeSmall = 16.0;
  static const double iconSizeRegular = 18.0;
  static const double iconSizeLarge = 48.0;

  // Dialog dimensions
  static const double dialogMinWidth = 780.0;
  static const double headerHeight = 70.0;
  static const double searchBarHeight = 36.0;

  // Data table settings
  static const int defaultRowsPerPage = 10;
  static const List<int> availableRowsPerPage = [5, 10, 20, 50];
  static const double headingRowHeight = 36.0;
  static const double dataRowHeight = 48.0;

  // Durations
  static const Duration snackBarDuration = Duration(seconds: 2);
  static const Duration shortAnimationDuration = Duration(milliseconds: 100);
}

/// Member model untuk type safety
class MemberModel {
  final String id;
  final String name;
  final String phone;
  final int points;
  final int discount;

  MemberModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.points,
    required this.discount,
  });

  factory MemberModel.fromMap(Map<String, dynamic> map) {
    return MemberModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      points: map['points'] ?? 0,
      discount: map['discount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'points': points,
      'discount': discount,
    };
  }

  MemberModel copyWith({
    String? id,
    String? name,
    String? phone,
    int? points,
    int? discount,
  }) {
    return MemberModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      points: points ?? this.points,
      discount: discount ?? this.discount,
    );
  }
}
