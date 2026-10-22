import 'package:flutter/material.dart';
import '../../core/state/auth_state.dart';
import '../../core/theme/app_theme.dart';

class MarketItem {
  final String id;
  final String title;
  final int price;
  final String category;
  final String sellerName;
  final bool isVerified;
  final String condition;
  final String campusId;

  MarketItem({
    required this.id,
    required this.title,
    required this.price,
    required this.category,
    required this.sellerName,
    this.isVerified = true,
    required this.condition,
    required this.campusId,
  });
}

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  String _selectedCategory = 'All';

  List<MarketItem> get _items {
    final activeCampusId = AuthState.instance.activeCampusId;
    return [
      MarketItem(
        id: 'm1',
        title: 'Thomas Calculus (14th Edition) with Solution Manual',
        price: 850,
        category: 'Textbooks',
        sellerName: 'Ali Raza',
        condition: 'Like New',
        campusId: activeCampusId,
      ),
      MarketItem(
        id: 'm2',
        title: 'Casio fx-991EX Scientific Calculator',
        price: 2200,
        category: 'Electronics',
        sellerName: 'Hamza Khan',
        condition: 'Used - Good',
        campusId: activeCampusId,
      ),
      MarketItem(
        id: 'm3',
        title: 'Engineering Mini Drafter + Drawing Board',
        price: 1500,
        category: 'Tools',
        sellerName: 'Usman Tariq',
        condition: 'Excellent',
        campusId: activeCampusId,
      ),
      MarketItem(
        id: 'm4',
        title: 'Lab Coat (Medium Size, 100% Cotton)',
        price: 400,
        category: 'Stationery',
        sellerName: 'Fatima Noor',
        condition: 'Brand New',
        campusId: activeCampusId,
      ),
    ];
  }

  void _showSellModal() {
    final titleCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Sell an Item on Campus', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Item Title', hintText: 'e.g. Digital Logic Design book')),
              const SizedBox(height: 10),
              TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price (PKR)', hintText: '500')),
              const SizedBox(height: 10),
              TextField(controller: descCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Condition & Details')),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Item published to campus marketplace!')),
                  );
                },
                child: const Text('Post Listing'),
              ),
              const SizedBox(height: 20),
            ],
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
              children: ['All', 'Textbooks', 'Electronics', 'Tools', 'Stationery'].map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                  ),
                );
              }).toList(),
            ),
          ),

          Expanded(
            child: GridView.builder(
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
                          child: const Icon(Icons.inventory_2_outlined, size: 28, color: AppColors.zinc500),
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
                            Text(
                              item.sellerName,
                              style: const TextStyle(fontSize: 10, color: AppColors.zinc500),
                            ),
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
        ],
      ),
    );
  }
}
