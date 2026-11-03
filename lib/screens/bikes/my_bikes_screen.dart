import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/constants/app_constants.dart';
import '../../core/state/auth_state.dart';
import '../../core/theme/app_colors.dart';
import '../../services/bike_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/state_view.dart';
import '../../widgets/sub_header.dart';
import 'bike_requests_screen.dart';
import 'list_bike_screen.dart';

class MyBikesScreen extends StatefulWidget {
  const MyBikesScreen({super.key});

  @override
  State<MyBikesScreen> createState() => _MyBikesScreenState();
}

class _MyBikesScreenState extends State<MyBikesScreen> {
  List<BikeModel> _myBikes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBikes();
  }

  Future<void> _loadBikes() async {
    setState(() => _isLoading = true);
    final campusId = AuthState.instance.activeCampusId;
    final allBikes = await BikeService.getBikes(campusId: campusId);
    if (mounted) {
      setState(() {
        _myBikes = allBikes;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleAvailability(BikeModel bike) async {
    final nextState = !bike.isAvailable;
    final ok = await BikeService.updateBikeAvailability(bikeId: bike.id, isAvailable: nextState);
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(nextState ? 'Bike marked as available!' : 'Bike marked as booked!'),
          backgroundColor: const Color(0xFF0E6B50),
        ),
      );
      _loadBikes();
    }
  }

  void _confirmDelete(BikeModel b) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete bike listing?'),
        content: Text('Are you sure you want to remove "${b.model}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final res = await BikeService.deleteBike(b.id);
              if (mounted) {
                if (res.success) {
                  _loadBikes();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bike listing deleted')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(res.message ?? 'Failed to delete bike')),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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
              title: 'My bikes',
              onBack: () => Navigator.of(context).pop(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const BikeRequestsScreen()),
                  );
                },
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: colors.amberSoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Review rental requests',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: colors.textOnAmberSoft,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            'Review',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: colors.textOnAmberSoft,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(LucideIcons.chevronRight, size: 18, color: colors.textOnAmberSoft),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const StateView.loadingList()
                  : _myBikes.isEmpty
                      ? StateView.empty(
                          title: 'No bikes listed yet',
                          body: 'List your bike for hourly or daily rentals to peers on your campus.',
                          actionLabel: 'List a bike',
                          onAction: () async {
                            final res = await Navigator.of(context).push<bool>(
                              MaterialPageRoute(builder: (_) => const ListBikeScreen()),
                            );
                            if (res == true) _loadBikes();
                          },
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                          itemCount: _myBikes.length,
                          itemBuilder: (context, index) {
                            final b = _myBikes[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                                border: Border.all(color: colors.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: colors.skeleton,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        alignment: Alignment.center,
                                        child: b.imageUrl != null && b.imageUrl!.isNotEmpty
                                            ? Image.network(
                                                b.imageUrl!,
                                                fit: BoxFit.cover,
                                                width: 56,
                                                height: 56,
                                                errorBuilder: (_, _, _) => Icon(LucideIcons.bike, size: 28, color: colors.textMuted),
                                              )
                                            : Icon(LucideIcons.bike, size: 28, color: colors.textMuted),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              b.model,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: colors.textPrimary,
                                              ),
                                            ),
                                            Text(
                                              b.rateText,
                                              style: TextStyle(fontSize: 13, color: colors.textMuted),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: b.isAvailable ? colors.primarySoft : colors.skeleton,
                                          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                                        ),
                                        child: Text(
                                          b.status,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: b.isAvailable ? colors.textOnPrimarySoft : colors.textPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Availability hours',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: colors.textPrimary),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: colors.background,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          b.window,
                                          style: TextStyle(fontSize: 14, color: colors.textPrimary),
                                        ),
                                        Text(
                                          'Active',
                                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: colors.primary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  if (b.isAvailable)
                                    Row(
                                      children: [
                                        Expanded(
                                          child: AppButton(
                                            text: 'Mark as booked',
                                            height: 48,
                                            backgroundColor: colors.amber,
                                            textColor: const Color(0xFF2B1800),
                                            onPressed: () => _toggleAvailability(b),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: AppButton(
                                            text: 'Pause listing',
                                            height: 48,
                                            isSecondary: true,
                                            onPressed: () {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Listing paused')),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    )
                                  else
                                    AppButton(
                                      text: 'Mark as returned',
                                      height: 48,
                                      onPressed: () => _toggleAvailability(b),
                                    ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: AppButton(
                                          text: 'Edit details',
                                          height: 44,
                                          isSecondary: true,
                                          onPressed: () async {
                                            final res = await Navigator.of(context).push<bool>(
                                              MaterialPageRoute(builder: (_) => ListBikeScreen(initialBike: b)),
                                            );
                                            if (res == true) _loadBikes();
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () => _confirmDelete(b),
                                        child: Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: colors.surface,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: colors.border),
                                          ),
                                          alignment: Alignment.center,
                                          child: Icon(LucideIcons.trash2, size: 18, color: colors.danger),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border(top: BorderSide(color: colors.border)),
              ),
              child: AppButton(
                text: 'Add another bike',
                isSecondary: true,
                onPressed: () async {
                  final res = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(builder: (_) => const ListBikeScreen()),
                  );
                  if (res == true) _loadBikes();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

