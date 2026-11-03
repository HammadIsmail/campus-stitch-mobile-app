import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';
import '../../core/state/auth_state.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/image_upload_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/sub_header.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _deptController;
  late TextEditingController _hostelController;
  String _selectedSemester = '5th';
  String? _avatarUrl;
  bool _isSaving = false;
  bool _isUploadingPhoto = false;

  final List<String> _semesters = [
    '1st', '2nd', '3rd', '4th', '5th', '6th', '7th', '8th',
  ];

  @override
  void initState() {
    super.initState();
    final user = AuthService.currentUser;
    _avatarUrl = user?.avatarUrl;
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _deptController = TextEditingController(text: user?.department ?? '');
    _hostelController = TextEditingController(text: user?.hostelBlock ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _deptController.dispose();
    _hostelController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    setState(() => _isUploadingPhoto = true);
    try {
      final url = await ImageUploadService.pickAndUploadImage();
      if (url != null && mounted) {
        setState(() {
          _avatarUrl = url;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo uploaded! Tap "Save changes" to apply.'),
            backgroundColor: Color(0xFF0E6B50),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error uploading profile picture: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload image: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final user = AuthService.currentUser;
    if (user != null) {
      final updatedUser = user.copyWith(
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        department: _deptController.text.trim(),
        hostelBlock: _hostelController.text.trim(),
        avatarUrl: _avatarUrl,
      );

      // Save locally to cache & state
      await AuthService.saveCurrentUser(updatedUser);
      AuthState.instance.login(updatedUser);

      // Persist to backend Supabase
      try {
        await ApiClient.patch(
          ApiConstants.profile,
          body: {
            'userId': user.id,
            'email': user.email,
            'fullName': _nameController.text.trim(),
            'phone': _phoneController.text.trim(),
            'department': _deptController.text.trim(),
            'hostelBlock': _hostelController.text.trim(),
            'avatarUrl': _avatarUrl ?? '',
          },
        );
      } catch (e) {
        debugPrint('Error syncing profile update to server: $e');
      }
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully!'),
        backgroundColor: Color(0xFF0E6B50),
      ),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final user = AuthService.currentUser;
    final initial = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()[0].toUpperCase()
        : 'U';
    final campusDisplay = '${user?.university ?? 'UET Lahore'}, ${user?.campusName ?? 'Faisalabad Campus'}';

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            SubHeader(
              title: 'Edit profile',
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar row
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _isUploadingPhoto ? null : _pickPhoto,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    color: colors.primary,
                                    borderRadius: BorderRadius.circular(36),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: _avatarUrl != null && _avatarUrl!.isNotEmpty
                                      ? Image.network(
                                          _avatarUrl!,
                                          width: 72,
                                          height: 72,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, _, _) => Center(
                                            child: Text(
                                              initial,
                                              style: const TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.w800,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        )
                                      : Center(
                                          child: Text(
                                            initial,
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                ),
                                if (_isUploadingPhoto)
                                  Container(
                                    width: 72,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      color: Colors.black45,
                                      borderRadius: BorderRadius.circular(36),
                                    ),
                                    child: const Center(
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          InkWell(
                            onTap: _isUploadingPhoto ? null : _pickPhoto,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              height: 44,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: colors.inputBorder),
                              ),
                              alignment: Alignment.center,
                              child: _isUploadingPhoto
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: colors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Uploading...',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: colors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(LucideIcons.camera, size: 16, color: colors.textPrimary),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Change photo',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: colors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          if (_avatarUrl != null && _avatarUrl!.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () {
                                setState(() => _avatarUrl = null);
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                height: 44,
                                width: 44,
                                decoration: BoxDecoration(
                                  color: colors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: colors.inputBorder),
                                ),
                                alignment: Alignment.center,
                                child: Icon(LucideIcons.trash2, size: 18, color: colors.danger),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Full name
                      AppTextField(
                        label: 'Full name',
                        controller: _nameController,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Enter full name';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // WhatsApp number
                      AppTextField(
                        label: 'WhatsApp number',
                        controller: _phoneController,
                        hintText: '03XX XXXXXXX',
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 14),

                      // Department and Semester
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: AppTextField(
                              label: 'Department',
                              controller: _deptController,
                              hintText: 'Computer Science',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Semester', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: colors.textPrimary)),
                                const SizedBox(height: 6),
                                Container(
                                  height: 48,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: colors.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: colors.inputBorder),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedSemester,
                                      isExpanded: true,
                                      icon: Icon(Icons.arrow_drop_down, color: colors.textMuted),
                                      items: _semesters.map((s) => DropdownMenuItem(value: s, child: Text(s, style: TextStyle(fontSize: 14, color: colors.textPrimary, fontWeight: FontWeight.w600)))).toList(),
                                      onChanged: (val) {
                                        if (val != null) setState(() => _selectedSemester = val);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Hostel
                      AppTextField(
                        label: 'Hostel',
                        controller: _hostelController,
                        hintText: 'e.g. Hostel 2, Block A',
                      ),
                      const SizedBox(height: 16),

                      // Campus lock banner
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: colors.skeleton,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(LucideIcons.lock, size: 20, color: colors.textPrimary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    campusDisplay,
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: colors.textPrimary),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Your university and campus cannot be changed after sign up. Contact support if this is wrong.',
                                    style: TextStyle(fontSize: 13, height: 1.45, color: colors.textPrimary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

            // Fixed Bottom CTA
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border(top: BorderSide(color: colors.border)),
              ),
              child: AppButton(
                text: 'Save changes',
                isLoading: _isSaving,
                onPressed: _saveChanges,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
