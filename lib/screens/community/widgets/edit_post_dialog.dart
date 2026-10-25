import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/post_model.dart';
import '../../../services/community_service.dart';

class EditPostDialog extends StatefulWidget {
  final PostModel post;
  final ValueChanged<PostModel> onPostUpdated;

  const EditPostDialog({
    super.key,
    required this.post,
    required this.onPostUpdated,
  });

  static Future<void> show(
    BuildContext context, {
    required PostModel post,
    required ValueChanged<PostModel> onPostUpdated,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => EditPostDialog(
        post: post,
        onPostUpdated: onPostUpdated,
      ),
    );
  }

  @override
  State<EditPostDialog> createState() => _EditPostDialogState();
}

class _EditPostDialogState extends State<EditPostDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late String _selectedFlair;
  bool _isSaving = false;

  final List<String> _flairs = [
    'Discussion',
    'Question',
    'Resource',
    'Notice',
    'Carpool',
    'Meme',
    'Event',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post.title);
    _contentController = TextEditingController(text: widget.post.content);
    _selectedFlair = _flairs.contains(widget.post.flair) ? widget.post.flair : 'Discussion';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final newTitle = _titleController.text.trim();
    final newContent = _contentController.text.trim();
    if (newTitle.isEmpty) return;

    setState(() => _isSaving = true);
    final scaffold = ScaffoldMessenger.of(context);

    final success = await CommunityService.updatePost(
      postId: widget.post.id,
      title: newTitle,
      content: newContent,
      flair: _selectedFlair,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.pop(context);
      final updated = widget.post.copyWith(
        title: newTitle,
        content: newContent,
        flair: _selectedFlair,
      );
      widget.onPostUpdated(updated);
      scaffold.showSnackBar(
        const SnackBar(
          content: Text('Post updated successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      scaffold.showSnackBar(
        const SnackBar(
          content: Text('Failed to update post'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Edit Post', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedFlair,
              decoration: const InputDecoration(
                labelText: 'Flair',
                border: OutlineInputBorder(),
              ),
              items: _flairs.map((f) {
                return DropdownMenuItem(value: f, child: Text(f));
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedFlair = val);
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Save'),
        ),
      ],
    );
  }
}
