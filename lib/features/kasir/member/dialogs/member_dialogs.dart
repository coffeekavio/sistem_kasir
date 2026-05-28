import 'package:flutter/material.dart';
import 'package:kasir/features/kasir/member/models/member_constants.dart';
import 'package:kasir/features/kasir/member/widgets/member_dialog.dart';
import 'package:kasir/features/kasir/member/helpers/member_operation_helper.dart';

/// Centralized dialogs untuk member operations
class MemberDialogs {
  /// Dialog untuk menambah member baru
  static Future<bool> showAddMemberDialog({
    required BuildContext context,
    required TextEditingController nameController,
    required TextEditingController phoneController,
    required Future<void> Function(String, String) onSave,
    required bool isLoading,
  }) async {
    nameController.clear();
    phoneController.clear();
    final parentContext = context;
    bool isSuccess = false;

    await showDialog(
      context: context,
      barrierDismissible: !isLoading,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              MemberUIConstants.borderRadiusLarge,
            ),
          ),
          title: MemberDialogField.buildDialogTitle(
            title: 'Tambah Member Baru',
            icon: Icons.person_add,
          ),
          titlePadding: EdgeInsets.fromLTRB(16, 16, 16, 12),
          contentPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MemberDialogField.buildTextField(
                    controller: nameController,
                    label: "Nama Member",
                    hint: "Masukkan nama lengkap",
                    icon: Icons.person,
                    autofocus: true,
                  ),
                  SizedBox(height: MemberUIConstants.spacingMedium),
                  MemberDialogField.buildTextField(
                    controller: phoneController,
                    label: "Nomor HP",
                    hint: "08xxxxxxxxxx",
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(dialogContext),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: Text(
                'Batal',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: MemberUIConstants.fontSizeRegular,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: MemberUIConstants.primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    MemberUIConstants.borderRadiusMedium,
                  ),
                ),
                elevation: 0,
              ),
              onPressed:
                  isLoading
                      ? null
                      : () async {
                        // Validate input
                        final error = MemberOperationHelper.validateMemberInput(
                          name: nameController.text,
                          phone: phoneController.text,
                        );

                        if (error != null) {
                          if (dialogContext.mounted) {
                            MemberOperationHelper.showSnackBar(
                              context: dialogContext,
                              message: error,
                              isSuccess: false,
                            );
                          }
                          return;
                        }

                        try {
                          await onSave(
                            nameController.text,
                            phoneController.text,
                          );

                          Navigator.pop(dialogContext);
                          isSuccess = true;

                          // Show success message with parent context
                          Future.delayed(
                            MemberUIConstants.shortAnimationDuration,
                            () {
                              if (parentContext.mounted) {
                                MemberOperationHelper.showSnackBar(
                                  context: parentContext,
                                  message:
                                      'Member "${nameController.text}" berhasil ditambahkan',
                                  isSuccess: true,
                                );
                              }
                            },
                          );
                        } catch (e) {
                          Navigator.pop(dialogContext);

                          Future.delayed(
                            MemberUIConstants.shortAnimationDuration,
                            () {
                              if (parentContext.mounted) {
                                MemberOperationHelper.showSnackBar(
                                  context: parentContext,
                                  message: 'Gagal menambah member: $e',
                                  isSuccess: false,
                                );
                              }
                            },
                          );
                        }
                      },
              child: Text(
                'Tambah',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: MemberUIConstants.fontSizeRegular,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          actionsPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
        );
      },
    );

    return isSuccess;
  }

  /// Dialog untuk edit member
  static Future<bool> showEditMemberDialog({
    required BuildContext context,
    required Map<String, dynamic> member,
    required TextEditingController nameController,
    required TextEditingController phoneController,
    required Function(String, String) onSave,
  }) async {
    nameController.text = member["name"];
    phoneController.text = member["phone"];
    final parentContext = context;
    bool isSuccess = false;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              MemberUIConstants.borderRadiusLarge,
            ),
          ),
          title: MemberDialogField.buildDialogTitle(
            title: 'Edit Member',
            icon: Icons.edit,
          ),
          titlePadding: EdgeInsets.fromLTRB(16, 16, 16, 12),
          contentPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MemberDialogField.buildTextField(
                    controller: nameController,
                    label: "Nama Member",
                    hint: "Masukkan nama",
                    icon: Icons.person,
                  ),
                  SizedBox(height: MemberUIConstants.spacingMedium),
                  MemberDialogField.buildTextField(
                    controller: phoneController,
                    label: "Nomor HP",
                    hint: "08xxxxxxxxxx",
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: Text(
                'Batal',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: MemberUIConstants.fontSizeRegular,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: MemberUIConstants.primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    MemberUIConstants.borderRadiusMedium,
                  ),
                ),
                elevation: 0,
              ),
              onPressed: () {
                final error = MemberOperationHelper.validateMemberInput(
                  name: nameController.text,
                  phone: phoneController.text,
                );

                if (error != null) {
                  MemberOperationHelper.showSnackBar(
                    context: dialogContext,
                    message: error,
                    isSuccess: false,
                  );
                  return;
                }

                try {
                  onSave(nameController.text, phoneController.text);
                  Navigator.pop(dialogContext);
                  isSuccess = true;

                  Future.delayed(MemberUIConstants.shortAnimationDuration, () {
                    if (parentContext.mounted) {
                      MemberOperationHelper.showSnackBar(
                        context: parentContext,
                        message: 'Member berhasil diperbarui',
                        isSuccess: true,
                      );
                    }
                  });
                } catch (e) {
                  Navigator.pop(dialogContext);
                  Future.delayed(MemberUIConstants.shortAnimationDuration, () {
                    if (parentContext.mounted) {
                      MemberOperationHelper.showSnackBar(
                        context: parentContext,
                        message: 'Gagal memperbarui member: $e',
                        isSuccess: false,
                      );
                    }
                  });
                }
              },
              child: Text(
                'Simpan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: MemberUIConstants.fontSizeRegular,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          actionsPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
        );
      },
    );

    return isSuccess;
  }

  /// Dialog untuk delete member
  static Future<bool> showDeleteMemberDialog({
    required BuildContext context,
    required Map<String, dynamic> member,
    required VoidCallback onConfirm,
  }) async {
    final parentContext = context;
    bool isSuccess = false;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              MemberUIConstants.borderRadiusLarge,
            ),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(
                    MemberUIConstants.borderRadiusSmall,
                  ),
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.red[600],
                  size: MemberUIConstants.iconSizeRegular,
                ),
              ),
              SizedBox(width: MemberUIConstants.spacingMedium),
              Expanded(
                child: Text(
                  'Hapus Member',
                  style: TextStyle(
                    fontSize: MemberUIConstants.fontSizeLarge,
                    fontWeight: FontWeight.bold,
                    color: MemberUIConstants.textPrimaryColor,
                  ),
                ),
              ),
            ],
          ),
          titlePadding: EdgeInsets.fromLTRB(16, 16, 16, 12),
          contentPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
          content: Padding(
            padding: EdgeInsets.symmetric(
              vertical: MemberUIConstants.spacingXSmall,
            ),
            child: Text(
              'Yakin ingin menghapus member "${member["name"]}"?\n\nTindakan ini tidak dapat dibatalkan.',
              style: TextStyle(
                fontSize: MemberUIConstants.fontSizeMedium,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: Text(
                'Batal',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: MemberUIConstants.fontSizeRegular,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    MemberUIConstants.borderRadiusMedium,
                  ),
                ),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                onConfirm();
                isSuccess = true;

                Future.delayed(MemberUIConstants.shortAnimationDuration, () {
                  if (parentContext.mounted) {
                    MemberOperationHelper.showSnackBar(
                      context: parentContext,
                      message: 'Member ${member["name"]} berhasil dihapus',
                      isSuccess: true,
                    );
                  }
                });
              },
              child: Text(
                'Hapus',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: MemberUIConstants.fontSizeRegular,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          actionsPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
        );
      },
    );

    return isSuccess;
  }
}
