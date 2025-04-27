import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'new_address_screen.dart';
import 'package:blossom_app/services/functions.dart';

class AddressDetailsScreen extends StatefulWidget {
  @override
  _AddressDetailsScreenState createState() => _AddressDetailsScreenState();
}

class _AddressDetailsScreenState extends State<AddressDetailsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<DocumentSnapshot> adresler = [];

  @override
  void initState() {
    super.initState();
    _fetchAddressDetails();
  }

  Future<void> _fetchAddressDetails() async {
    User? user = _auth.currentUser;
    if (user != null) {
      QuerySnapshot addressSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('addresses')
          .get();
      setState(() {
        adresler = addressSnapshot.docs;
      });
    }
  }

  Future<void> _adresDuzenle(BuildContext context, DocumentSnapshot adres) async {
    TextEditingController _baslikController = TextEditingController(text: adres['addressTitle']);
    TextEditingController _adresDetayController = TextEditingController(text: adres['address']);
    TextEditingController _ilDetayController = TextEditingController(text: adres['city']);
    TextEditingController _ilceDetayController = TextEditingController(text: adres['district']);
    TextEditingController _mahalleDetayController = TextEditingController(text: adres['neighborhood']);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Adres Düzenle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _baslikController,
                decoration: InputDecoration(labelText: 'Adres Başlığı'),
              ),
              TextField(
                controller: _adresDetayController,
                decoration: InputDecoration(labelText: 'Adres Detayı'),
              ),
              TextField(
                controller: _ilDetayController,
                decoration: InputDecoration(labelText: 'İl Detayı'),
              ),
              TextField(
                controller: _ilceDetayController,
                decoration: InputDecoration(labelText: 'İlçe Detayı'),
              ),
              TextField(
                controller: _mahalleDetayController,
                decoration: InputDecoration(labelText: 'Mahalle Detayı'),
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
                await adresGuncelle(
                  context,
                  adres.id,
                  _baslikController.text,
                  _adresDetayController.text,
                  _ilDetayController.text,
                  _ilceDetayController.text,
                  _mahalleDetayController.text,
                );
                Navigator.of(context).pop();
                _fetchAddressDetails();
              },
              child: Text('Güncelle'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _adresSil(BuildContext context, String adresId) async {
    bool confirm = await _showDeleteConfirmationDialog();
    if (confirm) {
      try {
        await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .collection('addresses')
            .doc(adresId)
            .delete();
        _fetchAddressDetails();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Adres silinirken hata oluştu: $e')),
        );
      }
    }
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Adres Sil'),
          content: Text('Bu adresi silmek istediğinizden emin misiniz?'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adres Detayları'),
        backgroundColor: Colors.pink.shade100,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NewAddressScreen()),
              ).then((value) {
                if (value == true) {
                  _fetchAddressDetails();
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
              'Mevcut Adresler',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            adresler.isEmpty
                ? Text('Adres bulunamadı.')
                : Expanded(
              child: ListView.builder(
                itemCount: adresler.length,
                itemBuilder: (context, index) {
                  var adres = adresler[index];
                  return Card(
                    child: ListTile(
                      title: Text(adres['addressTitle'] ?? 'Adres Başlığı'),
                      subtitle: Text(adres['address'] ?? 'Adres Detayı'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              _adresDuzenle(context, adres);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _adresSil(context, adres.id);
                            },
                          ),
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
