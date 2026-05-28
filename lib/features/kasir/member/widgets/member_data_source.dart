import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:kasir/features/kasir/member/models/member_constants.dart';

/// Data source untuk PaginatedDataTable2 - Member List
class MemberDataSource extends DataTableSource {
  final List<Map<String, dynamic>> members;
  final BuildContext context;
  final void Function(Map<String, dynamic> member) onEdit;
  final void Function(Map<String, dynamic> member) onDelete;

  MemberDataSource({
    required this.members,
    required this.context,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= members.length) return null;
    final member = members[index];

    return DataRow(
      cells: [
        _buildNumberCell(index),
        _buildNameCell(member),
        _buildPhoneCell(member),
        _buildPointsCell(member),
        _buildDiscountCell(member),
        _buildActionCell(member),
      ],
    );
  }

  /// Cell untuk nomor urut
  DataCell _buildNumberCell(int index) {
    return DataCell(
      Center(
        child: Text(
          '${index + 1}',
          style: TextStyle(
            fontSize: MemberUIConstants.fontSizeXSmall,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }

  /// Cell untuk nama member
  DataCell _buildNameCell(Map<String, dynamic> member) {
    return DataCell(
      Text(
        member["name"] ?? '-',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: MemberUIConstants.fontSizeSmall + 1,
          fontWeight: FontWeight.w600,
          color: MemberUIConstants.textPrimaryColor,
        ),
      ),
    );
  }

  /// Cell untuk nomor telepon
  DataCell _buildPhoneCell(Map<String, dynamic> member) {
    return DataCell(
      Text(
        member["phone"] ?? '-',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: MemberUIConstants.fontSizeSmall,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  /// Cell untuk poin
  DataCell _buildPointsCell(Map<String, dynamic> member) {
    return DataCell(
      Align(
        alignment: Alignment.centerRight,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(
              MemberUIConstants.borderRadiusSmall,
            ),
          ),
          child: Text(
            "${member["points"] ?? 0}P",
            style: TextStyle(
              fontSize: MemberUIConstants.fontSizeXSmall,
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  /// Cell untuk diskon
  DataCell _buildDiscountCell(Map<String, dynamic> member) {
    final discount = member["discount"] ?? 0;
    final discountValue = (discount is int ? discount : 0) * 1000;

    return DataCell(
      Align(
        alignment: Alignment.centerRight,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(
              MemberUIConstants.borderRadiusSmall,
            ),
            border: Border.all(color: Colors.green[200]!, width: 0.5),
          ),
          child: Text(
            "Rp$discountValue",
            style: TextStyle(
              fontSize: MemberUIConstants.fontSizeXSmall,
              color: Colors.green[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  /// Cell untuk action buttons (Edit only)
  DataCell _buildActionCell(Map<String, dynamic> member) {
    return DataCell(
      Align(
        alignment: Alignment.center,
        child: Tooltip(
          message: 'Edit',
          child: IconButton(
            icon: Icon(
              Icons.edit,
              size: 16,
              color: MemberUIConstants.primaryColor,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: () => onEdit(member),
          ),
        ),
      ),
    );
  }

  @override
  int get rowCount => members.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
