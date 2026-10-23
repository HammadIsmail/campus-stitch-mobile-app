import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../storage/session_store.dart';

class ApiResponse {
  final bool success;
  final dynamic data;
  final String? message;
  final int statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    required this.statusCode,
  });
}

class ApiClient {
  static const Duration _timeout = Duration(seconds: 15);

  static Future<Map<String, String>> _buildHeaders([Map<String, String>? customHeaders]) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final session = await SessionStore.loadSession();
    if (session != null) {
      final token = session['token'] as String?;
      final user = session['user'];
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      if (user != null) {
        headers['x-user-campus-id'] = user.campusId ?? '';
        headers['x-user-university-id'] = user.universityId ?? '';
        headers['x-user-role'] = user.role ?? 'student';
        headers['x-user-name'] = user.name ?? '';
      }
    }

    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }
    return headers;
  }

  static String humanizeError(dynamic error, [int? statusCode]) {
    if (error == null) {
      if (statusCode != null && statusCode >= 400) {
        return _statusMessage(statusCode);
      }
      return 'An unexpected error occurred. Please try again.';
    }

    final raw = error.toString().trim();
    if (raw.isEmpty) {
      if (statusCode != null && statusCode >= 400) {
        return _statusMessage(statusCode);
      }
      return 'An unexpected error occurred. Please try again.';
    }

    final lower = raw.toLowerCase();

    // 1. Browser Web, CORS, Fetch & Connection issues
    if (lower.contains('failed to fetch') ||
        lower.contains('clientexception') ||
        lower.contains('xmlhttprequest') ||
        lower.contains('cors') ||
        lower.contains('networkerror') ||
        lower.contains('load failed')) {
      return 'Unable to connect to the campus server. Please check your internet connection or try again later.';
    }

    // 2. DNS / Socket / Unreachable
    if (lower.contains('socketexception') ||
        lower.contains('failed host lookup') ||
        lower.contains('network is unreachable') ||
        lower.contains('connection refused') ||
        lower.contains('connection reset') ||
        lower.contains('broken pipe')) {
      return 'Unable to reach the campus server. Please verify your internet connection.';
    }

    // 3. Timeouts
    if (lower.contains('timeoutexception') || lower.contains('timed out')) {
      return 'Connection timed out. Please check your connection and try again.';
    }

    // 4. SSL / TLS / Certificates
    if (lower.contains('handshake') ||
        lower.contains('certificate') ||
        lower.contains('tls') ||
        lower.contains('ssl')) {
      return 'Secure connection failed. Please ensure your device date & time are correct.';
    }

    // 5. JSON Parse / Format exceptions (HTML error responses from server)
    if (lower.contains('formatexception') || lower.contains('unexpected character')) {
      return 'Campus server returned an unexpected response. Please try again in a moment.';
    }

    // 6. Common auth / credential errors
    if (lower.contains('invalid credential') ||
        lower.contains('invalid email or password') ||
        lower.contains('wrong password') ||
        (lower.contains('password') && lower.contains('incorrect')) ||
        (lower.contains('credential') && lower.contains('invalid'))) {
      return 'Invalid email or password. Please check your credentials and try again.';
    }

    if (lower.contains('already exists') || lower.contains('already registered') || lower.contains('email taken')) {
      return 'An account with this email already exists. Please sign in instead.';
    }

    if (lower.contains('user not found') || lower.contains('account not found') || lower.contains('record not found')) {
      return 'Account not found. Please verify your details or register.';
    }

    if (lower.contains('unauthorized') || lower.contains('jwt') || lower.contains('token expired')) {
      return 'Your session has expired. Please sign in again.';
    }

    if (lower.contains('forbidden') || lower.contains('access denied') || lower.contains('not authorized')) {
      return 'Access denied. You do not have permission for this campus resource.';
    }

    if (lower.contains('too many') || lower.contains('rate limit')) {
      return 'Too many attempts. Please wait a minute before trying again.';
    }

    // 7. If status code is an error and the message looks like a technical error dump
    if (statusCode != null && statusCode >= 400) {
      if (lower.contains('http') ||
          lower.contains('exception') ||
          lower.contains('status') ||
          lower.contains('{') ||
          raw.length > 70) {
        return _statusMessage(statusCode);
      }
    }

    // 8. Clean up technical wrapper prefixes like "Exception: ", "Error: ", ", uri=..."
    String clean = raw.replaceAll(RegExp(r'^(Exception:|Error:|ClientException:|HttpException:)\s*', caseSensitive: false), '');
    if (clean.contains(', uri=')) {
      clean = clean.split(', uri=')[0];
    }

    // If still contains technical words or stack trace indicators, provide safe fallback
    if (clean.contains('at ') ||
        clean.contains('package:') ||
        clean.contains('dart:') ||
        clean.contains('Exception') ||
        clean.contains('Error') ||
        clean.contains('http://') ||
        clean.contains('https://') ||
        clean.length > 90) {
      return 'Unable to complete request. Please check your connection and try again.';
    }

    return clean.trim();
  }

  static String _statusMessage(int statusCode) {
    if (statusCode == 400) return 'Invalid request details. Please check your input.';
    if (statusCode == 401) return 'Invalid email or password. Please verify your credentials.';
    if (statusCode == 403) return 'Access denied. You do not have permission for this resource.';
    if (statusCode == 404) return 'The requested campus record or service was not found.';
    if (statusCode == 409) return 'This account or record already exists.';
    if (statusCode == 422) return 'Please check the information entered and try again.';
    if (statusCode == 429) return 'Too many attempts. Please wait a few moments before trying again.';
    if (statusCode >= 500) return 'Campus server is temporarily unavailable. Please try again shortly.';
    return 'Unable to complete request. Please try again.';
  }

  static Future<ApiResponse> get(String url, {Map<String, String>? headers}) async {
    try {
      final requestHeaders = await _buildHeaders(headers);
      final res = await http.get(Uri.parse(url), headers: requestHeaders).timeout(_timeout);
      return _parseResponse(res);
    } on TimeoutException {
      return ApiResponse(
        success: false,
        message: 'Connection timed out. Please check your internet connection.',
        statusCode: 408,
      );
    } on SocketException {
      return ApiResponse(
        success: false,
        message: 'Unable to reach the campus server. Please verify your connection.',
        statusCode: 503,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: humanizeError(e),
        statusCode: 500,
      );
    }
  }

  static Future<ApiResponse> post(String url, {dynamic body, Map<String, String>? headers}) async {
    try {
      final requestHeaders = await _buildHeaders(headers);
      final res = await http.post(
        Uri.parse(url),
        headers: requestHeaders,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(_timeout);
      return _parseResponse(res);
    } on TimeoutException {
      return ApiResponse(
        success: false,
        message: 'Connection timed out. Please check your internet connection.',
        statusCode: 408,
      );
    } on SocketException {
      return ApiResponse(
        success: false,
        message: 'Unable to reach the campus server. Please verify your connection.',
        statusCode: 503,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: humanizeError(e),
        statusCode: 500,
      );
    }
  }

  static Future<ApiResponse> patch(String url, {dynamic body, Map<String, String>? headers}) async {
    try {
      final requestHeaders = await _buildHeaders(headers);
      final res = await http.patch(
        Uri.parse(url),
        headers: requestHeaders,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(_timeout);
      return _parseResponse(res);
    } on TimeoutException {
      return ApiResponse(
        success: false,
        message: 'Connection timed out. Please check your internet connection.',
        statusCode: 408,
      );
    } on SocketException {
      return ApiResponse(
        success: false,
        message: 'Unable to reach the campus server. Please verify your connection.',
        statusCode: 503,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: humanizeError(e),
        statusCode: 500,
      );
    }
  }

  static Future<ApiResponse> delete(String url, {dynamic body, Map<String, String>? headers}) async {
    try {
      final requestHeaders = await _buildHeaders(headers);
      final res = await http.delete(
        Uri.parse(url),
        headers: requestHeaders,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(_timeout);
      return _parseResponse(res);
    } on TimeoutException {
      return ApiResponse(
        success: false,
        message: 'Connection timed out. Please check your internet connection.',
        statusCode: 408,
      );
    } on SocketException {
      return ApiResponse(
        success: false,
        message: 'Unable to reach the campus server. Please verify your connection.',
        statusCode: 503,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: humanizeError(e),
        statusCode: 500,
      );
    }
  }

  static ApiResponse _parseResponse(http.Response res) {
    try {
      final body = jsonDecode(res.body);
      if (body is Map<String, dynamic>) {
        final hasExplicitSuccess = body.containsKey('success');
        final success = hasExplicitSuccess
            ? body['success'] == true
            : (res.statusCode >= 200 && res.statusCode < 300);

        final rawMsg = body['message']?.toString() ?? body['error']?.toString();
        final humanMsg = rawMsg != null ? humanizeError(rawMsg, res.statusCode) : (res.statusCode >= 400 ? _statusMessage(res.statusCode) : null);

        return ApiResponse(
          success: success,
          data: body,
          message: humanMsg,
          statusCode: res.statusCode,
        );
      }
      return ApiResponse(
        success: res.statusCode >= 200 && res.statusCode < 300,
        data: body,
        statusCode: res.statusCode,
      );
    } catch (_) {
      return ApiResponse(
        success: res.statusCode >= 200 && res.statusCode < 300,
        data: res.body,
        message: humanizeError(null, res.statusCode),
        statusCode: res.statusCode,
      );
    }
  }
}
