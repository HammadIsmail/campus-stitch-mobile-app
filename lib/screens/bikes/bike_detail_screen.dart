import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../models/chat_model.dart';
import '../../services/auth_service.dart';
import '../../services/bike_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/sub_header.dart';
import '../messages/chat_detail_screen.dart';
import 'list_bike_screen.dart';

class BikeDetailScreen extends StatefulWidget {
  final BikeModel bike;

  const BikeDetailScreen({super.key, required this.bike});

  @override
  State<BikeDetailScreen> createState() => _BikeDetailScreenState();
}

class _BikeDetailScreenState extends State<BikeDetailScreen> {
  final _messageController = TextEditingController();
  int _selectedSlotIndex = 0;
  String _selectedFrom = '4:00 PM';
  String _selectedUntil = '7:00 PM';
  bool _isSubmitting = false;

  final List<String> _slots = [
    'Today, 4:00 to 9:00 PM',
    'Tomorrow, 8:00 AM to 2:00 PM',
  ];

  final List<String> _fromTimes = ['4:00 PM', '5:00 PM', '6:00 PM', '7:00 PM'];
  final List<String> _untilTimes = ['6:00 PM', '7:00 PM', '8:00 PM', '9:00 PM'];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    setState(() => _isSubmitting = true);
    final user = AuthService.currentUser;

