import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'login_page.dart'; 
import 'dart:io';

enum Gender { erkek, kadin, diger }

extension GenderExtension on Gender {
  String toDisplayString() {
    switch (this) {
      case Gender.erkek:
        return 'Erkek';
      case Gender.kadin:
        return 'Kadın';
      case Gender.diger:
        return 'Diğer';
      default:
        return '';
    }
  }

  static Gender fromString(String gender) {
    switch (gender) {
      case 'Erkek':
        return Gender.erkek;
      case 'Kadın':
        return Gender.kadin;
      case 'Diğer':
        return Gender.diger;
      default:
        throw ArgumentError('Invalid gender value');
    }
  }
}

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  Gender? _selectedGender;
  XFile? _profilePhoto;

  Future<void> _saveUserToFirestore() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        String photoUrl = '';
        if (_profilePhoto != null) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('profile_photos/${userCredential.user!.uid}.jpg');
          await storageRef.putFile(File(_profilePhoto!.path));
          photoUrl = await storageRef.getDownloadURL();
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
          'gender': _selectedGender?.toDisplayString() ?? '',
          'age': int.parse(_ageController.text),
          'registrationDate': Timestamp.now(), 
          'profilePhoto': photoUrl, 
        });

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Kayıt Başarılı'),
              content: Text('Başarıyla kayıt oldunuz.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); 
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: Text('Tamam'),
                ),
              ],
            );
          },
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bir hata oluştu: $e')),
        );
      }
    }
  }

  Future<void> _pickProfilePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _profilePhoto = pickedFile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min, 
                  children: [
                    GestureDetector(
                      onTap: _pickProfilePhoto,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: _profilePhoto != null
                            ? FileImage(File(_profilePhoto!.path))
                            : null,
                        child: _profilePhoto == null
                            ? Icon(Icons.camera_alt, size: 50, color: Colors.grey[800])
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(labelText: 'Ad'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ad alanı boş olamaz';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(labelText: 'Soyad'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Soyad alanı boş olamaz';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'E-posta'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'E-posta alanı boş olamaz';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Geçerli bir e-posta adresi girin';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Şifre'),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Şifre alanı boş olamaz';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _ageController,
                      decoration: const InputDecoration(labelText: 'Yaş'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Yaş alanı boş olamaz';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Geçerli bir yaş girin';
                        }
                        return null;
                      },
                    ),
                    Row(
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
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveUserToFirestore,
                      child: const Text('Kayıt Ol'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
