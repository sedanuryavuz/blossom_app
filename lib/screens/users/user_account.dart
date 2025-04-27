import 'package:blossom_app/screens/users/order_service.dart';
import 'package:flutter/material.dart';
import '../../services/functions.dart';
import '../../services/auth_services.dart'; // AuthService importu
import 'user_details_screen.dart';
import 'address_details_screen.dart';
import 'new_card_screen.dart';
import 'change_password_screen.dart';
import 'change_email_screen.dart';
import 'cart_details_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: UserProfileScreen(),
    );
  }
}

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final AuthService _authService = AuthService();
  String _userName = '';
  List<String> _orderIds = []; // Sipariş ID'lerini saklamak için

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _fetchOrderIds(); // Sipariş ID'lerini almak için çağırıyoruz
  }

  Future<void> _fetchUserName() async {
    try {
      String userName = await _authService.getUserName();
      setState(() {
        _userName = userName;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kullanıcı adı alınırken bir hata oluştu: $e')),
      );
    }
  }

  Future<void> _fetchOrderIds() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid; //Mevcut kullanıcı IDsi
      final querySnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: userId) //Kullanıcıya ait siparişler
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          _orderIds = querySnapshot.docs.map((doc) => doc.id).toList(); //Sipariş ID'lerini listeye ekle
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bu kullanıcıya ait sipariş bulunamadı.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sipariş ID’leri alınırken bir hata oluştu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kullanıcı Profili'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: const Color.fromARGB(255, 255, 231, 240),
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Merhaba, $_userName',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      final userId = FirebaseAuth.instance.currentUser?.uid;
                      if (userId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderDetailScreen(userId: userId), // userId gönderiliyor
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Kullanıcı bulunamadı.')),
                        );
                      }
                    },
                    child: const Text(
                      'Siparişleri Görüntüle',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(157, 255, 106, 156),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),

                ],
              ),
            ),
            buildListTile(context, Icons.person, 'Kullanıcı Bilgilerim', KullaniciBilgileriEkrani()),
            buildListTile(context, Icons.location_on, 'Adres Bilgilerim', AddressDetailsScreen()),
            buildListTile(context, Icons.credit_card, 'Kayıtlı Kartlarım', MevcutKartlarScreen()),
            buildListTile(context, Icons.lock, 'Şifre Değişikliği', SifreDegistirScreen()),
            buildListTile(context, Icons.mail_rounded, 'E-Posta Değişikliği', ChangeEmailScreen()),
            buildListTile(context, Icons.exit_to_app, 'Çıkış Yap', null),
          ],
        ),
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
