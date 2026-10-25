import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';
import '../../core/state/auth_state.dart';
import '../../core/theme/app_theme.dart';
import '../../services/verification_service.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final ImagePicker _picker = ImagePicker();

  // Image bytes & names
  Uint8List? _selfieBytes;
  String? _selfieName;
  Uint8List? _cardBytes;
  String? _cardName;

  // Controllers
  late TextEditingController _nameCtrl;
  late TextEditingController _studentIdCtrl;
  late TextEditingController _universityCtrl;
  late TextEditingController _campusCtrl;
  late TextEditingController _programCtrl;
  late TextEditingController _deptCtrl;

  bool _isSubmitting = false;
  bool _submitSuccess = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final user = AuthState.instance.user;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _studentIdCtrl = TextEditingController(text: user?.studentId ?? '');
    _universityCtrl = TextEditingController(text: user?.universityName ?? 'UET Lahore');
    _campusCtrl = TextEditingController(text: user?.campusName ?? AuthState.instance.activeCampusName);
    _programCtrl = TextEditingController(text: user?.program ?? 'BS Computer Science');
    _deptCtrl = TextEditingController(text: 'Computer Science');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _studentIdCtrl.dispose();
    _universityCtrl.dispose();
    _campusCtrl.dispose();
    _programCtrl.dispose();
    _deptCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickSelfie(ImageSource source) async {
    setState(() => _errorMessage = null);
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selfieBytes = bytes;
          _selfieName = image.name;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not access camera or photos: $e';
      });
    }
  }

  Future<void> _pickCard(ImageSource source) async {
    setState(() => _errorMessage = null);
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        preferredCameraDevice: CameraDevice.rear,
        maxWidth: 1280,
        maxHeight: 960,
        imageQuality: 88,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _cardBytes = bytes;
          _cardName = image.name;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not access camera or photos: $e';
      });
    }
  }

  Future<void> _handleSubmit() async {
    setState(() => _errorMessage = null);

    if (_selfieBytes == null) {
      setState(() => _errorMessage = 'Please take or upload a live face selfie.');
      return;
    }

    if (_cardBytes == null) {
      setState(() => _errorMessage = 'Please take or upload your Student ID Card photo.');
      return;
    }

    if (_nameCtrl.text.trim().isEmpty || _studentIdCtrl.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please fill in your name and Student ID number.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = AuthState.instance.user;

      // 1. Upload live selfie to Cloudinary
      final selfieUploadRes = await ApiClient.uploadBytes(
        ApiConstants.upload,
        bytes: _selfieBytes!,
        filename: _selfieName ?? 'live_selfie.jpg',
        fields: {'folder': 'campus_stitch/kyc_selfies'},
      );

      if (!selfieUploadRes.success || selfieUploadRes.data is! Map || selfieUploadRes.data['url'] == null) {
        throw Exception(selfieUploadRes.message ?? 'Failed to upload live selfie.');
      }
      final livePhotoUrl = selfieUploadRes.data['url'] as String;

      // 2. Upload student ID card to Cloudinary
      final cardUploadRes = await ApiClient.uploadBytes(
        ApiConstants.upload,
        bytes: _cardBytes!,
        filename: _cardName ?? 'student_card.jpg',
        fields: {'folder': 'campus_stitch/verifications'},
      );

      if (!cardUploadRes.success || cardUploadRes.data is! Map || cardUploadRes.data['url'] == null) {
        throw Exception(cardUploadRes.message ?? 'Failed to upload student card.');
      }
      final cardPhotoUrl = cardUploadRes.data['url'] as String;

      // 3. Submit verification record
      final res = await VerificationService.submitVerification(
        name: _nameCtrl.text.trim(),
        studentId: _studentIdCtrl.text.trim(),
        email: user?.email ?? '',
        university: _universityCtrl.text.trim(),
        campusId: user?.campusId ?? AuthState.instance.activeCampusId,
        campusName: _campusCtrl.text.trim(),
        cardPhotoUrl: cardPhotoUrl,
        livePhotoUrl: livePhotoUrl,
        program: _programCtrl.text.trim(),
        department: _deptCtrl.text.trim(),
      );

      if (res.success) {
        setState(() {
          _submitSuccess = true;
          _isSubmitting = false;
        });
      } else {
        throw Exception(res.message ?? 'Failed to submit verification request.');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Identity Verification'),
      ),
      body: _submitSuccess ? _buildSuccessView(isDark) : _buildFormView(isDark),
    );
  }

  Widget _buildSuccessView(bool isDark) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isDark ? AppColors.white : AppColors.black,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                size: 40,
                color: isDark ? AppColors.black : AppColors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Verification Submitted!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your live face selfie and university student ID have been submitted for campus admin review.\n\nOnce approved, your account badge will automatically turn into Verified Student.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.zinc500, height: 1.5),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.white : AppColors.black,
                foregroundColor: isDark ? AppColors.black : AppColors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Return to Profile', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormView(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header info banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF18181B) : const Color(0xFFF4F4F5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.white : AppColors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'OFFICIAL STUDENT BADGE',
                        style: TextStyle(
                          color: isDark ? AppColors.black : AppColors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'To protect campus safety, prevent fraud, and build trust in rides and listings, take a quick live selfie and snap your student ID card.',
                  style: TextStyle(fontSize: 12, color: AppColors.zinc500, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Error Message Banner
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // STEP 1: Live Face Selfie Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.white : AppColors.black,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '1',
                                style: TextStyle(
                                  color: isDark ? AppColors.black : AppColors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Live Face Selfie',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                          ),
                        ],
                      ),
                      if (_selfieBytes != null)
                        const Row(
                          children: [
                            Icon(Icons.check_circle, size: 15, color: Colors.green),
                            SizedBox(width: 4),
                            Text('Captured', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Oval Selfie Preview / Camera Viewport
                  Container(
                    height: 240,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_selfieBytes != null)
                          Image.memory(
                            _selfieBytes!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          )
                        else
                          // Oval Face Guide Frame
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 130,
                                  height: 170,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.elliptical(130, 170)),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      width: 2,
                                      style: BorderStyle.solid,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Align face inside oval',
                                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (_selfieBytes != null)
                          Positioned(
                            bottom: 12,
                            right: 12,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black.withValues(alpha: 0.7),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () => _pickSelfie(ImageSource.camera),
                              icon: const Icon(Icons.refresh, size: 14),
                              label: const Text('Retake', style: TextStyle(fontSize: 11)),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Actions
                  if (_selfieBytes == null) ...[
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppColors.white : AppColors.black,
                        foregroundColor: isDark ? AppColors.black : AppColors.white,
                        minimumSize: const Size.fromHeight(44),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _pickSelfie(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt_outlined, size: 18),
                      label: const Text('Snap Live Selfie', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton.icon(
                        onPressed: () => _pickSelfie(ImageSource.gallery),
                        icon: const Icon(Icons.upload_file, size: 16),
                        label: const Text('Or upload a clear photo of your face', style: TextStyle(fontSize: 11)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // STEP 2: Student ID Card Photo
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.white : AppColors.black,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '2',
                                style: TextStyle(
                                  color: isDark ? AppColors.black : AppColors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Student ID Card (Front)',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                          ),
                        ],
                      ),
                      if (_cardBytes != null)
                        const Row(
                          children: [
                            Icon(Icons.check_circle, size: 15, color: Colors.green),
                            SizedBox(width: 4),
                            Text('Uploaded', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Card Container Preview
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF18181B) : const Color(0xFFF4F4F5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                        width: 1.5,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_cardBytes != null)
                          Image.memory(
                            _cardBytes!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          )
                        else
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.badge_outlined,
                                size: 44,
                                color: isDark ? Colors.white54 : Colors.black45,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Official Student Card Front',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Name, photo & roll number must be clearly readable',
                                style: TextStyle(fontSize: 10, color: AppColors.zinc500),
                              ),
                            ],
                          ),

                        if (_cardBytes != null)
                          Positioned(
                            bottom: 12,
                            right: 12,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black.withValues(alpha: 0.7),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () => _pickCard(ImageSource.camera),
                              icon: const Icon(Icons.refresh, size: 14),
                              label: const Text('Retake', style: TextStyle(fontSize: 11)),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Actions
                  if (_cardBytes == null) ...[
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark ? AppColors.white : AppColors.black,
                              foregroundColor: isDark ? AppColors.black : AppColors.white,
                              minimumSize: const Size.fromHeight(42),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => _pickCard(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt_outlined, size: 16),
                            label: const Text('Snap Card', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(42),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => _pickCard(ImageSource.gallery),
                            icon: const Icon(Icons.upload_file, size: 16),
                            label: const Text('Gallery', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // STEP 3: Confirm Details
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.white : AppColors.black,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '3',
                            style: TextStyle(
                              color: isDark ? AppColors.black : AppColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Academic Details',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: _nameCtrl,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Full Student Name',
                      prefixIcon: Icon(Icons.person_outline, size: 18),
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: _studentIdCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Student Roll No / ID Number',
                      prefixIcon: Icon(Icons.badge_outlined, size: 18),
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: _universityCtrl,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'University Institution',
                      prefixIcon: Icon(Icons.school_outlined, size: 18),
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: _campusCtrl,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Registered Campus',
                      prefixIcon: Icon(Icons.location_on_outlined, size: 18),
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: _programCtrl,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Degree Program',
                      prefixIcon: Icon(Icons.menu_book_outlined, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Submit Verification Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.white : AppColors.black,
              foregroundColor: isDark ? AppColors.black : AppColors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            onPressed: _isSubmitting ? null : _handleSubmit,
            child: _isSubmitting
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 10),
                      Text('Uploading & Submitting...', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shield_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Submit for Verification', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                    ],
                  ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
