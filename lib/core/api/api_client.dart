import 'dart:convert';
import 'package:flutter/foundation.dart';
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
      debugPrint('GET: $url');
      final res = await http.get(Uri.parse(url), headers: requestHeaders);
      return _parseResponse(res);
    } catch (e) {
      debugPrint('GET error on $url: $e');
      return ApiResponse(success: false, message: e.toString(), statusCode: 500);
    }
  }

  static Future<ApiResponse> post(String url, {dynamic body, Map<String, String>? headers}) async {
    try {
      final requestHeaders = await _buildHeaders(headers);
      debugPrint('POST: $url');
      final res = await http.post(
        Uri.parse(url),
        headers: requestHeaders,
        body: body != null ? jsonEncode(body) : null,
      );
      return _parseResponse(res);
    } catch (e) {
      debugPrint('POST error on $url: $e');
      return ApiResponse(success: false, message: e.toString(), statusCode: 500);
    }
  }

  static Future<ApiResponse> patch(String url, {dynamic body, Map<String, String>? headers}) async {
    try {
      final requestHeaders = await _buildHeaders(headers);
      debugPrint('PATCH: $url');
      final res = await http.patch(
        Uri.parse(url),
        headers: requestHeaders,
        body: body != null ? jsonEncode(body) : null,
      );
      return _parseResponse(res);
    } catch (e) {
      debugPrint('PATCH error on $url: $e');
      return ApiResponse(success: false, message: e.toString(), statusCode: 500);
    }
  }

  static Future<ApiResponse> delete(String url, {dynamic body, Map<String, String>? headers}) async {
    try {
      final requestHeaders = await _buildHeaders(headers);
      debugPrint('DELETE: $url');
      final res = await http.delete(
        Uri.parse(url),
        headers: requestHeaders,
        body: body != null ? jsonEncode(body) : null,
      );
      return _parseResponse(res);
    } catch (e) {
      debugPrint('DELETE error on $url: $e');
      return ApiResponse(success: false, message: e.toString(), statusCode: 500);
    }
  }

  static ApiResponse _parseResponse(http.Response res) {
    try {
      final body = jsonDecode(res.body);
      if (body is Map<String, dynamic>) {
        final success = body['success'] == true || (res.statusCode >= 200 && res.statusCode < 300);
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
        statusCode: res.statusCode,
      );
    }
  }
}
