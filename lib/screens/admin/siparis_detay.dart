import 'package:flutter/material.dart';
import 'models.dart';

class SiparisDetay extends StatelessWidget {
  final MyOrder siparis;

  SiparisDetay({required this.siparis});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sipariş Detayı'),
        backgroundColor: Colors.pink.shade300,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Adres: ${siparis.address.address}', style: TextStyle(fontSize: 16)),
            Text('Kart ID: ${siparis.card.cardNumber}', style: TextStyle(fontSize: 16)),
            Text('Tarih: ${siparis.timestamp.toDate()}', style: TextStyle(fontSize: 16)),
            Text('Tutar: ${siparis.totalAmount.toStringAsFixed(2)} ₺', style: TextStyle(fontSize: 16)),
            Text('Kullanıcı ID: ${siparis.userId}', style: TextStyle(fontSize: 16)),
            Text('Durum: ${siparis.status}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 16.0),
            Text('Ürünler:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: siparis.items.length,
                itemBuilder: (context, index) {
                  var item = siparis.items[index];
                  return ListTile(
                    title: Text(item.productName),
                    subtitle: Text('Renk: ${item.color}, Beden: ${item.size}, Miktar: ${item.quantity}, Fiyat: ${item.price.toStringAsFixed(2)} ₺'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
