import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ThemeState extends ChangeNotifier {
  static final ThemeState instance = ThemeState._internal();
  ThemeState._internal();

  static const String _themeFileName = '.campus_stitch_theme.json';
  ThemeMode _themeMode = ThemeMode.system;
  bool _isInitialized = false;

  ThemeMode get themeMode => _themeMode;
  bool get isInitialized => _isInitialized;

  static File? _getFile() {
    if (kIsWeb) return null;
    try {
      if (Platform.isAndroid) {
        final internalDir = Directory('/data/user/0/com.campusstitch.app/files');
        if (internalDir.existsSync()) {
          return File('${internalDir.path}/$_themeFileName');
        }
        final fallbackInternal = Directory('/data/data/com.campusstitch.app/files');
        if (fallbackInternal.existsSync()) {
          return File('${fallbackInternal.path}/$_themeFileName');
        }
      }
      final dir = Directory.systemTemp;
      return File('${dir.path}/$_themeFileName');
    } catch (_) {
      return null;
    }
  }

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      final file = _getFile();
      if (file != null && await file.exists()) {
        final content = await file.readAsString();
        final json = jsonDecode(content);
        if (json is Map<String, dynamic> && json['themeMode'] != null) {
          final modeStr = json['themeMode'].toString();
          if (modeStr == 'light') {
            _themeMode = ThemeMode.light;
          } else if (modeStr == 'dark') {
            _themeMode = ThemeMode.dark;
          } else {
            _themeMode = ThemeMode.system;
          }
        }
      }
    } catch (e) {
      debugPrint('ThemeState: Failed to load theme preference: $e');
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();

    try {
      final file = _getFile();
      if (file != null) {
        String modeStr = 'system';
        if (mode == ThemeMode.light) modeStr = 'light';
        if (mode == ThemeMode.dark) modeStr = 'dark';
        await file.writeAsString(jsonEncode({'themeMode': modeStr}));
      }
    } catch (e) {
      debugPrint('ThemeState: Failed to persist theme preference: $e');
    }
  }

  bool isDarkMode(BuildContext context) {
    if (_themeMode == ThemeMode.dark) return true;
    if (_themeMode == ThemeMode.light) return false;
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
  }

  String get currentModeTitle {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light Mode';
      case ThemeMode.dark:
        return 'Dark Mode';
      case ThemeMode.system:
        return 'System Default';
    }
  }
}
