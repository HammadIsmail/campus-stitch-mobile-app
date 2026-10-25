import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/community_service.dart';

class CreateCommunityDialog extends StatefulWidget {
  final VoidCallback onCommunityCreated;

  const CreateCommunityDialog({
    super.key,
    required this.onCommunityCreated,
  });

  static Future<void> show(BuildContext context, {required VoidCallback onCommunityCreated}) {
    return showDialog(
      context: context,
      builder: (ctx) => CreateCommunityDialog(onCommunityCreated: onCommunityCreated),
    );
  }

  @override
  State<CreateCommunityDialog> createState() => _CreateCommunityDialogState();
}

class _CreateCommunityDialogState extends State<CreateCommunityDialog> {
  final TextEditingController _handleCtrl = TextEditingController();
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();

  String _selectedCategory = 'Academic / Department';
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Academic / Department',
    'Clubs & Societies',
    'Hostel & Living',
    'General / Campus Life',
    'Buy & Sell',
  ];

  @override
  void dispose() {
    _handleCtrl.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final handle = _handleCtrl.text.trim();
    final title = _titleCtrl.text.trim();
    if (handle.isEmpty || title.isEmpty) return;

    final cleanHandle = handle.startsWith('r/') ? handle : 'r/$handle';
    setState(() => _isSubmitting = true);

    final res = await CommunityService.createCommunity(
      name: cleanHandle,
      title: title,
      description: _descCtrl.text.trim(),
      category: _selectedCategory,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (res.success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sub-community created successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      widget.onCommunityCreated();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message ?? 'Failed to create community'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(20),
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.groups_outlined, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Create Sub-Community',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Community Handle
              const Text('Community Handle', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextField(
                controller: _handleCtrl,
                decoration: InputDecoration(
                  hintText: 'r/ e.g. uet-ai or mech-lab',
                  hintStyle: const TextStyle(fontSize: 13, color: AppColors.zinc400),
                  filled: true,
                  fillColor: AppColors.zinc100,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Display Title
              const Text('Display Title', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextField(
                controller: _titleCtrl,
                decoration: InputDecoration(
                  hintText: 'e.g. UET Artificial Intelligence & Robotics',
                  hintStyle: const TextStyle(fontSize: 13, color: AppColors.zinc400),
                  filled: true,
                  fillColor: AppColors.zinc100,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Category
              const Text('Category', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.zinc100,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: _categories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat, style: const TextStyle(fontSize: 13)));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
              const SizedBox(height: 14),

              // Description & Topic
              const Text('Description & Topic', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'What is this community about? Who is it for?',
                  hintStyle: const TextStyle(fontSize: 13, color: AppColors.zinc400),
                  filled: true,
                  fillColor: AppColors.zinc100,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: AppColors.zinc300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    ),
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Create Community'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
