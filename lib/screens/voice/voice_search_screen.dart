import 'package:flutter/material.dart';
import '../../core/state/auth_state.dart';
import '../../core/theme/app_theme.dart';

class VoiceSuggestion {
  final String urdu;
  final String label;
  final String query;

  const VoiceSuggestion({
    required this.urdu,
    required this.label,
    required this.query,
  });
}

class VoiceSearchScreen extends StatefulWidget {
  const VoiceSearchScreen({super.key});

  @override
  State<VoiceSearchScreen> createState() => _VoiceSearchScreenState();
}

class _VoiceSearchScreenState extends State<VoiceSearchScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  bool _isListening = false;
  String _currentQuery = '';
  String? _aiResponse;
  String? _resultType;
  Map<String, dynamic>? _resultData;

  final TextEditingController _textController = TextEditingController();

  final List<VoiceSuggestion> _suggestions = const [
    VoiceSuggestion(
      urdu: 'کیا کوئی کھڑیاںوالہ جا رہا ہے؟',
      label: 'Khurrialwala commute ride',
      query: 'کیا کوئی کھڑیاںوالہ جا رہا ہے؟',
    ),
    VoiceSuggestion(
      urdu: 'ہاسٹل لانڈری یا استری سروس چاہیے',
      label: 'Campus Services & Laundry',
      query: 'Show campus services and laundry',
    ),
    VoiceSuggestion(
      urdu: 'ہاسٹل کے لیے فون کولر یا بک چاہیے',
      label: 'Hostel & Marketplace items',
      query: 'Show semiconductor phone cooler or textbook in market',
    ),
    VoiceSuggestion(
      urdu: 'طالبعلم کی تصدیق اور پروفائل چیک کریں',
      label: 'Student Verification & Card',
      query: 'Check my student verification status',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _simulateVoiceInput(String text) {
    setState(() {
      _isListening = true;
      _currentQuery = text;
      _aiResponse = null;
      _resultType = null;
      _resultData = null;
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _isListening = false;

        final lower = text.toLowerCase();
        if (lower.contains('کھڑیاںوالہ') || lower.contains('khurrialwala') || lower.contains('ride') || lower.contains('carpool')) {
          _aiResponse = 'مجھے آپ کے کیمپس کے لیے کھڑیاںوالہ کی تصدیق شدہ کارپول مل گئی ہے۔ احمد رضا کی ٹویوٹا کرولا صبح 8:00 بجے روانہ ہوگی۔';
          _resultType = 'ride';
          _resultData = {
            'title': 'Khurrialwala Morning Ride (8:00 AM)',
            'driver': 'Ahmed Raza (Verified)',
            'car': 'Toyota Corolla • 3 seats left',
            'fare': 'Rs. 250 / seat',
          };
        } else if (lower.contains('service') || lower.contains('سروس') || lower.contains('laundry') || lower.contains('لانڈری')) {
          _aiResponse = 'ہاسٹل میں تصدیق شدہ سٹوڈنٹ لانڈری اور استری سروس دستیاب ہے۔ ارسلان خان شام 6 بجے روم سے پک اپ کرتے ہیں۔';
          _resultType = 'service';
          _resultData = {
            'title': 'Express Student Laundry & Ironing',
            'driver': 'Arslan Khan (Hostel Block A)',
            'car': 'Rs. 50 / pair • Daily pickup',
            'fare': 'Available 6:00 PM - 10:00 PM',
          };
        } else if (lower.contains('کولر') || lower.contains('cooler') || lower.contains('book') || lower.contains('market')) {
          _aiResponse = 'ہاسٹل اور مارکیٹ پلیس میں سیمی کنڈکٹر فون کولر دستیاب ہے۔ قیمت 1,800 روپے ہے۔';
          _resultType = 'market';
          _resultData = {
            'title': 'Semiconductor Phone Cooler for Gaming & Lab',
            'seller': 'Zain Ali (Hostel Block C)',
            'price': 'Rs. 1,800',
            'condition': 'Like new • Magnetic clamp',
          };
        } else {
          _aiResponse = 'آپ کی درخواست کیمپس ڈیٹا بیس میں تلاش کر لی گئی ہے۔ آپ کیمپس ماڈیولز سے مطلوبہ معلومات دیکھ سکتے ہیں۔';
          _resultType = 'general';
          _resultData = {
            'title': 'Campus Record Match',
            'status': 'Found campus records for ${AuthState.instance.activeCampusName}',
          };
        }
      });
    });
  }

  void _toggleMic() {
    if (_isListening) {
      setState(() => _isListening = false);
    } else {
      _simulateVoiceInput('کیا کوئی کھڑیاںوالہ جا رہا ہے؟');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final campusName = AuthState.instance.activeCampusName;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Voice & AI Assistant'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Campus context badge
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.zinc900 : AppColors.zinc100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? AppColors.zinc800 : AppColors.zinc200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.record_voice_over, size: 14, color: AppColors.success),
                    const SizedBox(width: 6),
                    Text(
                      'Urdu & English Voice AI • $campusName',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Animated Mic Pulse Button
            Center(
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isListening ? _pulseAnimation.value : 1.0,
                    child: GestureDetector(
                      onTap: _toggleMic,
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isListening
                              ? AppColors.error
                              : (isDark ? AppColors.white : AppColors.black),
                          boxShadow: [
                            BoxShadow(
                              color: (_isListening ? AppColors.error : AppColors.black)
                                  .withValues(alpha: 0.25),
                              blurRadius: 18,
                              spreadRadius: _isListening ? 6 : 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          _isListening ? Icons.graphic_eq : Icons.mic,
                          size: 42,
                          color: _isListening
                              ? Colors.white
                              : (isDark ? AppColors.black : AppColors.white),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _isListening
                  ? 'Listening in Urdu & English...'
                  : 'Tap the microphone or choose a voice prompt',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _isListening ? AppColors.error : AppColors.zinc500,
              ),
            ),
            const SizedBox(height: 28),

            // Display current query / transcription
            if (_currentQuery.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.zinc900 : AppColors.zinc100,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? AppColors.zinc800 : AppColors.zinc200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.hearing, size: 18, color: AppColors.zinc500),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _currentQuery,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Display AI response card
            if (_aiResponse != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.zinc800 : AppColors.zinc200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.auto_awesome, size: 16, color: AppColors.success),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'CAMPUS AI ASSISTANT',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.success, letterSpacing: 0.8),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _aiResponse!,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, height: 1.4),
                    ),
                    if (_resultData != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.zinc900 : AppColors.zinc100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _resultType == 'ride'
                                  ? Icons.directions_car
                                  : (_resultType == 'service' ? Icons.build_outlined : Icons.shopping_bag),
                              size: 20,
                              color: isDark ? AppColors.white : AppColors.black,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _resultData!['title'] ?? '',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _resultData!['driver'] ?? _resultData!['author'] ?? _resultData!['seller'] ?? _resultData!['status'] ?? '',
                                    style: const TextStyle(fontSize: 11, color: AppColors.zinc500),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Suggested Voice Queries
            const Text(
              'QUICK URDU & ENGLISH VOICE PROMPTS',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.zinc500, letterSpacing: 0.8),
            ),
            const SizedBox(height: 10),

            ..._suggestions.map((sugg) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () => _simulateVoiceInput(sugg.query),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isDark ? AppColors.zinc800 : AppColors.zinc200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.mic_none, size: 18, color: AppColors.zinc500),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sugg.urdu,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                sugg.label,
                                style: const TextStyle(fontSize: 11, color: AppColors.zinc500),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.zinc500),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
