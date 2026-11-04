import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../core/api/api_constants.dart';
import '../core/storage/session_store.dart';
import '../models/chat_model.dart';

class ChatService {
  static final AudioRecorder _recorder = AudioRecorder();
  static bool _isRecording = false;
  static DateTime? _recordStartTime;

  static bool get isRecording => _isRecording;

  /// Check microphone permission
  static Future<bool> hasMicPermission() async {
    try {
      return await _recorder.hasPermission();
    } catch (e) {
      debugPrint('Error checking mic permission: $e');
      return false;
    }
  }

  /// Start recording voice message
  static Future<String?> startRecording() async {
    try {
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) return null;

      String path;
      if (kIsWeb) {
        path = '';
      } else {
        final tempDir = await getTemporaryDirectory();
        path = '${tempDir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      }

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );

      _isRecording = true;
      _recordStartTime = DateTime.now();
      return path;
    } catch (e) {
      debugPrint('Error starting audio recording: $e');
      _isRecording = false;
      return null;
    }
  }

  /// Stop recording voice message
  static Future<Map<String, dynamic>?> stopRecording() async {
    try {
      if (!_isRecording) return null;

      final path = await _recorder.stop();
      final durationMs = _recordStartTime != null
          ? DateTime.now().difference(_recordStartTime!).inMilliseconds
          : 0;

      _isRecording = false;
      _recordStartTime = null;

      if (path == null) return null;

      final seconds = (durationMs / 1000).round();
      final minutes = seconds ~/ 60;
      final remainingSecs = seconds % 60;
      final durationStr = '$minutes:${remainingSecs.toString().padLeft(2, '0')}';

      // Generate waveform peaks for visual rendering
      final random = Random();
      final peaks = List<double>.generate(24, (_) => 0.2 + random.nextDouble() * 0.75);

      return {
        'path': path,
        'duration': durationStr,
        'durationSeconds': seconds,
        'waveformPeaks': peaks,
      };
    } catch (e) {
      debugPrint('Error stopping audio recording: $e');
      _isRecording = false;
      return null;
    }
  }

  /// Cancel recording without saving
  static Future<void> cancelRecording() async {
    try {
      if (_isRecording) {
        await _recorder.stop();
        _isRecording = false;
        _recordStartTime = null;
      }
    } catch (e) {
      debugPrint('Error cancelling recording: $e');
    }
  }

  /// Upload voice message file to server
  static Future<String?> uploadVoiceFile(String filePath) async {
    try {
      if (kIsWeb) {
        return null; // Web uses direct stream
      }

      final file = File(filePath);
      if (!file.existsSync()) return null;

      final request = http.MultipartRequest('POST', Uri.parse(ApiConstants.upload));
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      request.fields['folder'] = 'campus_stitch/voice';

      final streamedResponse = await request.send().timeout(const Duration(seconds: 15));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['url']?.toString();
      }
    } catch (e) {
      debugPrint('Error uploading voice file: $e');
    }
    return null;
  }

  static Future<Map<String, String>> _buildHeaders([String? campusId]) async {
    final token = SessionStore.token;
    final user = await SessionStore.getUser();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      'x-user-campus-id': campusId ?? user?.campusId ?? '',
      if (user != null) 'x-user-name': user.fullName,
    };
  }

  /// Fetch user conversations (Inbox)
  static Future<List<ConversationModel>> getConversations({required String campusId}) async {
    try {
      final user = await SessionStore.getUser();
      final uri = Uri.parse('${ApiConstants.messages}?campus_id=$campusId&user_id=${user?.id ?? ""}');
      final headers = await _buildHeaders(campusId);
      final res = await http.get(uri, headers: headers).timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['conversations'] is List) {
          return (body['conversations'] as List)
              .map((c) => ConversationModel.fromJson(c, currentUserId: user?.id))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Error fetching conversations: $e');
    }
    return [];
  }

  /// Fetch messages within a conversation thread
  static Future<List<ChatMessageModel>> getMessages({
    required String conversationId,
    required String campusId,
  }) async {
    try {
      final user = await SessionStore.getUser();
      final uri = Uri.parse(
        '${ApiConstants.messages}?campus_id=$campusId&conversation_id=$conversationId',
      );
      final headers = await _buildHeaders(campusId);
      final res = await http.get(uri, headers: headers).timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['messages'] is List) {
          return (body['messages'] as List)
              .map((m) => ChatMessageModel.fromJson(m, currentUserId: user?.id))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Error fetching messages: $e');
    }
    return [];
  }

  /// Send a text message
  static Future<ChatMessageModel?> sendMessage({
    required String campusId,
    required String conversationId,
    required String text,
    String? recipientId,
    String? recipientName,
    String? contextType,
    String? contextTitle,
  }) async {
    try {
      final user = await SessionStore.getUser();
      final payload = {
        'campus_id': campusId,
        'conversation_id': conversationId,
        'sender_id': user?.id ?? 'u_me',
        'sender_name': user?.fullName ?? 'Student',
        'recipient_id': recipientId,
        'recipient_name': recipientName,
        'text': text.trim(),
        'context_type': contextType ?? 'general',
        'context_title': contextTitle ?? 'Discussion',
      };

      final headers = await _buildHeaders(campusId);
      final res = await http.post(
        Uri.parse(ApiConstants.messages),
        headers: headers,
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['message'] != null) {
          return ChatMessageModel.fromJson(body['message'], currentUserId: user?.id);
        }
      }
    } catch (e) {
      debugPrint('Error sending text message: $e');
    }

    // Fallback message object for optimistic UI
    return ChatMessageModel(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      senderId: 'u_me',
      senderName: 'You',
      text: text.trim(),
      createdAt: DateTime.now(),
      isMe: true,
      status: 'sent',
    );
  }

  /// Send a voice message
  static Future<ChatMessageModel?> sendVoiceMessage({
    required String campusId,
    required String conversationId,
    required String filePath,
    required String duration,
    List<double>? waveformPeaks,
    String? recipientId,
    String? recipientName,
    String? contextType,
    String? contextTitle,
  }) async {
    // 1. Upload audio file
    String? voiceUrl = await uploadVoiceFile(filePath);

    // If upload fails, use local file path fallback
    voiceUrl ??= filePath;

    final user = await SessionStore.getUser();
    final peaks = waveformPeaks ?? List<double>.generate(24, (_) => 0.5);

    try {
      final payload = {
        'campus_id': campusId,
        'conversation_id': conversationId,
        'sender_id': user?.id ?? 'u_me',
        'sender_name': user?.fullName ?? 'Student',
        'recipient_id': recipientId,
        'recipient_name': recipientName,
        'voice_url': voiceUrl,
        'duration': duration,
        'waveform_peaks': peaks,
        'context_type': contextType ?? 'general',
        'context_title': contextTitle ?? 'Discussion',
      };

      final res = await http.post(
        Uri.parse(ApiConstants.messages),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['message'] != null) {
          return ChatMessageModel.fromJson(body['message'], currentUserId: user?.id);
        }
      }
    } catch (e) {
      debugPrint('Error sending voice message: $e');
    }

    // Optimistic voice message fallback
    return ChatMessageModel(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      senderId: 'u_me',
      senderName: 'You',
      voiceUrl: voiceUrl,
      duration: duration,
      waveformPeaks: peaks,
      createdAt: DateTime.now(),
      isMe: true,
      status: 'sent',
    );
  }
}
