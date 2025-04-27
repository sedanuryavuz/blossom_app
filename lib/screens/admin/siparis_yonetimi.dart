import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models.dart';
import 'siparis_detay.dart';

class SiparisYonetimi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sipariş Yönetimi'),
        backgroundColor: Colors.pink.shade300,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Bir hata oluştu!',
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('Veri yok'));
          }

          var siparisList = snapshot.data!.docs
              .map((doc) => MyOrder.fromFirestore(doc))
              .toList();

          return ListView.builder(
            itemCount: siparisList.length,
            itemBuilder: (context, index) {
              var siparis = siparisList[index];
              return Card(
                margin: EdgeInsets.all(8.0),
                elevation: 4.0,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sipariş ${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Adres: ${siparis.address.address}',
                        style: TextStyle(color: Colors.black54),
                      ),
                      Text(
                        'Kart ID: ${siparis.card.cardNumber}',
                        style: TextStyle(color: Colors.black54),
                      ),
                      Text(
                        'Tarih: ${siparis.timestamp.toDate()}',
                        style: TextStyle(color: Colors.black54),
                      ),
                      Text(
                        'Tutar: ${siparis.totalAmount.toStringAsFixed(2)} ₺',
                        style: TextStyle(color: Colors.black54),
                      ),
                      Text(
                        'Kullanıcı ID: ${siparis.userId}',
                        style: TextStyle(color: Colors.black54),
                      ),
                      Text(
                        'Durum: ${siparis.status}',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SiparisDetay(siparis: siparis),
                            ),
                          );
                        },
                        child: Text('Detayları Görüntüle'),
                      ),
                      SizedBox(height: 16.0),
                      DropdownButton<String>(
                        value: siparis.status,
                        onChanged: (newStatus) async {
                          if (newStatus != null && newStatus != siparis.status) {
                            try {
                              await siparis.updateStatus(newStatus);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Durum güncellendi'),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Durum güncelleme hatası: $e'),
                                ),
                              );
                            }
                          }
                        },
                        items: <String>[
                          'Sipariş Oluşturuldu',
                          'Sipariş Hazırlanıyor',
                          'Kargoya Verildi',
                          'Teslim Edildi',
                          'İade Talebi Oluşturuldu',
                          'İptal Talebi Oluşturuldu',
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
