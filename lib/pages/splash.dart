import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_page.dart';
import 'login_page.dart'; 
import 'package:gunes_saati/Service/auth.dart';
import 'package:gunes_saati/main.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int _currentIndex = 0;
  bool _isLoading = true;

  final List<String> _images = [
    'assets/images/intro1.jpg',
    'assets/images/intro2.jpg',
    'assets/images/intro3.jpg',
  ];

  final List<String> _texts = [
    'Bir hesabınız yoksa, alttaki buton ile kayıt olabilirsiniz.',
    'Konum al butonu ile konumunuzu onayladıktan sonra, güneş doğuş ve batış saatini öğrenebilirsiniz.',
    'Gelen bilgileri isimlendirdikten sonra, kaydederseniz listeleme ekranından istediğiniz zaman erişebilirsiniz.',
  ];

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  
  Future<void> _checkFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isFirstLaunch = prefs.getBool('isFirstLaunch');
    
    if (isFirstLaunch == null || isFirstLaunch) {
      
      prefs.setBool('isFirstLaunch', false);
      setState(() {
        _isLoading = false; 
      });
    } else {
      
      _checkLoginStatus();
    }
  }
  Future<void> _checkLoginStatus() async {
    Auth auth = Auth();
    bool isLoggedInToday = await auth.isLoggedInToday();

    if (FirebaseAuth.instance.currentUser != null && isLoggedInToday) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MainPage()), 
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage()), 
      );
    }
  }

  void _nextPage() {
    if (_currentIndex < _images.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      _checkLoginStatus(); 
    }
  }

@override
Widget build(BuildContext context) {
  final double screenHeight = MediaQuery.of(context).size.height;
  final double screenWidth = MediaQuery.of(context).size.width;

  return BackgroundScaffold(
    body: Center(
      child: _isLoading
          ? CircularProgressIndicator() 
          : SingleChildScrollView(
              child: Container(
                height: screenHeight * 0.9, 
                padding: EdgeInsets.all(16.0), 
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: screenHeight * 0.5, 
                      child: Image.asset(
                        _images[_currentIndex],
                        fit: BoxFit.contain, 
                        width: screenWidth * 0.9, 
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      height: screenHeight * 0.3, 
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _texts[_currentIndex],
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20), 
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _nextPage,
                            child: Text(_currentIndex < _images.length - 1 ? 'Sonraki' : 'Tamam'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    ),
  );
}


}
