import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/bike_service.dart';
import '../../services/image_upload_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/sub_header.dart';

class ListBikeScreen extends StatefulWidget {
  final BikeModel? initialBike;

  const ListBikeScreen({super.key, this.initialBike});

  @override
  State<ListBikeScreen> createState() => _ListBikeScreenState();
}

class _ListBikeScreenState extends State<ListBikeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _modelController = TextEditingController();
  final _hourlyRateController = TextEditingController();
  final _dailyRateController = TextEditingController();
  final _pickupSpotController = TextEditingController();

  String? _uploadedImageUrl;
  bool _isUploadingImage = false;

  String _availableFrom = '4:00 PM';
  String _untilTime = '9:00 PM';
  bool _helmetIncluded = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.initialBike != null) {
      final b = widget.initialBike!;
      _modelController.text = b.model;
      _hourlyRateController.text = b.hourlyRate.toInt().toString();
      _dailyRateController.text = b.dailyRate.toInt().toString();
      _pickupSpotController.text = b.location;
      _uploadedImageUrl = b.imageUrl;
    }
  }

  final List<String> _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  final Set<int> _selectedDays = {0, 1, 2, 3, 4}; // Mon - Fri selected by default

  final List<String> _timeOptions = [
    '8:00 AM',
    '10:00 AM',
    '12:00 PM',
    '2:00 PM',
    '4:00 PM',
    '6:00 PM',
    '8:00 PM',
    '9:00 PM',
    '10:00 PM',
  ];

  @override
  void dispose() {
    _modelController.dispose();
    _hourlyRateController.dispose();
    _dailyRateController.dispose();
    _pickupSpotController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final user = AuthService.currentUser;
    final hourly = double.tryParse(_hourlyRateController.text.trim()) ?? 0.0;
    final daily = double.tryParse(_dailyRateController.text.trim()) ?? 0.0;
    final chosenDays = _selectedDays.map((idx) => _days[idx]).toList();

    final isEditing = widget.initialBike != null;
    final res = isEditing
        ? await BikeService.updateBike(
            bikeId: widget.initialBike!.id,
            model: _modelController.text.trim(),
            hourlyRate: hourly,
            dailyRate: daily,
            location: _pickupSpotController.text.trim(),
            imageUrl: _uploadedImageUrl,
          )
        : await BikeService.listBike(
            model: _modelController.text.trim(),
            hourlyRate: hourly,
            dailyRate: daily,
            pickupSpot: _pickupSpotController.text.trim(),
            availableFrom: _availableFrom,
            untilTime: _untilTime,
            days: chosenDays,
            helmetIncluded: _helmetIncluded,
            ownerName: user?.fullName ?? 'Student',
            campusId: user?.campusId,
          );

    if (!mounted) return;

    if (res.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Bike listing updated!' : 'Your bike listing is now live!'),
          backgroundColor: const Color(0xFF0E6B50),
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _isSubmitting = false;
        _errorMessage = res.message ?? (isEditing ? 'Failed to update bike' : 'Failed to list bike');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            SubHeader(
              title: widget.initialBike != null ? 'Edit your bike' : 'List your bike',
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
                                          'Add photos of your bike',
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

                      // Bike model
                      AppTextField(
                        label: 'Bike model',
                        controller: _modelController,
                        hintText: 'e.g. Honda CD 70',
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Enter bike model';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Rs per hour and Rs per day
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Rs per hour',
                              controller: _hourlyRateController,
                              hintText: '80',
                              keyboardType: TextInputType.number,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return 'Enter rate';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppTextField(
                              label: 'Rs per day',
                              controller: _dailyRateController,
                              hintText: '500',
                              keyboardType: TextInputType.number,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return 'Enter rate';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Pickup spot
                      AppTextField(
                        label: 'Pickup spot',
                        controller: _pickupSpotController,
                        hintText: 'e.g. Hostel 2 gate',
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Enter pickup spot';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Available from / Until
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Available from', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: colors.textPrimary)),
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
                                      value: _availableFrom,
                                      isExpanded: true,
                                      icon: Icon(Icons.arrow_drop_down, color: colors.textMuted),
                                      items: _timeOptions.map((t) => DropdownMenuItem(value: t, child: Text(t, style: TextStyle(fontSize: 14, color: colors.textPrimary, fontWeight: FontWeight.w600)))).toList(),
                                      onChanged: (val) {
                                        if (val != null) setState(() => _availableFrom = val);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Until', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: colors.textPrimary)),
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
                                      value: _untilTime,
                                      isExpanded: true,
                                      icon: Icon(Icons.arrow_drop_down, color: colors.textMuted),
                                      items: _timeOptions.map((t) => DropdownMenuItem(value: t, child: Text(t, style: TextStyle(fontSize: 14, color: colors.textPrimary, fontWeight: FontWeight.w600)))).toList(),
                                      onChanged: (val) {
                                        if (val != null) setState(() => _untilTime = val);
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

                      // Days of week
                      Text(
                        'On these days',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: colors.textPrimary),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: List.generate(_days.length, (idx) {
                          final isSelected = _selectedDays.contains(idx);
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    if (_selectedDays.length > 1) _selectedDays.remove(idx);
                                  } else {
                                    _selectedDays.add(idx);
                                  }
                                });
                              },
                              child: Container(
                                height: 44,
                                margin: EdgeInsets.only(right: idx < _days.length - 1 ? 6 : 0),
                                decoration: BoxDecoration(
                                  color: isSelected ? colors.primary : colors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: isSelected ? colors.primary : colors.inputBorder),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  _days[idx],
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                    color: isSelected ? Colors.white : colors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 14),

                      // Helmet included checkbox
                      GestureDetector(
                        onTap: () => setState(() => _helmetIncluded = !_helmetIncluded),
                        child: Container(
                          height: 44,
                          color: Colors.transparent,
                          child: Row(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _helmetIncluded,
                                  activeColor: colors.primary,
                                  onChanged: (val) => setState(() => _helmetIncluded = val ?? true),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Helmet included',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ],
                          ),
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
                text: widget.initialBike != null ? 'Update bike' : 'Publish my bike',
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
