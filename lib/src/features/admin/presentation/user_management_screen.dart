import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitx/constants.dart';
import 'package:fitx/src/core/auth/app_role.dart';
import 'package:fitx/src/core/auth/auth_controller.dart';
import 'package:fitx/src/core/providers/firebase_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// شاشة إدارة المستخدمين للـ Admin/SuperAdmin
/// - إنشاء مستخدم جديد
/// - تعديل دور المستخدم
/// - تعطيل/تفعيل حساب
/// - تعيين المستخدمين للجيمات والمدربين
class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  String _searchQuery = '';
  AppRole? _filterRole;
  String? _filterGymId;
  bool _showDisabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'إدارة المستخدمين',
          style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Global App Disable Button
          IconButton(
            icon: const Icon(Icons.block, color: errorColor),
            onPressed: () => _showGlobalDisableDialog(context),
            tooltip: 'تعطيل التطبيق',
          ),
          // Add User Button
          IconButton(
            icon: const Icon(Icons.person_add, color: primaryColor),
            onPressed: () => _showCreateUserDialog(context),
            tooltip: 'إضافة مستخدم',
          ),
          const SizedBox(width: spaceSm),
        ],
      ),
      body: Column(
        children: [
          // Search & Filters
          _buildFilters(),
          
          // Users List
          Expanded(
            child: _buildUsersList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateUserDialog(context),
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add, color: Color(0xFF1A1A00)),
        label: const Text(
          'مستخدم جديد',
          style: TextStyle(color: Color(0xFF1A1A00)),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      child: Column(
        children: [
          // Search
          TextField(
            onChanged: (v) => setState(() => _searchQuery = v),
            style: const TextStyle(color: textPrimary),
            decoration: InputDecoration(
              hintText: 'بحث بالاسم أو الإيميل...',
              hintStyle: const TextStyle(color: textTertiary),
              prefixIcon: const Icon(Icons.search, color: textTertiary),
              filled: true,
              fillColor: surfaceColorLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radiusMd),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: spaceMd),
          
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Role Filter
                _FilterChip(
                  label: 'الكل',
                  isSelected: _filterRole == null,
                  onTap: () => setState(() => _filterRole = null),
                ),
                const SizedBox(width: spaceSm),
                _FilterChip(
                  label: 'متدرب',
                  isSelected: _filterRole == AppRole.trainee,
                  onTap: () => setState(() => _filterRole = AppRole.trainee),
                ),
                const SizedBox(width: spaceSm),
                _FilterChip(
                  label: 'مدرب',
                  isSelected: _filterRole == AppRole.trainer,
                  onTap: () => setState(() => _filterRole = AppRole.trainer),
                ),
                const SizedBox(width: spaceSm),
                _FilterChip(
                  label: 'جيم',
                  isSelected: _filterRole == AppRole.gym,
                  onTap: () => setState(() => _filterRole = AppRole.gym),
                ),
                const SizedBox(width: spaceSm),
                _FilterChip(
                  label: 'أدمن',
                  isSelected: _filterRole == AppRole.admin,
                  onTap: () => setState(() => _filterRole = AppRole.admin),
                ),
              ],
            ),
          ),
          const SizedBox(height: spaceSm),
          
          // Show disabled toggle
          Row(
            children: [
              Checkbox(
                value: _showDisabled,
                onChanged: (v) => setState(() => _showDisabled = v ?? false),
                activeColor: errorColor,
              ),
              const Text(
                'إظهار الحسابات المعطلة',
                style: TextStyle(color: textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getUsersStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: primaryColor),
          );
        }

        final docs = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final name = (data['name'] ?? '').toString().toLowerCase();
          final email = (data['email'] ?? '').toString().toLowerCase();
          final query = _searchQuery.toLowerCase();
          
          return name.contains(query) || email.contains(query);
        }).toList();

        if (docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: textTertiary),
                SizedBox(height: spaceMd),
                Text(
                  'لا يوجد مستخدمين',
                  style: TextStyle(color: textSecondary, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            
            return _UserCard(
              userId: doc.id,
              data: data,
              onEdit: () => _showEditUserDialog(context, doc.id, data),
              onDisable: () => _toggleUserStatus(doc.id, data),
              onDelete: () => _confirmDeleteUser(doc.id, data),
              onChangeRole: () => _showChangeRoleDialog(context, doc.id, data),
              onAssignGym: () => _showAssignGymDialog(context, doc.id, data),
            );
          },
        );
      },
    );
  }

  Stream<QuerySnapshot> _getUsersStream() {
    var query = ref.read(firestoreProvider)
        .collection('users')
        .orderBy('createdAt', descending: true);

    if (_filterRole != null) {
      query = query.where('role', isEqualTo: _filterRole!.name);
    }

    if (!_showDisabled) {
      query = query.where('isDisabled', isEqualTo: false);
    }

    return query.snapshots();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Dialogs
  // ───────────────────────────────────────────────────────────────────────────

  void _showCreateUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _CreateUserDialog(),
    );
  }

  void _showEditUserDialog(BuildContext context, String userId, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => _EditUserDialog(userId: userId, data: data),
    );
  }

  void _showChangeRoleDialog(BuildContext context, String userId, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => _ChangeRoleDialog(userId: userId, currentRole: data['role'] ?? 'trainee'),
    );
  }

  void _showAssignGymDialog(BuildContext context, String userId, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => _AssignGymDialog(userId: userId, currentGymId: data['gymId']),
    );
  }

  void _showGlobalDisableDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: bgColor,
        title: const Row(
          children: [
            Icon(Icons.warning, color: errorColor),
            SizedBox(width: spaceSm),
            Text('تعطيل التطبيق', style: TextStyle(color: errorColor)),
          ],
        ),
        content: const Text(
          'هل تريد تعطيل التطبيق عن جميع المستخدمين؟\n\nهذا الإجراء خطير جداً!',
          style: TextStyle(color: textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(color: textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              await _setGlobalDisable(true);
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: errorColor),
            child: const Text('تعطيل', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Actions
  // ───────────────────────────────────────────────────────────────────────────

  Future<void> _toggleUserStatus(String userId, Map<String, dynamic> data) async {
    final isCurrentlyDisabled = data['isDisabled'] ?? false;
    
    await ref.read(firestoreProvider)
        .collection('users')
        .doc(userId)
        .update({
      'isDisabled': !isCurrentlyDisabled,
      'disabledAt': !isCurrentlyDisabled ? FieldValue.serverTimestamp() : null,
      'disabledBy': !isCurrentlyDisabled 
          ? ref.read(authStateProvider).value?.uid 
          : null,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCurrentlyDisabled ? 'تم تفعيل المستخدم' : 'تم تعطيل المستخدم'),
        backgroundColor: isCurrentlyDisabled ? Colors.green : errorColor,
      ),
    );
  }

  Future<void> _confirmDeleteUser(String userId, Map<String, dynamic> data) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: bgColor,
        title: const Text('حذف المستخدم', style: TextStyle(color: errorColor)),
        content: Text(
          'هل أنت متأكد من حذف ${data['name'] ?? 'هذا المستخدم'}؟\nهذا الإجراء لا يمكن التراجع عنه!',
          style: const TextStyle(color: textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء', style: TextStyle(color: textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: errorColor),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Delete from Firestore
        await ref.read(firestoreProvider).collection('users').doc(userId).delete();
        
        // Try to delete from Auth (requires Admin SDK)
        // This would need Cloud Function
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف المستخدم'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في الحذف: $e'),
            backgroundColor: errorColor,
          ),
        );
      }
    }
  }

  Future<void> _setGlobalDisable(bool disable) async {
    await ref.read(firestoreProvider).collection('app_config').doc('global').set({
      'isDisabled': disable,
      'disabledAt': disable ? FieldValue.serverTimestamp() : null,
      'disabledBy': disable ? ref.read(authStateProvider).value?.uid : null,
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(disable ? 'تم تعطيل التطبيق عالمياً' : 'تم تفعيل التطبيق'),
        backgroundColor: disable ? errorColor : Colors.green,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter Chip Widget
// ─────────────────────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : surfaceColorLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF1A1A00) : textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// User Card Widget
// ─────────────────────────────────────────────────────────────────────────────

class _UserCard extends StatelessWidget {
  final String userId;
  final Map<String, dynamic> data;
  final VoidCallback onEdit;
  final VoidCallback onDisable;
  final VoidCallback onDelete;
  final VoidCallback onChangeRole;
  final VoidCallback onAssignGym;

  const _UserCard({
    required this.userId,
    required this.data,
    required this.onEdit,
    required this.onDisable,
    required this.onDelete,
    required this.onChangeRole,
    required this.onAssignGym,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = data['isDisabled'] ?? false;
    final role = data['role'] as String? ?? 'trainee';
    final roleColor = _getRoleColor(role);
    
    return Container(
      margin: const EdgeInsets.only(bottom: spaceMd),
      decoration: BoxDecoration(
        color: isDisabled ? surfaceColorLight.withOpacity(0.5) : surfaceColorLight,
        borderRadius: BorderRadius.circular(radiusLg),
        border: Border.all(
          color: isDisabled ? errorColor.withOpacity(0.3) : Colors.transparent,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(spaceMd),
        leading: CircleAvatar(
          backgroundColor: roleColor.withOpacity(0.2),
          child: Icon(
            _getRoleIcon(role),
            color: roleColor,
            size: 20,
          ),
        ),
        title: Text(
          data['name'] ?? 'بدون اسم',
          style: TextStyle(
            color: isDisabled ? textTertiary : textPrimary,
            fontWeight: FontWeight.bold,
            decoration: isDisabled ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data['email'] ?? 'بدون إيميل',
              style: const TextStyle(color: textSecondary),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getRoleLabel(role),
                    style: TextStyle(
                      color: roleColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (data['gymName'] != null) ...[
                  const SizedBox(width: spaceSm),
                  const Icon(Icons.business, size: 14, color: textTertiary),
                  const SizedBox(width: 4),
                  Text(
                    data['gymName'],
                    style: const TextStyle(color: textTertiary, fontSize: 12),
                  ),
                ],
                if (isDisabled) ...[
                  const SizedBox(width: spaceSm),
                  const Icon(Icons.block, size: 14, color: errorColor),
                  const SizedBox(width: 4),
                  const Text(
                    'معطل',
                    style: TextStyle(color: errorColor, fontSize: 12),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: textTertiary),
          color: surfaceColorLight,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, color: textPrimary, size: 20),
                  SizedBox(width: 8),
                  Text('تعديل', style: TextStyle(color: textPrimary)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'role',
              child: Row(
                children: [
                  Icon(Icons.admin_panel_settings, color: primaryColor, size: 20),
                  SizedBox(width: 8),
                  Text('تغيير الدور', style: TextStyle(color: textPrimary)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'gym',
              child: Row(
                children: [
                  Icon(Icons.business, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Text('تعيين جيم', style: TextStyle(color: textPrimary)),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'disable',
              child: Row(
                children: [
                  Icon(
                    isDisabled ? Icons.check_circle : Icons.block, 
                    color: isDisabled ? Colors.green : errorColor, 
                    size: 20
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isDisabled ? 'تفعيل' : 'تعطيل', 
                    style: const TextStyle(color: textPrimary)
                  ),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: errorColor, size: 20),
                  SizedBox(width: 8),
                  Text('حذف', style: TextStyle(color: errorColor)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit();
              case 'role':
                onChangeRole();
              case 'gym':
                onAssignGym();
              case 'disable':
                onDisable();
              case 'delete':
                onDelete();
            }
          },
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'superAdmin':
        return Colors.purple;
      case 'admin':
        return Colors.red;
      case 'gym':
        return Colors.blue;
      case 'trainer':
        return Colors.orange;
      case 'trainee':
        return Colors.green;
      default:
        return textTertiary;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'superAdmin':
      case 'admin':
        return Icons.admin_panel_settings;
      case 'gym':
        return Icons.business;
      case 'trainer':
        return Icons.school;
      case 'trainee':
        return Icons.person;
      default:
        return Icons.person_outline;
    }
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'superAdmin':
        return 'سوبر أدمن';
      case 'admin':
        return 'أدمن';
      case 'gym':
        return 'جيم';
      case 'trainer':
        return 'مدرب';
      case 'trainee':
        return 'متدرب';
      default:
        return role;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Create User Dialog
// ─────────────────────────────────────────────────────────────────────────────

class _CreateUserDialog extends ConsumerStatefulWidget {
  const _CreateUserDialog();

  @override
  ConsumerState<_CreateUserDialog> createState() => _CreateUserDialogState();
}

class _CreateUserDialogState extends ConsumerState<_CreateUserDialog> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  AppRole _selectedRole = AppRole.trainee;
  String? _selectedGymId;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: bgColor,
      title: const Text('إنشاء مستخدم جديد', style: TextStyle(color: textPrimary)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameCtrl,
              style: const TextStyle(color: textPrimary),
              decoration: const InputDecoration(
                labelText: 'الاسم',
                labelStyle: TextStyle(color: textSecondary),
                prefixIcon: Icon(Icons.person, color: textTertiary),
              ),
            ),
            const SizedBox(height: spaceMd),
            TextField(
              controller: _emailCtrl,
              style: const TextStyle(color: textPrimary),
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'البريد الإلكتروني',
                labelStyle: TextStyle(color: textSecondary),
                prefixIcon: Icon(Icons.email, color: textTertiary),
              ),
            ),
            const SizedBox(height: spaceMd),
            TextField(
              controller: _passwordCtrl,
              style: const TextStyle(color: textPrimary),
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'كلمة المرور',
                labelStyle: TextStyle(color: textSecondary),
                prefixIcon: Icon(Icons.lock, color: textTertiary),
              ),
            ),
            const SizedBox(height: spaceMd),
            DropdownButtonFormField<AppRole>(
              value: _selectedRole,
              dropdownColor: surfaceColorLight,
              decoration: const InputDecoration(
                labelText: 'الدور',
                labelStyle: TextStyle(color: textSecondary),
              ),
              items: AppRole.values.map((role) {
                return DropdownMenuItem(
                  value: role,
                  child: Text(
                    _getRoleLabel(role.name),
                    style: const TextStyle(color: textPrimary),
                  ),
                );
              }).toList(),
              onChanged: (v) => setState(() => _selectedRole = v!),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء', style: TextStyle(color: textSecondary)),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createUser,
          style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1A1A00)),
                )
              : const Text('إنشاء', style: TextStyle(color: Color(0xFF1A1A00))),
        ),
      ],
    );
  }

  Future<void> _createUser() async {
    if (_nameCtrl.text.isEmpty || _emailCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى ملء جميع الحقول'), backgroundColor: errorColor),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create user in Firebase Auth
      final authResult = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );

      final uid = authResult.user!.uid;

      // Create user document in Firestore
      await ref.read(firestoreProvider).collection('users').doc(uid).set({
        'uid': uid,
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'role': _selectedRole.name,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': ref.read(authStateProvider).value?.uid,
        'isDisabled': false,
        'accessCode': (100000 + DateTime.now().millisecondsSinceEpoch % 900000).toString(),
        'qrData': 'fitx:$uid:${(100000 + DateTime.now().millisecondsSinceEpoch % 900000)}',
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إنشاء المستخدم بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: errorColor,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'superAdmin':
        return 'سوبر أدمن';
      case 'admin':
        return 'أدمن';
      case 'gym':
        return 'جيم';
      case 'trainer':
        return 'مدرب';
      case 'trainee':
        return 'متدرب';
      default:
        return role;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Edit User Dialog
// ─────────────────────────────────────────────────────────────────────────────

class _EditUserDialog extends ConsumerStatefulWidget {
  final String userId;
  final Map<String, dynamic> data;

  const _EditUserDialog({required this.userId, required this.data});

  @override
  ConsumerState<_EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends ConsumerState<_EditUserDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.data['name'] ?? '');
    _emailCtrl = TextEditingController(text: widget.data['email'] ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: bgColor,
      title: const Text('تعديل المستخدم', style: TextStyle(color: textPrimary)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameCtrl,
              style: const TextStyle(color: textPrimary),
              decoration: const InputDecoration(
                labelText: 'الاسم',
                labelStyle: TextStyle(color: textSecondary),
                prefixIcon: Icon(Icons.person, color: textTertiary),
              ),
            ),
            const SizedBox(height: spaceMd),
            TextField(
              controller: _emailCtrl,
              style: const TextStyle(color: textPrimary),
              enabled: false, // Email cannot be changed easily
              decoration: const InputDecoration(
                labelText: 'البريد الإلكتروني (غير قابل للتعديل)',
                labelStyle: TextStyle(color: textTertiary),
                prefixIcon: Icon(Icons.email, color: textTertiary),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء', style: TextStyle(color: textSecondary)),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _updateUser,
          style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1A1A00)),
                )
              : const Text('حفظ', style: TextStyle(color: Color(0xFF1A1A00))),
        ),
      ],
    );
  }

  Future<void> _updateUser() async {
    setState(() => _isLoading = true);

    try {
      await ref.read(firestoreProvider).collection('users').doc(widget.userId).update({
        'name': _nameCtrl.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث المستخدم'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: errorColor,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Change Role Dialog
// ─────────────────────────────────────────────────────────────────────────────

class _ChangeRoleDialog extends ConsumerStatefulWidget {
  final String userId;
  final String currentRole;

  const _ChangeRoleDialog({required this.userId, required this.currentRole});

  @override
  ConsumerState<_ChangeRoleDialog> createState() => _ChangeRoleDialogState();
}

class _ChangeRoleDialogState extends ConsumerState<_ChangeRoleDialog> {
  late AppRole _selectedRole;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedRole = AppRole.values.firstWhere(
      (r) => r.name == widget.currentRole,
      orElse: () => AppRole.trainee,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: bgColor,
      title: const Text('تغيير الدور', style: TextStyle(color: textPrimary)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'اختر الدور الجديد:',
              style: TextStyle(color: textSecondary),
            ),
            const SizedBox(height: spaceMd),
            ...AppRole.values.map((role) {
              return RadioListTile<AppRole>(
                title: Text(
                  _getRoleLabel(role.name),
                  style: const TextStyle(color: textPrimary),
                ),
                value: role,
                groupValue: _selectedRole,
                activeColor: primaryColor,
                onChanged: (v) => setState(() => _selectedRole = v!),
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء', style: TextStyle(color: textSecondary)),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _changeRole,
          style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1A1A00)),
                )
              : const Text('حفظ', style: TextStyle(color: Color(0xFF1A1A00))),
        ),
      ],
    );
  }

  Future<void> _changeRole() async {
    if (_selectedRole.name == widget.currentRole) {
      Navigator.pop(context);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(firestoreProvider).collection('users').doc(widget.userId).update({
        'role': _selectedRole.name,
        'roleChangedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تغيير الدور'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: errorColor,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'superAdmin':
        return 'سوبر أدمن';
      case 'admin':
        return 'أدمن';
      case 'gym':
        return 'جيم';
      case 'trainer':
        return 'مدرب';
      case 'trainee':
        return 'متدرب';
      default:
        return role;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Assign Gym Dialog
// ─────────────────────────────────────────────────────────────────────────────

class _AssignGymDialog extends ConsumerStatefulWidget {
  final String userId;
  final String? currentGymId;

  const _AssignGymDialog({required this.userId, this.currentGymId});

  @override
  ConsumerState<_AssignGymDialog> createState() => _AssignGymDialogState();
}

class _AssignGymDialogState extends ConsumerState<_AssignGymDialog> {
  String? _selectedGymId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedGymId = widget.currentGymId;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: bgColor,
      title: const Text('تعيين الجيم', style: TextStyle(color: textPrimary)),
      content: SizedBox(
        width: double.maxFinite,
        child: StreamBuilder<QuerySnapshot>(
          stream: ref.read(firestoreProvider)
              .collection('gyms')
              .where('isActive', isEqualTo: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: primaryColor),
              );
            }

            final gyms = snapshot.data!.docs;

            if (gyms.isEmpty) {
              return const Text(
                'لا يوجد جيمات متاحة',
                style: TextStyle(color: textSecondary),
              );
            }

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'اختر الجيم:',
                    style: TextStyle(color: textSecondary),
                  ),
                  const SizedBox(height: spaceMd),
                  ...gyms.map((gym) {
                    final data = gym.data() as Map<String, dynamic>;
                    final isSelected = gym.id == _selectedGymId;

                    return RadioListTile<String>(
                      title: Text(
                        data['name'] ?? 'بدون اسم',
                        style: const TextStyle(color: textPrimary),
                      ),
                      subtitle: Text(
                        data['location'] ?? '',
                        style: const TextStyle(color: textTertiary, fontSize: 12),
                      ),
                      value: gym.id,
                      groupValue: _selectedGymId,
                      activeColor: primaryColor,
                      onChanged: (v) => setState(() => _selectedGymId = v),
                    );
                  }),
                  if (_selectedGymId != null)
                    TextButton(
                      onPressed: () => setState(() => _selectedGymId = null),
                      child: const Text('إلغاء تعيين الجيم', style: TextStyle(color: errorColor)),
                    ),
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء', style: TextStyle(color: textSecondary)),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _assignGym,
          style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1A1A00)),
                )
              : const Text('حفظ', style: TextStyle(color: Color(0xFF1A1A00))),
        ),
      ],
    );
  }

  Future<void> _assignGym() async {
    setState(() => _isLoading = true);

    try {
      if (_selectedGymId == null) {
        // Remove gym assignment
        await ref.read(firestoreProvider).collection('users').doc(widget.userId).update({
          'gymId': FieldValue.delete(),
          'gymName': FieldValue.delete(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Get gym name
        final gymDoc = await ref.read(firestoreProvider)
            .collection('gyms')
            .doc(_selectedGymId)
            .get();
        
        final gymName = gymDoc.data()?['name'] ?? 'بدون اسم';

        await ref.read(firestoreProvider).collection('users').doc(widget.userId).update({
          'gymId': _selectedGymId,
          'gymName': gymName,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث تعيين الجيم'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: errorColor,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
