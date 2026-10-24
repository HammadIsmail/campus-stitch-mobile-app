import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../api/api_client.dart';

class AuthState extends ChangeNotifier {
  static final AuthState instance = AuthState._internal();
  AuthState._internal();

  UserModel? _user;
  bool _isLoading = true;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Active Tenant Scope
  String get activeCampusId => _user?.campusId ?? 'camp_uet_main';
  String get activeCampusName => _user?.campusName ?? 'Main Campus (Lahore)';
  String get activeUniversityName => _user?.universityName ?? 'UET Lahore';
  String get role => _user?.role ?? 'student';

  bool get isSuperAdmin => _user?.isSuperAdmin ?? false;
  bool get isCampusAdmin => _user?.isCampusAdmin ?? false;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await AuthService.checkCurrentSession();
    } catch (e) {
      debugPrint('Auth initialization error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await AuthService.signIn(email: email, password: password);
      if (res.success && res.data is Map && (res.data as Map)['user'] != null) {
        _user = UserModel.fromJson(Map<String, dynamic>.from((res.data as Map)['user']));
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = ApiClient.humanizeError(res.message, res.statusCode);
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = ApiClient.humanizeError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required String studentId,
    required String universityId,
    required String universityName,
    required String campusId,
    required String campusName,
    String? program,
    String? code,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await AuthService.signUp(
        name: name,
        email: email,
        password: password,
        studentId: studentId,
        universityId: universityId,
        universityName: universityName,
        campusId: campusId,
        campusName: campusName,
        program: program,
        code: code,
      );

      if (res.success && res.data is Map && (res.data as Map)['user'] != null) {
        _user = UserModel.fromJson(Map<String, dynamic>.from((res.data as Map)['user']));
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = ApiClient.humanizeError(res.message, res.statusCode);
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = ApiClient.humanizeError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _user = null;
    await AuthService.signOut();
    notifyListeners();
  }

  Future<bool> deleteAccount() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await AuthService.deleteAccount(
        userId: _user?.userId,
        email: _user?.email,
      );
      _user = null;
      _isLoading = false;
      notifyListeners();
      return res.success;
    } catch (e) {
      _errorMessage = ApiClient.humanizeError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
