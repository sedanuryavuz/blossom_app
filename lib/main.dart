import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/main/bottom_navigation_bar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async{
  /* StatefulWidget:  değişen bir kullanıcı arayüzü bileşeni demektir
 *StatelessWidget:  değişmeyen bir kullanıcı arayüzü bileşenidir
 * */
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load();
 runApp(MaterialApp(

  home:
  BottomNavScreen(),
)
  );
}

/*
* */










