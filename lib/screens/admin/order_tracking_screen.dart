import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SiparisIadeleri extends StatefulWidget {
  @override
  _SiparisIadeleriState createState() => _SiparisIadeleriState();
}

class _SiparisIadeleriState extends State<SiparisIadeleri> {
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
          .where('status', isEqualTo: 'İade Talebi Oluşturuldu') // Sadece iade talebi olan siparişleri çek
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

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({'status': newStatus});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sipariş durumu güncellendi')),
      );
      _fetchOrders(); // Güncellenmiş siparişleri tekrar çek
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Durum güncelleme hatası: $e')),
      );
    }
  }

  void _markAsReturned(String orderId) async {
    await _updateOrderStatus(orderId, 'İade Edildi');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('İade Siparişleri'),
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
              ),
              if (orderData['status'] == 'İade Talebi Oluşturuldu')
                ListTile(
                  title: ElevatedButton(
                    onPressed: () => _markAsReturned(order['id']),
                    child: Text('İade Edildi Olarak İşaretle'),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
