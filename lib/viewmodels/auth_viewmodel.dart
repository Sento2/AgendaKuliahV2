import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Import Package Google
import '../core/constants/google_client_id.dart';
import '../data/services/supabase_service.dart';
import '../models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  // Panggil service yang sudah kita buat sebelumnya
  final SupabaseService _supabaseService = SupabaseService();

  // Pengganti MutableLiveData
  User? _currentUser;
  bool _isLoading =
      false; // Tambahan untuk memunculkan efek loading berputar di UI
  String? _errorMessage;

  // Getters (Pengganti LiveData)
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // 1. FUNGSI LOGIN (REGULER)
  Future<bool> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      _errorMessage = "Username dan password tidak boleh kosong!";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    User? user = await _supabaseService.checkLogin(username, password);

    _isLoading = false;

    if (user != null) {
      _currentUser = user;
      notifyListeners();
      return true;
    } else {
      _errorMessage = "Username atau password salah!";
      notifyListeners();
      return false;
    }
  }

  // 2. FUNGSI REGISTER
  Future<bool> register(
    String username,
    String password,
    String confirmPass,
    String email,
  ) async {
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

    bool isSuccess = await _supabaseService.registerUser(
      username,
      password,
      email,
    );

    _isLoading = false;

    if (isSuccess) {
      notifyListeners();
      return true;
    } else {
      _errorMessage = "Gagal mendaftar. Coba lagi.";
      notifyListeners();
      return false;
    }
  }

  // 3. FUNGSI LOGIN GOOGLE (BARU TERSAMBUNG SUPABASE)
  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final String dartDefineClientId = const String.fromEnvironment(
        'GOOGLE_WEB_CLIENT_ID',
      ).trim();
      final String? resolvedClientId = dartDefineClientId.isNotEmpty
          ? dartDefineClientId
          : getGoogleWebClientId();

      if (kIsWeb &&
          (resolvedClientId == null ||
              resolvedClientId.isEmpty ||
              resolvedClientId.startsWith('YOUR_GOOGLE_WEB_CLIENT_ID'))) {
        _isLoading = false;
        _errorMessage =
            'Google Web Client ID belum diset atau belum cocok. Pastikan meta tag google-signin-client_id di web/index.html berisi OAuth Client ID tipe Web yang benar, lalu daftarkan origin web aktif di Google Cloud Console. Untuk Flutter Web, origin harus cocok persis dengan alamat yang sedang dipakai, misalnya http://localhost:59829 atau gunakan web port tetap.';
        notifyListeners();
        return false;
      }

      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: kIsWeb ? resolvedClientId : null,
        scopes: [
          'email',
          'https://www.googleapis.com/auth/calendar.events', // Izin baca/tulis kalender
        ],
      );

      // Memunculkan pop-up akun Google
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        _isLoading = false;
        _errorMessage = "Login Google dibatalkan.";
        notifyListeners();
        return false;
      }

      // Ambil email dan nama dari Google
      String email = googleUser.email;
      String displayName = googleUser.displayName ?? "Mahasiswa";

      // Simpan/Cek ke Supabase Database kelompok kalian
      User? dbUser = await _supabaseService.loginWithGoogleData(
        email,
        displayName,
      );

      _isLoading = false;

      if (dbUser != null) {
        _currentUser = dbUser; // Berhasil masuk!
        notifyListeners();
        return true;
      } else {
        _errorMessage = "Gagal sinkronisasi dengan database.";
        notifyListeners();
        return false;
      }
    } catch (error) {
      _isLoading = false;
      _errorMessage = "Gagal login dengan Google: $error";
      notifyListeners();
      return false;
    }
  }

  // 4. FUNGSI LOGOUT
  void logout() async {
    _currentUser = null;
    // Keluar dari sesi Google juga
    await GoogleSignIn().signOut();
    notifyListeners();
  }
}
