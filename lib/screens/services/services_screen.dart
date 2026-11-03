import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_strings.dart';
import '../../core/state/auth_state.dart';
import '../../core/theme/app_theme.dart';
import '../../models/chat_model.dart';
import '../../models/service_model.dart';
import '../../services/auth_service.dart';
import '../../services/campus_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_header.dart';
import '../../widgets/chip_filter_row.dart';
import '../../widgets/state_view.dart';
import '../messages/chat_detail_screen.dart';
import 'offer_service_screen.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  List<CampusServiceModel> _services = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Printing',
    'Repair',
    'Laundry',
    'Food',
  ];

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadServices() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final campusId = AuthState.instance.activeCampusId;
    try {
      final services = await CampusService.getServices(
        campusId: campusId,
        category: _selectedCategory == 'All' ? null : _selectedCategory,
      );
      if (mounted) {
        setState(() {
          _services = services;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  List<CampusServiceModel> get _filteredServices {
    final query = _searchController.text.trim().toLowerCase();
    return _services.where((s) {
      final matchesCategory = _selectedCategory == 'All' ||
          s.category.toLowerCase() == _selectedCategory.toLowerCase() ||
          s.name.toLowerCase().contains(_selectedCategory.toLowerCase());
      if (!matchesCategory) return false;
      if (query.isEmpty) return true;
      return s.name.toLowerCase().contains(query) ||
          s.notes.toLowerCase().contains(query) ||
          s.provider.toLowerCase().contains(query) ||
          s.location.toLowerCase().contains(query);
    }).toList();
  }

  void _openChat(CampusServiceModel service) {
    final conv = ConversationModel(
      id: 'conv_service_${service.id}',
      contactId: service.userId ?? 'contact_${service.provider.toLowerCase().replaceAll(RegExp(r'\s+'), '_')}',
      contactName: service.provider,
      contextType: 'service',
      contextId: service.id,
      contextTitle: service.name,
      contextSubtitle: service.rate,
      lastMessage: 'Hi, I need details about ${service.name}.',
      lastTime: 'Just now',
      unreadCount: 0,
      campusId: service.campusId ?? '',
      messages: [],
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatDetailScreen(conversation: conv),
      ),
    );
  }

  void _onContact(CampusServiceModel service) async {
    if (service.phone.isNotEmpty) {
      final clean = service.phone.replaceAll(RegExp(r'[^0-9+]'), '');
      final whatsappUrl = Uri.parse('https://wa.me/$clean');
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
        return;
      }
    }
    if (mounted) {
      _showDetailsModal(service);
    }
  }

  Future<void> _deleteService(CampusServiceModel service) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete service?'),
        content: const Text('This will remove your service offer permanently.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final ok = await CampusService.deleteService(service.id);
      if (!mounted) return;
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service deleted successfully')),
        );
        _loadServices();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete service')),
        );
      }
    }
  }

  void _showDetailsModal(CampusServiceModel service) {
    final colors = context.colors;
    final currentUser = AuthService.currentUser;
    final isOwner = currentUser != null &&
        ((service.userId != null && service.userId == currentUser.id) ||
            service.provider.toLowerCase() == currentUser.fullName.toLowerCase());

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (service.imageUrl != null && service.imageUrl!.isNotEmpty) ...[
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: colors.skeleton,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.network(
                    service.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(height: 14),
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colors.primarySoft,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    clipBehavior: Clip.antiAlias,
                    alignment: Alignment.center,
                    child: service.imageUrl != null && service.imageUrl!.isNotEmpty
                        ? Image.network(
                            service.imageUrl!,
                            fit: BoxFit.cover,
                            width: 44,
                            height: 44,
                            errorBuilder: (_, _, _) => Text(
                              service.initial,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: colors.textOnPrimarySoft,
                              ),
                            ),
                          )
                        : Text(
                            service.initial,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: colors.textOnPrimarySoft,
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.category,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: colors.primary,
                          ),
                        ),
                        Text(
                          service.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: colors.textPrimary,
                          ),
                        ),
                        Text(
                          service.rate,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isOwner)
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: colors.textPrimary),
                      onSelected: (val) async {
                        Navigator.of(ctx).pop();
                        if (val == 'edit') {
                          final res = await Navigator.of(context).push<bool>(
                            MaterialPageRoute(
                              builder: (_) => OfferServiceScreen(initialService: service),
                            ),
                          );
                          if (res == true) _loadServices();
                        } else if (val == 'delete') {
                          _deleteService(service);
                        }
                      },
                      itemBuilder: (menuCtx) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 18),
                              SizedBox(width: 8),
                              Text('Edit service'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete service', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (service.notes.isNotEmpty) ...[
                Text(
                  'Details',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: colors.textMuted),
                ),
                const SizedBox(height: 4),
                Text(
                  service.notes,
                  style: TextStyle(fontSize: 14, color: colors.textPrimary),
                ),
                const SizedBox(height: 12),
              ],
              Text(
                'Location: ${service.location}',
                style: TextStyle(fontSize: 13, color: colors.textMuted),
              ),
              if (service.schedule.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Schedule: ${service.schedule}',
                  style: TextStyle(fontSize: 13, color: colors.textMuted),
                ),
              ],
              const SizedBox(height: 20),
              if (!isOwner) ...[
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: 'Chat in app',
                        icon: LucideIcons.messageSquare,
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          _openChat(service);
                        },
                      ),
                    ),
                    if (service.phone.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: AppButton(
                          text: 'WhatsApp',
                          icon: LucideIcons.phone,
                          isSecondary: true,
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            _onContact(service);
                          },
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
              ],
              AppButton(
                text: 'Close',
                isSecondary: true,
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        );
      },
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
            AppHeader(
              title: AppStrings.tabServices,
              actionLabel: AppStrings.offerServiceAction,
              onActionTap: () async {
                final created = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(builder: (_) => const OfferServiceScreen()),
                );
                if (created == true) {
                  _loadServices();
                }
              },
            ),

            // Search Bar & Filters
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Column(
                children: [
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: colors.inputBorder),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        Icon(LucideIcons.search, size: 20, color: colors.textMuted),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
                            textAlignVertical: TextAlignVertical.center,
                            style: TextStyle(fontSize: 14, color: colors.textPrimary),
                            decoration: AppTheme.borderlessInput(
                              hintText: AppStrings.searchServicesPlaceholder,
                              hintStyle: TextStyle(fontSize: 14, color: colors.textMuted),
                            ),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() {});
                            },
                            child: Icon(LucideIcons.x, size: 18, color: colors.textMuted),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ChipFilterRow(
                    chips: _categories,
                    selectedChip: _selectedCategory,
                    onSelected: (val) {
                      setState(() => _selectedCategory = val);
                      _loadServices();
                    },
                  ),
                ],
              ),
            ),

            // Main Content Area
            Expanded(
              child: _isLoading
                  ? const StateView.loadingList()
                  : _hasError
                      ? StateView.offline(onAction: _loadServices)
                      : _filteredServices.isEmpty
                          ? StateView.empty(
                              title: AppStrings.servicesEmptyTitle,
                              body: AppStrings.servicesEmptyBody,
                              actionLabel: AppStrings.offerServiceCTA,
                              onAction: () async {
                                final created = await Navigator.of(context).push<bool>(
                                  MaterialPageRoute(builder: (_) => const OfferServiceScreen()),
                                );
                                if (created == true) _loadServices();
                              },
                            )
                          : RefreshIndicator(
                              onRefresh: _loadServices,
                              color: colors.primary,
                              child: ListView.builder(
                                padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                                itemCount: _filteredServices.length,
                                itemBuilder: (context, index) {
                                  final s = _filteredServices[index];
                                  final currentUser = AuthService.currentUser;
                                  final isOwner = currentUser != null &&
                                      ((s.userId != null && s.userId == currentUser.id) ||
                                          s.provider.toLowerCase() == currentUser.fullName.toLowerCase());
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
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: colors.primarySoft,
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              clipBehavior: Clip.antiAlias,
                                              alignment: Alignment.center,
                                              child: s.imageUrl != null && s.imageUrl!.isNotEmpty
                                                  ? Image.network(
                                                      s.imageUrl!,
                                                      fit: BoxFit.cover,
                                                      width: 40,
                                                      height: 40,
                                                      errorBuilder: (_, _, _) => Text(
                                                        s.initial,
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w800,
                                                          color: colors.textOnPrimarySoft,
                                                        ),
                                                      ),
                                                    )
                                                  : Text(
                                                      s.initial,
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
                                                    s.category,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w700,
                                                      color: colors.primary,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 1),
                                                  Text(
                                                    s.name,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w700,
                                                      color: colors.textPrimary,
                                                      height: 1.25,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              s.rate,
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w800,
                                                color: colors.textPrimary,
                                              ),
                                            ),
                                            if (isOwner) ...[
                                              const SizedBox(width: 4),
                                              PopupMenuButton<String>(
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(),
                                                icon: Icon(Icons.more_vert, size: 20, color: colors.textMuted),
                                                onSelected: (val) async {
                                                  if (val == 'edit') {
                                                    final res = await Navigator.of(context).push<bool>(
                                                      MaterialPageRoute(
                                                        builder: (_) => OfferServiceScreen(initialService: s),
                                                      ),
                                                    );
                                                    if (res == true) {
                                                      _loadServices();
                                                    }
                                                  } else if (val == 'delete') {
                                                    _deleteService(s);
                                                  }
                                                },
                                                itemBuilder: (ctx) => [
                                                  const PopupMenuItem(
                                                    value: 'edit',
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.edit_outlined, size: 18),
                                                        SizedBox(width: 8),
                                                        Text('Edit service'),
                                                      ],
                                                    ),
                                                  ),
                                                  const PopupMenuItem(
                                                    value: 'delete',
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                                        SizedBox(width: 8),
                                                        Text('Delete service', style: TextStyle(color: Colors.red)),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '${s.provider}, ${s.location}${s.notes.isNotEmpty ? ' · ${s.notes}' : ''}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: colors.textMuted,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (!isOwner) ...[
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: AppButton(
                                                  text: 'Chat',
                                                  icon: LucideIcons.messageSquare,
                                                  height: 40,
                                                  onPressed: () => _openChat(s),
                                                ),
                                              ),
                                              if (s.phone.isNotEmpty) ...[
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: AppButton(
                                                    text: 'WhatsApp',
                                                    icon: LucideIcons.phone,
                                                    height: 40,
                                                    isSecondary: true,
                                                    onPressed: () => _onContact(s),
                                                  ),
                                                ),
                                              ],
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: AppButton(
                                                  text: 'Details',
                                                  height: 40,
                                                  isSecondary: true,
                                                  onPressed: () => _showDetailsModal(s),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
