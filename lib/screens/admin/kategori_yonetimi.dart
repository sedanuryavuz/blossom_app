// KategoriEkrani.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:blossom_app/services/auth_services.dart';
import 'package:blossom_app/services/functions.dart';


class KategoriEkrani extends StatefulWidget {
  const KategoriEkrani({Key? key}) : super(key: key);

  @override
  State<KategoriEkrani> createState() => _KategoriEkraniState();
}

class _KategoriEkraniState extends State<KategoriEkrani> {
  final KategoriService _authService = KategoriService();

  void _kategoriEkleDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Yeni Kategori Ekle'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Kategori adı'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('İptal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Ekle'),
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  _authService.kategoriEkle(controller.text);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _kategoriDuzenleDialog(BuildContext context, String kategoriId, String currentName) {
    final TextEditingController controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Kategori Düzenle'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Kategori adı'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('İptal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Kaydet'),
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  _authService.kategoriDuzenle(kategoriId, controller.text);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _kategoriSilDialog(BuildContext context, String kategoriId, String kategoriIsmi) async {
    bool? isConfirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Kategori Sil'),
          content: const Text('Bu kategoriyi silmek istediğinizden emin misiniz?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Hayır'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Evet'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (isConfirmed == true) {
      try {
        await _authService.kategoriSil(kategoriId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$kategoriIsmi başarıyla silindi.')),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: ${error.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategoriler'),
        backgroundColor: Colors.pink.shade100,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('category').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No categories found.'));
          }

          final categories = snapshot.data!.docs;

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final doc = categories[index];
              final kategoriId = doc.id;
              final kategoriIsmi = doc['isim'];

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(
                    kategoriIsmi,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _kategoriDuzenleDialog(context, kategoriId, kategoriIsmi);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _kategoriSilDialog(context, kategoriId, kategoriIsmi);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _kategoriEkleDialog(context),
        child: const Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}