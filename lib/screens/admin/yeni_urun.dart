import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class NewProductScreen extends StatefulWidget {
  @override
  _NewProductScreenState createState() => _NewProductScreenState();
}

class _NewProductScreenState extends State<NewProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final picker = ImagePicker();
  File? _image;
  String? _downloadURL;
  String? _selectedCategory;
  List<String> _categories = [];
  bool _isLoadingCategories = true;
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final querySnapshot = await _firestore.collection('category').get();
      final categories = querySnapshot.docs.map((doc) => doc.data()['isim'] as String).toList();

      if (mounted) {
        setState(() {
          _categories = categories;
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCategories = false;
        });
      }
      showErrorDialog('Kategoriler yüklenemedi. Hata: $e');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;
    final storageRef = FirebaseStorage.instance.ref().child('products/${DateTime.now()}.png');
    final uploadTask = storageRef.putFile(_image!);

    final snapshot = await uploadTask.whenComplete(() {});
    _downloadURL = await snapshot.ref.getDownloadURL();
    print('Download URL: $_downloadURL');
  }

  void _addProduct() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _uploadImage();
        await _firestore.collection('products').add({
          'name': _titleController.text,
          'category': _selectedCategory,
          'price': double.parse(_priceController.text),
          'image': _downloadURL,
        });
        Navigator.pop(context);
      } catch (e) {
        showErrorDialog('Ürün eklenemedi. Hata: $e');
      }
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hata'),
          content: Text(message),
          actions: <Widget>[
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yeni Ürün Ekle'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Ürün Başlığı'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Lütfen bir başlık girin';
                  }
                  return null;
                },
              ),
              _isLoadingCategories
                  ? Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(labelText: 'Kategori'),
                items: _categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Lütfen bir kategori seçin';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Fiyat'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Lütfen bir fiyat girin';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Fotoğraf Seç'),
              ),
              if (_image != null)
                Image.file(_image!, height: 200, width: 200, fit: BoxFit.cover),
              ElevatedButton(
                onPressed: _addProduct,
                child: Text('Ürün Ekle'),
              ),
              if (_downloadURL != null)
                Text('Fotoğraf Yüklendi! URL: $_downloadURL'),
            ],
          ),
        ),
      ),
    );
  }
}
