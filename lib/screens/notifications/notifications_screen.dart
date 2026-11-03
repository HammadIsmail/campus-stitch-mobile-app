import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/storage/session_store.dart';
import '../../core/theme/app_colors.dart';
import '../../models/chat_model.dart';
import '../../models/notification_model.dart';
import '../../services/notification_service.dart';
import '../../widgets/state_view.dart';
import '../../widgets/sub_header.dart';
import '../bikes/bike_requests_screen.dart';
import '../market/market_screen.dart';
import '../messages/chat_detail_screen.dart';
import '../profile/user_profile_screen.dart';
import '../ratings/rate_user_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Requests', 'Ratings'];

  List<NotificationItemModel> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await SessionStore.getUser();
      final campusId = user?.campusId ?? 'camp_fast_isb';
      final list = await NotificationService.getNotifications(
        campusId: campusId,
        filter: _selectedFilter,
      );

      if (mounted) {
        setState(() {
          _notifications = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Could not load notifications';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markAllAsRead() async {
    final user = await SessionStore.getUser();
    final campusId = user?.campusId ?? 'camp_fast_isb';

    setState(() {
      for (var n in _notifications) {
        n.read = true;
      }
    });

    await NotificationService.markAllAsRead(campusId: campusId);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('All notifications marked as read'),
          backgroundColor: context.colors.primary,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handleNotificationTap(NotificationItemModel item) async {
    final user = await SessionStore.getUser();
    final campusId = user?.campusId ?? 'camp_fast_isb';

    if (!item.read) {
      setState(() => item.read = true);
      NotificationService.markAsRead(item.id, campusId: campusId);
    }

    if (!mounted) return;

    final link = item.deeplink ?? '';
    if (link.startsWith('chat:') || item.type == 'chat' || item.type == 'voice') {
      final convoId = link.replaceAll('chat:', '');
      final convo = ConversationModel(
        id: convoId.isNotEmpty ? convoId : 'conv_notif',
        contactId: 'u_peer',
        contactName: item.title.split(' ').first,
        contextType: 'general',
        contextTitle: item.body,
        lastMessage: item.body,
        lastTime: item.time,
        campusId: campusId,
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ChatDetailScreen(conversation: convo)),
      );
    } else if (link == 'bikes:requests' || item.type == 'bike_request') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const BikeRequestsScreen()),
      );
    } else if (link.startsWith('rate:') || item.type == 'rating_prompt') {
      final peerName = item.metadata?['peer_name']?.toString() ?? 'Campus Peer';
      final peerId = item.metadata?['peer_id']?.toString() ?? 'u_peer';
      final ctxTitle = item.metadata?['context_title']?.toString() ?? item.body;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RateUserScreen(
            peerId: peerId,
            peerName: peerName,
            contextTitle: ctxTitle,
          ),
        ),
      );
    } else if (item.type == 'market_request' || item.type == 'market_sold') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MarketScreen()),
      );
    } else if (item.type == 'new_rating') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const UserProfileScreen()),
      );
    }
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'voice':
      case 'chat':
      case 'message':
        return LucideIcons.messageSquare;
      case 'bike':
      case 'bike_request':
      case 'bike_booked':
      case 'bike_returned':
        return LucideIcons.bike;
      case 'market':
      case 'market_request':
      case 'market_sold':
        return LucideIcons.shoppingBag;
      case 'rating':
      case 'rating_prompt':
      case 'new_rating':
        return LucideIcons.star;
      default:
        return LucideIcons.bell;
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
              title: 'Notifications',
              onBack: () => Navigator.of(context).pop(),
            ),

            // Filter chips and Mark all read action
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _filters.map((filter) {
                          final isSelected = _selectedFilter == filter;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _selectedFilter = filter);
                                _loadNotifications();
                              },
                              child: Container(
                                height: 44,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: isSelected ? colors.primary : colors.surface,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: isSelected ? colors.primary : colors.inputBorder,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  filter,
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
                    ),
                  ),
                  GestureDetector(
                    onTap: _markAllAsRead,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      child: Text(
                        'Mark all read',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Notifications List
            Expanded(
              child: _buildBody(colors),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(AppColorsExtension colors) {
    if (_isLoading) {
      return const StateView.loadingList();
    }

    if (_errorMessage != null) {
      return StateView.offline(onRetry: _loadNotifications);
    }

    if (_notifications.isEmpty) {
      return StateView.empty(
        title: 'No notifications',
        body: 'Activity about your bike rentals, marketplace buy requests, and ratings will appear here.',
        icon: LucideIcons.bell,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      color: colors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final item = _notifications[index];
          final isUnread = !item.read;

          final cardBg = isUnread ? const Color(0xFFE9F4EE) : colors.surface;
          final iconBg = isUnread ? colors.primary : colors.skeleton;
          final iconFg = isUnread ? Colors.white : colors.textMuted;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.head != null && item.head!.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: Text(
                    item.head!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: colors.textMuted,
                    ),
                  ),
                ),
              ],
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () => _handleNotificationTap(item),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: colors.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: iconBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          child: Icon(_getIcon(item.type), size: 20, color: iconFg),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: colors.textPrimary,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    item.time,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: colors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.body,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: colors.textMuted,
                                ),
                              ),
                              if (item.cta != null && item.cta!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  item.cta!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: colors.primary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
