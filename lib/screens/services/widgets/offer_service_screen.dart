import 'package:flutter/material.dart';
import '../../../core/state/auth_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/campus_service.dart';

class ServiceTemplate {
  final String title;
  final String defaultRate;
  final IconData icon;

  const ServiceTemplate({
    required this.title,
    required this.defaultRate,
    required this.icon,
  });
}

class OfferServiceScreen extends StatefulWidget {
  final VoidCallback onServiceCreated;

  const OfferServiceScreen({super.key, required this.onServiceCreated});

  @override
  State<OfferServiceScreen> createState() => _OfferServiceScreenState();
}

class _OfferServiceScreenState extends State<OfferServiceScreen> {
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _locationCtrl = TextEditingController(text: 'Hostel Block A');
  final TextEditingController _rateCtrl = TextEditingController();
  final TextEditingController _scheduleCtrl = TextEditingController(text: 'Daily 5 PM – 10 PM');
  final TextEditingController _phoneCtrl = TextEditingController(text: '+923001234567');
  final TextEditingController _notesCtrl = TextEditingController();

  bool _isSubmitting = false;

  final List<ServiceTemplate> _templates = const [
    ServiceTemplate(
      title: 'Laundry Pickup & Wash',
      defaultRate: 'Rs. 40 / pair',
      icon: Icons.local_laundry_service_outlined,
    ),
    ServiceTemplate(
      title: 'Cooler & Electrician Repairs',
      defaultRate: 'Rs. 200 visit',
      icon: Icons.bolt_outlined,
    ),
    ServiceTemplate(
      title: 'Past Papers & Printout Delivery',
      defaultRate: 'Rs. 5 / page',
      icon: Icons.print_outlined,
    ),
    ServiceTemplate(
      title: 'Laptop Setup & OS Formatting',
      defaultRate: 'Rs. 500',
      icon: Icons.build_outlined,
    ),
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _rateCtrl.dispose();
    _scheduleCtrl.dispose();
    _phoneCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _applyTemplate(ServiceTemplate template) {
    setState(() {
      _titleCtrl.text = template.title;
      if (_rateCtrl.text.isEmpty) {
        _rateCtrl.text = template.defaultRate;
      }
    });
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    final rate = _rateCtrl.text.trim();
    final location = _locationCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();

    if (title.isEmpty || rate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in service title and rate'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final user = AuthState.instance.user;
    setState(() => _isSubmitting = true);

    final res = await CampusService.createService(
      name: title,
      rate: rate,
      location: location.isNotEmpty ? location : 'Campus Service Point',
      schedule: _scheduleCtrl.text.trim().isNotEmpty ? _scheduleCtrl.text.trim() : 'Daily 5 PM – 10 PM',
      phone: phone,
      notes: _notesCtrl.text.trim(),
      provider: user?.name ?? 'Student',
      campusId: AuthState.instance.activeCampusId,
      universityId: user?.universityId,
      userId: user?.userId,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (res.success) {
      widget.onServiceCreated();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Campus service published successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message ?? 'Failed to publish campus service'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.black : AppColors.lightBg,
      appBar: AppBar(
        title: const Text('Offer Campus Service', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'Services Hub',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.zinc400 : AppColors.zinc500,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Templates
            Text(
              'QUICK SERVICE TEMPLATES',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                color: isDark ? AppColors.zinc400 : AppColors.zinc600,
              ),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 2.2,
              ),
              itemCount: _templates.length,
              itemBuilder: (context, i) {
                final t = _templates[i];
                final isSelected = _titleCtrl.text == t.title;
                return InkWell(
                  onTap: () => _applyTemplate(t),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? Colors.white : Colors.black)
                          : (isDark ? AppColors.zinc900 : Colors.white),
                      border: Border.all(
                        color: isSelected
                            ? (isDark ? Colors.white : Colors.black)
                            : (isDark ? AppColors.zinc800 : AppColors.zinc200),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          t.icon,
                          size: 20,
                          color: isSelected
                              ? (isDark ? Colors.black : Colors.white)
                              : (isDark ? Colors.white : Colors.black),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                t.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? (isDark ? Colors.black : Colors.white)
                                      : (isDark ? Colors.white : Colors.black),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                t.defaultRate,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isSelected
                                      ? (isDark ? Colors.black87 : Colors.white70)
                                      : (isDark ? AppColors.zinc400 : AppColors.zinc500),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Form container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.zinc900 : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppColors.zinc800 : AppColors.zinc200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('Service Title *'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _titleCtrl,
                    decoration: _inputDecoration(
                      'e.g. Desert Cooler Cleaning & Pump Setup',
                      isDark,
                    ),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('Location / Campus Block *'),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _locationCtrl,
                              decoration: _inputDecoration('Hostel Block A', isDark, prefixIcon: Icons.location_on_outlined),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('Rate / Charges *'),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _rateCtrl,
                              decoration: _inputDecoration('e.g. Rs. 200 visit', isDark),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('Available Hours'),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _scheduleCtrl,
                              decoration: _inputDecoration('e.g. 5 PM – 10 PM', isDark, prefixIcon: Icons.access_time),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('Contact Phone *'),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _phoneCtrl,
                              keyboardType: TextInputType.phone,
                              decoration: _inputDecoration('0300-1234567', isDark, prefixIcon: Icons.phone_outlined),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  _buildFieldLabel('Additional Notes'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _notesCtrl,
                    maxLines: 2,
                    decoration: _inputDecoration(
                      'Bring own detergent, urgent 2-hour delivery available, warranty...',
                      isDark,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Cash-on-delivery notice
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.zinc800.withAlpha(120) : AppColors.zinc100,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? AppColors.zinc700 : AppColors.zinc300,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          size: 16,
                          color: isDark ? AppColors.zinc300 : AppColors.zinc700,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Campus services are fulfilled peer-to-peer. All fees are settled directly in cash upon delivery/completion.',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppColors.zinc300 : AppColors.zinc700,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Colors.white : Colors.black,
                        foregroundColor: isDark ? Colors.black : Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: isDark ? Colors.black : Colors.white,
                              ),
                            )
                          : const Text(
                              'Publish Service Listing',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
    );
  }

  InputDecoration _inputDecoration(String hint, bool isDark, {IconData? prefixIcon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 16, color: isDark ? AppColors.zinc400 : AppColors.zinc500) : null,
      prefixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      filled: true,
      fillColor: isDark ? AppColors.zinc800 : AppColors.zinc100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
    );
  }
}
