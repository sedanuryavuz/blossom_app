import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  ProductDetailScreen({required this.productId});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Map<String, dynamic>? _productData;
  bool _isFavorite = false;
  final _commentController = TextEditingController();
  double _rating = 0;

  @override
  void initState() {
    super.initState();
    _fetchProductData();
    _checkIfFavorite();
  }

  Future<void> _fetchProductData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .get();
      if (doc.exists) {
        setState(() {
          _productData = doc.data();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ürün bulunamadı.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veri alma hatası: $e')),
      );
    }
  }

  Future<void> _checkIfFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final favoriteRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(widget.productId);

      final doc = await favoriteRef.get();
      setState(() {
        _isFavorite = doc.exists;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen giriş yapın.')),
      );
      return;
    }

    if (_productData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ürün verileri alınamadı.')),
      );
      return;
    }

    final favoriteRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(widget.productId);

    try {
      if (_isFavorite) {
        // Favorilerden kaldır
        await favoriteRef.delete();
      } else {
        // Favorilere ekle
        await favoriteRef.set({
          'name': _productData!['name'] ?? 'İsimsiz Ürün',
          'price': _productData!['price'] ?? 0.0,
          'imageUrl': _productData!['image'] ?? '',
        });
      }
      setState(() {
        _isFavorite = !_isFavorite;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Favori hatası: $e')),
      );
    }
  }

  Future<void> _addToCart() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen giriş yapın.')),
      );
      return;
    }

    if (_productData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ürün verileri alınamadı.')),
      );
      return;
    }

    final cartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(widget.productId);

    try {
      await cartRef.set({
        'productName': _productData!['name'] ?? 'İsimsiz Ürün',
        'price': _productData!['price'] ?? 0.0,
        'size': (_productData!['sizes'] as List<dynamic>?)?.isNotEmpty == true
            ? _productData!['sizes'][0]
            : 'Bilinmiyor',
        'color': (_productData!['colors'] as List<dynamic>?)?.isNotEmpty == true
            ? _productData!['colors'][0]
            : 'Bilinmiyor',
        'quantity': 1,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ürün sepete eklendi.')),
      );

      // Sepet ekranına geçiş
      Navigator.pushReplacementNamed(context, '/cart');

    } catch (e) {
      print('Sepete ekleme hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sepete ekleme hatası: $e')),
      );
    }
  }

  Future<void> _submitReview() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen giriş yapın.')),
      );
      return;
    }

    if (_commentController.text.isEmpty || _rating <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Yorum ve puan giriniz.')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('products').doc(widget.productId).collection('productReviews').add({
        'userId': user.uid,
        'rating': _rating,
        'comment': _commentController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Yorumunuz başarıyla eklendi.')),
      );

      _commentController.clear();
      setState(() {
        _rating = 0;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Yorum ekleme hatası: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_productData == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Ürün Detayları'),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final imageUrl = _productData!['image'] ?? '';
    final name = _productData!['name'] ?? 'İsimsiz Ürün';
    final price = _productData!['price'] ?? 0.0;
    final sizes = (_productData!['sizes'] as List<dynamic>?)?.cast<String>() ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Ürün Detayları'),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              imageUrl.isNotEmpty
                  ? Image.network(imageUrl)
                  : Placeholder(fallbackHeight: 200.0),
              SizedBox(height: 16.0),
              Text(
                name,
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              Text(
                '₺${price.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 20.0, color: Colors.grey[600]),
              ),
              SizedBox(height: 16.0),

              Wrap(
                spacing: 8.0,
                children: sizes.map((size) => Chip(label: Text(size))).toList(),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _addToCart,
                child: Text('Sepete Ekle'),
              ),

              // Yorum Formu
              SizedBox(height: 16.0),
              Text(
                'Yorum Yaz',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Yorumunuz',
                ),
                maxLines: 3,
              ),
              SizedBox(height: 8.0),
              Row(
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () {
                      setState(() {
                        _rating = index + 1.0;
                      });
                    },
                  );
                }),
              ),
              SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: _submitReview,
                child: Text('Yorumu Gönder'),
              ),

              // Yorumları Göster
              SizedBox(height: 16.0),
              Text(
                'Yorumlar',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('products')
                    .doc(widget.productId)
                    .collection('productReviews')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final reviews = snapshot.data!.docs;
                  return Column(
                    children: reviews.map((review) {
                      final data = review.data() as Map<String, dynamic>;
                      return ListTile(
                        title: Text(data['comment']),
                        subtitle: Text('Puan: ${data['rating']}'),
                        trailing: Text(data['timestamp']?.toDate()?.toString() ?? 'Bilinmiyor'),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
