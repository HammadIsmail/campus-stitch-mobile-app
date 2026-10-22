import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../models/user_model.dart';

class SessionStore {
  static const String _sessionFileName = '.campus_stitch_session.json';
  static UserModel? _memoryUser;
  static String? _memoryToken;

  static File? _getFile() {
    if (kIsWeb) return null;
    try {
      final dir = Directory.systemTemp;
      return File('${dir.path}/$_sessionFileName');
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveSession({
    required String token,
    required UserModel user,
  }) async {
    _memoryToken = token;
    _memoryUser = user;

    final file = _getFile();
    if (file != null) {
      try {
        final data = {
          'token': token,
          'user': user.toJson(),
        };
        await file.writeAsString(jsonEncode(data));
      } catch (e) {
        debugPrint('Error saving session to file: $e');
      }
    }
  }

  static Future<Map<String, dynamic>?> loadSession() async {
    if (_memoryToken != null && _memoryUser != null) {
      return {
        'token': _memoryToken,
        'user': _memoryUser,
      };
    }

    final file = _getFile();
    if (file != null && await file.exists()) {
      try {
        final content = await file.readAsString();
        final json = jsonDecode(content);
        if (json is Map<String, dynamic> && json['token'] != null && json['user'] != null) {
          final token = json['token'].toString();
          final user = UserModel.fromJson(Map<String, dynamic>.from(json['user']));
          _memoryToken = token;
          _memoryUser = user;
          return {
            'token': token,
            'user': user,
          };
        }
      } catch (e) {
        debugPrint('Error reading session file: $e');
      }
    }
    return null;
  }

  static Future<void> clearSession() async {
    _memoryToken = null;
    _memoryUser = null;
    final file = _getFile();
    if (file != null && await file.exists()) {
      try {
        await file.delete();
      } catch (_) {}
    }
  }
}
