# Member Feature - Dokumentasi Struktur

## 📁 Struktur File

```
lib/features/kasir/member/
├── index_member.dart                    # Main screen (Entry point)
├── dialogs/
│   └── member_dialogs.dart             # Centralized dialogs (Add, Edit, Delete)
├── widgets/
│   ├── member_dialog.dart              # Reusable dialog components
│   └── member_data_source.dart         # Data table source
├── helpers/
│   └── member_operation_helper.dart    # Helper functions & validation
├── models/
│   └── member_constants.dart           # Constants, UI values & Models
```

## 🎯 Best Practices Implementasi

### 1. **Separation of Concerns**

- `index_member.dart`: UI logic & state management
- `member_dialogs.dart`: Dialog business logic
- `member_data_source.dart`: Data table management
- `member_operation_helper.dart`: Utility functions
- `member_constants.dart`: Constants & models

### 2. **Error Handling**

```dart
// Sebelum:
ScaffoldMessenger.of(context).showSnackBar(...) // Error jika context deactivate

// Sesudah:
if (mounted) {
  ScaffoldMessenger.of(context).showSnackBar(...)
}
```

### 3. **Context Safety**

```dart
// Capture parent context sebelum dialog
final parentContext = context;

// Gunakan dialog context untuk dialog operations
// Gunakan parent context untuk snackbar setelah dialog ditutup
```

## 📋 File Descriptions

### `index_member.dart`

**Purpose**: Main screen & state management
**Key Methods**:

- `_loadMembers()`: Fetch member data dengan error handling
- `_addMember()`: Trigger add dialog
- `_editMember()`: Trigger edit dialog
- `_deleteMember()`: Trigger delete dialog
- `_buildHeader()`: UI header dengan search
- `_buildMemberList()`: UI member list

### `member_dialogs.dart`

**Purpose**: Centralized dialog implementations
**Key Methods**:

- `showAddMemberDialog()`: Add member dialog
- `showEditMemberDialog()`: Edit member dialog
- `showDeleteMemberDialog()`: Delete member dialog

**Keuntungan**:

- Reusable dialogs
- Centralized logic
- Easy to test
- Consistent UI

### `member_dialog.dart`

**Purpose**: Reusable UI components untuk dialogs
**Key Methods**:

- `buildTextField()`: Reusable text field
- `buildDialogTitle()`: Reusable dialog title
- `buildActionButtons()`: Reusable action buttons

### `member_data_source.dart`

**Purpose**: DataTable2 data source
**Key Methods**:

- `_buildNumberCell()`: Number column
- `_buildNameCell()`: Name column
- `_buildPhoneCell()`: Phone column
- `_buildPointsCell()`: Points column
- `_buildDiscountCell()`: Discount column
- `_buildActionCell()`: Edit/Delete buttons

### `member_operation_helper.dart`

**Purpose**: Helper functions & validation
**Key Methods**:

- `validateMemberInput()`: Input validation
- `createMember()`: Create member dengan error handling
- `showSnackBar()`: Safe snackbar display
- `isValidPhoneNumber()`: Phone validation

### `member_constants.dart`

**Purpose**: Constants & models
**Content**:

- `MemberUIConstants`: Color, size, spacing constants
- `MemberModel`: Type-safe member model

## ✨ Fitur-Fitur Baru

### 1. **Type Safety**

```dart
// MemberModel untuk type safety
final member = MemberModel.fromMap(memberMap);
final map = member.toMap();
```

### 2. **Centralized Constants**

```dart
// Semua UI constants di satu tempat
const primaryColor = Color(0xFF1E88E5);
const borderRadiusMedium = 8.0;
const fontSizeRegular = 12.0;
```

### 3. **Validation**

```dart
final error = MemberOperationHelper.validateMemberInput(
  name: nameInput,
  phone: phoneInput,
);
if (error != null) {
  // Show error
}
```

### 4. **Error Handling**

- Mounted checks sebelum setState/snackbar
- Context capture untuk dialog safety
- Try-catch di semua async operations

## 🔧 Cara Menggunakan

### Menambah Member

```dart
_addMember(); // Automatic dialog handling
```

### Edit Member

```dart
_editMember(memberData);
```

### Delete Member

```dart
_deleteMember(memberData);
```

## 📱 Maintenance

### Menambah Field Baru

1. Update `MemberModel` di `member_constants.dart`
2. Update dialog di `member_dialogs.dart`
3. Update data source di `member_data_source.dart`
4. Update validation di `member_operation_helper.dart`

### Mengubah UI

1. Update constants di `member_constants.dart`
2. Update widgets di `member_dialog.dart`
3. Widgets otomatis tersync di semua dialogs

### Menambah Validasi

1. Tambah fungsi di `member_operation_helper.dart`
2. Call dari `member_dialogs.dart`

## 🐛 Debugging

### Dialog tidak tampil

- Check context mounted
- Check dialog context vs parent context

### Snackbar error

- Pastikan menggunakan parent context
- Add `if (mounted)` check
- Check Future.delayed timing

### Data tidak update

- Check `setState()` dipanggil
- Check `if (mounted)` condition
- Check async/await chain

## 📚 Referensi

- Flutter Best Practices: Clean Code
- SOLID Principles
- Widget Lifecycle Management
- Context Safety Patterns
