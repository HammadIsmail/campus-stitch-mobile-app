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
      return ApiResponse(success: false, message: e.toString(), statusCode: 500);
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
      return ApiResponse(success: false, message: e.toString(), statusCode: 500);
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
      return ApiResponse(success: false, message: e.toString(), statusCode: 500);
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
      return ApiResponse(success: false, message: e.toString(), statusCode: 500);
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

        return ApiResponse(
          success: success,
          data: body,
          message: body['message']?.toString() ?? body['error']?.toString(),
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
        message: res.statusCode >= 400 ? 'Server responded with code ${res.statusCode}' : null,
        statusCode: res.statusCode,
      );
    }
  }
}
