import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'product_details.dart'; // Ürün detay ekranını içe aktar

class FavorilerEkrani extends StatefulWidget {
  @override
  _FavorilerEkraniState createState() => _FavorilerEkraniState();
}

class _FavorilerEkraniState extends State<FavorilerEkrani> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Future<List<DocumentSnapshot>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _favoritesFuture = _fetchFavorites();
  }

  Future<List<DocumentSnapshot>> _fetchFavorites() async {
    final user = _auth.currentUser;
    if (user == null) {

      return [];
    }

    try {

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .get();


      return snapshot.docs;
    } catch (e) {
      throw Exception('Favoriler alınamadı: $e');
    }
  }

  void _toggleFavorite(String productId) async {
    final user = _auth.currentUser;
    if (user == null) {

      return;
    }

    final favoriteRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(productId);

    try {
      final doc = await favoriteRef.get();

      if (doc.exists) {

        await favoriteRef.delete();
      } else {

        final productDoc = await FirebaseFirestore.instance.collection('products').doc(productId).get();
        if (productDoc.exists) {
          final data = productDoc.data()!;
          await favoriteRef.set({
            'name': data['name'],
            'imageUrl': data['imageUrl'],
            // Diğer gerekli alanları ekleyin
          });
        }
      }


      setState(() {
        _favoritesFuture = _fetchFavorites();
      });
    } catch (e) {

      print('Favori güncelleme hatası: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favoriler'),
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Favori ürün bulunamadı.'));
          } else {
            final favoriteDocs = snapshot.data!;
            return ListView.builder(
              itemCount: favoriteDocs.length,
              itemBuilder: (context, index) {
                final doc = favoriteDocs[index];
                final productId = doc.id;

                // Map<String, dynamic> türüne dönüştürme
                final data = doc.data() as Map<String, dynamic>;
                final name = data['name'] ?? 'Ürün İsmi Yok';
                final imageUrl = data['imageUrl'] as String?;

                return ListTile(
                  title: Text(name),
                  leading: imageUrl != null
                      ? Image.network(imageUrl)
                      : Icon(Icons.image_not_supported, size: 50),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.favorite,
                      color: Colors.red,
                    ),
                    onPressed: () => _toggleFavorite(productId),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailScreen(productId: productId),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
