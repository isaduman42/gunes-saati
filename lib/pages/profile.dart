import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;
  String? _profileImageUrl;


  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController ageController = TextEditingController();

  Gender? _selectedGender; 
  bool isEditing = false; 

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    var userDoc = await _firestore.collection('users').doc(_auth.currentUser?.uid).get();
    if (userDoc.exists) {
      var userData = userDoc.data()!;
      firstNameController.text = userData['firstName'] ?? 'Bilinmiyor';
      lastNameController.text = userData['lastName'] ?? 'Bilinmiyor';
      emailController.text = userData['email'] ?? 'Bilinmiyor';
      ageController.text = userData['age'].toString();

      _selectedGender = Gender.values.firstWhere(
        (gender) => gender.toString() == userData['gender'],
        orElse: () => Gender.diger,
      );

      _profileImageUrl = userData['profilePhoto'];
      setState(() {}); 
    }
  }

@override
Widget build(BuildContext context) {
  return WillPopScope(
    onWillPop: () async {
      if (isEditing) {
        setState(() {
          isEditing = false;
        });
        return false; 
      }
      return true; 
    },
    child: Scaffold(
      resizeToAvoidBottomInset: true, 
      appBar: AppBar(
        title: Text("Profil"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _showLogoutConfirmationDialog(context);
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png', 
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 100, 
            left: MediaQuery.of(context).size.width / 2 - 50,
            child: GestureDetector(
              onTap: () {
                if (isEditing) {
                  _pickImage();
                } else {
                  _showProfileImageDialog();
                }
              },
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : _profileImageUrl != null
                        ? NetworkImage(_profileImageUrl!)
                        : AssetImage('assets/default_profile.png') as ImageProvider,
              ),
            ),
          ),
          Positioned(
            top: 220,
            left: 16,
            right: 16,
            bottom: 16, 
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildProfileField("Ad", firstNameController, isEditing),
                    SizedBox(height: 10),
                    _buildProfileField("Soyad", lastNameController, isEditing),
                    SizedBox(height: 10),
                    _buildProfileField("Email", emailController, isEditing),
                    SizedBox(height: 10),
                    _buildGenderField(isEditing),
                    SizedBox(height: 10),
                    _buildProfileField("Yaş", ageController, isEditing, isNumber: true),
                    SizedBox(height: 10),
                    FutureBuilder<DocumentSnapshot>(
                      future: _firestore.collection('users').doc(_auth.currentUser?.uid).get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(child: Text("Bir hata oluştu"));
                        }

                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return Center(child: Text("Kullanıcı verisi bulunamadı"));
                        }

                        var userData = snapshot.data!.data() as Map<String, dynamic>;
                        Timestamp registrationTimestamp = userData['registrationDate'];
                        DateTime registrationDate = registrationTimestamp.toDate();
                        String formattedDate = DateFormat('dd.MM.yyy HH:mm').format(registrationDate);

                        return Text("Kayıt Tarihi: $formattedDate", style: TextStyle(fontSize: 18));
                      },
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if (isEditing) {
                              _saveProfile();
                            }
                            isEditing = !isEditing;
                          });
                        },
                        child: Text(isEditing ? "Kaydet" : "Profili Düzenle"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}





  Widget _buildProfileField(String label, TextEditingController controller, bool enabled, {bool isNumber = false}) {
    return enabled
      ? TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(),
          ),
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: TextStyle(color: Colors.black),
        )
      : Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(
              controller.text.isNotEmpty ? controller.text : 'Bilinmiyor',
              style: TextStyle(color: Colors.black),
            ),
          ],
        );
  }

  Widget _buildGenderField(bool enabled) {
    return enabled
      ? _buildGenderSelection()
      : Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Cinsiyet'),
            Text(
              _selectedGender != null
                ? _selectedGender.toString().split('.').last 
                : 'Bilinmiyor',
              style: TextStyle(color: Colors.black),
            ),
          ],
        );
  }

  Widget _buildGenderSelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Text('Cinsiyet:'),
        Row(
          children: [
            Radio<Gender>(
              value: Gender.erkek,
              groupValue: _selectedGender,
              onChanged: (Gender? value) {
                setState(() {
                  _selectedGender = value;
                });
              },
            ),
            const Text('Erkek'),
            Radio<Gender>(
              value: Gender.kadin,
              groupValue: _selectedGender,
              onChanged: (Gender? value) {
                setState(() {
                  _selectedGender = value;
                });
              },
            ),
            const Text('Kadın'),
            Radio<Gender>(
              value: Gender.diger,
              groupValue: _selectedGender,
              onChanged: (Gender? value) {
                setState(() {
                  _selectedGender = value;
                });
              },
            ),
            const Text('Diğer'),
          ],
        ),
      ],
    );
  }

  Future<void> _saveProfile() async {
    String? profilePhotoUrl;
    if (_profileImage != null) {
      profilePhotoUrl = await _uploadProfileImage();
    }

    await _firestore.collection('users').doc(_auth.currentUser?.uid).update({
      'firstName': firstNameController.text,
      'lastName': lastNameController.text,
      'email': emailController.text,
      'gender': _selectedGender?.toString() ?? 'diger',
      'age': int.tryParse(ageController.text) ?? 0,
      if (profilePhotoUrl != null) 'profilePhoto': profilePhotoUrl,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Profil başarıyla güncellendi")),
    );
  }

  Future<String?> _uploadProfileImage() async {
    final ref = _storage.ref().child('profile_images/${_auth.currentUser?.uid}.jpg');
    await ref.putFile(_profileImage!);
    return await ref.getDownloadURL();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _showProfileImageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Profil Resmi'),
          content: Image.network(_profileImageUrl ?? ''),
          actions: [
            TextButton(
              child: Text('Tamam'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Çıkış Yap'),
          content: Text('Çıkış yapmak istediğinize emin misiniz?'),
          actions: [
            TextButton(
              child: Text('Hayır'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Evet'),
              onPressed: () async {
                await _auth.signOut();
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed('/login'); 
              },
            ),
          ],
        );
      },
    );
  }
}

enum Gender { erkek, kadin, diger }
