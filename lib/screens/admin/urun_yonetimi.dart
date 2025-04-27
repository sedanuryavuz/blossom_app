import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'yeni_urun.dart';
import 'urun_duzenle.dart';

class UrunYonetimi extends StatefulWidget {
  @override
  _UrunYonetimiScreenState createState() => _UrunYonetimiScreenState();
}

class _UrunYonetimiScreenState extends State<UrunYonetimi> {
  List products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    setState(() {
      isLoading = true;
    });

    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('products').get();
      final firebaseProducts = querySnapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>
      }).toList();

      if (mounted) {
        setState(() {
          products = firebaseProducts;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      showErrorDialog('Ürünler yüklenemedi. Hata: $e');
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

  Future<void> deleteProduct(String productId, String productName) async {
    try {
      await FirebaseFirestore.instance.collection('products').doc(productId).delete();
      setState(() {
        products.removeWhere((product) => product['id'] == productId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$productName başarıyla silindi.')),
      );
    } catch (e) {
      showErrorDialog('Ürün silinirken hata oluştu. Hata: $e');
    }
  }

  void addNewProduct() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NewProductScreen()),
    ).then((_) {
      fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ürün Listesi'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          final imageUrl = product['image'] ?? '';
          final title = product['title'] ?? 'Bilgi Yok';
          final category = product['category'] ?? 'Bilgi Yok';

          return ListTile(
            leading: imageUrl.isNotEmpty
                ? Image.network(imageUrl)
                : Icon(Icons.image, size: 50),
            title: Text(title),
            subtitle: Text(category),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProductScreen(product: product),
                      ),
                    ).then((updated) {
                      if (updated != null && updated) {
                        fetchProducts();
                      }
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Ürünü Sil'),
                          content: Text('Bu ürünü silmek istediğinize emin misiniz?'),
                          actions: <Widget>[
                            TextButton(
                              child: Text('İptal'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text('Sil'),
                              onPressed: () {
                                Navigator.of(context).pop();
                                deleteProduct(product['id'], title);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewProduct,
        child: Icon(Icons.add),
        backgroundColor: Colors.pink,
      ),
    );
  }
}
