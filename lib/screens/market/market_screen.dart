import 'package:flutter/material.dart';
import '../../core/state/auth_state.dart';
import '../../core/theme/app_theme.dart';
import '../../services/market_service.dart';

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

  void _showSellModal() {
    final titleCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String condition = 'Like new';
    String category = 'Books';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
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
                const Text(
                  'Sell an Item on Campus',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
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
                  onPressed: () async {
                    final title = titleCtrl.text.trim();
                    final price = int.tryParse(priceCtrl.text.trim()) ?? 0;
                    if (title.isEmpty || price <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a valid title and price')),
                      );
                      return;
                    }

                    Navigator.pop(ctx);
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
                    );

                    if (success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Item published to campus marketplace!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                      _fetchListings();
                    }
                  },
                  child: const Text('Post Listing'),
                ),
              ],
            ),
          ),
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
                            padding: const EdgeInsets.all(32),
                            children: [
                              const SizedBox(height: 60),
                              const Icon(Icons.storefront_outlined, size: 64, color: AppColors.zinc400),
                              const SizedBox(height: 16),
                              const Text(
                                'No Marketplace Listings',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _selectedCategory == 'All'
                                    ? 'No items have been posted for sale on $campusName yet.'
                                    : 'No items found in "$_selectedCategory" category.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 12, color: AppColors.zinc500),
                              ),
                              const SizedBox(height: 20),
                              Center(
                                child: ElevatedButton.icon(
                                  onPressed: _showSellModal,
                                  icon: const Icon(Icons.add, size: 16),
                                  label: const Text('Post First Item'),
                                ),
                              ),
                            ],
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.85,
                            ),
                            itemCount: _items.length,
                            itemBuilder: (context, index) {
                              final item = _items[index];
                              return Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 70,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).brightness == Brightness.dark
                                              ? AppColors.zinc800
                                              : AppColors.zinc100,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Icon(
                                          Icons.inventory_2_outlined,
                                          size: 28,
                                          color: AppColors.zinc500,
                                        ),
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
                                      Row(
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
                                            const Icon(Icons.verified, size: 14, color: AppColors.success),
                                        ],
                                      ),
                                    ],
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
