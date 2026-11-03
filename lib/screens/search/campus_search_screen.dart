import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/constants/app_constants.dart';
import '../../core/state/auth_state.dart';
import '../../core/storage/session_store.dart';
import '../../core/theme/app_theme.dart';
import '../../models/ai_search_model.dart';
import '../../models/bike_model.dart';
import '../../models/market_item_model.dart';
import '../../models/roommate_model.dart';
import '../../services/assistant_service.dart';
import '../../widgets/state_view.dart';
import '../../widgets/sub_header.dart';
import '../bikes/bike_detail_screen.dart';
import '../market/market_item_detail_screen.dart';
import '../market/market_screen.dart';
import '../roommates/roommate_detail_screen.dart';
import '../services/services_screen.dart';

enum _AskState { initial, searching, results, noMatch, offline }

class CampusSearchScreen extends StatefulWidget {
  final String? initialQuery;

  const CampusSearchScreen({super.key, this.initialQuery});

  @override
  State<CampusSearchScreen> createState() => _CampusSearchScreenState();
}

class _CampusSearchScreenState extends State<CampusSearchScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _queryController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _spinController;

  _AskState _currentState = _AskState.initial;
  String _activeQuery = '';
  AiSearchResultModel? _searchResult;
  bool _alertToggle = false;

  final List<String> _starterIdeas = const [
    'Aaj shaam ko koi bike available hai?',
    'Air cooler sale pe hai?',
    'Hostel 3 mein printing wala koi hai?',
  ];

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    if (widget.initialQuery != null && widget.initialQuery!.trim().isNotEmpty) {
      _queryController.text = widget.initialQuery!.trim();
      _performSearch(widget.initialQuery!.trim());
    }
  }

  @override
  void dispose() {
    _queryController.dispose();
    _scrollController.dispose();
    _spinController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String queryText) async {
    final clean = queryText.trim();
    if (clean.isEmpty) return;

    setState(() {
      _activeQuery = clean;
      _currentState = _AskState.searching;
    });

    final user = await SessionStore.getUser();
    final campusId = user?.campusId ?? AuthState.instance.activeCampusId;
    final campusName = user?.campusName ?? AuthState.instance.activeCampusName;

    final result = await AssistantService.searchCampusAi(
      query: clean,
      campusId: campusId,
      campusName: campusName,
    );

    if (!mounted) return;

    if (result == null) {
      setState(() => _currentState = _AskState.offline);
      return;
    }

    setState(() {
      _searchResult = result;
      // If there are cards OR if the chatbot gave a real reply, show results view!
      _currentState = (result.cards.isNotEmpty || result.reply.isNotEmpty)
          ? _AskState.results
          : _AskState.noMatch;
    });
  }

  void _onCardTap(AiSearchCardModel card) {
    if (card.type == 'bike') {
      final bike = BikeModel(
        id: card.id,
        model: card.title,
        hourlyRate: 80,
        dailyRate: 500,
        location: card.meta,
        ownerName: 'Hamza A.',
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BikeDetailScreen(bike: bike)),
      );
    } else if (card.type == 'market') {
      final priceNum = int.tryParse(card.price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 12000;
      final item = MarketItemModel(
        id: card.id,
        title: card.title,
        price: priceNum,
        category: 'Market Item',
        condition: card.meta,
        sellerName: 'Campus Peer',
        campusId: AuthState.instance.activeCampusId,
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MarketItemDetailScreen(item: item)),
      );
    } else if (card.type == 'roommate') {
      final post = RoommatePostModel(
        id: card.id,
        title: card.title,
        rent: card.price,
        area: card.meta,
        who: 'Campus Student',
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RoommateDetailScreen(post: post)),
      );
    } else if (card.type == 'service') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ServicesScreen()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MarketScreen()),
      );
    }
  }

  IconData _getIconForTag(String tag) {
    switch (tag.toLowerCase()) {
      case 'bike':
        return LucideIcons.bike;
      case 'service':
        return LucideIcons.wrench;
      case 'roommate':
        return LucideIcons.home;
      default:
        return LucideIcons.shoppingBag;
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
              title: 'Ask $kAppName',
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: _buildCurrentStateView(colors),
            ),
            _buildBottomBar(colors),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStateView(AppColorsExtension colors) {
    switch (_currentState) {
      case _AskState.initial:
        return _buildInitialView(colors);
      case _AskState.searching:
        return _buildSearchingView(colors);
      case _AskState.results:
        return _buildResultsView(colors);
      case _AskState.noMatch:
        return _buildNoMatchView(colors);
      case _AskState.offline:
        return StateView.offline(onRetry: () => _performSearch(_activeQuery));
    }
  }

  // 1. Start / Initial Screen (Ask.dc.html)
  Widget _buildInitialView(AppColorsExtension colors) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sparkle Icon Circle
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colors.primarySoft,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              LucideIcons.sparkles,
              size: 28,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 14),

          // Title
          Text(
            'What are you looking for?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),

          // Subtitle
          Text(
            'Ask in English, Urdu or Roman Urdu. I will search bikes, market items and services on your campus only.',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: colors.textMuted,
            ),
          ),
          const SizedBox(height: 24),

          // "Try asking" suggestions section
          Text(
            'Try asking',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: colors.textMuted,
            ),
          ),
          const SizedBox(height: 10),

          ..._starterIdeas.map((idea) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () {
                  _queryController.text = idea;
                  _performSearch(idea);
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 56),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          idea,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        LucideIcons.arrowRight,
                        size: 18,
                        color: colors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // 2. Searching State (AskThinking.dc.html)
  Widget _buildSearchingView(AppColorsExtension colors) {
    final campusName = AuthState.instance.activeCampusName;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // User Prompt Bubble
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 300),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(16).copyWith(bottomRight: const Radius.circular(4)),
              ),
              child: Text(
                _activeQuery,
                style: const TextStyle(fontSize: 14, color: Colors.white, height: 1.4),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // "Looking for you" Progress Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16).copyWith(bottomLeft: const Radius.circular(4)),
              border: Border.all(color: colors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Looking for you',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: colors.textPrimary),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(LucideIcons.check, size: 18, color: colors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Understood your request',
                        style: TextStyle(fontSize: 13, color: colors.textPrimary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(LucideIcons.check, size: 18, color: colors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Checked only $campusName listings',
                        style: TextStyle(fontSize: 13, color: colors.textPrimary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    RotationTransition(
                      turns: _spinController,
                      child: Icon(LucideIcons.loader, size: 18, color: colors.primary),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Searching Market, Bikes, and Services...',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: colors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Shimmer Skeleton Cards
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: colors.skeleton,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 80, height: 12, color: colors.skeleton),
                      const SizedBox(height: 8),
                      Container(width: 160, height: 14, color: colors.skeleton),
                      const SizedBox(height: 8),
                      Container(width: 100, height: 12, color: colors.skeleton),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. Results View (AskResults.dc.html)
  Widget _buildResultsView(AppColorsExtension colors) {
    final result = _searchResult;
    if (result == null) return const SizedBox.shrink();

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      children: [
        // User Prompt Bubble
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 300),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(16).copyWith(bottomRight: const Radius.circular(4)),
            ),
            child: Text(
              _activeQuery,
              style: const TextStyle(fontSize: 14, color: Colors.white, height: 1.4),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Assistant summary bubble
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 330),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16).copyWith(bottomLeft: const Radius.circular(4)),
              border: Border.all(color: colors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.reply.isNotEmpty
                      ? result.reply
                      : 'Aapki campus mein ${result.cards.length} items mili hain. Card pe tap karke detail dekh lein.',
                  style: TextStyle(fontSize: 14, height: 1.45, color: colors.textPrimary),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: result.searchedTags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: colors.skeleton,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: colors.textPrimary),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Result Cards
        ...result.cards.map((card) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () => _onCardTap(card),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.border),
                ),
                child: Row(
                  children: [
                    // Icon / Photo box
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: colors.skeleton,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Icon(_getIconForTag(card.tag), size: 30, color: colors.textMuted),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: colors.primarySoft,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              card.tag,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: colors.textOnSoft,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            card.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            card.price,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: colors.textPrimary,
                            ),
                          ),
                          Text(
                            card.meta,
                            style: TextStyle(fontSize: 12, color: colors.textMuted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(LucideIcons.chevronRight, size: 18, color: colors.textMuted),
                  ],
                ),
              ),
            ),
          );
        }),

        // Follow-up suggestion chips
        if (result.chips.isNotEmpty) ...[
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: result.chips.map((chip) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () {
                      _queryController.text = chip;
                      _performSearch(chip);
                    },
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: colors.inputBorder),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        chip,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  // 4. No Match View (AskNoResults.dc.html)
  Widget _buildNoMatchView(AppColorsExtension colors) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      children: [
        // User Prompt Bubble
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 300),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(16).copyWith(bottomRight: const Radius.circular(4)),
            ),
            child: Text(
              _activeQuery,
              style: const TextStyle(fontSize: 14, color: Colors.white, height: 1.4),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Assistant Explanation
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 330),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16).copyWith(bottomLeft: const Radius.circular(4)),
              border: Border.all(color: colors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _searchResult?.reply.isNotEmpty == true
                      ? _searchResult!.reply
                      : 'Abhi aapki campus mein "$_activeQuery" ki koi listing nahi mili.',
                  style: TextStyle(fontSize: 14, height: 1.45, color: colors.textPrimary),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: colors.skeleton,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _searchResult?.searchedTags.isNotEmpty == true
                        ? _searchResult!.searchedTags.first
                        : 'Searched Campus',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: colors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // "Want something specific?" notification card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Want something specific?',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: colors.textPrimary),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Tell me when this item is listed on my campus',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary),
                    ),
                  ),
                  Switch.adaptive(
                    value: _alertToggle,
                    activeTrackColor: colors.primary,
                    activeThumbColor: Colors.white,
                    onChanged: (val) {
                      setState(() => _alertToggle = val);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(val ? 'Alert saved for $_activeQuery' : 'Alert turned off'),
                          backgroundColor: colors.primary,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MarketScreen()));
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.inputBorder),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Browse marketplace',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: colors.textPrimary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Bottom Search Bar
  Widget _buildBottomBar(AppColorsExtension colors) {
    final isSearching = _currentState == _AskState.searching;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: isSearching ? colors.divider : colors.background,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: colors.inputBorder),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: TextField(
                controller: _queryController,
                enabled: !isSearching,
                textAlignVertical: TextAlignVertical.center,
                style: TextStyle(fontSize: 15, color: colors.textPrimary),
                decoration: AppTheme.borderlessInput(
                  hintText: 'Koi bike ya cooler mil sakta hai?',
                  hintStyle: TextStyle(fontSize: 14, color: colors.textMuted),
                ),
                onSubmitted: (val) => _performSearch(val),
              ),
            ),
          ),
          const SizedBox(width: 8),

          if (isSearching)
            GestureDetector(
              onTap: () => setState(() => _currentState = _AskState.initial),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.textPrimary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(LucideIcons.square, size: 16, color: Colors.white),
              ),
            )
          else
            GestureDetector(
              onTap: () => _performSearch(_queryController.text),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(LucideIcons.send, size: 20, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
