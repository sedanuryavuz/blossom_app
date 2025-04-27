import 'package:blossom_app/services/functions.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'package:blossom_app/services/auth_services.dart';

class RegisterScreen extends StatefulWidget {
  RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _tname = TextEditingController();
  final TextEditingController _tsname = TextEditingController();
  final TextEditingController _temail = TextEditingController();
  final TextEditingController _tTelNo = TextEditingController();
  final TextEditingController _tpassword = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _tname.dispose();
    _tsname.dispose();
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
            const SizedBox(height: 60),
            const Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Kayıt Ol",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontFamily: "Nunito2",
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Hesap Oluştur",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: "Nunito3",
                    ),
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
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                              ),
                              child: TextFormField(
                                controller: _tname,
                                decoration: const InputDecoration(
                                  hintText: "Ad",
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontFamily: "Nunito2",
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                              ),
                              child: TextFormField(
                                controller: _tsname,
                                decoration: const InputDecoration(
                                  hintText: "Soyad",
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontFamily: "Nunito2",
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.shade200,
                            ),
                          ),
                        ),
                        child: TextFormField(
                          controller: _temail,
                          decoration: const InputDecoration(
                            hintText: "Email",
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontFamily: "Nunito2",
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.shade200,
                            ),
                          ),
                        ),
                        child: TextFormField(
                          controller: _tTelNo,
                          decoration: const InputDecoration(
                            hintText: "Telefon Numarası",
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontFamily: "Nunito2",
                            ),
                            border: InputBorder.none,
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Lütfen bir telefon numarası girin';
                            } else if (!RegExp(r'^\+?0[0-9]{10}$').hasMatch(value)) {
                              return 'Geçerli bir telefon numarası girin';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.shade200,
                            ),
                          ),
                        ),
                        child: TextFormField(
                          controller: _tpassword,
                          obscureText: true,
                          decoration: const InputDecoration(
                            hintText: "Şifre",
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontFamily: "Nunito2",
                            ),
                            border: InputBorder.none,
                          ),
                          onFieldSubmitted: (value) async {
                            await _keyPressRegister(context);
                          },
                        ),
                      ),
                      const SizedBox(height: 40),
                      MaterialButton(
                        onPressed: () async {
                          await _keyPressRegister(context);
                        },
                        height: 50,
                        color: Colors.pink[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Center(
                          child: Text(
                            "Kayıt Ol",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Nunito3",
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text(
                            "Bir hesabın var mı?",
                            style: TextStyle(
                              fontFamily: "Nunito3",
                            ),
                          ),
                          const SizedBox(width: 5),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "Giriş Yap",
                              style: TextStyle(
                                color: Colors.pink,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Nunito2",
                              ),
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

  Future<void> _keyPressRegister(BuildContext context) async {
    bool isSuccess = await kayitOl(
      context: context,
      name: _tname.text,
      surname: _tsname.text,
      email: _temail.text,
      phone: _tTelNo.text,
      password: _tpassword.text,
      authService: _authService,
    );

    if (isSuccess) {
      //kayıt basarılı oldugunda textfield'ları temizler
      _tname.clear();
      _tsname.clear();
      _temail.clear();
      _tTelNo.clear();
      _tpassword.clear();
    }
  }

}
