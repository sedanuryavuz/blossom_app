import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Map<String, dynamic>> _cartItems = [];
  double _totalAmount = 0.0;
  Map<String, dynamic>? _selectedCard;
  Map<String, dynamic>? _selectedAddress;

  @override
  void initState() {
    super.initState();
    _fetchCartItems();
    _fetchUserDetails();
  }

  Future<void> _fetchCartItems() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen giriş yapın.')),
      );
      return;
    }

    final cartSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .get();

    final cartItems = cartSnapshot.docs.map((doc) {
      final data = doc.data();
      final price = data['price'] as double;
      final quantity = data['quantity'] as int;
      _totalAmount += price * quantity;
      return {
        'id': doc.id,
        'productName': data['productName'],
        'price': price,
        'size': data['size'],
        'color': data['color'],
        'quantity': quantity,
      };
    }).toList();

    setState(() {
      _cartItems = cartItems;
    });
  }

  Future<void> _fetchUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen giriş yapın.')),
      );
      return;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final userData = userDoc.data();
    if (userData != null) {
      setState(() {
        _selectedCard = userData['selectedCard'];
        _selectedAddress = userData['selectedAddress'];
      });
    }
  }

  void _urunMiktariArttir(int index) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final cartItem = _cartItems[index];
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(cartItem['id']);

    setState(() {
      cartItem['quantity'] += 1;
      _totalAmount += cartItem['price'];
    });

    await docRef.update({'quantity': cartItem['quantity']});
  }

  void _decreaseQuantity(int index) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final cartItem = _cartItems[index];
    if (cartItem['quantity'] > 1) {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .doc(cartItem['id']);

      setState(() {
        cartItem['quantity'] -= 1;
        _totalAmount -= cartItem['price'];
      });

      await docRef.update({'quantity': cartItem['quantity']});
    }
  }

  void _selectCard() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final cardDocs = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cards')
        .get();

    if (cardDocs.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen bir kart ekleyin.')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          itemCount: cardDocs.docs.length,
          itemBuilder: (context, index) {
            final cardData = cardDocs.docs[index].data();
            return ListTile(
              title: Text('Kart: ${cardData['cardNumber']}'),
              onTap: () {
                setState(() {
                  _selectedCard = cardData;
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  void _selectAddress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final addressDocs = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('addresses')
        .get();

    if (addressDocs.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen önce bir adres ekleyin.')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          itemCount: addressDocs.docs.length,
          itemBuilder: (context, index) {
            final addressData = addressDocs.docs[index].data();
            return ListTile(
              title: Text('Adres: ${addressData['address']}'),
              onTap: () {
                setState(() {
                  _selectedAddress = addressData;
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  void _completeOrder() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen giriş yapın.')),
      );
      return;
    }

    if (_selectedCard == null || _selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen kart ve adres bilgilerini seçin.')),
      );
      return;
    }

    try {
      final orderRef = FirebaseFirestore.instance.collection('orders').doc();
      await orderRef.set({
        'userId': user.uid,
        'items': _cartItems,
        'totalAmount': _totalAmount,
        'card': _selectedCard,
        'address': _selectedAddress,
        'createdAt': Timestamp.now(),
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .get()
          .then((snapshot) {
        for (DocumentSnapshot ds in snapshot.docs) {
          ds.reference.delete();
        }
      });

      setState(() {
        _cartItems.clear();
        _totalAmount = 0.0;
        _selectedCard = null;
        _selectedAddress = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sipariş tamamlandı!')),
      );

      Future.delayed(Duration(seconds: 3), () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sipariş oluşturuldu!')),
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sipariş tamamlama hatası: $e')),
      );
    }
  }

  void _refresh() {
    setState(() {
      _fetchCartItems();
      _fetchUserDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sepetim'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _cartItems.length,
              itemBuilder: (context, index) {
                final item = _cartItems[index];
                return ListTile(
                  title: Text(item['productName']),
                  subtitle: Text(
                      '₺${item['price']} - ${item['size']} - ${item['color']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () => _decreaseQuantity(index),
                      ),
                      Text('${item['quantity']}'),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () => _urunMiktariArttir(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Toplam: ₺${_totalAmount.toStringAsFixed(2)}'),
                SizedBox(height: 8.0),
                ElevatedButton(
                  onPressed: _selectCard,
                  child: Text(_selectedCard != null
                      ? 'Kart: ${_selectedCard!['cardNumber']}'
                      : 'Kart Seç'),
                ),
                ElevatedButton(
                  onPressed: _selectAddress,
                  child: Text(_selectedAddress != null
                      ? 'Adres: ${_selectedAddress!['address']}'
                      : 'Adres Seç'),
                ),
                ElevatedButton(
                  onPressed: _completeOrder,
                  child: Text('Siparişi Tamamla'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
