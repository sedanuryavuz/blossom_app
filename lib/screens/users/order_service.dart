import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderDetailScreen extends StatefulWidget {
  final String userId;

  OrderDetailScreen({required this.userId});

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: widget.userId)
          .get();
      final orders = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'data': doc.data(),
        };
      }).toList();
      setState(() {
        _orders = orders;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veri alma hatası: $e')),
      );
    }
  }

  Future<void> _submitReturnRequest(String orderId) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({'returnRequest': true});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('İade talebiniz alındı')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Talep oluşturma hatası: $e')),
      );
    }
  }

  Future<void> _submitCancelRequest(String orderId) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({'cancelRequest': true});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('İptal talebiniz alındı')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Talep oluşturma hatası: $e')),
      );
    }
  }

  Future<void> _withdrawCancelRequest(String orderId) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({'cancelRequest': FieldValue.delete()});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('İptal talebiniz geri alındı')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Talep geri alma hatası: $e')),
      );
    }
  }

  Future<void> _withdrawReturnRequest(String orderId) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({'returnRequest': FieldValue.delete()});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('İade talebiniz geri alındı')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Talep geri alma hatası: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sipariş Detayı'),
      ),
      body: _orders.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          final orderData = order['data'];
          final items = (orderData['items'] as List<dynamic>).map((item) {
            final data = item as Map<String, dynamic>;
            return ListTile(
              leading: data['imageUrl'] != null
                  ? Image.network(data['imageUrl'])
                  : Icon(Icons.image),
              title: Text(data['productName']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Fiyat: ₺${data['price']}'),
                  Text('Beden: ${data['size']}'),
                  Text('Renk: ${data['color']}'),
                  Text('Adet: ${data['quantity']}'),
                ],
              ),
            );
          }).toList();

          return ExpansionTile(
            title: Text(
                'Sipariş ${index + 1} - Toplam: ₺${orderData['totalAmount'].toStringAsFixed(2)}'),
            children: [
              ...items,
              ListTile(
                title: Text('Durum: ${orderData['status']}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (orderData['returnRequest'] == true)
                      Text('İade Talebi: Alındı'),
                    if (orderData['cancelRequest'] == true)
                      Text('İptal Talebi: Alındı'),
                  ],
                ),
              ),
              if (orderData['status'] == 'Teslim Edildi' &&
                  orderData['returnRequest'] != true)
                ListTile(
                  title: ElevatedButton(
                    onPressed: () => _submitReturnRequest(order['id']),
                    child: Text('İade Talebi Oluştur'),
                  ),
                ),
              if (orderData['status'] != 'Cancelled' &&
                  orderData['cancelRequest'] != true)
                ListTile(
                  title: ElevatedButton(
                    onPressed: () => _submitCancelRequest(order['id']),
                    child: Text('İptal Talebi Oluştur'),
                  ),
                ),
              if (orderData['cancelRequest'] == true)
                ListTile(
                  title: ElevatedButton(
                    onPressed: () => _withdrawCancelRequest(order['id']),
                    child: Text('İptal Talebini Geri Al'),
                  ),
                ),
              if (orderData['returnRequest'] == true)
                ListTile(
                  title: ElevatedButton(
                    onPressed: () => _withdrawReturnRequest(order['id']),
                    child: Text('İade Talebini Geri Al'),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
