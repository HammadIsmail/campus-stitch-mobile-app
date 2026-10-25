import 'package:flutter/material.dart';
import '../../../core/state/auth_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/hostel_service.dart';

class PostRoommateDialog extends StatefulWidget {
  final VoidCallback onPosted;

  const PostRoommateDialog({super.key, required this.onPosted});

  static Future<void> show(BuildContext context, {required VoidCallback onPosted}) {
    return showDialog(
      context: context,
      builder: (ctx) => PostRoommateDialog(onPosted: onPosted),
    );
  }

  @override
  State<PostRoommateDialog> createState() => _PostRoommateDialogState();
}

class _PostRoommateDialogState extends State<PostRoommateDialog> {
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _rentCtrl = TextEditingController();
  final TextEditingController _detailsCtrl = TextEditingController();
  final TextEditingController _customAmenityCtrl = TextEditingController();

  final List<String> _selectedAmenities = [];
  bool _isSubmitting = false;

  final List<String> _presetAmenities = [
    'WiFi',
    'Attached Bath',
    'Generator / UPS',
    'AC',
    'Geyser',
    'Mess / Food',
    'Laundry',
    'Study Table',
    'Filtered Water',
    'Cleaning Staff',
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _rentCtrl.dispose();
    _detailsCtrl.dispose();
    _customAmenityCtrl.dispose();
    super.dispose();
  }

  void _addCustomAmenity() {
    final text = _customAmenityCtrl.text.trim();
    if (text.isNotEmpty && !_selectedAmenities.contains(text)) {
      setState(() {
        _selectedAmenities.add(text);
        _customAmenityCtrl.clear();
      });
    }
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    final rent = _rentCtrl.text.trim();
    if (title.isEmpty || rent.isEmpty) return;

    final user = AuthState.instance.user;
    setState(() => _isSubmitting = true);

    final res = await HostelService.createRoommate(
      title: title,
      monthlyRent: rent,
      details: _detailsCtrl.text.trim(),
      amenities: _selectedAmenities,
      campusId: AuthState.instance.activeCampusId,
      universityId: user?.universityId,
      userName: user?.name,
      userId: user?.userId,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (res.success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Roommate vacancy published successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      widget.onPosted();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message ?? 'Failed to publish vacancy'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? AppColors.zinc900 : Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Post Roommate Vacancy',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: 20, color: isDark ? Colors.white70 : Colors.black54),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  'Title',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _titleCtrl,
                  style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    hintText: 'e.g. 1 seat in Block A (3rd Floor)',
                    hintStyle: TextStyle(fontSize: 13, color: isDark ? AppColors.zinc500 : AppColors.zinc400),
                    filled: true,
                    fillColor: isDark ? AppColors.zinc800 : AppColors.zinc100,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 14),

                // Monthly Rent
                Text(
                  'Monthly Rent (Rs.)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _rentCtrl,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    hintText: 'e.g. 8000',
                    hintStyle: TextStyle(fontSize: 13, color: isDark ? AppColors.zinc500 : AppColors.zinc400),
                    filled: true,
                    fillColor: isDark ? AppColors.zinc800 : AppColors.zinc100,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 14),

                // Details & Description
                Text(
                  'Details & Description',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _detailsCtrl,
                  maxLines: 3,
                  style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Describe room condition, roommate preferences, quiet hours...',
                    hintStyle: TextStyle(fontSize: 13, color: isDark ? AppColors.zinc500 : AppColors.zinc400),
                    filled: true,
                    fillColor: isDark ? AppColors.zinc800 : AppColors.zinc100,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 14),

                // Commodities & Amenities
                Row(
                  children: [
                    Text(
                      'Commodities & Amenities ',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                    ),
                    Text('(Tap to select)', style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : AppColors.zinc500)),
                  ],
                ),
                const SizedBox(height: 8),

                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _presetAmenities.map((amenity) {
                    final isSelected = _selectedAmenities.contains(amenity);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedAmenities.remove(amenity);
                          } else {
                            _selectedAmenities.add(amenity);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark ? Colors.white : Colors.black)
                              : (isDark ? AppColors.zinc800 : Colors.white),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? (isDark ? Colors.white : Colors.black)
                                : (isDark ? AppColors.zinc700 : AppColors.zinc300),
                          ),
                        ),
                        child: Text(
                          isSelected ? '✓ $amenity' : '+ $amenity',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? (isDark ? Colors.black : Colors.white)
                                : (isDark ? Colors.white : AppColors.zinc700),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),

                // Custom Commodity Input
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _customAmenityCtrl,
                        style: TextStyle(fontSize: 12, color: isDark ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          hintText: 'Add custom commodity (e.g. Fridge, Balcony).',
                          hintStyle: TextStyle(fontSize: 11, color: isDark ? AppColors.zinc500 : AppColors.zinc400),
                          filled: true,
                          fillColor: isDark ? AppColors.zinc800 : AppColors.zinc100,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark ? Colors.white : Colors.black,
                        side: BorderSide(color: isDark ? Colors.white38 : AppColors.zinc300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      onPressed: _addCustomAmenity,
                      child: Text('Add', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark ? Colors.white : Colors.black,
                        side: BorderSide(color: isDark ? Colors.white38 : AppColors.zinc300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Colors.white : Colors.black,
                        foregroundColor: isDark ? Colors.black : Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      ),
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: isDark ? Colors.black : Colors.white))
                          : Text('Publish Listing', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.black : Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
