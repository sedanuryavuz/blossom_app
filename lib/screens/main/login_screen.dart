import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'package:blossom_app/services/auth_services.dart';
import 'package:blossom_app/screens/users/user_account.dart';
import 'package:blossom_app/services/functions.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _temail = TextEditingController();
  final TextEditingController _tpassword = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _temail.dispose();
    _tpassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              Colors.pink.shade200,
              Colors.pink.shade100,
              Colors.pink.shade50,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 80),
            const Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Giriş Yap",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontFamily: "Nunito2"),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Tekrardan Hoşgeldin",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: "Nunito3"),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(225, 95, 27, .3),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom:
                                  BorderSide(color: Colors.grey.shade200),
                                ),
                              ),
                              child: TextField(
                                controller: _temail,
                                decoration: const InputDecoration(
                                  hintText: "Email ",
                                  hintStyle: TextStyle(
                                      color: Colors.grey,
                                      fontFamily: "Nunito2"),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom:
                                  BorderSide(color: Colors.grey.shade200),
                                ),
                              ),
                              child: TextField(
                                controller: _tpassword,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  hintText: "Şifre",
                                  hintStyle: TextStyle(
                                      color: Colors.grey,
                                      fontFamily: "Nunito2"),
                                  border: InputBorder.none,
                                ),
                                onSubmitted: (value) async {
                                  await _keyPressLogin(context);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      MaterialButton(
                        onPressed: () async {
                          await _keyPressLogin(context);
                          //enter tusuna basıldıgında ekrandaki yazıların sıfırlanmaması icin
                        },
                        height: 50,
                        color: Colors.pink[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Center(
                          child: Text(
                            "Giriş Yap",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Nunito3"),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text("Hala bir hesabın yok mu?",
                              style: TextStyle(fontFamily: "Nunito3")),
                          const SizedBox(width: 5),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        RegisterScreen()),
                              );
                            },
                            child: const Text(
                              "Kayıt Ol",
                              style: TextStyle(
                                  color: Colors.pink,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Nunito2"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _keyPressLogin(BuildContext context) async {
    await girisYap(
      context: context,
      email: _temail.text,
      password: _tpassword.text,
      authService: _authService,
    );
  }
}
