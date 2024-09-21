import 'package:flutter/material.dart';
import 'package:gunes_saati/Service/auth.dart';
import 'package:gunes_saati/pages/register_page.dart';
import 'package:gunes_saati/pages/main_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with WidgetsBindingObserver {
  final _tEmail = TextEditingController();
  final _tPassword = TextEditingController();
  
  final Auth _auth = Auth();

  bool isLogin = true;
  String? errorMessage;
  bool _keyboardVisible = false;

  Future<void> signIn() async {
    String? error = await _auth.signIn(
      email: _tEmail.text,
      password: _tPassword.text,
    );
    if (error == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainPage()),
      );
    } else {
      setState(() {
        errorMessage = error;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    final keyboardVisible = WidgetsBinding.instance.window.viewInsets.bottom > 0;
    if (keyboardVisible != _keyboardVisible) {
      setState(() {
        _keyboardVisible = keyboardVisible;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return WillPopScope(
    onWillPop: () async {
      return false; 
    },
    child: Scaffold(
      resizeToAvoidBottomInset: false, 
      body: Stack(
        children: [

          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png', 
              fit: BoxFit.cover,
            ),
          ),
         
          AnimatedPositioned(
            top: _keyboardVisible ? -130 : 85, 
            left: 0,
            right: 0,
            duration: const Duration(milliseconds: 300),
            child: Align(
              alignment: Alignment.topCenter,
              child: Image.asset(
                'assets/images/logo.png',
                width: 110,
                height: 110, 
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: EdgeInsets.only(bottom: _keyboardVisible ? 185 : 0), 
                  child: Column(
                    mainAxisSize: MainAxisSize.min, 
                    children: [
                      TextField(
                        controller: _tEmail,
                        decoration: const InputDecoration(
                          hintText: "Email",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      TextField(
                        controller: _tPassword,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: "Şifre",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      if (errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            errorMessage!,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ElevatedButton(
                        onPressed: signIn,
                        child: const Text("Giriş Yap"),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isLogin = !isLogin;
                          });
                          if (!isLogin) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => RegisterPage()),
                            );
                          }
                        },
                        child: Text("Kayıt olmak için tıklayın."),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

}
