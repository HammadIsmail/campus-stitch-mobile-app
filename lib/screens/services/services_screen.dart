import 'package:flutter/material.dart';
import '../../core/state/auth_state.dart';
import '../../core/theme/app_theme.dart';
import '../../models/service_model.dart';
import '../../services/campus_service.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/public_profile_dialog.dart';
import '../../widgets/review_modal.dart';
import '../../widgets/verified_student_badge.dart';
import '../messages/messages_screen.dart';
import '../notifications/notifications_screen.dart';

import 'widgets/edit_service_dialog.dart';
import 'widgets/offer_service_screen.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  List<CampusServiceModel> _services = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final campusId = AuthState.instance.activeCampusId;
    try {
      final services = await CampusService.getServices(campusId: campusId);
      if (mounted) {
        setState(() {
          _services = services;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _confirmDeleteService(CampusServiceModel service) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Campus Service', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to delete this service listing?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            onPressed: () async {
              final scaffold = ScaffoldMessenger.of(context);
              Navigator.pop(ctx);
              final success = await CampusService.deleteService(service.id);
              if (!mounted) return;
              if (success) {
                setState(() => _services.removeWhere((s) => s.id == service.id));
                scaffold.showSnackBar(
                  const SnackBar(content: Text('Service deleted successfully'), backgroundColor: AppColors.zinc800),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  IconData _getServiceIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('laundry') || lower.contains('wash')) return Icons.local_laundry_service_outlined;
    if (lower.contains('cooler') || lower.contains('electric')) return Icons.bolt_outlined;
    if (lower.contains('print') || lower.contains('paper')) return Icons.print_outlined;
    if (lower.contains('laptop') || lower.contains('repair')) return Icons.build_outlined;
    return Icons.auto_awesome_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final campusName = AuthState.instance.activeCampusName;
    final universityName = AuthState.instance.user?.universityName ?? 'UET Lahore';

    final user = AuthState.instance.user;
    final currentUserName = (user != null && user.name.isNotEmpty) ? user.name.trim().toLowerCase() : '';

    return Scaffold(
      backgroundColor: isDark ? AppColors.black : AppColors.lightBg,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            _buildTopAppBar(campusName, isDark),

            // Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadData,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  children: [
                    // Campus Pill
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.zinc800 : AppColors.zinc200,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_on_outlined, size: 14, color: isDark ? Colors.white70 : AppColors.zinc600),
                            const SizedBox(width: 4),
                            Text(
                              '$campusName • $universityName',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppColors.zinc800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Campus Services Hub Card
                    _buildServicesHeaderCard(campusName, isDark),
                    const SizedBox(height: 20),

                    // Campus Services Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Campus Services',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.zinc800 : AppColors.zinc100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isDark ? AppColors.zinc700 : AppColors.zinc300),
                          ),
                          child: Text(
                            '${_services.length} available',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Reliable door-to-door services run by fellow students in $campusName',
                      style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : AppColors.zinc500),
                    ),
                    const SizedBox(height: 12),

                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 36),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_services.isEmpty)
                      _buildEmptyCard('No campus services offered yet. Tap above to offer a service!', isDark)
                    else
                      ..._services.map((s) => _buildServiceCard(s, currentUserName, isDark)),

                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Top App Bar ---
  Widget _buildTopAppBar(String campusName, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isDark ? AppColors.zinc900 : Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('CampuStitch', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                  Text(
                    campusName.toUpperCase(),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.zinc500),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Stack(
                  children: [
                    Icon(Icons.chat_bubble_outline, size: 20),
                    Positioned(right: 0, top: 0, child: CircleAvatar(radius: 3, backgroundColor: AppColors.error)),
                  ],
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MessagesScreen()));
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Stack(
                  children: [
                    Icon(Icons.notifications_none, size: 20),
                    Positioned(right: 0, top: 0, child: CircleAvatar(radius: 3, backgroundColor: AppColors.error)),
                  ],
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Services Header Card ---
  Widget _buildServicesHeaderCard(String campusName, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.zinc900 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.zinc800 : AppColors.zinc200),
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
                  color: isDark ? AppColors.zinc800 : AppColors.zinc100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.home_repair_service_outlined, size: 24, color: isDark ? Colors.white : Colors.black),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Campus Services Hub', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                    Text(
                      'Verified Student Services & Campus Essentials for $campusName',
                      style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : AppColors.zinc500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.white : Colors.black,
                foregroundColor: isDark ? Colors.black : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.build_outlined, size: 16),
              label: const Text('Offer Campus Service', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OfferServiceScreen(onServiceCreated: _loadData),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- Student Service Card ---
  Widget _buildServiceCard(CampusServiceModel service, String currentUserName, bool isDark) {
    final isAuthor = currentUserName.isNotEmpty && service.provider.trim().toLowerCase() == currentUserName;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.zinc900 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.zinc800 : AppColors.zinc200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Icon + Title + Rate
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.zinc800 : AppColors.zinc100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_getServiceIcon(service.name), size: 20, color: isDark ? Colors.white : Colors.black),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      service.rate,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.success),
                    ),
                  ],
                ),
              ),
              if (service.verified)
                const VerifiedStudentBadge(size: 14),
            ],
          ),

          const SizedBox(height: 12),

          // Provider info (Clickable to open Student Public Profile)
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              PublicProfileDialog.show(
                context,
                userId: service.userId ?? service.provider,
                fallbackName: service.provider,
                fallbackVerified: service.verified,
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: isDark ? AppColors.zinc800 : AppColors.zinc200,
                    child: Text(
                      service.provider.isNotEmpty ? service.provider[0].toUpperCase() : 'S',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    service.provider,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, decoration: TextDecoration.underline),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.open_in_new, size: 11, color: isDark ? Colors.white54 : AppColors.zinc400),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Details chips
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (service.location.isNotEmpty)
                _buildInfoChip(Icons.location_on_outlined, service.location, isDark),
              if (service.schedule.isNotEmpty)
                _buildInfoChip(Icons.schedule_outlined, service.schedule, isDark),
            ],
          ),

          if (service.notes.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              service.notes,
              style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : AppColors.zinc600),
            ),
          ],

          const SizedBox(height: 14),

          // Action Buttons: Edit/Delete if author, Rate/Chat if peer
          if (isAuthor) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? Colors.white : Colors.black,
                    side: BorderSide(color: isDark ? Colors.white38 : AppColors.zinc300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 14),
                  label: const Text('Edit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    EditServiceDialog.show(
                      context,
                      service: service,
                      onUpdated: (updated) {
                        setState(() {
                          final idx = _services.indexWhere((s) => s.id == updated.id);
                          if (idx != -1) _services[idx] = updated;
                        });
                      },
                    );
                  },
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: Color(0xFFFCA5A5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  icon: const Icon(Icons.delete_outline, size: 14, color: AppColors.error),
                  label: const Text('Delete', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.error)),
                  onPressed: () => _confirmDeleteService(service),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? Colors.white : Colors.black,
                      side: BorderSide(color: isDark ? Colors.white38 : AppColors.zinc300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: Icon(Icons.star_outline, size: 14, color: isDark ? Colors.white : Colors.black),
                    label: Text('Rate Provider', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                    onPressed: () {
                      ReviewModal.show(
                        context,
                        targetUserId: service.provider,
                        targetName: service.provider,
                        category: 'services',
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.white : Colors.black,
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: Icon(Icons.chat_bubble_outline, size: 14, color: isDark ? Colors.black : Colors.white),
                    label: Text('Chat', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.black : Colors.white)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MessagesScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.zinc800 : AppColors.zinc100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: isDark ? Colors.white70 : AppColors.zinc600),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : AppColors.zinc700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(String message, bool isDark) {
    return EmptyStateView(
      icon: Icons.home_repair_service_outlined,
      title: 'Nothing Listed Yet',
      message: message,
    );
  }
}

// Backwards compatibility alias
typedef HostelScreen = ServicesScreen;
