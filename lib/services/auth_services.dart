import 'dart:convert';
import 'package:blossom_app/screens/admin/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';


import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
class AuthService {
  FirebaseAuth _auth = FirebaseAuth.instance;
  final userCollection = FirebaseFirestore.instance.collection("users");



  Future<User?> registerUser({
    required String name,
    required String surname,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      // Kullanıcıyı kaydetme işlemi
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;


      if (user != null) {
        await userCollection.doc(user.uid).set({
          "email": email,
          "name": name,
          "surname": surname,
          "phone": phone,
        });
        return user;
      } else {
        return null;
      }
    } on FirebaseAuthException catch (e) {

      throw e;
    } catch (e) {

      throw e;
    }
  }


  Future<User?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print('Giriş sırasında bir hata oluştu: $e');
      rethrow;
    }
  }

  Future<void> sifreDegistir(
      String eskiSifre,
      String yeniSifre,
      String yeniSifreTekrar,
      ) async {
    User? user = _auth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Kullanıcı bulunamadı.',
      );
    }

    if (yeniSifre != yeniSifreTekrar) {
      throw FirebaseAuthException(
        code: 'password-mismatch',
        message: 'Yeni şifreler eşleşmiyor.',
      );
    }

    AuthCredential credential = EmailAuthProvider.credential(
      email: user.email!,
      password: eskiSifre,
    );

    try {
      await user.reauthenticateWithCredential(credential);

      if (yeniSifre.length < 6) {
        throw FirebaseAuthException(
          code: 'weak-password',
          message: 'Şifre çok zayıf. Şifre en az 6 karakter olmalı.',
        );
      }

      if (eskiSifre == yeniSifre) {
        throw FirebaseAuthException(
          code: 'same-password',
          message: 'Yeni şifre eski şifre ile aynı olamaz.',
        );
      }

      await user.updatePassword(yeniSifre);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        print('Eski şifre yanlış.');
      } else {
        print('Şifre değiştirme sırasında bir hata oluştu: ${e.message}');
      }
      rethrow;
    } catch (e) {
      print('Bilinmeyen bir hata oluştu: $e');
      rethrow;
    }
  }

  Future<String?> mevcutEmailiAl() async {
    User? kullanici = _auth.currentUser;
    if (kullanici == null) {
      return null;
    }
    DocumentSnapshot kullaniciDoc = await userCollection.doc(kullanici.uid).get();
    return kullaniciDoc['email'] ?? '';
  }

  Future<void> emailGuncelle(String yeniEmail) async {
    User? kullanici = _auth.currentUser;

    if (kullanici == null) {
      throw Exception('Kullanıcı bulunamadı.');
    }

    if (kullanici.email == yeniEmail) {
      throw Exception('Yeni e-posta adresi mevcut e-posta ile aynı olamaz.');
    }

    try {
      await kullanici.updateEmail(yeniEmail);


      await userCollection.doc(kullanici.uid).update({
        'email': yeniEmail,
      });
    } catch (e) {
      throw Exception('E-Posta adresi değiştirilemedi: $e');
    }
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Kullanıcı adını Firestore'dan al
  Future<String> getUserName() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      return userDoc['name'] ?? 'Kullanıcı';
    }
    return 'Kullanıcı';
  }
}




