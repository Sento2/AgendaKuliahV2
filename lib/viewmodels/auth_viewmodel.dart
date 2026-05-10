import 'package:flutter/material.dart';
import '../data/services/supabase_service.dart';
import '../models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  // Panggil service yang sudah kita buat sebelumnya
  final SupabaseService _supabaseService = SupabaseService();

  // Pengganti MutableLiveData
  User? _currentUser;
  bool _isLoading = false; // Tambahan untuk memunculkan efek loading berputar di UI
  String? _errorMessage;

  // Getters (Pengganti LiveData)
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // 1. FUNGSI LOGIN
  Future<bool> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      _errorMessage = "Username dan password tidak boleh kosong!";
      notifyListeners(); // Pengganti .setValue() untuk update UI
      return false;
    }

    // Mulai loading
    _isLoading = true;
    _errorMessage = null; 
    notifyListeners();

    // Proses ambil data dari Supabase (Pengganti Executors background thread)
    User? user = await _supabaseService.checkLogin(username, password);

    // Selesai loading
    _isLoading = false;
    
    if (user != null) {
      _currentUser = user; // Simpan data user yang login
      notifyListeners();
      return true; // Berhasil login
    } else {
      _errorMessage = "Username atau password salah!";
      notifyListeners();
      return false; // Gagal login
    }
  }

  // 2. FUNGSI REGISTER
  Future<bool> register(String username, String password, String confirmPass, String email) async {
    if (username.isEmpty || password.isEmpty || email.isEmpty) {
      _errorMessage = "Semua kolom wajib diisi!";
      notifyListeners();
      return false;
    }
    if (password != confirmPass) {
      _errorMessage = "Konfirmasi password tidak cocok!";
      notifyListeners();
      return false;
    }
    if (password.length < 6) {
      _errorMessage = "Password minimal 6 karakter!";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    bool isSuccess = await _supabaseService.registerUser(username, password, email);

    _isLoading = false;
    
    if (isSuccess) {
      notifyListeners();
      return true; // Berhasil register
    } else {
      _errorMessage = "Gagal mendaftar. Coba lagi.";
      notifyListeners();
      return false; // Gagal register
    }
  }

  // 3. FUNGSI LOGOUT (Tambahan)
  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}