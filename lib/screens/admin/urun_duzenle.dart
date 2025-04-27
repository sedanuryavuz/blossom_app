/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProductScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  EditProductScreen({required this.product});

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _priceController;
  late final TextEditingController _imageController;
  String? _selectedCategory;
  List<String> _categories = [];
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.product['title']);
    _priceController = TextEditingController(text: widget.product['price'].toString());
    _imageController = TextEditingController(text: widget.product['image']);
    _selectedCategory = widget.product['category'];
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('category').get();
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

  void _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('products').doc(widget.product['id']).update({
          'title': _titleController.text,
          'category': _selectedCategory,
          'price': double.tryParse(_priceController.text) ?? 0.0,
          'image': _imageController.text,
        });
        Navigator.pop(context, true); // Güncelleme başarılı
      } catch (e) {
        print('Error updating product: $e');
        showErrorDialog('Ürün güncellenemedi. Hata: $e');
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
        title: Text('Ürün Düzenle'),
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
              TextFormField(
                controller: _imageController,
                decoration: InputDecoration(labelText: 'Resim URL'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Lütfen bir resim URL girin';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateProduct,
                child: Text('Güncelle'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProductScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  EditProductScreen({required this.product});

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _priceController;
  late final TextEditingController _imageController;
  String? _selectedCategory;
  List<String> _categories = [];
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.product['title']);
    _priceController = TextEditingController(text: widget.product['price'].toString());
    _imageController = TextEditingController(text: widget.product['image']);
    _selectedCategory = widget.product['category'];
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('category').get();
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

  void _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('products').doc(widget.product['id']).update({
          'title': _titleController.text,
          'category': _selectedCategory,
          'price': double.tryParse(_priceController.text) ?? 0.0,
          'image': _imageController.text,
        });
        Navigator.pop(context, true);
      } catch (e) {
        print('Error updating product: $e');
        showErrorDialog('Ürün güncellenemedi. Hata: $e');
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
        title: Text('Ürün Düzenle'),
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
                  if (double.tryParse(value) == null) {
                    return 'Geçerli bir sayı girin';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _imageController,
                decoration: InputDecoration(labelText: 'Resim URL'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Lütfen bir resim URL girin';
                  }
                  if (!Uri.tryParse(value)!.hasAbsolutePath ?? true) {
                    return 'Geçerli bir URL girin';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateProduct,
                child: Text('Güncelle'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
