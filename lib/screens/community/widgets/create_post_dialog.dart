import 'package:flutter/material.dart';
import '../../../core/state/auth_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/community_model.dart';
import '../../../services/community_service.dart';

class CreatePostDialog extends StatefulWidget {
  final List<CommunityModel> communities;
  final String initialCommunity;
  final VoidCallback onPostCreated;

  const CreatePostDialog({
    super.key,
    required this.communities,
    required this.initialCommunity,
    required this.onPostCreated,
  });

  static Future<void> show(
    BuildContext context, {
    required List<CommunityModel> communities,
    required String initialCommunity,
    required VoidCallback onPostCreated,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => CreatePostDialog(
        communities: communities,
        initialCommunity: initialCommunity,
        onPostCreated: onPostCreated,
      ),
    );
  }

  @override
  State<CreatePostDialog> createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends State<CreatePostDialog> {
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _contentCtrl = TextEditingController();
  final TextEditingController _imageCtrl = TextEditingController();
  final TextEditingController _linkCtrl = TextEditingController();

  late String _selectedComm;
  String _selectedFlair = 'Discussion';
  int _activeTab = 0; // 0: Post, 1: Images, 2: Link
  int _titleLength = 0;
  bool _isSubmitting = false;

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
    if (widget.initialCommunity != 'all' && widget.initialCommunity.isNotEmpty) {
      _selectedComm = widget.initialCommunity;
    } else if (widget.communities.isNotEmpty) {
      _selectedComm = widget.communities.first.name;
    } else {
      _selectedComm = 'r/campus-stitch-feedback';
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _imageCtrl.dispose();
    _linkCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;

    final user = AuthState.instance.user;
    setState(() => _isSubmitting = true);

    final res = await CommunityService.createPost(
      communityName: _selectedComm,
      title: title,
      content: _contentCtrl.text.trim(),
      flair: _selectedFlair,
      imageUrl: _imageCtrl.text.trim().isNotEmpty ? _imageCtrl.text.trim() : null,
      linkUrl: _linkCtrl.text.trim().isNotEmpty ? _linkCtrl.text.trim() : null,
      campusId: AuthState.instance.activeCampusId,
      universityId: user?.universityId,
      authorName: user?.name,
      authorStudentId: user?.studentId,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (res.success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post published successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      widget.onPostCreated();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message ?? 'Failed to publish post'),
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
                      Icon(Icons.chat_bubble_outline, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Create a Post',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
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

              // Choose Community
              const Text('Choose Community', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: widget.communities.any((c) => c.name == _selectedComm)
                    ? _selectedComm
                    : (widget.communities.isNotEmpty ? widget.communities.first.name : null),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.zinc100,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: widget.communities.isNotEmpty
                    ? widget.communities.map((c) {
                        return DropdownMenuItem(
                          value: c.name,
                          child: Text(
                            '${c.name} — ${c.title}',
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList()
                    : [
                        DropdownMenuItem(
                          value: _selectedComm,
                          child: Text(_selectedComm, style: const TextStyle(fontSize: 12)),
                        ),
                      ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedComm = val);
                },
              ),
              const SizedBox(height: 14),

              // Post Type Tabs (Post, Images, Link)
              Container(
                decoration: BoxDecoration(
                  color: AppColors.zinc100,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _activeTab = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _activeTab == 0 ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: _activeTab == 0
                                ? [const BoxShadow(color: Colors.black12, blurRadius: 2)]
                                : null,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat_bubble_outline, size: 14),
                              SizedBox(width: 4),
                              Text('Post', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _activeTab = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _activeTab == 1 ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: _activeTab == 1
                                ? [const BoxShadow(color: Colors.black12, blurRadius: 2)]
                                : null,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_outlined, size: 14),
                              SizedBox(width: 4),
                              Text('Images', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _activeTab = 2),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _activeTab == 2 ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: _activeTab == 2
                                ? [const BoxShadow(color: Colors.black12, blurRadius: 2)]
                                : null,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.link, size: 14),
                              SizedBox(width: 4),
                              Text('Link', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Select Flair
              const Text('Select Flair', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _flairs.map((flair) {
                  final isSel = _selectedFlair == flair;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFlair = flair),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSel ? Colors.black : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSel ? Colors.black : AppColors.zinc300,
                        ),
                      ),
                      child: Text(
                        flair,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSel ? Colors.white : AppColors.zinc700,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // Title with counter
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Title', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  Text('$_titleLength/300', style: const TextStyle(fontSize: 10, color: AppColors.zinc400)),
                ],
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _titleCtrl,
                maxLength: 300,
                onChanged: (v) => setState(() => _titleLength = v.length),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'Title of your post',
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

              // Optional Image or Link field
              if (_activeTab == 1) ...[
                const Text('Image URL', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextField(
                  controller: _imageCtrl,
                  decoration: InputDecoration(
                    hintText: 'https://example.com/image.png',
                    hintStyle: const TextStyle(fontSize: 13, color: AppColors.zinc400),
                    filled: true,
                    fillColor: AppColors.zinc100,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 14),
              ] else if (_activeTab == 2) ...[
                const Text('Link URL', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextField(
                  controller: _linkCtrl,
                  decoration: InputDecoration(
                    hintText: 'https://example.com',
                    hintStyle: const TextStyle(fontSize: 13, color: AppColors.zinc400),
                    filled: true,
                    fillColor: AppColors.zinc100,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Content Area
              const Text('Content (Text / Markdown)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextField(
                controller: _contentCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'What is on your mind?',
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

              // Actions
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
                        : const Text('Post to Community'),
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