    final res = await BikeService.requestBikeRental(
      bikeId: widget.bike.id,
      renterName: user?.fullName ?? 'Student',
      slotDay: _selectedSlotIndex == 0 ? 'Today' : 'Tomorrow',
      slotTime: '$_selectedFrom to $_selectedUntil',
      note: _messageController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (res.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rental request sent to bike owner!'),
          backgroundColor: Color(0xFF0E6B50),
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message ?? 'Failed to send request'),
          backgroundColor: const Color(0xFFB3261E),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final currentUser = AuthService.currentUser;
    final isOwner = currentUser != null && widget.bike.ownerName.toLowerCase() == currentUser.fullName.toLowerCase();

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            SubHeader(
              title: 'Bike details',
              onBack: () => Navigator.of(context).pop(),
              trailing: isOwner
                  ? PopupMenuButton<String>(
                      icon: Icon(LucideIcons.moreVertical, size: 20, color: colors.textPrimary),
                      onSelected: (val) async {
                        final nav = Navigator.of(context);
                        final scaffold = ScaffoldMessenger.of(context);
                        if (val == 'edit') {
                          final updated = await nav.push<bool>(
                            MaterialPageRoute(builder: (_) => ListBikeScreen(initialBike: widget.bike)),
                          );
                          if (updated == true && mounted) {
                            nav.pop(true);
                          }
                        } else if (val == 'delete') {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete bike listing?'),
                              content: Text('Are you sure you want to remove "${widget.bike.model}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.of(ctx).pop();
                                    final res = await BikeService.deleteBike(widget.bike.id);
                                    if (mounted) {
                                      if (res.success) {
                                        nav.pop(true);
                                      } else {
                                        scaffold.showSnackBar(
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
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit bike')),
                        const PopupMenuItem(value: 'delete', child: Text('Delete listing', style: TextStyle(color: Colors.red))),
                      ],
                    )
                  : null,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bike Photo Box
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: colors.skeleton,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: (widget.bike.imageUrl != null && widget.bike.imageUrl!.isNotEmpty)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                widget.bike.imageUrl!,
                                width: double.infinity,
                                height: 150,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Icon(LucideIcons.bike, size: 56, color: colors.textMuted),
                              ),
                            )
                          : Icon(LucideIcons.bike, size: 56, color: colors.textMuted),
                    ),
                    const SizedBox(height: 14),

                    // Header Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.bike.model,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: colors.textPrimary,
                                  letterSpacing: -0.01,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Owner: ${widget.bike.ownerName} · Pickup at ${widget.bike.location}',
                                style: TextStyle(fontSize: 13, color: colors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: widget.bike.isAvailable ? colors.primarySoft : colors.skeleton,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                          ),
                          child: Text(
                            widget.bike.status,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: widget.bike.isAvailable ? colors.textOnPrimarySoft : colors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Per Hour and Per Day boxes
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: colors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Per hour', style: TextStyle(fontSize: 12, color: colors.textMuted)),
                                const SizedBox(height: 2),
                                Text(
                                  'Rs ${widget.bike.hourlyRate.toInt()}',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: colors.textPrimary),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: colors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Per day', style: TextStyle(fontSize: 12, color: colors.textMuted)),
                                const SizedBox(height: 2),
                                Text(
                                  'Rs ${widget.bike.dailyRate.toInt()}',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: colors.textPrimary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    if (isOwner) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: colors.primarySoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(LucideIcons.info, size: 20, color: colors.primary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'This is your bike listing. You can edit or delete this listing from the top right menu.',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: colors.textOnPrimarySoft,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ] else ...[
                      // Owner is free at
                      Text(
                        'Owner is free at',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: colors.textPrimary),
                      ),
                      const SizedBox(height: 6),
                      Column(
                        children: List.generate(_slots.length, (idx) {
                          final isSelected = idx == _selectedSlotIndex;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedSlotIndex = idx),
                            child: Container(
                              height: 44,
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                color: isSelected ? colors.primarySoft : colors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: isSelected ? colors.primary : colors.inputBorder),
                              ),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _slots[idx],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                  color: isSelected ? colors.textOnPrimarySoft : colors.textPrimary,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 8),

                      // From and Until Dropdowns
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('From', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: colors.textPrimary)),
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
                                      value: _selectedFrom,
                                      isExpanded: true,
                                      icon: Icon(Icons.arrow_drop_down, color: colors.textMuted),
                                      items: _fromTimes.map((t) => DropdownMenuItem(value: t, child: Text(t, style: TextStyle(fontSize: 14, color: colors.textPrimary, fontWeight: FontWeight.w600)))).toList(),
                                      onChanged: (val) {
                                        if (val != null) setState(() => _selectedFrom = val);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Until', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: colors.textPrimary)),
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
                                      value: _selectedUntil,
                                      isExpanded: true,
                                      icon: Icon(Icons.arrow_drop_down, color: colors.textMuted),
                                      items: _untilTimes.map((t) => DropdownMenuItem(value: t, child: Text(t, style: TextStyle(fontSize: 14, color: colors.textPrimary, fontWeight: FontWeight.w600)))).toList(),
                                      onChanged: (val) {
                                        if (val != null) setState(() => _selectedUntil = val);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Message input
                      AppTextField(
                        label: 'Message to owner (optional)',
                        controller: _messageController,
                        hintText: 'Where are you going?',
                      ),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ),

            if (!isOwner)
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                decoration: BoxDecoration(
                  color: colors.surface,
                  border: Border(top: BorderSide(color: colors.border)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppButton(
                      text: 'Chat with owner',
                      icon: LucideIcons.messageSquare,
                      isSecondary: true,
                      onPressed: () {
                        final conv = ConversationModel(
                          id: 'conv_bike_${widget.bike.id}',
                          contactId: 'contact_${widget.bike.ownerName.toLowerCase().replaceAll(RegExp(r'\s+'), '_')}',
                          contactName: widget.bike.ownerName,
                          contextType: 'bike',
                          contextId: widget.bike.id,
                          contextTitle: widget.bike.model,
                          contextSubtitle: widget.bike.rateText,
                          lastMessage: 'Hi, is your bike ${widget.bike.model} available?',
                          lastTime: 'Just now',
                          unreadCount: 0,
                          campusId: widget.bike.campusId ?? '',
                          messages: [],
                        );
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ChatDetailScreen(conversation: conv),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    AppButton(
                      text: 'Send rental request',
                      isLoading: _isSubmitting,
                      onPressed: _submitRequest,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

