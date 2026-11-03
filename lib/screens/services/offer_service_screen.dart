import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../models/service_model.dart';
import '../../services/auth_service.dart';
import '../../services/campus_service.dart';
import '../../services/image_upload_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/sub_header.dart';

class OfferServiceScreen extends StatefulWidget {
  final CampusServiceModel? initialService;

  const OfferServiceScreen({super.key, this.initialService});

  @override
  State<OfferServiceScreen> createState() => _OfferServiceScreenState();
}

class _OfferServiceScreenState extends State<OfferServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _whatsappController = TextEditingController();

  String? _uploadedImageUrl;
  bool _isUploadingImage = false;

  final List<String> _categories = [
    'Printing',
    'Repair',
    'Laundry',
    'Food',
    'Tutoring',
    'Other',
  ];
  late String _selectedCategory;

  final List<String> _units = ['page', 'kg', 'hour', 'job'];
  late String _selectedUnit;

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedCategory = _categories.first;
    _selectedUnit = _units.first;

    if (widget.initialService != null) {
      final s = widget.initialService!;
      _titleController.text = s.name;
      _locationController.text = s.location;
      _descriptionController.text = s.notes;
      _whatsappController.text = s.phone;
      _uploadedImageUrl = s.imageUrl;

      if (_categories.contains(s.category)) {
        _selectedCategory = s.category;
      }

      // Try to parse rate: e.g. "Rs 5 / page" or "5 / page" or "5"
      final match = RegExp(r'(?:Rs\s*)?(\d+)(?:\s*/\s*(\w+))?').firstMatch(s.rate);
      if (match != null) {
        _priceController.text = match.group(1) ?? '';
        final parsedUnit = match.group(2)?.toLowerCase();
        if (parsedUnit != null && _units.contains(parsedUnit)) {
          _selectedUnit = parsedUnit;
        }
      } else {
        _priceController.text = s.rate;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final user = AuthService.currentUser;
    final rateStr = 'Rs ${_priceController.text.trim()} / $_selectedUnit';
    final isEditing = widget.initialService != null;

    if (isEditing) {
      final ok = await CampusService.updateService(
        id: widget.initialService!.id,
        name: _titleController.text.trim(),
        rate: rateStr,
        category: _selectedCategory,
        location: _locationController.text.trim().isNotEmpty
            ? _locationController.text.trim()
            : 'Campus Hostel',
        schedule: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : 'Daily',
        notes: _descriptionController.text.trim(),
        phone: _whatsappController.text.trim(),
        imageUrl: _uploadedImageUrl,
      );

      if (!mounted) return;
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Service updated successfully!'),
            backgroundColor: Color(0xFF0E6B50),
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _isSubmitting = false;
          _errorMessage = 'Failed to update service';
        });
      }
    } else {
      final res = await CampusService.createService(
        name: _titleController.text.trim(),
        rate: rateStr,
        category: _selectedCategory,
        location: _locationController.text.trim().isNotEmpty
            ? _locationController.text.trim()
            : 'Campus Hostel',
        schedule: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : 'Daily',
        notes: _descriptionController.text.trim(),
        phone: _whatsappController.text.trim(),
        imageUrl: _uploadedImageUrl,
        provider: user?.fullName ?? 'Student',
        campusId: user?.campusId,
        userId: user?.id,
      );

      if (!mounted) return;

      if (res.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Service published to your campus!'),
            backgroundColor: Color(0xFF0E6B50),
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _isSubmitting = false;
          _errorMessage = res.message ?? 'Failed to publish service';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isEditing = widget.initialService != null;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            SubHeader(
              title: isEditing ? 'Edit service' : AppStrings.offerServiceAction,
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
                                          'Add photo of your service',
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

                      // Category selection
                      Text(
                        'Category',
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
                        children: _categories.map((cat) {
                          final isSelected = cat == _selectedCategory;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedCategory = cat),
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
                                cat,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                  color: isSelected ? Colors.white : colors.textPrimary,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),

                      // Service title
                      AppTextField(
                        label: 'Service title',
                        controller: _titleController,
                        hintText: 'e.g. B&W and colour printing',
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter a service title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Description
                      Text(
                        'What do you offer?',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Timings, turnaround, anything students should know',
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
                      const SizedBox(height: 14),

                      // Price and Unit
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: AppTextField(
                              label: 'Price (Rs)',
                              controller: _priceController,
                              hintText: '5',
                              keyboardType: TextInputType.number,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Enter price';
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
                                  'Per',
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
                                    child: DropdownButton<String>(
                                      value: _selectedUnit,
                                      isExpanded: true,
                                      icon: Icon(Icons.arrow_drop_down, color: colors.textMuted),
                                      items: _units.map((unit) {
                                        return DropdownMenuItem<String>(
                                          value: unit,
                                          child: Text(
                                            unit,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: colors.textPrimary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) setState(() => _selectedUnit = val);
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

                      // Location
                      AppTextField(
                        label: 'Hostel and block',
                        controller: _locationController,
                        hintText: 'e.g. Hostel 3, Block B',
                      ),
                      const SizedBox(height: 14),

                      // WhatsApp
                      AppTextField(
                        label: 'WhatsApp number',
                        controller: _whatsappController,
                        hintText: '03XX XXXXXXX',
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

            // Fixed Bottom Action
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border(top: BorderSide(color: colors.border)),
              ),
              child: AppButton(
                text: isEditing ? 'Update service' : 'Publish to my campus',
                isLoading: _isSubmitting,
                onPressed: _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
