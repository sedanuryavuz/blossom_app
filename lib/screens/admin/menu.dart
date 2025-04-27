import 'package:blossom_app/screens/admin/order_tracking_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'kategori_yonetimi.dart';
import 'siparis_yonetimi.dart';
import 'urun_yonetimi.dart';
import 'package:blossom_app/screens/users/change_password_screen.dart';
import 'package:blossom_app/services/functions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<Map<String, dynamic>> _fetchStatistics() async {
    final firestore = FirebaseFirestore.instance;

    //Kullanıcı sayısı
    final userCountSnapshot = await firestore.collection('users').count().get();
    final userCount = userCountSnapshot.count;

    //Sipariş sayısı
    final orderCountSnapshot = await firestore.collection('orders').count().get();
    final orderCount = orderCountSnapshot.count;

    //Kategori sayısı
    final categoryCountSnapshot = await firestore.collection('category').count().get();
    final categoryCount = categoryCountSnapshot.count;

    //Ürün sayısı
    final productCountSnapshot = await firestore.collection('products').count().get();
    final productCount = productCountSnapshot.count;

    //Toplam kazanc
    final earningsSnapshot = await firestore.collection('earnings').doc('total').get();
    final earnings = earningsSnapshot.data()?['total'] ?? '0';

    return {
      'userCount': userCount,
      'orderCount': orderCount,
      'categoryCount': categoryCount,
      'productCount': productCount,
      'earnings': earnings,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('blossom'),
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 211, 225),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(
                child: Text(
                  'Menü',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            buildListTile(context, Icons.home, 'Ana Sayfa', const HomeScreen()),
            buildListTile(context, Icons.category, 'Kategoriler', KategoriEkrani()),
            buildListTile(context, Icons.archive_rounded, 'Ürünler', UrunYonetimi()),
            buildListTile(context, Icons.shopping_cart, 'Siparişler', SiparisYonetimi()),
            buildListTile(context, Icons.undo, 'İadeler', SiparisIadeleri()),
            buildListTile(context, Icons.settings, 'Ayarlar', SifreDegistirScreen()),
            const Spacer(),
            buildListTile(context, Icons.exit_to_app, 'Çıkış Yap', null),
          ],
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchStatistics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            return GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16.0),
              crossAxisSpacing: 20.0,
              mainAxisSpacing: 20.0,
              children: [
                AnaSayfa(
                  baslik: 'Kayıtlı Kullanıcı Sayısı',
                  sayi: data['userCount'].toString(),
                  icon: Icons.person,
                ),
                AnaSayfa(
                  baslik: 'Toplam Sipariş Sayısı',
                  sayi: data['orderCount'].toString(),
                  icon: Icons.shopping_cart,
                ),
                AnaSayfa(
                  baslik: 'Toplam Kategori Sayısı',
                  sayi: data['categoryCount'].toString(),
                  icon: Icons.category,
                ),
                AnaSayfa(
                  baslik: 'Toplam Ürün Sayısı',
                  sayi: data['productCount'].toString(),
                  icon: Icons.shopping_basket,
                ),
                AnaSayfa(
                  baslik: 'Toplam Kazanç',
                  sayi: '${data['earnings']} ₺',
                  icon: Icons.attach_money,
                ),
              ],
            );
          } else {
            return Center(child: Text('Veri bulunamadı.'));
          }
        },
      ),
    );
  }

  Widget buildListTile(
      BuildContext context, IconData icon, String title, Widget? targetScreen) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.pink),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right, color: Colors.pink),
        onTap: () {
          if (targetScreen != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => targetScreen),
            );
          } else {
            cikisYap(context);
          }
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        tileColor: Colors.white,
        selectedTileColor: Colors.pink.shade50,
      ),
    );
  }
}

class AnaSayfa extends StatelessWidget {
  final String baslik;
  final String sayi;
  final IconData icon;

  const AnaSayfa({
    required this.baslik,
    required this.sayi,
    required this.icon,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.pink.shade100,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 40.0, color: Colors.white),
          const SizedBox(height: 10.0),
          Text(
            baslik,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          const SizedBox(height: 5.0),
          Text(
            sayi,
            style: const TextStyle(color: Colors.white, fontSize: 19.0),
          ),
        ],
      ),
    );
  }
}
