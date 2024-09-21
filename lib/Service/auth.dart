import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get autoStateChanges => _firebaseAuth.authStateChanges();

  // Register
  Future<void> createUser({
    required String name,
    required String lastName,
    required String email,
    required String password,
    required String age,
    required String gender,
    required DateTime registrationDate,
  }) async {
    await FirebaseFirestore.instance.collection('users').add({
      'name': name,
      'lastName': lastName,
      'email': email,
      'password': password,
      'age': age,
      'gender': gender,
      'registrationDate': registrationDate,
    });
  }

  // Login
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Kullanıcı giriş yaptığında giriş zamanını kaydet
      await _saveLoginTime();

      // Başarı durumunda null döndür
      return null;
    } on FirebaseAuthException catch (e) {
      // Hata kodlarına göre uygun mesajı döndür
      if (e.code == 'user-not-found') {
        return 'Kullanıcı bulunamadı. Lütfen e-posta adresinizi kontrol edin.';
      } else if (e.code == 'wrong-password') {
        return 'Şifre hatalı. Lütfen tekrar deneyin.';
      } else {
        return 'Giriş başarısız. Lütfen tekrar deneyin.';
      }
    } catch (e) {
      // Diğer hataları genel bir mesajla döndür
      return 'Bir hata oluştu. Lütfen tekrar deneyin.';
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    
    // Oturum kapatıldığında giriş zamanını sil
    await _clearLoginTime();
  }

  // Giriş zamanını kaydet
  Future<void> _saveLoginTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime now = DateTime.now();
    await prefs.setString('lastLogin', now.toIso8601String());
  }

  // Giriş zamanını temizle (Oturum kapatma durumunda kullanılacak)
  Future<void> _clearLoginTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('lastLogin');
  }

  // Giriş zamanını kontrol etme
  Future<bool> isLoggedInToday() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lastLogin = prefs.getString('lastLogin');
    if (lastLogin != null) {
      DateTime lastLoginDate = DateTime.parse(lastLogin);
      DateTime now = DateTime.now();
      // Giriş tarihi bugüne aitse true döndür
      return now.difference(lastLoginDate).inDays == 0;
    }
    return false;
  }
}
