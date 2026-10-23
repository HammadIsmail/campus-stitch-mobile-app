import 'package:flutter/material.dart';
import '../../core/state/auth_state.dart';
import '../../core/theme/app_theme.dart';
import '../../models/verification_model.dart';
import '../../services/verification_service.dart';

class CampusAdminScreen extends StatefulWidget {
  const CampusAdminScreen({super.key});

  @override
  State<CampusAdminScreen> createState() => _CampusAdminScreenState();
}

class _CampusAdminScreenState extends State<CampusAdminScreen> {
  List<VerificationModel> _verifications = [];
  bool _isLoading = true;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _loadQueue();
  }

  Future<void> _loadQueue() async {
    setState(() => _isLoading = true);
    try {
      final campusId = AuthState.instance.activeCampusId;
      final list = await VerificationService.getVerifications(campusId: campusId);
      setState(() => _verifications = list);
    } catch (e) {
      debugPrint('Error loading verification queue: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _reviewItem(VerificationModel item, String action) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(action == 'approved' ? 'Approve Student Verification?' : 'Reject Verification Request?'),
        content: Text(
          action == 'approved'
              ? 'This will verify ${item.name} (${item.studentId}) for ${item.campusName} with instant peer-to-peer trust.'
              : 'Reject verification for ${item.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: action == 'approved' ? AppColors.success : AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(action == 'approved' ? 'Confirm Approval' : 'Confirm Reject'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final res = await VerificationService.reviewVerification(
      verificationId: item.id,
      action: action,
    );

    if (res.success) {
      setState(() {
        _verifications.removeWhere((v) => v.id == item.id);
        _statusMessage = 'Student verification marked as $action.';
      });
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _statusMessage = null);
      });
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message ?? 'Review failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final campusName = AuthState.instance.activeCampusName;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Campus Verification Portal'),
            Text(
              campusName,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.zinc500),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadQueue,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: AppColors.campusAdmin.withValues(alpha: 0.1),
                  child: Row(
                    children: [
                      const Icon(Icons.shield_outlined, color: AppColors.campusAdmin, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Identity Review Queue for $campusName. Side-by-side verification prevents identity fraud.',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.campusAdmin),
                        ),
                      ),
                    ],
                  ),
                ),

                if (_statusMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: AppColors.success.withValues(alpha: 0.15),
                    child: Text(
                      _statusMessage!,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.success),
                    ),
                  ),

                Expanded(
                  child: _verifications.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.verified_user_outlined, size: 48, color: AppColors.zinc400),
                              const SizedBox(height: 12),
                              const Text(
                                'All Verifications Cleared',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'No pending student verification requests for $campusName',
                                style: const TextStyle(fontSize: 12, color: AppColors.zinc500),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _verifications.length,
                          separatorBuilder: (_, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final item = _verifications[index];
                            return _buildVerificationCard(item);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildVerificationCard(VerificationModel item) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Info Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${item.studentId} • ${item.program}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.zinc500),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.confidenceStatus == 'matches'
                        ? AppColors.success.withValues(alpha: 0.1)
                        : AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: item.confidenceStatus == 'matches'
                          ? AppColors.success.withValues(alpha: 0.3)
                          : AppColors.warning.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.confidenceStatus == 'matches' ? Icons.check_circle : Icons.warning_amber,
                        size: 12,
                        color: item.confidenceStatus == 'matches' ? AppColors.success : AppColors.warning,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.confidenceStatus == 'matches' ? 'Match Confirmed' : 'Check Photo',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: item.confidenceStatus == 'matches' ? AppColors.success : AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Side-by-Side Images (Student Card vs Live Selfie)
            Row(
              children: [
                // 1. Student Card Front
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'STUDENT CARD FRONT',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.zinc500, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          height: 120,
                          width: double.infinity,
                          color: AppColors.zinc800,
                          child: item.cardPhotoUrl != null && item.cardPhotoUrl!.isNotEmpty
                              ? Image.network(
                                  item.cardPhotoUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Center(
                                    child: Icon(Icons.badge, color: AppColors.zinc400, size: 36),
                                  ),
                                )
                              : const Center(
                                  child: Icon(Icons.badge, color: AppColors.zinc400, size: 36),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // 2. Live Face Selfie
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'LIVE FACE SELFIE',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.zinc500, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          height: 120,
                          width: double.infinity,
                          color: AppColors.zinc800,
                          child: item.livePhotoUrl != null && item.livePhotoUrl!.isNotEmpty
                              ? Image.network(
                                  item.livePhotoUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Center(
                                    child: Icon(Icons.face, color: AppColors.zinc400, size: 36),
                                  ),
                                )
                              : const Center(
                                  child: Icon(Icons.face, color: AppColors.zinc400, size: 36),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _reviewItem(item, 'rejected'),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Reject', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _reviewItem(item, 'approved'),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Approve', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
