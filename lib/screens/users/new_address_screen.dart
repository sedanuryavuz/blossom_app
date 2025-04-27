import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NewAddressScreen extends StatefulWidget {
  @override
  _NewAddressScreenState createState() => _NewAddressScreenState();
}

class _NewAddressScreenState extends State<NewAddressScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();
  TextEditingController _addressTitleController = TextEditingController();
  TextEditingController _neighborhoodController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  String? _selectedCity;
  String? _selectedDistrict;

  List<String> cities = ['İstanbul', 'Ankara', 'İzmir'];
  Map<String, List<String>> districts = {
    'İstanbul': ['Beşiktaş', 'Kadıköy', 'Şişli'],
    'Ankara': ['Çankaya', 'Keçiören', 'Yenimahalle'],
    'İzmir': ['Konak', 'Karşıyaka', 'Bornova'],
  };

  Future<void> _saveAddress() async {
    if (_formKey.currentState!.validate()) {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('addresses')
            .add({
          'addressTitle': _addressTitleController.text,
          'city': _selectedCity,
          'district': _selectedDistrict,
          'neighborhood': _neighborhoodController.text,
          'address': _addressController.text,
        });
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yeni Adres Ekle'),
        backgroundColor: Colors.pink.shade100,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _addressTitleController,
                decoration: InputDecoration(
                  labelText: 'Adres Başlığı',
                  icon: Icon(Icons.title, color: Colors.pink),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide:
                    BorderSide(color: Colors.pink.withOpacity(0.5)),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Adres başlığını girin';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCity,
                      items: cities.map((city) {
                        return DropdownMenuItem<String>(
                          value: city,
                          child: Text(city),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCity = value;
                          _selectedDistrict = null;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'İl',
                        icon: Icon(Icons.location_city, color: Colors.pink),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                              color: Colors.pink.withOpacity(0.5)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null) {
                          return 'İlinizi seçin';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedDistrict,
                      items: _selectedCity != null
                          ? districts[_selectedCity]!.map((district) {
                        return DropdownMenuItem<String>(
                          value: district,
                          child: Text(district),
                        );
                      }).toList()
                          : [],
                      onChanged: (value) {
                        setState(() {
                          _selectedDistrict = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'İlçe',
                        icon: Icon(Icons.location_city, color: Colors.pink),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                              color: Colors.pink.withOpacity(0.5)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null) {
                          return 'İlçenizi seçin';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _neighborhoodController,
                decoration: InputDecoration(
                  labelText: 'Mahalle',
                  icon: Icon(Icons.location_city, color: Colors.pink),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide:
                    BorderSide(color: Colors.pink.withOpacity(0.5)),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Mahallenizi girin';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10.0),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Adres',
                  icon: Icon(Icons.location_on, color: Colors.pink),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide:
                    BorderSide(color: Colors.pink.withOpacity(0.5)),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Adresinizi girin';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveAddress,
                child: Text('Kaydet', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink.shade100,
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
