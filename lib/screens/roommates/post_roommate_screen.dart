import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/constants/app_constants.dart';
import '../../core/state/auth_state.dart';
import '../../core/theme/app_theme.dart';
import '../../models/roommate_model.dart';
import '../../services/auth_service.dart';
import '../../services/image_upload_service.dart';
import '../../services/roommate_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/segmented_control.dart';
import '../../widgets/sub_header.dart';

class PostRoommateScreen extends StatefulWidget {
  final RoommatePostModel? initialPost;

  const PostRoommateScreen({super.key, this.initialPost});

  @override
  State<PostRoommateScreen> createState() => _PostRoommateScreenState();
}

class _PostRoommateScreenState extends State<PostRoommateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _rentController = TextEditingController();
  final _areaController = TextEditingController();
  final _aboutController = TextEditingController();
  final _customPrefController = TextEditingController();

  String? _uploadedImageUrl;
  bool _isUploadingImage = false;

  int _selectedTypeIndex = 0; // 0: I have a room, 1: I need a room
  int _selectedSeatsOpen = 1;

  final List<String> _presetPreferences = [
    'Non-smoker',
    'Quiet',
    'Early riser',
    'Night owl',
    'Vegetarian',
  ];
  final Set<String> _selectedPreferences = {};
  final List<String> _customPreferences = [];

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.initialPost != null) {
      final p = widget.initialPost!;
      _titleController.text = p.title;
      _rentController.text = p.rentAmount > 0 ? p.rentAmount.toInt().toString() : '';
      _areaController.text = p.area;
      _aboutController.text = p.about;
      _selectedTypeIndex = p.type == 'have_room' ? 0 : 1;
      _selectedSeatsOpen = p.seatsOpen;
      _uploadedImageUrl = p.imageUrl;

      for (final tag in p.tags) {
        if (_presetPreferences.contains(tag)) {
          _selectedPreferences.add(tag);
        } else {
          _customPreferences.add(tag);
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _rentController.dispose();
    _areaController.dispose();
    _aboutController.dispose();
    _customPrefController.dispose();
    super.dispose();
  }

  void _addCustomPreference() {
    final text = _customPrefController.text.trim();
    if (text.isNotEmpty && !_customPreferences.contains(text) && !_selectedPreferences.contains(text)) {
      setState(() {
        _customPreferences.add(text);
        _customPrefController.clear();
      });
    }
  }

  void _removeCustomPreference(String pref) {
    setState(() {
      _customPreferences.remove(pref);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final user = AuthService.currentUser;
    final rentVal = double.tryParse(_rentController.text.trim()) ?? 0.0;
    final allTags = [..._selectedPreferences, ..._customPreferences];
    final isEditing = widget.initialPost != null;

    final res = isEditing
        ? await RoommateService.updatePost(
            id: widget.initialPost!.id,
            title: _titleController.text.trim(),
            rentAmount: rentVal,
            type: _selectedTypeIndex == 0 ? 'have_room' : 'need_room',
            area: _areaController.text.trim(),
            preferences: allTags,
            about: _aboutController.text.trim(),
            imageUrl: _uploadedImageUrl,
          )
        : await RoommateService.createPost(
            title: _titleController.text.trim(),
            rentAmount: rentVal,
            type: _selectedTypeIndex == 0 ? 'have_room' : 'need_room',
            seatsOpen: _selectedSeatsOpen,
            totalSeats: 3,
            area: _areaController.text.trim(),
            preferences: allTags,
            about: _aboutController.text.trim(),
            who: user?.fullName ?? 'Student',
            phone: user?.phone ?? '',
            imageUrl: _uploadedImageUrl,
            campusId: user?.campusId,
            userId: user?.id,
          );

    if (!mounted) return;

    if (res.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Roommate post updated successfully!' : 'Roommate post published to your campus!'),
          backgroundColor: const Color(0xFF0E6B50),
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _isSubmitting = false;
        _errorMessage = res.message ?? (isEditing ? 'Failed to update post' : 'Failed to publish post');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final campusName = AuthState.instance.currentUser?.campusName ?? 'Your Campus';
    final isEditing = widget.initialPost != null;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            SubHeader(
              title: isEditing ? 'Edit roommate post' : 'New roommate post',
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colors.danger.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: colors.danger.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: colors.danger, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Add photos / uploaded photo container
                      GestureDetector(
                        onTap: _isUploadingImage
                            ? null
                            : () async {
                                setState(() => _isUploadingImage = true);
                                final url = await ImageUploadService.pickAndUploadImage();
                                if (mounted) {
                                  setState(() {
                                    _isUploadingImage = false;
                                    if (url != null) _uploadedImageUrl = url;
                                  });
                                }
                              },
                        child: Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colors.inputBorder,
                              width: 1.5,
                            ),
                          ),
                          child: _isUploadingImage
                              ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(strokeWidth: 2.5, color: colors.primary),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Uploading photo...',
                                        style: TextStyle(fontSize: 13, color: colors.textMuted),
                                      ),
                                    ],
                                  ),
                                )
                              : _uploadedImageUrl != null
                                  ? Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(14),
                                          child: Image.network(
                                            _uploadedImageUrl!,
                                            width: double.infinity,
                                            height: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: GestureDetector(
                                            onTap: () => setState(() => _uploadedImageUrl = null),
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withValues(alpha: 0.6),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(LucideIcons.x, size: 16, color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(LucideIcons.plus, size: 24, color: colors.textPrimary),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Add photos of your room',
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
                      const SizedBox(height: 14),

                      // Segmented switcher
                      AppSegmentedControl(
                        segments: const ['I have a room', 'I need a room'],
                        selectedIndex: _selectedTypeIndex,
                        onChanged: (idx) => setState(() => _selectedTypeIndex = idx),
                      ),
                      const SizedBox(height: 14),

                      // Title
                      AppTextField(
                        label: 'Title',
                        controller: _titleController,
                        hintText: 'e.g. One seat open in a 3-person room',
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter a post title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Rent and Seats Open
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: AppTextField(
                              label: 'Rent per person (Rs)',
                              controller: _rentController,
                              hintText: '9000',
                              keyboardType: TextInputType.number,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Enter rent';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Seats open',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: colors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  height: 48,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: colors.surface,
                                    borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
                                    border: Border.all(color: colors.inputBorder),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<int>(
                                      value: _selectedSeatsOpen,
                                      isExpanded: true,
                                      icon: Icon(Icons.arrow_drop_down, color: colors.textMuted),
                                      items: const [
                                        DropdownMenuItem(value: 1, child: Text('1')),
                                        DropdownMenuItem(value: 2, child: Text('2')),
                                        DropdownMenuItem(value: 3, child: Text('3')),
                                      ],
                                      onChanged: (val) {
                                        if (val != null) setState(() => _selectedSeatsOpen = val);
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

                      // Hostel or area
                      AppTextField(
                        label: 'Hostel or area',
                        controller: _areaController,
                        hintText: 'e.g. Hostel 2, Block A',
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Enter hostel or area';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Preferences
                      Text(
                        'Preferences',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ..._presetPreferences.map((pref) {
                            final isSelected = _selectedPreferences.contains(pref);
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedPreferences.remove(pref);
                                  } else {
                                    _selectedPreferences.add(pref);
                                  }
                                });
                              },
                              child: Container(
                                height: 44,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: isSelected ? colors.primary : colors.surface,
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                                  border: Border.all(
                                    color: isSelected ? colors.primary : colors.inputBorder,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  pref,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                    color: isSelected ? Colors.white : colors.textPrimary,
                                  ),
                                ),
                              ),
                            );
                          }),
                          ..._customPreferences.map((customPref) {
                            return Container(
                              height: 44,
                              padding: const EdgeInsets.fromLTRB(16, 0, 6, 0),
                              decoration: BoxDecoration(
                                color: colors.primary,
                                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    customPref,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: () => _removeCustomPreference(customPref),
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      alignment: Alignment.center,
                                      child: const Icon(LucideIcons.x, size: 16, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Add custom preference row
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
                                border: Border.all(color: colors.inputBorder),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              child: TextField(
                                controller: _customPrefController,
                                textAlignVertical: TextAlignVertical.center,
                                style: TextStyle(fontSize: 14, color: colors.textPrimary),
                                decoration: AppTheme.borderlessInput(
                                  hintText: 'Add your own, e.g. No loud music',
                                  hintStyle: TextStyle(fontSize: 14, color: colors.textMuted),
                                ),
                                onSubmitted: (_) => _addCustomPreference(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          AppButton(
                            text: 'Add',
                            width: 84,
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            onPressed: _addCustomPreference,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // About the room
                      Text(
                        'About the room',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _aboutController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'Beds, furniture, Wi-Fi, who you are',
                          hintStyle: TextStyle(color: colors.textMuted, fontSize: 14),
                          filled: true,
                          fillColor: colors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
                            borderSide: BorderSide(color: colors.inputBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
                            borderSide: BorderSide(color: colors.inputBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
                            borderSide: BorderSide(color: colors.primary, width: 2),
                          ),
                          contentPadding: const EdgeInsets.all(14),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

            // Fixed Bottom Area
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border(top: BorderSide(color: colors.border)),
              ),
              child: Column(
                children: [
                  Text(
                    'Visible only to students of $campusName.',
                    style: TextStyle(fontSize: 12, color: colors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  AppButton(
                    text: isEditing ? 'Update post' : 'Post to my campus',
                    isLoading: _isSubmitting,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
