import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/image_upload_service.dart';
import '../../services/market_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/sub_header.dart';

class SellItemScreen extends StatefulWidget {
  final MarketItemModel? initialItem;

  const SellItemScreen({super.key, this.initialItem});

  @override
  State<SellItemScreen> createState() => _SellItemScreenState();
}

class _SellItemScreenState extends State<SellItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _brandController = TextEditingController();
  final _priceController = TextEditingController();
  final _tankController = TextEditingController();
  final _powerController = TextEditingController();
  final _bookAuthorController = TextEditingController();
  final _bookEditionController = TextEditingController();

  String? _uploadedImageUrl;
  bool _isUploadingImage = false;

  final List<String> _categories = [
    'Appliances: Air cooler',
    'Furniture',
    'Books',
    'Electronics',
  ];
  late String _selectedCategory;

  final List<String> _conditions = ['New', 'Like new', 'Used'];
  String _selectedCondition = 'Used';

  bool _isNegotiable = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedCategory = _categories.first;
    if (widget.initialItem != null) {
      final item = widget.initialItem!;
      _titleController.text = item.title;
      _priceController.text = item.price.toString();
      _brandController.text = item.brand;
      _uploadedImageUrl = item.imageUrl;
      if (_conditions.contains(item.condition)) {
        _selectedCondition = item.condition;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _tankController.dispose();
    _powerController.dispose();
    _bookAuthorController.dispose();
    _bookEditionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final user = AuthService.currentUser;
    final priceVal = int.tryParse(_priceController.text.trim()) ?? 0;

    final Map<String, dynamic> attributes = {};
    if (_selectedCategory.contains('Air cooler') || _selectedCategory.contains('Appliances')) {
      if (_tankController.text.isNotEmpty) attributes['Tank'] = '${_tankController.text.trim()} litres';
      if (_powerController.text.isNotEmpty) attributes['Power'] = '${_powerController.text.trim()} W';
    } else if (_selectedCategory.contains('Books')) {
      if (_bookAuthorController.text.isNotEmpty) attributes['Author'] = _bookAuthorController.text.trim();
      if (_bookEditionController.text.isNotEmpty) attributes['Edition'] = _bookEditionController.text.trim();
    }

    // Map UI category to standard category
    String normalizedCat = 'Other';
    if (_selectedCategory.contains('Appliances')) {
      normalizedCat = 'Appliances';
    } else if (_selectedCategory.contains('Furniture')) {
      normalizedCat = 'Furniture';
    } else if (_selectedCategory.contains('Books')) {
      normalizedCat = 'Books';
    } else if (_selectedCategory.contains('Electronics')) {
      normalizedCat = 'Electronics';
    }

    final isEditing = widget.initialItem != null;
    final res = isEditing
        ? await MarketService.updateListing(
            listingId: widget.initialItem!.id,
            title: _titleController.text.trim(),
            price: priceVal,
            category: normalizedCat,
            condition: _selectedCondition,
            imageUrl: _uploadedImageUrl,
          )
        : await MarketService.createListing(
            title: _titleController.text.trim(),
            price: priceVal,
            category: normalizedCat,
            brand: _brandController.text.trim(),
            condition: _selectedCondition,
            location: 'Hostel',
            sellerName: user?.fullName ?? 'Student',
            campusId: user?.campusId,
            imageUrl: _uploadedImageUrl,
            isNegotiable: _isNegotiable,
            attributes: attributes,
          );

    if (!mounted) return;

    if (res.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Your listing has been updated!' : 'Your item is listed on your campus market!'),
          backgroundColor: const Color(0xFF0E6B50),
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _isSubmitting = false;
        _errorMessage = res.message ?? (isEditing ? 'Failed to update item' : 'Failed to list item');
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
              title: widget.initialItem != null ? 'Edit listing' : 'Sell an item',
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
                                          'Add photos of your item',
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

                      // Category Dropdown
                      Text('Category', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: colors.textPrimary)),
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
                            value: _selectedCategory,
                            isExpanded: true,
                            icon: Icon(Icons.arrow_drop_down, color: colors.textMuted),
                            items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: TextStyle(fontSize: 14, color: colors.textPrimary, fontWeight: FontWeight.w600)))).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedCategory = val);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'The fields below change with the category you pick.',
                        style: TextStyle(fontSize: 12, color: colors.textMuted),
                      ),
                      const SizedBox(height: 14),

                      // Title
                      AppTextField(
                        label: 'Title',
                        controller: _titleController,
                        hintText: 'e.g. Air cooler, Super Asia',
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Enter item title';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Brand and Price
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Brand',
                              controller: _brandController,
                              hintText: 'Super Asia',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppTextField(
                              label: 'Price (Rs)',
                              controller: _priceController,
                              hintText: '14500',
                              keyboardType: TextInputType.number,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return 'Enter price';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Condition buttons
                      Text('Condition', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: colors.textPrimary)),
                      const SizedBox(height: 6),
                      Row(
                        children: _conditions.map((cond) {
                          final isSelected = cond == _selectedCondition;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedCondition = cond),
                              child: Container(
                                height: 44,
                                margin: EdgeInsets.only(right: cond != _conditions.last ? 8 : 0),
                                decoration: BoxDecoration(
                                  color: isSelected ? colors.primary : colors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: isSelected ? colors.primary : colors.inputBorder),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  cond,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                    color: isSelected ? Colors.white : colors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),

                      // Dynamic Fields based on Category
                      if (_selectedCategory.contains('Air cooler') || _selectedCategory.contains('Appliances')) ...[
                        Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                label: 'Tank capacity (litres)',
                                controller: _tankController,
                                hintText: '45',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AppTextField(
                                label: 'Power (watts)',
                                controller: _powerController,
                                hintText: '180',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                      ] else if (_selectedCategory.contains('Books')) ...[
                        Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                label: 'Author',
                                controller: _bookAuthorController,
                                hintText: 'Thomas & Finney',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AppTextField(
                                label: 'Edition',
                                controller: _bookEditionController,
                                hintText: '12th Edition',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Negotiable Checkbox
                      GestureDetector(
                        onTap: () => setState(() => _isNegotiable = !_isNegotiable),
                        child: Container(
                          height: 44,
                          color: Colors.transparent,
                          child: Row(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _isNegotiable,
                                  activeColor: colors.primary,
                                  onChanged: (val) => setState(() => _isNegotiable = val ?? true),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Price is negotiable',
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
                text: widget.initialItem != null ? 'Update listing' : 'List on my campus market',
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
