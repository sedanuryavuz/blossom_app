import 'package:blossom_app/screens/main/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:blossom_app/screens/users/change_email_screen.dart';

class KullaniciBilgileriEkrani extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kullanıcı Bilgileri'),
        backgroundColor: Colors.pink.shade100,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: KullaniciBilgileriFormu(),
      ),
    );
  }
}

class KullaniciBilgileriFormu extends StatefulWidget {
  @override
  _KullaniciBilgileriFormuState createState() =>
      _KullaniciBilgileriFormuState();
}

class _KullaniciBilgileriFormuState extends State<KullaniciBilgileriFormu> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();
  final _adController = TextEditingController();
  final _soyadController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    _adController.dispose();
    _soyadController.dispose();
    _emailController.dispose();
    _telefonController.dispose();
    super.dispose();
  }

  void _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        setState(() {
          _adController.text = userDoc['name'] ?? '';
          _soyadController.text = userDoc['surname'] ?? '';
          _emailController.text = user.email ?? '';
          _telefonController.text = userDoc['phone'] ?? '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: 20.0),
          _buildTextField(_adController, 'Ad', Icons.person),
          const SizedBox(height: 10.0),
          _buildTextField(_soyadController, 'Soyad', Icons.person),
          const SizedBox(height: 10.0),
          _buildEmailField(),
          const SizedBox(height: 10.0),
          _buildPhoneField(_telefonController, 'Telefon Numarası', Icons.phone),
          const SizedBox(height: 10.0),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _kullaniciBilgileriniGuncelle();
              }
            },
            child: Text('Bilgilerimi Kaydet',
                style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink.shade100,
            ),
          ),
          const SizedBox(height: 10.0),
          TextButton(
            onPressed: () {
              _hesabiKapat();
            },
            child: const Text(
              'Hesabımı Kapat',
              style: TextStyle(color: Colors.pink),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String labelText, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 241, 237, 237),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(icon, color: Colors.pink),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
        ),
        validator: (value) {
          if (value!.isEmpty) {
            return 'Lütfen $labelText girin';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildEmailField() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 241, 237, 237),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'E-Posta',
                prefixIcon: Icon(Icons.email, color: Colors.pink),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 15.0, vertical: 15.0),
              ),
              readOnly: true,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChangeEmailScreen()),
              );
            },
            child: Text(
              'Değiştir',
              style: TextStyle(color: Colors.pink),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneField(
      TextEditingController controller, String labelText, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 241, 237, 237),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(icon, color: Colors.pink),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
        ),
        keyboardType: TextInputType.phone,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Lütfen $labelText girin';
          } else if (!RegExp(r'^\+?0[0-9]{10}$').hasMatch(value)) {
            return 'Geçerli bir telefon numarası girin';
          }
          return null;
        },
      ),
    );
  }

  void _kullaniciBilgileriniGuncelle() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).update({
          'ad': _adController.text,
          'soyad': _soyadController.text,
          'telefon': _telefonController.text,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kullanıcı bilgileri güncellendi')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bilgiler güncellenirken bir hata oluştu')),
        );
      }
    }
  }

  void _hesabiKapat() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hesabınızı Kapat'),
          content: const Text('Hesabınızı kapatmak istediğinize emin misiniz?'),
          actions: <Widget>[
            TextButton(
              child: const Text('İptal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Kapat'),
              onPressed: () {
                _kapatHesabi();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _kapatHesabi() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).delete();
        await user.delete();
        await _auth.signOut();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Hesabınız başarıyla kapatıldı. Yönlendiriliyorsunuz...'),
          ),
        );
        Future.delayed(Duration(seconds: 2), () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => LoginScreen()),
            (Route<dynamic> route) => false,
          );
        });
      } catch (e) {
        if (e is FirebaseAuthException) {
          if (e.code == 'requires-recent-login') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Hesabınızın kapatılması için tekrar giriş yapmanız gerekiyor.'),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Bir hata oluştu: ${e.message}'),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hesap kapatılırken bir hata oluştu: $e'),
            ),
          );
        }
      }
    }
  }
}
