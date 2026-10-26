import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';
import '../../core/state/auth_state.dart';
import '../../core/theme/app_theme.dart';
import '../../services/market_service.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/public_profile_dialog.dart';
import '../../widgets/review_modal.dart';
import '../../widgets/verified_student_badge.dart';
import '../messages/messages_screen.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  String _selectedCategory = 'All';
  List<MarketItemModel> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchListings();
  }

  Future<void> _fetchListings() async {
    setState(() => _isLoading = true);
    final campusId = AuthState.instance.activeCampusId;
    final list = await MarketService.getListings(
      campusId: campusId,
      category: _selectedCategory,
    );
    if (mounted) {
      setState(() {
        _items = list;
        _isLoading = false;
      });
    }
  }

  Widget _buildItemImage(String? imageUrl, bool isDark, {double height = 80, double? width, BoxFit fit = BoxFit.cover}) {
    if (imageUrl == null || imageUrl.trim().isEmpty) {
      return Container(
        height: height,
        width: width ?? double.infinity,
        color: isDark ? AppColors.zinc800 : AppColors.zinc100,
        child: Icon(Icons.inventory_2_outlined, size: 28, color: isDark ? AppColors.zinc500 : AppColors.zinc400),
      );
    }

    final trimmed = imageUrl.trim();

    if (trimmed.startsWith('data:image')) {
      try {
        final commaIdx = trimmed.indexOf(',');
        if (commaIdx != -1) {
          final base64Str = trimmed.substring(commaIdx + 1);
          final bytes = base64Decode(base64Str);
          return Image.memory(
            bytes,
            height: height,
            width: width ?? double.infinity,
            fit: fit,
            errorBuilder: (context, error, stackTrace) => Container(
              height: height,
              width: width ?? double.infinity,
              color: isDark ? AppColors.zinc800 : AppColors.zinc100,
              child: Icon(Icons.broken_image_outlined, size: 28, color: isDark ? AppColors.zinc500 : AppColors.zinc400),
            ),
          );
        }
      } catch (_) {}
    }

    return Image.network(
      trimmed,
      height: height,
      width: width ?? double.infinity,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: height,
          width: width ?? double.infinity,
          color: isDark ? AppColors.zinc800 : AppColors.zinc100,
          child: const Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => Container(
        height: height,
        width: width ?? double.infinity,
        color: isDark ? AppColors.zinc800 : AppColors.zinc100,
        child: Icon(Icons.broken_image_outlined, size: 28, color: isDark ? AppColors.zinc500 : AppColors.zinc400),
      ),
    );
  }

  void _showSellModal() {
    final titleCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String condition = 'Like new';
    String category = 'Books';
    Uint8List? imageBytes;
    String? imageName;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return StatefulBuilder(
          builder: (ctx, setModalState) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Sell an Item on Campus',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Image Upload Area
                  if (imageBytes == null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.zinc900 : const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.65),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_a_photo_outlined, size: 22, color: AppColors.error),
                              const SizedBox(width: 8),
                              Text(
                                'Item Photo (Compulsory)*',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'A clear photo is required to post this item for sale',
                            style: TextStyle(fontSize: 11, color: AppColors.error, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: isDark ? Colors.white : Colors.black,
                                    side: BorderSide(color: isDark ? AppColors.zinc700 : AppColors.zinc300),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                  icon: const Icon(Icons.photo_library_outlined, size: 16),
                                  label: const Text('Gallery', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  onPressed: () async {
                                    try {
                                      final xFile = await ImagePicker().pickImage(
                                        source: ImageSource.gallery,
                                        maxWidth: 1200,
                                        maxHeight: 1200,
                                        imageQuality: 85,
                                      );
                                      if (xFile != null) {
                                        final bytes = await xFile.readAsBytes();
                                        setModalState(() {
                                          imageBytes = bytes;
                                          imageName = xFile.name;
                                        });
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Could not access gallery: $e')),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: isDark ? Colors.white : Colors.black,
                                    side: BorderSide(color: isDark ? AppColors.zinc700 : AppColors.zinc300),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                  icon: const Icon(Icons.camera_alt_outlined, size: 16),
                                  label: const Text('Camera', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  onPressed: () async {
                                    try {
                                      final xFile = await ImagePicker().pickImage(
                                        source: ImageSource.camera,
                                        maxWidth: 1200,
                                        maxHeight: 1200,
                                        imageQuality: 85,
                                      );
                                      if (xFile != null) {
                                        final bytes = await xFile.readAsBytes();
                                        setModalState(() {
                                          imageBytes = bytes;
                                          imageName = xFile.name;
                                        });
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Could not open camera: $e')),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      height: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? AppColors.zinc700 : AppColors.zinc300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: Stack(
                          children: [
                            Image.memory(
                              imageBytes!,
                              width: double.infinity,
                              height: 140,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.black87,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.close, color: Colors.white, size: 16),
                                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    setModalState(() {
                                      imageBytes = null;
                                      imageName = null;
                                    });
                                  },
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 6,
                              left: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle, color: AppColors.success, size: 12),
                                    SizedBox(width: 4),
                                    Text(
                                      'Photo attached',
                                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Item Title',
                      hintText: 'e.g. Digital Logic Design textbook',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Price (PKR)',
                      hintText: '800',
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: ['Books', 'Electronics', 'Hostel', 'Furniture', 'Other'].map((c) {
                      return DropdownMenuItem(value: c, child: Text(c));
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) setModalState(() => category = v);
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: condition,
                    decoration: const InputDecoration(labelText: 'Condition'),
                    items: ['New', 'Like new', 'Good', 'Fair'].map((c) {
                      return DropdownMenuItem(value: c, child: Text(c));
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) setModalState(() => condition = v);
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Details & Pickup Location',
                      hintText: 'e.g. Pickup at CS Dept or Hostel Block B',
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            final title = titleCtrl.text.trim();
                            final price = int.tryParse(priceCtrl.text.trim()) ?? 0;
                            if (title.isEmpty || price <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please enter a valid title and price')),
                              );
                              return;
                            }

                            if (imageBytes == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Item photo is compulsory. Please attach or capture a photo.'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                              return;
                            }

                            setModalState(() => isSubmitting = true);

                            String imageUrl = '';
                            try {
                              final uploadRes = await ApiClient.uploadBytes(
                                ApiConstants.upload,
                                bytes: imageBytes!,
                                filename: imageName ?? 'item.jpg',
                                fields: {'folder': 'campus_stitch/market'},
                              );
                              if (uploadRes.success && uploadRes.data is Map && uploadRes.data['url'] != null) {
                                imageUrl = uploadRes.data['url'] as String;
                              } else {
                                imageUrl = 'data:image/jpeg;base64,${base64Encode(imageBytes!)}';
                              }
                            } catch (_) {
                              imageUrl = 'data:image/jpeg;base64,${base64Encode(imageBytes!)}';
                            }

                            final success = await MarketService.createListing(
                              campusId: AuthState.instance.activeCampusId,
                              universityId: AuthState.instance.activeUniversityId,
                              sellerName: AuthState.instance.user?.name ?? 'Student',
                              title: title,
                              price: price,
                              category: category,
                              condition: condition,
                              description: descCtrl.text.trim(),
                              location: 'Campus',
                              imageUrl: imageUrl,
                            );

                            if (!ctx.mounted) return;
                            Navigator.pop(ctx);
                            if (!mounted) return;

                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Item published to campus marketplace!'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                              _fetchListings();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to publish item. Please try again.'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          },
                    child: isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Post Listing'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEditListingModal(MarketItemModel item) {
    final titleCtrl = TextEditingController(text: item.title);
    final priceCtrl = TextEditingController(text: item.price.toString());
    final descCtrl = TextEditingController(text: item.description ?? '');
    String condition = item.condition;
    String category = item.category;
    String? currentImageUrl = item.imageUrl;
    Uint8List? newImageBytes;
    String? newImageName;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return StatefulBuilder(
          builder: (ctx, setModalState) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Edit Marketplace Listing',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Image section in Edit
                  if (newImageBytes != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      height: 130,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? AppColors.zinc700 : AppColors.zinc300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: Stack(
                          children: [
                            Image.memory(newImageBytes!, width: double.infinity, height: 130, fit: BoxFit.cover),
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Container(
                                decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
                                child: IconButton(
                                  icon: const Icon(Icons.close, color: Colors.white, size: 16),
                                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    setModalState(() {
                                      newImageBytes = null;
                                      newImageName = null;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (currentImageUrl != null && currentImageUrl!.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      height: 130,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? AppColors.zinc700 : AppColors.zinc300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: Stack(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 130,
                              child: _buildItemImage(currentImageUrl, isDark, height: 130),
                            ),
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
                                    child: IconButton(
                                      icon: const Icon(Icons.photo_library_outlined, color: Colors.white, size: 16),
                                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                      padding: EdgeInsets.zero,
                                      tooltip: 'Change Photo',
                                      onPressed: () async {
                                        try {
                                          final xFile = await ImagePicker().pickImage(
                                            source: ImageSource.gallery,
                                            maxWidth: 1200,
                                            maxHeight: 1200,
                                            imageQuality: 85,
                                          );
                                          if (xFile != null) {
                                            final bytes = await xFile.readAsBytes();
                                            setModalState(() {
                                              newImageBytes = bytes;
                                              newImageName = xFile.name;
                                            });
                                          }
                                        } catch (_) {}
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
                                    child: IconButton(
                                      icon: const Icon(Icons.close, color: Colors.white, size: 16),
                                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                      padding: EdgeInsets.zero,
                                      tooltip: 'Remove Photo',
                                      onPressed: () {
                                        setModalState(() => currentImageUrl = null);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? Colors.white : Colors.black,
                          side: BorderSide(color: isDark ? AppColors.zinc700 : AppColors.zinc300),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        icon: const Icon(Icons.add_a_photo_outlined, size: 16),
                        label: const Text('Add Item Photo'),
                        onPressed: () async {
                          try {
                            final xFile = await ImagePicker().pickImage(
                              source: ImageSource.gallery,
                              maxWidth: 1200,
                              maxHeight: 1200,
                              imageQuality: 85,
                            );
                            if (xFile != null) {
                              final bytes = await xFile.readAsBytes();
                              setModalState(() {
                                newImageBytes = bytes;
                                newImageName = xFile.name;
                              });
                            }
                          } catch (_) {}
                        },
                      ),
                    ),

                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: 'Item Title'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Price (PKR)'),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: ['Books', 'Electronics', 'Hostel', 'Furniture', 'Other'].contains(category) ? category : 'Other',
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: ['Books', 'Electronics', 'Hostel', 'Furniture', 'Other'].map((c) {
                      return DropdownMenuItem(value: c, child: Text(c));
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) setModalState(() => category = v);
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: ['New', 'Like new', 'Good', 'Fair'].contains(condition) ? condition : 'Good',
                    decoration: const InputDecoration(labelText: 'Condition'),
                    items: ['New', 'Like new', 'Good', 'Fair'].map((c) {
                      return DropdownMenuItem(value: c, child: Text(c));
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) setModalState(() => condition = v);
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Details & Location'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isSaving
                        ? null
                        : () async {
                            final title = titleCtrl.text.trim();
                            final price = int.tryParse(priceCtrl.text.trim()) ?? item.price;
                            if (title.isEmpty || price <= 0) return;

                            if (newImageBytes == null && (currentImageUrl == null || currentImageUrl!.trim().isEmpty)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Item photo is compulsory. Please attach a photo.'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                              return;
                            }

                            setModalState(() => isSaving = true);

                            String? finalImageUrl = currentImageUrl;
                            if (newImageBytes != null) {
                              try {
                                final uploadRes = await ApiClient.uploadBytes(
                                  ApiConstants.upload,
                                  bytes: newImageBytes!,
                                  filename: newImageName ?? 'item.jpg',
                                  fields: {'folder': 'campus_stitch/market'},
                                );
                                if (uploadRes.success && uploadRes.data is Map && uploadRes.data['url'] != null) {
                                  finalImageUrl = uploadRes.data['url'] as String;
                                } else {
                                  finalImageUrl = 'data:image/jpeg;base64,${base64Encode(newImageBytes!)}';
                                }
                              } catch (_) {
                                finalImageUrl = 'data:image/jpeg;base64,${base64Encode(newImageBytes!)}';
                              }
                            }

                            final success = await MarketService.updateListing(
                              id: item.id,
                              title: title,
                              price: price,
                              category: category,
                              condition: condition,
                              description: descCtrl.text.trim(),
                              imageUrl: finalImageUrl,
                            );

                            if (!ctx.mounted) return;
                            Navigator.pop(ctx);
                            if (!mounted) return;

                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Listing updated successfully!'), backgroundColor: AppColors.success),
                              );
                              _fetchListings();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Failed to update listing'), backgroundColor: AppColors.error),
                              );
                            }
                          },
                    child: isSaving
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Save Changes'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _confirmDeleteListing(MarketItemModel item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Listing', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete "${item.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await MarketService.deleteListing(item.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Listing deleted successfully!'), backgroundColor: AppColors.zinc800),
                );
                _fetchListings();
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to delete listing'), backgroundColor: AppColors.error),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showItemDetails(MarketItemModel item) {
    final user = AuthState.instance.user;
    final currentUserName = (user != null && user.name.isNotEmpty)
        ? user.name.trim().toLowerCase()
        : '';
    final isMine = (currentUserName.isNotEmpty &&
        item.sellerName.trim().toLowerCase() == currentUserName) ||
        AuthState.instance.isCampusAdmin ||
        AuthState.instance.isSuperAdmin;

    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (item.imageUrl != null && item.imageUrl!.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: _buildItemImage(
                    item.imageUrl,
                    Theme.of(context).brightness == Brightness.dark,
                    height: 180,
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  'Rs. ${item.price}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('${item.category} • Condition: ${item.condition}', style: const TextStyle(color: AppColors.zinc500, fontSize: 12)),
            if (item.description != null && item.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(item.description!, style: const TextStyle(fontSize: 13)),
            ],
            const SizedBox(height: 12),
            InkWell(
              onTap: () {
                PublicProfileDialog.show(
                  context,
                  userId: item.sellerName,
                  fallbackName: item.sellerName,
                  fallbackVerified: item.isVerified,
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.person_outline, size: 16),
                    const SizedBox(width: 6),
                    Text(item.sellerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    if (item.isVerified) ...[
                      const SizedBox(width: 4),
                      const VerifiedStudentBadge(size: 14),
                    ],
                    const SizedBox(width: 4),
                    const Icon(Icons.open_in_new, size: 12, color: AppColors.zinc500),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (isMine)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showEditListingModal(item);
                      },
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Edit Listing'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _confirmDeleteListing(item);
                      },
                      icon: const Icon(Icons.delete_outline, size: 16, color: Colors.white),
                      label: const Text('Delete', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ReviewModal.show(
                          context,
                          targetUserId: item.sellerName,
                          targetName: item.sellerName,
                          category: 'marketplace',
                        );
                      },
                      icon: const Icon(Icons.star_outline, size: 16),
                      label: const Text('Rate Seller'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MessagesScreen()),
                        );
                      },
                      icon: const Icon(Icons.chat_bubble_outline, size: 16),
                      label: const Text('Contact Seller'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final campusName = AuthState.instance.activeCampusName;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Campus Marketplace'),
            Text(
              campusName,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.zinc500),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_shopping_cart),
            tooltip: 'Sell Item',
            onPressed: _showSellModal,
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Pills
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              children: ['All', 'Books', 'Electronics', 'Hostel', 'Furniture', 'Other'].map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _selectedCategory = cat);
                      _fetchListings();
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchListings,
                    child: _items.isEmpty
                        ? ListView(
                            padding: const EdgeInsets.all(20),
                            children: [
                              EmptyStateView(
                                icon: Icons.storefront_outlined,
                                title: 'No Marketplace Listings',
                                message: _selectedCategory == 'All'
                                    ? 'No items have been posted for sale on $campusName yet. Be the first student to post!'
                                    : 'No items found in "$_selectedCategory" category.',
                                actionLabel: 'Post an Item for Sale',
                                onAction: _showSellModal,
                              ),
                            ],
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.80,
                            ),
                            itemCount: _items.length,
                            itemBuilder: (context, index) {
                              final item = _items[index];
                              final user = AuthState.instance.user;
                              final currentUserName = (user != null && user.name.isNotEmpty)
                                  ? user.name.trim().toLowerCase()
                                  : '';
                              final isMine = (currentUserName.isNotEmpty &&
                                  item.sellerName.trim().toLowerCase() == currentUserName) ||
                                  AuthState.instance.isCampusAdmin ||
                                  AuthState.instance.isSuperAdmin;

                              return Card(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () => _showItemDetails(item),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: SizedBox(
                                                height: 75,
                                                width: double.infinity,
                                                child: _buildItemImage(
                                                  item.imageUrl,
                                                  Theme.of(context).brightness == Brightness.dark,
                                                  height: 75,
                                                ),
                                              ),
                                            ),
                                            if (isMine)
                                              Positioned(
                                                top: 4,
                                                right: 4,
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () => _showEditListingModal(item),
                                                      child: Container(
                                                        padding: const EdgeInsets.all(5),
                                                        decoration: BoxDecoration(
                                                          color: Colors.black.withValues(alpha: 0.75),
                                                          shape: BoxShape.circle,
                                                        ),
                                                        child: const Icon(Icons.edit, size: 13, color: Colors.white),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 5),
                                                    GestureDetector(
                                                      onTap: () => _confirmDeleteListing(item),
                                                      child: Container(
                                                        padding: const EdgeInsets.all(5),
                                                        decoration: BoxDecoration(
                                                          color: Colors.black.withValues(alpha: 0.75),
                                                          shape: BoxShape.circle,
                                                        ),
                                                        child: const Icon(Icons.delete_outline, size: 13, color: AppColors.error),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Rs. ${item.price}',
                                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          item.title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                                        ),
                                        const Spacer(),
                                        InkWell(
                                          onTap: () {
                                            PublicProfileDialog.show(
                                              context,
                                              userId: item.sellerName,
                                              fallbackName: item.sellerName,
                                              fallbackVerified: item.isVerified,
                                            );
                                          },
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  item.sellerName,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(fontSize: 10, color: AppColors.zinc500),
                                                ),
                                              ),
                                              if (item.isVerified)
                                                const VerifiedStudentBadge(size: 12),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
