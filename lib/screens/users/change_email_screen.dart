// change_email_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChangeEmailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('E-Posta Değiştir'),
        backgroundColor: Colors.pink.shade100,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: ChangeEmailForm(),
      ),
    );
  }
}

class ChangeEmailForm extends StatefulWidget {
  @override
  _ChangeEmailFormState createState() => _ChangeEmailFormState();
}

class _ChangeEmailFormState extends State<ChangeEmailForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _currentEmailController = TextEditingController();
  TextEditingController _newEmailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _setCurrentEmail();
  }

  Future<void> _setCurrentEmail() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      String email = userDoc['email'] ?? '';
      _currentEmailController.text = email;
    }
  }

  Future<void> _updateEmail() async {
    User? user = _auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kullanıcı bulunamadı.')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    String newEmail = _newEmailController.text;

    if (user.email == newEmail) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Yeni e-posta adresi mevcut e-posta ile aynı olamaz.')),
      );
      return;
    }

    try {
      await user.updateEmail(newEmail);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('E-posta adresi başarıyla değiştirildi.')),
      );

    } catch (e) {
      print('E-Posta değiştirirken bir hata oluştu: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('E-Posta adresi değiştirilemedi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextFormField(
            controller: _currentEmailController,
            decoration: InputDecoration(
              labelText: 'Mevcut E-Posta Adresi',
              icon: Icon(Icons.email),
            ),
            readOnly: true,
          ),
          SizedBox(height: 20.0),
          TextFormField(
            controller: _newEmailController,
            decoration: InputDecoration(
              labelText: 'Yeni E-Posta Adresi',
              icon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Yeni e-posta adresi gerekli.';
              }
              if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(value)) {
                return 'Geçerli bir e-posta adresi girin.';
              }
              return null;
            },
          ),
          SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: _updateEmail,
            child: Text('E-Posta Değiştir', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink.shade100,
            ),
          ),
        ],
      ),
    );
  }
}
