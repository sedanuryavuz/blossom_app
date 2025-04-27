import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:blossom_app/screens/users/new_card_screen.dart';
import 'package:blossom_app/services/functions.dart';

class MevcutKartlarScreen extends StatefulWidget {
  @override
  _MevcutKartlarScreenState createState() => _MevcutKartlarScreenState();
}

class _MevcutKartlarScreenState extends State<MevcutKartlarScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<DocumentSnapshot> kartlar = [];
  String? _notificationMessage;

  @override
  void initState() {
    super.initState();
    _fetchCardDetails();
  }

  Future<void> _fetchCardDetails() async {
    User? user = _auth.currentUser;
    if (user != null) {
      QuerySnapshot cardSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cards')
          .get();
      setState(() {
        kartlar = cardSnapshot.docs;
      });
    }
  }

  Future<void> _kartDuzenle(BuildContext context, DocumentSnapshot kart) async {
    TextEditingController _kartNumarasiController = TextEditingController(text: kart['cardNumber']);
    TextEditingController _kartSahibiController = TextEditingController(text: kart['cardHolder']);
    TextEditingController _sonKullanmaTarihiController = TextEditingController(text: kart['expiryDate']);
    TextEditingController _cvvController = TextEditingController(text: kart['cvv']);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Kart Düzenle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _kartNumarasiController,
                decoration: InputDecoration(labelText: 'Kart Numarası'),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(16),
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              TextField(
                controller: _kartSahibiController,
                decoration: InputDecoration(labelText: 'Kart Sahibi'),
              ),
              TextField(
                controller: _sonKullanmaTarihiController,
                decoration: InputDecoration(labelText: 'Son Kullanma Tarihi (MM/YY)'),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(5),
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (value) {
                  // Tarih formatını kontrol et
                  if (value.length == 2 && !value.contains('/')) {
                    _sonKullanmaTarihiController.text = '$value/';
                    _sonKullanmaTarihiController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _sonKullanmaTarihiController.text.length),
                    );
                  }
                },
              ),
              TextField(
                controller: _cvvController,
                decoration: InputDecoration(labelText: 'CVV'),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(3),
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (value) {
                  if (value.length > 3) {
                    _cvvController.text = value.substring(0, 3);
                    _cvvController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _cvvController.text.length),
                    );
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('İptal'),
            ),
            TextButton(
              onPressed: () async {
                await kartGuncelle(
                  context,
                  kart.id,
                  _kartNumarasiController.text,
                  _kartSahibiController.text,
                  _sonKullanmaTarihiController.text,
                  _cvvController.text,
                );
                Navigator.of(context).pop();
                _fetchCardDetails();
              },
              child: Text('Güncelle'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _kartSil(BuildContext context, String kartId) async {
    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('cards')
          .doc(kartId)
          .delete();
      setState(() {
        _notificationMessage = 'Kart başarıyla silindi.';
        _fetchCardDetails();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kart silinirken hata oluştu: $e')),
      );
    }
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context, String kartId) async {
    bool confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Kart Sil'),
          content: Text('Bu kartı silmek istediğinizden emin misiniz?'),
          actions: <Widget>[
            TextButton(
              child: Text('Hayır'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('Evet'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    ) ?? false;

    if (confirm) {
      _kartSil(context, kartId);
    }
  }

  Widget deleteItems(BuildContext context, String kartId) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.black),
            onPressed: () {
              _showDeleteConfirmationDialog(context, kartId);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kart Detayları'),
        backgroundColor: Colors.pink.shade100,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NewCardScreen()),
              ).then((value) {
                if (value == true) {
                  _fetchCardDetails();
                }
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Mevcut Kartlar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _notificationMessage != null
                ? Padding(
              padding: EdgeInsets.only(bottom: 10.0),
              child: Text(
                _notificationMessage!,
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            )
                : SizedBox.shrink(),
            kartlar.isEmpty
                ? Text('Kart bulunamadı.')
                : Expanded(
              child: ListView.builder(
                itemCount: kartlar.length,
                itemBuilder: (context, index) {
                  var kart = kartlar[index];
                  return Card(
                    child: ListTile(
                      subtitle: Text(kart['cardNumber'] ?? 'Kart Numarası'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              _kartDuzenle(context, kart);
                            },
                          ),
                          deleteItems(context, kart.id),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
