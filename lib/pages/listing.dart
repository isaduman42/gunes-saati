import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gunes_saati/pages/profile.dart';
import 'package:gunes_saati/pages/main_page.dart';
import 'package:gunes_saati/main.dart'; 

class ListingPage extends StatefulWidget {    
  @override
  _ListingPageState createState() => _ListingPageState();
}

class _ListingPageState extends State<ListingPage> {
  int _selectedIndex = 1; 
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return BackgroundScaffold(
        body: Center(
          child: Text("Kullanıcı oturumu bulunamadı."),
        ),
      );
    }

    return BackgroundScaffold(
      body: Column(
        children: [
          AppBar(
            title: Text("Listeleme"),
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0, 
            actions: [
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  showSearch(
                    context: context,
                    delegate: DataSearch(
                      currentUser: _currentUser!,
                    ),
                  );
                },
              ),
            ],
            foregroundColor: Colors.black, 
          ),
          Expanded(child: _buildBody()),
          _buildBottomNavigationBar(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('sunrise_sunset_data')
          .doc(_currentUser!.uid)
          .collection('entries')
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('Kayıt bulunamadı.'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var entry = snapshot.data!.docs[index].data() as Map<String, dynamic>;

            return ListTile(
              title: Text(entry['name'] ?? 'No Name'),
              onTap: () {
                _showDetailDialog(
                  documentId: snapshot.data!.docs[index].id,
                  name: entry['name'] ?? 'No Name',
                  location: entry['location'] ?? 'No Location',
                  sunrise: entry['sunrise'] ?? 'No Sunrise',
                  sunset: entry['sunset'] ?? 'No Sunset',
                  date: entry['date'] ?? 'No Date',
                );
              },
            );
          },
        );
      },
    );
  }

  void _showDetailDialog({
    required String documentId,
    required String name,
    required String location,
    required String sunrise,
    required String sunset,
    required String date,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Konum: $location"),
              SizedBox(height: 10),
              Text("Güneş Doğuşu: $sunrise"),
              Text("Güneş Batışı: $sunset"),
              Text("Tarih: $date"),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Sil"),
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteEntry(documentId);
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

  Future<void> _deleteEntry(String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('sunrise_sunset_data')
          .doc(_currentUser!.uid)
          .collection('entries')
          .doc(documentId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Kayıt başarıyla silindi")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Silme işlemi başarısız: $e")),
      );
    }
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MainPage()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage()),
      );
    }
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Ana Sayfa',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'Listeleme',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: const Color.fromARGB(255, 209, 172, 50),
      onTap: _onItemTapped,
    );
  }
}

class DataSearch extends SearchDelegate<String> {
  final User currentUser;

  DataSearch({required this.currentUser});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = ''; 
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return BackgroundScaffold(
      body: _buildSearchResults(context),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return BackgroundScaffold(
      body: _buildSearchResults(context),
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('sunrise_sunset_data')
          .doc(currentUser.uid)
          .collection('entries')
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('Kayıt bulunamadı.'));
        }

        var data = snapshot.data!.docs.where((doc) {
          var name = (doc.data() as Map<String, dynamic>)['name']?.toString() ?? '';
          return name.toLowerCase().contains(query.toLowerCase());
        }).toList();

        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            var entry = data[index].data() as Map<String, dynamic>;

            return ListTile(
              title: Text(entry['name'] ?? 'No Name'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(entry['name'] ?? 'No Name'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Konum: ${entry['location'] ?? 'No Location'}"),
                          SizedBox(height: 10),
                          Text("Güneş Doğuşu: ${entry['sunrise'] ?? 'No Sunrise'}"),
                          Text("Güneş Batışı: ${entry['sunset'] ?? 'No Sunset'}"),
                          Text("Tarih: ${entry['date'] ?? 'No Date'}"),
                        ],
                      ),
                      actions: <Widget>[
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
              },
            );
          },
        );
      },
    );
  }
}
