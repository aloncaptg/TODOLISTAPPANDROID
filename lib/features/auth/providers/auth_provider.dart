import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/storage_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final StorageService _storageService;
  UserModel? _currentUser;
  bool _isLoading = true;

  AuthProvider(this._storageService) {
    _loadUserSession();
  }

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;

  Future<void> _loadUserSession() async {
    _isLoading = true;
    notifyListeners();
    _currentUser = await _storageService.loadUser();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> login({
    required String name,
    required String email,
    String avatar = '👨‍💻',
    String title = 'Productivity Master',
  }) async {
    final user = UserModel(
      id: const Uuid().v4(),
      name: name,
      email: email,
      avatar: avatar,
      title: title,
      isGuest: false,
    );
    _currentUser = user;
    await _storageService.saveUser(user);
    notifyListeners();
  }

  Future<void> loginAsGuest() async {
    final user = UserModel(
      id: 'guest-${const Uuid().v4().substring(0, 6)}',
      name: 'Tamu (Guest)',
      email: 'guest@tugasku.pro',
      avatar: '🚀',
      title: 'Enterprise Explorer',
      isGuest: true,
    );
    _currentUser = user;
    await _storageService.saveUser(user);
    notifyListeners();
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    required String avatar,
    required String title,
  }) async {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      name: name,
      email: email,
      avatar: avatar,
      title: title,
    );
    await _storageService.saveUser(_currentUser!);
    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;
    await _storageService.clearUser();
    notifyListeners();
  }
}
