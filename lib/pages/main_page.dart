import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gunes_saati/pages/listing.dart';
import 'package:gunes_saati/pages/profile.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String _locationMessage = "";
  String _sunriseSunsetMessage = "";
  int _selectedIndex = 0;
  Position? _currentPosition;
  TextEditingController _nameController = TextEditingController();

  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  Future<void> _checkUser() async {
    _currentUser = FirebaseAuth.instance.currentUser;

    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Kullanıcı oturumu bulunamadı."),
      ));
    }
  }

  Future<void> _getCurrentLocation() async {
    PermissionStatus permission = await Permission.location.status;
    permission = await Permission.location.request();

    if (permission.isDenied || permission.isPermanentlyDenied) {
      setState(() {
        _locationMessage = "Konum izni reddedildi.";
      });
      return;
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _locationMessage = "Konum servisleri kapalı.";
      });
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _currentPosition = position;
      await _getPlaceFromCoordinates(position.latitude, position.longitude);
    } catch (e) {
      setState(() {
        _locationMessage = "Konum alınamadı: ${e.toString()}";
      });
    }
  }

  Future<void> _getPlaceFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          String administrativeArea = place.administrativeArea ?? "Eyalet bulunamadı";
          String country = place.country ?? "Ülke bulunamadı";
          _locationMessage = "$administrativeArea, $country";
        });
      } else {
        setState(() {
          _locationMessage = "Adres bulunamadı.";
        });
      }
    } catch (e) {
      setState(() {
        _locationMessage = "Adres bulunamadı: ${e.toString()}";
      });
    }
  }

  Future<void> getSunriseSunsetData() async {
    if (_currentPosition == null) {
      setState(() {
        _sunriseSunsetMessage = "Öncelikle konumu alın.";
      });
      return;
    }

    final String url =
        'https://api.sunrise-sunset.org/json?lat=${_currentPosition!.latitude}&lng=${_currentPosition!.longitude}&formatted=0';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        String sunrise = data['results']['sunrise'];
        String sunset = data['results']['sunset'];

        DateTime sunriseTime = DateTime.parse(sunrise).toLocal();
        DateTime sunsetTime = DateTime.parse(sunset).toLocal();

        String sunriseFormatted = DateFormat('HH:mm:ss').format(sunriseTime);
        String sunsetFormatted = DateFormat('HH:mm:ss').format(sunsetTime);

        setState(() {
          _sunriseSunsetMessage = "Güneş doğuşu: $sunriseFormatted\nGüneş batışı: $sunsetFormatted";
        });

        _showSunriseSunsetDialog(
          location: _locationMessage,
          sunriseTime: sunriseFormatted,
          sunsetTime: sunsetFormatted,
        );
      } else {
        setState(() {
          _sunriseSunsetMessage = 'Gün doğumu ve batımı verisi alınamadı: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _sunriseSunsetMessage = "Veri alınamadı: $e";
      });
    }
  }

  Future<void> _saveDataToFirestore(String name, String location, String sunrise, String sunset) async {
    if (_currentUser != null) {
      try {
        String userId = _currentUser!.uid;

        DocumentReference userDocRef = FirebaseFirestore.instance
            .collection('sunrise_sunset_data')
            .doc(userId);

        await userDocRef.collection('entries').add({
          'name': name,
          'location': location,
          'sunrise': sunrise,
          'sunset': sunset,
          'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Veriler başarıyla kaydedildi!"),
        ));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Veriler kaydedilemedi: $e"),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Kullanıcı oturumu bulunamadı."),
      ));
    }
  }

  void _showSunriseSunsetDialog({
    required String location,
    required String sunriseTime,
    required String sunsetTime,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Güneş Bilgileri"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Konum: $location"),
              SizedBox(height: 10),
              Text("Güneş Doğuşu: $sunriseTime"),
              Text("Güneş Batışı: $sunsetTime"),
              SizedBox(height: 10),
              Text("Tarih: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}"),
              SizedBox(height: 10),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "İsimlendirme",
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Kaydet"),
              onPressed: () {
                _saveDataToFirestore(
                  _nameController.text,
                  location,
                  sunriseTime,
                  sunsetTime,
                );
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Tamam"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _onItemTapped(int index) async {
    if (index == 1) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ListingPage()),
      );
      setState(() {
        _selectedIndex = 0;
      });
    } else if (index == 2) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage()),
      );
      setState(() {
        _selectedIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            top: 85, 
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.topCenter,
              child: Image.asset(
                'assets/images/logo.png', 
                width: 110, 
                height: 110,  
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _getCurrentLocation,
                    child: Text("Konumu Al"),
                  ),
                  SizedBox(height: 20),
                  Text(
                    _locationMessage,
                    style: TextStyle(color: Colors.black,
                    shadows: [
                      Shadow(
                        blurRadius: 5.0,
                        color: Colors.black.withOpacity(0.5),
                        offset: Offset(0, 2),
                      ),
                    ]),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: getSunriseSunsetData,
                    child: Text("Güneş Bilgilerini Al"),
                  ),
                  SizedBox(height: 20),
                  Text(
                    _sunriseSunsetMessage,
                    style: TextStyle(color: Colors.black,
                    shadows: [
                      Shadow(
                        blurRadius: 5.0,
                        color: Colors.black.withOpacity(0.5),
                        offset: Offset(0, 2),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Liste',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
      ),
    );
  }
}
