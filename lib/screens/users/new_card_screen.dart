import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NewCardScreen extends StatefulWidget {
  @override
  _NewCardScreenState createState() => _NewCardScreenState();
}

class _NewCardScreenState extends State<NewCardScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();
  TextEditingController _cardTitleController = TextEditingController();
  TextEditingController _cardNumberController = TextEditingController();
  TextEditingController _cardHolderController = TextEditingController();
  TextEditingController _cvvController = TextEditingController();

  final List<String> _months = ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12'];
  final List<String> _years = List.generate(20, (index) => (DateTime.now().year + index).toString().substring(2));

  String? _selectedMonth;
  String? _selectedYear;

  Future<void> _saveCard() async {
    if (_formKey.currentState!.validate()) {
      User? user = _auth.currentUser;
      if (user != null) {
        String expiryDate = '$_selectedMonth/$_selectedYear';
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('cards')
            .add({
          'cardNumber': _cardNumberController.text,
          'cardHolder': _cardHolderController.text,
          'expiryDate': expiryDate,
          'cvv': _cvvController.text,
        });
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yeni Kart Ekle'),
        backgroundColor: Colors.pink.shade100,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[


              SizedBox(height: 10),
              TextFormField(
                controller: _cardNumberController,
                decoration: InputDecoration(
                  labelText: 'Kart Numarası',
                  icon: Icon(Icons.credit_card, color: Colors.pink),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.pink.withOpacity(0.5)),
                  ),
                ),
                keyboardType: TextInputType.number,

                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Kart numarasını girin';
                  }
                  if (value.length != 16) {
                    return 'Kart numarası 16 haneli olmalı';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _cardHolderController,
                decoration: InputDecoration(
                  labelText: 'Kart Sahibi',
                  icon: Icon(Icons.person, color: Colors.pink),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.pink.withOpacity(0.5)),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Kart sahibini girin';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.start,

                children: [
                  SizedBox(width: 7),
                  Container(
                    width: 120,

                    child: DropdownButtonFormField<String>(
                      value: _selectedMonth,
                      items: _months.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedMonth = value;
                        });
                      },

                      decoration: InputDecoration(
                        labelText: 'Ay',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 11),
                        border: OutlineInputBorder(

                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        icon: Icon(Icons.calendar_today, color: Colors.pink),
                      ),
                      validator: (value) {
                        if (value == null) {
                          return 'Ay seçin';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 20),
                  Container(
                    width: 90,
                    child: DropdownButtonFormField<String>(
                      value: _selectedYear,
                      items: _years.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedYear = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Yıl',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 11),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),

                      ),
                      validator: (value) {
                        if (value == null) {
                          return 'Yıl seçin';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),





              SizedBox(height: 10),
              TextFormField(
                controller: _cvvController,
                decoration: InputDecoration(
                  labelText: 'CVV',
                  icon: Icon(Icons.lock, color: Colors.pink),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.pink.withOpacity(0.5)),
                  ),
                ),
                keyboardType: TextInputType.number,

                validator: (value) {
                  if (value!.isEmpty) {
                    return 'CVV kodunu girin';
                  }
                  if (value.length != 3) {
                    return 'CVV 3 haneli olmalı';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveCard,
                child: Text(
                  'Kaydet',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink.shade100,
                  padding: EdgeInsets.symmetric(vertical: 15.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
