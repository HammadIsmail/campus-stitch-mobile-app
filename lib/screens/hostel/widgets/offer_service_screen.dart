import 'package:flutter/material.dart';
import '../../../core/state/auth_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/hostel_service.dart';

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

    final res = await HostelService.createService(
      name: title,
      rate: rate,
      location: location.isNotEmpty ? location : 'Hostel Block A',
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
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Campus service published successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      widget.onServiceCreated();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message ?? 'Failed to publish service'),
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
        titleSpacing: 0,
        title: const Text('Offer Campus Service', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'Hostel Hub',
                style: TextStyle(fontSize: 12, color: AppColors.zinc500, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Service Templates
              const Text(
                'QUICK SERVICE TEMPLATES',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.zinc500),
              ),
              const SizedBox(height: 10),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _templates.length,
                itemBuilder: (context, index) {
                  final t = _templates[index];
                  return InkWell(
                    onTap: () => _applyTemplate(t),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.zinc900 : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? AppColors.zinc800 : AppColors.zinc200),
                      ),
                      child: Row(
                        children: [
                          Icon(t.icon, size: 20, color: isDark ? Colors.white : Colors.black),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  t.title,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  t.defaultRate,
                                  style: TextStyle(fontSize: 10, color: isDark ? Colors.white70 : AppColors.zinc500),
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

              // Form Container
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
                    // Service Title *
                    _buildFieldLabel('Service Title *'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _titleCtrl,
                      decoration: _inputDecoration('e.g. Desert Cooler Cleaning & Pump Setup', isDark),
                    ),
                    const SizedBox(height: 14),

                    // Location / Hostel * and Rate / Charges * in a Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel('Location / Hostel *'),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _locationCtrl,
                                decoration: _inputDecoration('Hostel Block A', isDark, prefixIcon: Icons.location_on_outlined),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
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

                    // Available Hours and Contact Phone in a Row
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
                                decoration: _inputDecoration('Daily 5 PM – 10 PM', isDark, prefixIcon: Icons.access_time),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel('Contact Phone *'),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _phoneCtrl,
                                keyboardType: TextInputType.phone,
                                decoration: _inputDecoration('+923001234567', isDark, prefixIcon: Icons.phone_outlined),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Additional Notes
                    _buildFieldLabel('Additional Notes'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _notesCtrl,
                      maxLines: 3,
                      decoration: _inputDecoration('Bring own soap, urgent delivery available, warranty details...', isDark),
                    ),
                    const SizedBox(height: 20),

                    // Publish Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? Colors.white : Colors.black,
                          foregroundColor: isDark ? Colors.black : Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: _isSubmitting ? null : _submit,
                        child: _isSubmitting
                            ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: isDark ? Colors.black : Colors.white))
                            : Text('Publish Service Listing', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.black : Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
    );
  }

  InputDecoration _inputDecoration(String hint, bool isDark, {IconData? prefixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: AppColors.zinc400),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 16, color: AppColors.zinc500) : null,
      filled: true,
      fillColor: isDark ? AppColors.zinc800 : AppColors.zinc100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      isDense: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
    );
  }
}
