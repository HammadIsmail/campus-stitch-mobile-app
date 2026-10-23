import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class NotificationItem {
  final String id;
  final String type; // 'ride', 'market', 'bike', 'verification', 'community'
  final String title;
  final String message;
  final String time;
  final String deeplink;
  bool read;

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.time,
    required this.deeplink,
    this.read = false,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'All';

  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      type: 'ride',
      title: 'Ride Seat Confirmed!',
      message: 'Your seat in Ahmed Raza\'s Khurrialwala carpool split (8:00 AM) is confirmed.',
      time: '10m ago',
      deeplink: '/commute',
      read: false,
    ),
    NotificationItem(
      id: '2',
      type: 'market',
      title: 'Buyer Inquired on Phone Cooler',
      message: 'Sara Khan sent an inquiry about your Semiconductor Phone Cooler listing.',
      time: '1h ago',
      deeplink: '/market',
      read: false,
    ),
    NotificationItem(
      id: '3',
      type: 'verification',
      title: 'Student Identity Verified',
      message: 'Your Student ID Card has been officially reviewed and verified by Campus Administration.',
      time: 'Yesterday',
      deeplink: '/profile',
      read: true,
    ),
    NotificationItem(
      id: '4',
      type: 'bike',
      title: 'Cycle Rental Available',
      message: 'The Honda CD 70 / cycle rental you watched is ready for pickup at Hostel Block A.',
      time: '2d ago',
      deeplink: '/commute',
      read: true,
    ),
    NotificationItem(
      id: '5',
      type: 'community',
      title: 'New Reply in r/cs-uet',
      message: 'Bilal Cheema replied to your thread: "Tips for Operating Systems Lab 3".',
      time: '3d ago',
      deeplink: '/community',
      read: true,
    ),
  ];

  int get _unreadCount => _notifications.where((n) => !n.read).length;

  List<NotificationItem> get _filteredNotifications {
    if (_selectedFilter == 'All') return _notifications;
    if (_selectedFilter == 'Commute') {
      return _notifications.where((n) => n.type == 'ride' || n.type == 'bike').toList();
    }
    if (_selectedFilter == 'Market') {
      return _notifications.where((n) => n.type == 'market').toList();
    }
    if (_selectedFilter == 'Verification') {
      return _notifications.where((n) => n.type == 'verification').toList();
    }
    return _notifications;
  }

  void _markAllAsRead() {
    setState(() {
      for (var n in _notifications) {
        n.read = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All campus notifications marked as read'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'ride':
        return Icons.directions_car_outlined;
      case 'bike':
        return Icons.two_wheeler_outlined;
      case 'market':
        return Icons.shopping_bag_outlined;
      case 'verification':
        return Icons.verified_user_outlined;
      case 'community':
        return Icons.forum_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'ride':
        return const Color(0xFF2563EB);
      case 'bike':
        return const Color(0xFF0D9488);
      case 'market':
        return const Color(0xFFD97706);
      case 'verification':
        return AppColors.success;
      case 'community':
        return const Color(0xFF8B5CF6);
      default:
        return AppColors.zinc500;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Notifications'),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.white : AppColors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_unreadCount new',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.black : AppColors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton.icon(
              onPressed: _markAllAsRead,
              icon: const Icon(Icons.done_all, size: 16),
              label: const Text('Mark read', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: ['All', 'Commute', 'Market', 'Verification'].map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedFilter = filter);
                    },
                    selectedColor: isDark ? AppColors.white : AppColors.black,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? (isDark ? AppColors.black : AppColors.white)
                          : (isDark ? AppColors.zinc400 : AppColors.zinc600),
                    ),
                    backgroundColor: isDark ? AppColors.zinc900 : AppColors.zinc100,
                    side: BorderSide(
                      color: isSelected
                          ? Colors.transparent
                          : (isDark ? AppColors.zinc800 : AppColors.zinc200),
                    ),
                    showCheckmark: false,
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),

          // Notifications List
          Expanded(
            child: _filteredNotifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_off_outlined,
                          size: 48,
                          color: isDark ? AppColors.zinc700 : AppColors.zinc400,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No notifications found',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'You\'re all caught up with your campus updates.',
                          style: TextStyle(fontSize: 12, color: AppColors.zinc500),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredNotifications.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = _filteredNotifications[index];
                      final iconColor = _getColorForType(item.type);

                      return InkWell(
                        onTap: () {
                          setState(() {
                            item.read = true;
                          });
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: item.read
                                ? (isDark ? AppColors.darkCard : AppColors.white)
                                : (isDark
                                    ? AppColors.zinc900.withValues(alpha: 0.9)
                                    : AppColors.zinc100.withValues(alpha: 0.9)),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: item.read
                                  ? (isDark ? AppColors.zinc800 : AppColors.zinc200)
                                  : (isDark ? AppColors.zinc700 : AppColors.zinc300),
                              width: item.read ? 1 : 1.5,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: iconColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(_getIconForType(item.type), color: iconColor, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.title,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: item.read ? FontWeight.w700 : FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          item.time,
                                          style: const TextStyle(fontSize: 11, color: AppColors.zinc500),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.message,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? AppColors.zinc400 : AppColors.zinc600,
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!item.read) ...[
                                const SizedBox(width: 8),
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(top: 4),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.white : AppColors.black,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
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
