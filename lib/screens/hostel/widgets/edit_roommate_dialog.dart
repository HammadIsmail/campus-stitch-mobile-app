import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/hostel_model.dart';
import '../../../services/hostel_service.dart';

class EditRoommateDialog extends StatefulWidget {
  final RoommateModel roommate;
  final ValueChanged<RoommateModel> onUpdated;

  const EditRoommateDialog({
    super.key,
    required this.roommate,
    required this.onUpdated,
  });

  static Future<void> show(
    BuildContext context, {
    required RoommateModel roommate,
    required ValueChanged<RoommateModel> onUpdated,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => EditRoommateDialog(roommate: roommate, onUpdated: onUpdated),
    );
  }

  @override
  State<EditRoommateDialog> createState() => _EditRoommateDialogState();
}

class _EditRoommateDialogState extends State<EditRoommateDialog> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _rentCtrl;
  late final TextEditingController _detailsCtrl;
  late final TextEditingController _customAmenityCtrl;
  late final List<String> _selectedAmenities;

  bool _isSaving = false;

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
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.roommate.title);
    _rentCtrl = TextEditingController(
      text: widget.roommate.monthlyRent > 0
          ? widget.roommate.monthlyRent.toString()
          : widget.roommate.rent.replaceAll(RegExp(r'[^\d]'), ''),
    );
    _detailsCtrl = TextEditingController(text: widget.roommate.details);
    _customAmenityCtrl = TextEditingController();
    _selectedAmenities = List<String>.from(widget.roommate.amenities);
  }

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

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    final rent = _rentCtrl.text.trim();
    if (title.isEmpty || rent.isEmpty) return;

    setState(() => _isSaving = true);
    final scaffold = ScaffoldMessenger.of(context);

    final success = await HostelService.updateRoommate(
      id: widget.roommate.id,
      title: title,
      monthlyRent: rent,
      details: _detailsCtrl.text.trim(),
      amenities: _selectedAmenities,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.pop(context);
      final updated = widget.roommate.copyWith(
        title: title,
        rent: 'Rs. $rent',
        monthlyRent: int.tryParse(rent) ?? 0,
        details: _detailsCtrl.text.trim(),
        amenities: _selectedAmenities,
      );
      widget.onUpdated(updated);
      scaffold.showSnackBar(
        const SnackBar(
          content: Text('Roommate vacancy updated successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      scaffold.showSnackBar(
        const SnackBar(
          content: Text('Failed to update roommate vacancy'),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit Roommate Vacancy',
                      style: TextStyle(
                        fontSize: 16,
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

                Text('Title', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                const SizedBox(height: 6),
                TextField(
                  controller: _titleCtrl,
                  style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark ? AppColors.zinc800 : AppColors.zinc100,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 14),

                Text('Monthly Rent (Rs.)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                const SizedBox(height: 6),
                TextField(
                  controller: _rentCtrl,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark ? AppColors.zinc800 : AppColors.zinc100,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 14),

                Text('Details & Description', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                const SizedBox(height: 6),
                TextField(
                  controller: _detailsCtrl,
                  maxLines: 3,
                  style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark ? AppColors.zinc800 : AppColors.zinc100,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 14),

                Text('Commodities & Amenities', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
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

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _customAmenityCtrl,
                        style: TextStyle(fontSize: 12, color: isDark ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          hintText: 'Add custom commodity...',
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
                      ),
                      onPressed: _addCustomAmenity,
                      child: Text('Add', style: TextStyle(fontSize: 12, color: isDark ? Colors.white : Colors.black)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark ? Colors.white : Colors.black,
                        side: BorderSide(color: isDark ? Colors.white38 : AppColors.zinc300),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Colors.white : Colors.black,
                        foregroundColor: isDark ? Colors.black : Colors.white,
                      ),
                      onPressed: _isSaving ? null : _save,
                      child: _isSaving
                          ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: isDark ? Colors.black : Colors.white))
                          : Text('Save Changes', style: TextStyle(color: isDark ? Colors.black : Colors.white)),
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
