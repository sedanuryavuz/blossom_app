import 'package:blossom_app/services/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SifreDegistirScreen extends StatefulWidget {
  @override
  _SifreDegistirScreenState createState() => _SifreDegistirScreenState();
}

class _SifreDegistirScreenState extends State<SifreDegistirScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Şifre Değiştir'),
        backgroundColor: Colors.pink.shade100,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SifreDegistirFormu(),
      ),
    );
  }
}

class SifreDegistirFormu extends StatefulWidget {
  @override
  _SifreDegistirFormuState createState() => _SifreDegistirFormuState();
}

class _SifreDegistirFormuState extends State<SifreDegistirFormu> {
  final _formKey = GlobalKey<FormState>();
  final _eskiSifreController = TextEditingController();
  final _yeniSifreController = TextEditingController();
  final _yeniSifreTekrarController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _isObscureOldPassword = true;
  bool _isObscureNewPassword = true;
  bool _isObscureConfirmNewPassword = true;

  @override
  void dispose() {
    _eskiSifreController.dispose();
    _yeniSifreController.dispose();
    _yeniSifreTekrarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: 20.0),
          _buildPasswordField(_eskiSifreController, 'Eski Şifre', _isObscureOldPassword, (value) {
            setState(() {
              _isObscureOldPassword = value;
            });
          }),
          const SizedBox(height: 10.0),
          _buildPasswordField(_yeniSifreController, 'Yeni Şifre', _isObscureNewPassword, (value) {
            setState(() {
              _isObscureNewPassword = value;
            });
          }),
          const SizedBox(height: 10.0),
          _buildPasswordField(_yeniSifreTekrarController, 'Yeni Şifre (Tekrar)', _isObscureConfirmNewPassword, (value) {
            setState(() {
              _isObscureConfirmNewPassword = value;
            });
          }),
          const SizedBox(height: 10.0),
          ElevatedButton(
            onPressed: _isLoading ? null : _changePassword,
            child: _isLoading
                ? CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            )
                : Text('Şifreyi Değiştir', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink.shade100,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String labelText, bool obscureText, ValueChanged<bool> onToggle) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 241, 237, 237),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(Icons.lock, color: Colors.pink),
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility ,
              color: Colors.pink,
            ),
            onPressed: () => onToggle(!obscureText),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
        ),
        validator: (value) {
          if (value!.isEmpty) {
            return 'Lütfen $labelText girin';
          }
          return null;
        },
      ),
    );
  }

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        await _authService.sifreDegistir(
          _eskiSifreController.text,
          _yeniSifreController.text,
          _yeniSifreTekrarController.text,
        );
        _showSuccessDialog(context, 'Şifre başarıyla değiştirildi.');
        // Textfield'ları sıfırla
        _eskiSifreController.clear();
        _yeniSifreController.clear();
        _yeniSifreTekrarController.clear();
      } on FirebaseAuthException catch (e) {
        _showErrorDialog(context, e.message ?? 'Bir hata oluştu.');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hata'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Tamam'),
          ),
        ],
      ),
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
            onPressed: () {
              Navigator.of(context).pop();

            },
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}
