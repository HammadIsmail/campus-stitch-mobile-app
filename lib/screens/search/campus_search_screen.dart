import 'package:flutter/material.dart';
import '../../core/state/auth_state.dart';
import '../../core/theme/app_theme.dart';
import '../../services/assistant_service.dart';

class AssistantChatMessage {
  final bool isUser;
  final String text;
  final AssistantResponse? response;
  final Map<String, bool> actionDone;

  AssistantChatMessage({
    required this.isUser,
    required this.text,
    this.response,
    Map<String, bool>? actionDone,
  }) : actionDone = actionDone ?? {};
}

class CampusSearchScreen extends StatefulWidget {
  final String? initialQuery;

  const CampusSearchScreen({super.key, this.initialQuery});

  @override
  State<CampusSearchScreen> createState() => _CampusSearchScreenState();
}

class _CampusSearchScreenState extends State<CampusSearchScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<AssistantChatMessage> _messages = [];
  bool _isLoading = false;

  final List<String> _suggestions = const [
    'Is anyone going to Khurrialwala today?',
    'Can I rent a bike or bicycle tomorrow?',
    'Looking for a room cooler or textbook to buy',
    'Anyone offering laundry pickup or printer repair?',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null && widget.initialQuery!.trim().isNotEmpty) {
      _handleSendQuery(widget.initialQuery!.trim());
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSendQuery(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(AssistantChatMessage(isUser: true, text: trimmed));
      _isLoading = true;
    });
    _textController.clear();
    _scrollToBottom();

    final res = await AssistantService.askAssistant(trimmed);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _messages.add(AssistantChatMessage(
        isUser: false,
        text: res?.reply ??
            'I checked campus records for you. You can find rides, bike rentals, student services, or marketplace items directly.',
        response: res,
      ));
    });
    _scrollToBottom();
  }

  void _markActionDone(int msgIndex, String itemId) {
    setState(() {
      _messages[msgIndex].actionDone[itemId] = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final campusName = AuthState.instance.activeCampusName;

    return Scaffold(
      backgroundColor: isDark ? AppColors.zinc950 : const Color(0xFFF9F9FB),
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: isDark ? AppColors.zinc900 : Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.emerald500.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.auto_awesome, size: 18, color: AppColors.emerald500),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Campus Search Assistant', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                Text(
                  campusName.toUpperCase(),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.zinc500),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Message stream or empty state
          Expanded(
            child: _messages.isEmpty ? _buildEmptyState(isDark) : _buildChatList(isDark),
          ),

          if (_isLoading)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: isDark ? AppColors.zinc900 : Colors.white,
              child: Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.emerald500),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Searching live campus database...',
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : AppColors.zinc600),
                  ),
                ],
              ),
            ),

          // Bottom Input Bar
          _buildInputBar(isDark),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isDark ? AppColors.zinc800 : AppColors.zinc100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.zinc700 : AppColors.zinc300),
            ),
            child: Icon(Icons.auto_awesome, size: 28, color: AppColors.emerald500),
          ),
          const SizedBox(height: 16),
          const Text(
            'How can I help your campus life?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            'Ask in plain English or Urdu if someone is going somewhere, bike to rent, item to buy, or student service.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : AppColors.zinc500),
          ),
          const SizedBox(height: 28),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'QUICK SEARCHES',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: isDark ? Colors.white60 : AppColors.zinc400,
              ),
            ),
          ),
          const SizedBox(height: 10),

          ..._suggestions.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () => _handleSendQuery(s),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.zinc900 : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? AppColors.zinc800 : AppColors.zinc200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            s,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : AppColors.zinc800,
                            ),
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, size: 12, color: isDark ? Colors.white38 : AppColors.zinc400),
                      ],
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildChatList(bool isDark) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        if (msg.isUser) {
          return Align(
            alignment: Alignment.centerRight,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12, left: 40),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.emerald500 : Colors.black,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(4),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Text(
                msg.text,
                style: const TextStyle(fontSize: 13.5, color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          );
        } else {
          return Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chips
                  if (msg.response?.chips.isNotEmpty ?? false)
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: msg.response!.chips.map((chip) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.zinc800 : AppColors.zinc200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            chip,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white70 : AppColors.zinc700,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 6),

                  // Natural Language Reply Container
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.zinc900 : Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      border: Border.all(color: isDark ? AppColors.zinc800 : AppColors.zinc200),
                    ),
                    child: Text(
                      msg.text,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: isDark ? Colors.white : AppColors.zinc900,
                        height: 1.35,
                      ),
                    ),
                  ),

                  // Render Actionable Cards if response has tool results
                  if (msg.response != null) _buildResultCards(msg.response!, index, isDark),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildResultCards(AssistantResponse resp, int msgIndex, bool isDark) {
    final optType = resp.optionsType;

    // 1. RIDE CARDS
    if (optType == 'ride' && resp.rides.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text(
            'AVAILABLE COMMUTE RIDES (${resp.rides.length})',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? Colors.white60 : AppColors.zinc500),
          ),
          const SizedBox(height: 6),
          ...resp.rides.map((r) {
            final id = r['id']?.toString() ?? '';
            final isDone = _messages[msgIndex].actionDone[id] ?? false;
            final from = r['from_location'] ?? 'Pickup';
            final to = r['to_location'] ?? 'Campus';
            final time = r['departure_time'] ?? 'Time';
            final driver = r['organizer_name'] ?? 'Student';
            final price = r['price_per_seat'] ?? '0';
            final seats = r['available_seats'] ?? 1;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.zinc900 : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? AppColors.zinc800 : AppColors.zinc200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.directions_car, size: 16, color: AppColors.emerald500),
                          const SizedBox(width: 6),
                          Text('$from → $to', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Text('Rs. $price', style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 12, color: isDark ? Colors.white60 : AppColors.zinc500),
                      const SizedBox(width: 4),
                      Text(time, style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : AppColors.zinc500)),
                      const SizedBox(width: 8),
                      Text('• $driver', style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : AppColors.zinc500)),
                      const SizedBox(width: 8),
                      Text('$seats seats left', style: TextStyle(fontSize: 11, color: AppColors.emerald500, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: ElevatedButton(
                      onPressed: isDone ? null : () => _markActionDone(msgIndex, id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDone ? AppColors.zinc700 : AppColors.emerald500,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        isDone ? '✓ Ride Requested' : 'Request Ride (Cash on Trip)',
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      );
    }

    // 2. BIKE CARDS
    if (optType == 'bike' && resp.bikes.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text(
            'AVAILABLE BIKES FOR RENT (${resp.bikes.length})',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? Colors.white60 : AppColors.zinc500),
          ),
          const SizedBox(height: 6),
          ...resp.bikes.map((b) {
            final id = b['id']?.toString() ?? '';
            final isDone = _messages[msgIndex].actionDone[id] ?? false;
            final model = b['model'] ?? 'Bike';
            final owner = b['owner_name'] ?? 'Student';
            final rate = b['daily_rate'] ?? '0';

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.zinc900 : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? AppColors.zinc800 : AppColors.zinc200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.two_wheeler, size: 16, color: Colors.blueAccent),
                          const SizedBox(width: 6),
                          Text(model, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Text('Rs. $rate / day', style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Owner: $owner', style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : AppColors.zinc500)),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: ElevatedButton(
                      onPressed: isDone ? null : () => _markActionDone(msgIndex, id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDone ? AppColors.zinc700 : (isDark ? Colors.white : Colors.black),
                        foregroundColor: isDone ? Colors.white : (isDark ? Colors.black : Colors.white),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        isDone ? '✓ Rent Requested' : 'Rent Bike (Cash Handover)',
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      );
    }

    // 3. MARKETPLACE CARDS
    if (optType == 'listing' && resp.listings.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text(
            'MARKETPLACE ITEMS (${resp.listings.length})',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? Colors.white60 : AppColors.zinc500),
          ),
          const SizedBox(height: 6),
          ...resp.listings.map((l) {
            final id = l['id']?.toString() ?? '';
            final isDone = _messages[msgIndex].actionDone[id] ?? false;
            final title = l['title'] ?? 'Item';
            final price = l['price'] ?? '0';
            final seller = l['seller_name'] ?? 'Student';
            final condition = l['condition'] ?? 'Used';

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.zinc900 : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? AppColors.zinc800 : AppColors.zinc200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('Rs. $price', style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Seller: $seller • $condition', style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : AppColors.zinc500)),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: ElevatedButton(
                      onPressed: isDone ? null : () => _markActionDone(msgIndex, id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDone ? AppColors.zinc700 : AppColors.emerald500,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        isDone ? '✓ Buy Request Sent' : 'Request to Buy (Cash Pickup)',
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      );
    }

    // 4. CAMPUS SERVICE CARDS
    if (optType == 'service' && resp.services.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text(
            'CAMPUS STUDENT SERVICES (${resp.services.length})',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? Colors.white60 : AppColors.zinc500),
          ),
          const SizedBox(height: 6),
          ...resp.services.map((s) {
            final id = s['id']?.toString() ?? '';
            final isDone = _messages[msgIndex].actionDone[id] ?? false;
            final name = s['name'] ?? 'Service';
            final rate = s['rate'] ?? 'Negotiable';
            final provider = s['provider'] ?? 'Student';
            final schedule = s['schedule'] ?? 'Daily';

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.zinc900 : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? AppColors.zinc800 : AppColors.zinc200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.build_outlined, size: 16, color: Colors.purpleAccent),
                          const SizedBox(width: 6),
                          Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Text(rate, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: AppColors.emerald500)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('By $provider • $schedule', style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : AppColors.zinc500)),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: ElevatedButton(
                      onPressed: isDone ? null : () => _markActionDone(msgIndex, id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDone ? AppColors.zinc700 : AppColors.emerald500,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        isDone ? '✓ Service Requested' : 'Request Service (Cash Delivery)',
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildInputBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.zinc900 : Colors.white,
        border: Border(top: BorderSide(color: isDark ? AppColors.zinc800 : AppColors.zinc200)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.zinc800 : AppColors.zinc100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isDark ? AppColors.zinc700 : AppColors.zinc300),
                ),
                child: TextField(
                  controller: _textController,
                  textInputAction: TextInputAction.send,
                  onSubmitted: _handleSendQuery,
                  style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Ask for ride, bike, item, or service...',
                    hintStyle: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : AppColors.zinc400),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send_rounded, size: 20),
              color: AppColors.emerald500,
              onPressed: () => _handleSendQuery(_textController.text),
            ),
          ],
        ),
      ),
    );
  }
}
