import 'dart:async';
import 'package:blossom_app/screens/users/user_details_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:blossom_app/services/auth_services.dart';
import 'package:blossom_app/screens/users/user_account.dart';
import 'package:blossom_app/screens/main/login_screen.dart';
import 'package:blossom_app/screens/admin/main.dart';
import 'package:blossom_app/screens/main/bottom_navigation_bar.dart';
import 'package:blossom_app/screens/main/home_screen.dart';
import 'package:blossom_app/screens/admin/kategori_yonetimi.dart';

Future<bool> kayitOl({
  required BuildContext context,
  required String name,
  required String surname,
  required String email,
  required String phone,
  required String password,
  required AuthService authService,
}) async {
  if (name.isEmpty ||
      surname.isEmpty ||
      email.isEmpty ||
      phone.isEmpty ||
      password.isEmpty) {
    _showErrorDialog(context, 'Lütfen tüm alanları doldurun.');
    return false;
  } else if (!RegExp(r'^\+?0[0-9]{10}$').hasMatch(phone)) {
    _showErrorDialog(context, 'Geçerli bir telefon numarası girin.');
    return false;
  }

  try {
    User? user = await authService.registerUser(
      name: name,
      surname: surname,
      email: email,
      phone: phone,
      password: password,
    );

    if (user != null) {
      _showSuccessDialog(context, 'Kayıt başarılı!');
      return true;
    } else {
      _showErrorDialog(context, 'Kayıt işlemi başarısız oldu.');
    }
  } on FirebaseAuthException catch (e) {
    // FirebaseAuthException hatalarını işler
    if (e.code == 'email-already-in-use') {
      _showErrorDialog(context, 'Bu e-posta adresi zaten kullanımda.');
    } else if (e.code == 'weak-password') {
      _showErrorDialog(context, 'Şifre çok zayıf.');
    } else if (e.code == 'invalid-email') {
      _showErrorDialog(context, 'Geçersiz email adresi.');
    } else {
      _showErrorDialog(context, 'Bir hata oluştu: ${e.message}');
    }
  } catch (e) {
    // Diğer hataları işler
    _showErrorDialog(context, 'Bir hata oluştu: ${e.toString()}');
  }
  return false;
}


Future<void> girisYap({
  required BuildContext context,
  required String email,
  required String password,
  required AuthService authService,
}) async {
  if (email.isEmpty || password.isEmpty) {
    _showErrorDialog(context, "E-posta adresi veya şifre boş olamaz");
    return;
  }

  try {
    User? user = await authService.loginUser(
      email: email,
      password: password,
    );

    if (user != null) {
      const String adminId = '5tEWjZJw88McpagWxKUOmcpFRpj2';

      if (user.uid == adminId) {
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminScreen(),
            ),
          );
        }
      } else {
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => UserProfileScreen(),
            ),
          );
        }
      }
    }
  } on FirebaseAuthException catch (e) {
    if (context.mounted) {
      String errorMessage = _getErrorMessage(e);
      _showErrorDialog(context, errorMessage);
    }
  } catch (e) {
    if (context.mounted) {
      _showErrorDialog(context, "Giriş başarısız: ${e.toString()}");
    }
  }
}

String _getErrorMessage(FirebaseAuthException e) {
  switch (e.code) {
    case 'user-not-found':
      return "Kayıtlı kullanıcı bulunamadı";
    case 'wrong-password':
      return "E-posta veya şifre hatalı";
    case 'invalid-email':
      return "Geçersiz e-posta adresi formatı";
    case 'user-disabled':
      return "Bu kullanıcı hesabı devre dışı bırakıldı";
    case 'too-many-requests':
      return "Çok fazla giriş denemesi. Lütfen daha sonra tekrar deneyin.";
    case 'operation-not-allowed':
      return "Bu giriş yöntemi devre dışı bırakıldı.";
    default:
      return "Bir hata oluştu. Hata kodu: ${e.code}\nMesaj: ${e.message}";
  }
}




