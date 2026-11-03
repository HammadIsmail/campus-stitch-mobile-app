import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../services/bike_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/segmented_control.dart';
import '../../widgets/state_view.dart';
import '../../widgets/sub_header.dart';
import '../ratings/rate_user_screen.dart';

class BikeRequestsScreen extends StatefulWidget {
  const BikeRequestsScreen({super.key});

  @override
  State<BikeRequestsScreen> createState() => _BikeRequestsScreenState();
}

class _BikeRequestsScreenState extends State<BikeRequestsScreen> {
  int _selectedTabIndex = 0; // 0: Pending, 1: Booked
  List<BikeRequestModel> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    final status = _selectedTabIndex == 0 ? 'pending' : 'booked';
    final reqs = await BikeService.getRequests(status: status);
    if (mounted) {
      setState(() {
        _requests = reqs;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleAction(String id, String action) async {
    final targetReq = _requests.firstWhere((r) => r.id == id, orElse: () => _requests.first);
    final success = await BikeService.respondToRequest(id: id, action: action);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request marked as $action!'),
          backgroundColor: const Color(0xFF0E6B50),
        ),
      );
      _loadRequests();

      if (action == 'return') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RateUserScreen(
              peerId: targetReq.renterId ?? 'u_renter',
              peerName: targetReq.renterName,
              contextTitle: 'Bike rental: ${targetReq.bikeModel}',
              transactionId: targetReq.id,
              category: 'bike',
            ),
          ),
        );
      }
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
              title: 'Rental requests',
              onBack: () => Navigator.of(context).pop(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AppSegmentedControl(
                segments: const ['Pending', 'Booked'],
                selectedIndex: _selectedTabIndex,
                onChanged: (idx) {
                  setState(() => _selectedTabIndex = idx);
                  _loadRequests();
                },
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const StateView.loadingList()
                  : _requests.isEmpty
                      ? StateView.empty(
                          title: _selectedTabIndex == 0 ? 'No pending requests' : 'No active rentals',
                          body: _selectedTabIndex == 0
                              ? 'When students on your campus request your bike, they will appear here.'
                              : 'Active bookings for your bikes will be tracked here until returned.',
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                          itemCount: _requests.length,
                          itemBuilder: (context, index) {
                            final r = _requests[index];
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
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: colors.primarySoft,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          r.initial,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: colors.textOnPrimarySoft,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              r.name,
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                color: colors.textPrimary,
                                              ),
                                            ),
                                            Text(
                                              'Wants ${r.bike}',
                                              style: TextStyle(fontSize: 12, color: colors.textMuted),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: r.isPending ? colors.amberSoft : colors.skeleton,
                                          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                                        ),
                                        child: Text(
                                          r.status,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: r.isPending ? colors.textOnAmberSoft : colors.textPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    r.slot,
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: colors.textPrimary),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    r.note,
                                    style: TextStyle(fontSize: 13, color: colors.textMuted),
                                  ),
                                  const SizedBox(height: 10),
                                  if (r.isPending)
                                    Row(
                                      children: [
                                        Expanded(
                                          child: AppButton(
                                            text: 'Decline',
                                            height: 46,
                                            isSecondary: true,
                                            onPressed: () => _handleAction(r.id, 'decline'),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: AppButton(
                                            text: 'Accept booking',
                                            height: 46,
                                            onPressed: () => _handleAction(r.id, 'accept'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (r.isBooked)
                                    AppButton(
                                      text: 'Mark as returned',
                                      height: 46,
                                      backgroundColor: colors.amber,
                                      textColor: const Color(0xFF2B1800),
                                      onPressed: () => _handleAction(r.id, 'return'),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

