import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/hostel_model.dart';
import '../../../services/hostel_service.dart';

class EditServiceDialog extends StatefulWidget {
  final HostelServiceModel service;
  final ValueChanged<HostelServiceModel> onUpdated;

  const EditServiceDialog({
    super.key,
    required this.service,
    required this.onUpdated,
  });

  static Future<void> show(
    BuildContext context, {
    required HostelServiceModel service,
    required ValueChanged<HostelServiceModel> onUpdated,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => EditServiceDialog(service: service, onUpdated: onUpdated),
    );
  }

  @override
  State<EditServiceDialog> createState() => _EditServiceDialogState();
}

class _EditServiceDialogState extends State<EditServiceDialog> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _rateCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _scheduleCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _notesCtrl;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.service.name);
    _rateCtrl = TextEditingController(text: widget.service.rate);
    _locationCtrl = TextEditingController(text: widget.service.location);
    _scheduleCtrl = TextEditingController(text: widget.service.schedule);
    _phoneCtrl = TextEditingController(text: widget.service.phone);
    _notesCtrl = TextEditingController(text: widget.service.notes);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _rateCtrl.dispose();
    _locationCtrl.dispose();
    _scheduleCtrl.dispose();
    _phoneCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    final rate = _rateCtrl.text.trim();
    if (title.isEmpty || rate.isEmpty) return;

    setState(() => _isSaving = true);
    final scaffold = ScaffoldMessenger.of(context);

    final success = await HostelService.updateService(
      id: widget.service.id,
      name: title,
      rate: rate,
      location: _locationCtrl.text.trim(),
      schedule: _scheduleCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.pop(context);
      final updated = widget.service.copyWith(
        name: title,
        rate: rate,
        location: _locationCtrl.text.trim(),
        schedule: _scheduleCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        notes: _notesCtrl.text.trim(),
      );
      widget.onUpdated(updated);
      scaffold.showSnackBar(
        const SnackBar(
          content: Text('Campus service updated successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      scaffold.showSnackBar(
        const SnackBar(
          content: Text('Failed to update campus service'),
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
                      'Edit Campus Service',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
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

                Text('Service Title *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
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

                Text('Rate / Charges *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                const SizedBox(height: 6),
                TextField(
                  controller: _rateCtrl,
                  style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark ? AppColors.zinc800 : AppColors.zinc100,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 14),

                Text('Location / Hostel', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                const SizedBox(height: 6),
                TextField(
                  controller: _locationCtrl,
                  style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark ? AppColors.zinc800 : AppColors.zinc100,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 14),

                Text('Available Hours', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                const SizedBox(height: 6),
                TextField(
                  controller: _scheduleCtrl,
                  style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark ? AppColors.zinc800 : AppColors.zinc100,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 14),

                Text('Contact Phone', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                const SizedBox(height: 6),
                TextField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark ? AppColors.zinc800 : AppColors.zinc100,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 14),

                Text('Additional Notes', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                const SizedBox(height: 6),
                TextField(
                  controller: _notesCtrl,
                  maxLines: 2,
                  style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark ? AppColors.zinc800 : AppColors.zinc100,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
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