void cikisYap(BuildContext context) {
  _showAlertDialogYesOrNo(context, "Çıkış yapmak istediğinize emin misiniz?", (value) async {
    if (value == 'OK') {
      FirebaseAuth auth = FirebaseAuth.instance;
      await auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  });
}

Future<void> kartSil(BuildContext context, String kartId) async {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? user = _auth.currentUser;
  if (user != null) {
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cards')
        .doc(kartId)
        .delete();
  }
}

Future<void> kartGuncelle(
    BuildContext context,
    String kartId,
    String cardNumber,
    String cardHolder,
    String expiryDate,
    String cvv,
    ) async {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? user = _auth.currentUser;
  if (user != null) {
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cards')
        .doc(kartId)
        .update({
      'cardNumber': cardNumber,
      'cardHolder': cardHolder,
      'expiryDate': expiryDate,
      'cvv': cvv,
    });
  }
}

Widget deleteItems() {
  return Container(
    color: Colors.red,
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.symmetric(horizontal: 20.0),
    child: const Icon(
      Icons.delete,
      color: Colors.white,
    ),
  );
}

Future<void> adresGuncelle(
    BuildContext context,
    String docId,
    String yeniAdresDetayi,
    String yeniAdresBasligi,
    String yeniAdresIli,
    String yeniAdresIlcesi,
    String yeniAdresMahallesi,
    ) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('addresses')
        .doc(docId)
        .update({
      'addressTitle': yeniAdresBasligi,
      'address': yeniAdresDetayi,
      'city': yeniAdresIli,
      'district': yeniAdresIlcesi,
      'neighborhood': yeniAdresMahallesi,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Adres başarıyla güncellendi'),
      ),
    );
  }
}

void _showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 10),
            Text("Hata"),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            child: Text("Tamam"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

void _showAlertDialogYesOrNo(BuildContext context, String message, Function(String) onResult) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Row(
          children: [
            SizedBox(width: 10),
            Text("Blossom"),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, 'Cancel');
              onResult('Cancel');
            },
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, 'OK');
              onResult('OK');
            },
            child: const Text('Çıkış Yap'),
          ),
        ],
      );
    },
  );
}

void _showSuccessDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Başarılı'),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Tamam'),
        ),
      ],
    ),
  );
}

Future<void> toggleFavorite(BuildContext context, String productId, bool isFavorite) async {
  final user = FirebaseAuth.instance.currentUser;
  print("Current User: $user");

  if (user == null) {

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Lütfen giriş yapın.')),
    );
    return;
  }

  final favoritesRef = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('favorites')
      .doc(productId);

  try {
    if (isFavorite) {

      await favoritesRef.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ürün favorilerden çıkarıldı.')),
      );
    } else {

      await favoritesRef.set({});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ürün favorilere eklendi.')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Hata: ${e.toString()}')),
    );
  }
}


class KategoriService {
final FirebaseFirestore _db = FirebaseFirestore.instance;

Future<void> kategoriEkle(String kategoriAdi) async {
  await _db.collection('category').add({
    'isim': kategoriAdi,
  });
}

Future<void> kategoriSil(String kategoriId) async {
  await _db.collection('category').doc(kategoriId).delete();
}

Future<void> kategoriDuzenle(String kategoriId, String yeniKategoriAdi) async {
  await _db.collection('category').doc(kategoriId).update({
      'isim': yeniKategoriAdi,
  });
}
}


Future<List<Map<String, dynamic>>> searchProducts(String category, String searchQuery) async {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  try {
    Query query = _firestore.collection('products');

    /*if (category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }*/


    if (searchQuery.isNotEmpty) {
      query = query
          .where('name', isGreaterThanOrEqualTo: searchQuery)
          .where('name', isLessThanOrEqualTo: '$searchQuery\uf8ff');
    }

    QuerySnapshot querySnapshot = await query.get();

    return querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = Map<String, dynamic>.from(doc.data() as Map);
      return data;
    }).toList();
  } catch (e) {
    print('Ürün araması sırasında hata oluştu: $e');
    return [];
  }
}


Future<Map<String, dynamic>?> fetchUserDetails() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;

  final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  return userDoc.data();
}

Future<void> saveOrder(String userId, Map<String, dynamic> orderData) async {
  await FirebaseFirestore.instance.collection('orders').add(orderData);
}

void showOrderCompletionNotification(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Sipariş tamamlandı!')),
  );
}