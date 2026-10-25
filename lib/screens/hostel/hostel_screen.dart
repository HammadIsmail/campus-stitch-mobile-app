import 'package:flutter/material.dart';
import '../../core/state/auth_state.dart';
import '../../core/theme/app_theme.dart';
import '../../models/hostel_model.dart';
import '../../services/hostel_service.dart';
import '../messages/messages_screen.dart';
import '../notifications/notifications_screen.dart';

import 'widgets/edit_roommate_dialog.dart';
import 'widgets/edit_service_dialog.dart';
import 'widgets/offer_service_screen.dart';
import 'widgets/post_roommate_dialog.dart';

class HostelScreen extends StatefulWidget {
  const HostelScreen({super.key});

  @override
  State<HostelScreen> createState() => _HostelScreenState();
}

class _HostelScreenState extends State<HostelScreen> {
  List<RoommateModel> _roommates = [];
  List<HostelServiceModel> _services = [];
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
      final results = await Future.wait([
        HostelService.getRoommates(campusId: campusId),
        HostelService.getServices(campusId: campusId),
      ]);
      if (mounted) {
        setState(() {
          _roommates = results[0] as List<RoommateModel>;
          _services = results[1] as List<HostelServiceModel>;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _confirmDeleteRoommate(RoommateModel roommate) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Roommate Vacancy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to delete this listing?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            onPressed: () async {
              final scaffold = ScaffoldMessenger.of(context);
              Navigator.pop(ctx);
              final success = await HostelService.deleteRoommate(roommate.id);
              if (!mounted) return;
              if (success) {
                setState(() => _roommates.removeWhere((r) => r.id == roommate.id));
                scaffold.showSnackBar(
                  const SnackBar(content: Text('Vacancy deleted successfully'), backgroundColor: AppColors.zinc800),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteService(HostelServiceModel service) {
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
              final success = await HostelService.deleteService(service.id);
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

                    // Hostel Hub Card
                    _buildHostelHubHeaderCard(campusName, isDark),
                    const SizedBox(height: 20),

                    // Section 1: Roommates Near You
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Roommates Near You',
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
                            '${_roommates.length} available',
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
                      'Verified $campusName hostel residents looking for sharing partners',
                      style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : AppColors.zinc500),
                    ),
                    const SizedBox(height: 12),

                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_roommates.isEmpty)
                      _buildEmptyCard('No roommate vacancies posted yet.', isDark)
                    else
                      ..._roommates.map((r) => _buildRoommateCard(r, currentUserName, isDark, universityName)),

                    const SizedBox(height: 24),

                    // Section 2: Student Services
                    const Text(
                      'Student Services',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Reliable door-to-door services run by fellow students',
                      style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : AppColors.zinc500),
                    ),
                    const SizedBox(height: 12),

                    if (_isLoading)
                      const SizedBox.shrink()
                    else if (_services.isEmpty)
                      _buildEmptyCard('No student services offered yet.', isDark)
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

  // --- Hostel Hub Card ---
  Widget _buildHostelHubHeaderCard(String campusName, bool isDark) {
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
                child: Icon(Icons.apartment, size: 24, color: isDark ? Colors.white : Colors.black),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Hostel Hub', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                    Text(
                      'Verified Roommates & Campus Services for $campusName',
                      style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : AppColors.zinc500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? Colors.white : Colors.black,
                    side: BorderSide(color: isDark ? Colors.white38 : AppColors.zinc300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.build_outlined, size: 16),
                  label: const Text('Offer Service', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.white : Colors.black,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Post Room', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  onPressed: () {
                    PostRoommateDialog.show(context, onPosted: _loadData);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Roommate Card ---
  Widget _buildRoommateCard(RoommateModel room, String currentUserName, bool isDark, String universityName) {
    final isAuthor = currentUserName.isNotEmpty && room.owner.trim().toLowerCase() == currentUserName;

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
          // Title and Rent
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  room.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: room.rent.isNotEmpty ? room.rent : 'Rs. ${room.monthlyRent}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: ' /mo',
                      style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : AppColors.zinc500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (room.details.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              room.details,
              style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : AppColors.zinc600, height: 1.4),
            ),
          ],
          if (room.amenities.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: room.amenities.map((a) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.zinc800 : AppColors.zinc100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isDark ? AppColors.zinc700 : AppColors.zinc200),
                  ),
                  child: Text(
                    a,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.zinc700,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 14),

          // Author Row
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: isDark ? AppColors.zinc700 : Colors.black,
                child: Text(
                  room.owner.isNotEmpty ? room.owner[0].toUpperCase() : 'M',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            room.owner,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.shield_outlined, size: 10, color: Color(0xFFD97706)),
                              SizedBox(width: 2),
                              Text('Unverified', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      universityName,
                      style: TextStyle(fontSize: 10, color: isDark ? Colors.white60 : AppColors.zinc500),
                    ),
                  ],
                ),
              ),
              if (isAuthor) ...[
                IconButton(
                  icon: Icon(Icons.edit_outlined, size: 18, color: isDark ? Colors.white70 : AppColors.zinc600),
                  onPressed: () {
                    EditRoommateDialog.show(
                      context,
                      roommate: room,
                      onUpdated: (updated) {
                        setState(() {
                          final idx = _roommates.indexWhere((r) => r.id == updated.id);
                          if (idx != -1) _roommates[idx] = updated;
                        });
                      },
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                  onPressed: () => _confirmDeleteRoommate(room),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // --- Student Service Card ---
  Widget _buildServiceCard(HostelServiceModel service, String currentUserName, bool isDark) {
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
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Student Campus Service',
                      style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : AppColors.zinc500),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.zinc800 : AppColors.zinc100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isDark ? AppColors.zinc700 : AppColors.zinc300),
                ),
                child: Text(
                  service.rate,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Provider info box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.zinc800 : AppColors.zinc100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? AppColors.zinc700 : AppColors.zinc200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: isDark ? AppColors.zinc700 : Colors.black,
                      child: Text(
                        service.provider.isNotEmpty ? service.provider.substring(0, service.provider.length >= 2 ? 2 : 1).toUpperCase() : 'MI',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  service.provider,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.shield_outlined, size: 9, color: Color(0xFFD97706)),
                                    SizedBox(width: 2),
                                    Text('Unverified', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Verified Service Provider',
                            style: TextStyle(fontSize: 10, color: isDark ? Colors.white70 : AppColors.zinc500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (service.location.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 14, color: isDark ? Colors.white70 : AppColors.zinc500),
                      const SizedBox(width: 6),
                      Text(
                        service.location,
                        style: TextStyle(fontSize: 11, color: isDark ? Colors.white : AppColors.zinc700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
                if (service.schedule.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: isDark ? Colors.white70 : AppColors.zinc500),
                      const SizedBox(width: 6),
                      Text(
                        service.schedule,
                        style: TextStyle(fontSize: 11, color: isDark ? Colors.white : AppColors.zinc700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
                if (service.phone.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.phone_outlined, size: 14, color: isDark ? Colors.white70 : AppColors.zinc500),
                      const SizedBox(width: 6),
                      Text(
                        service.phone,
                        style: TextStyle(fontSize: 11, color: isDark ? Colors.white : AppColors.zinc700),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Actions
          if (isAuthor) ...[
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
                    icon: Icon(Icons.edit_outlined, size: 14, color: isDark ? Colors.white : Colors.black),
                    label: Text('Edit Service', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.white : Colors.black,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                icon: Icon(Icons.chat_bubble_outline, size: 14, color: isDark ? Colors.black : Colors.white),
                label: Text('Chat with Provider', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.black : Colors.white)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Connecting with ${service.provider}...'),
                      backgroundColor: AppColors.zinc800,
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyCard(String message, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.zinc900 : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.zinc800 : AppColors.zinc200),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : AppColors.zinc500),
        ),
      ),
    );
  }
}
