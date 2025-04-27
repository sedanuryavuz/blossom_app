import 'package:cloud_firestore/cloud_firestore.dart';

// Address Model
class Address {
  final String address;
  final String addressTitle;
  final String city;
  final String district;
  final String neighborhood;

  Address({
    required this.address,
    required this.addressTitle,
    required this.city,
    required this.district,
    required this.neighborhood,
  });

  factory Address.fromFirestore(Map<String, dynamic> data) {
    return Address(
      address: data['address'] as String? ?? '',
      addressTitle: data['addressTitle'] as String? ?? '',
      city: data['city'] as String? ?? '',
      district: data['district'] as String? ?? '',
      neighborhood: data['neighborhood'] as String? ?? '',
    );
  }
}

// PaymentCard Model
class PaymentCard {
  final String cardHolder;
  final String cardNumber;
  final String cvv;
  final String expiryDate;
  final Timestamp createdAt;

  PaymentCard({
    required this.cardHolder,
    required this.cardNumber,
    required this.cvv,
    required this.expiryDate,
    required this.createdAt,
  });

  factory PaymentCard.fromFirestore(Map<String, dynamic> data) {
    return PaymentCard(
      cardHolder: data['cardHolder'] as String? ?? '',
      cardNumber: data['cardNumber'] as String? ?? '',
      cvv: data['cvv'] as String? ?? '',
      expiryDate: data['expiryDate'] as String? ?? '',
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }
}

// Item Model
class Item {
  final String color;
  final String id;
  final double price;
  final String productName;
  final int quantity;
  final String size;

  Item({
    required this.color,
    required this.id,
    required this.price,
    required this.productName,
    required this.quantity,
    required this.size,
  });

  factory Item.fromFirestore(Map<String, dynamic> data) {
    return Item(
      color: data['color'] as String? ?? '',
      id: data['id'] as String? ?? '',
      price: (data['price'] as num).toDouble(),
      productName: data['productName'] as String? ?? '',
      quantity: data['quantity'] as int? ?? 0,
      size: data['size'] as String? ?? '',
    );
  }
}

// MyOrder Model
class MyOrder {
  final Address address;
  final PaymentCard card;
  final List<Item> items;
  final double totalAmount;
  final String userId;
  String status;
  final Timestamp timestamp;
  final String id;


  MyOrder({
    required this.address,
    required this.card,
    required this.items,
    required this.totalAmount,
    required this.userId,
    required this.status,
    required this.timestamp,
    required this.id,

  });

  factory MyOrder.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw StateError("Missing data for document ${doc.id}");
    }

    return MyOrder(
      address: Address.fromFirestore(data['address'] as Map<String, dynamic>),
      card: PaymentCard.fromFirestore(data['card'] as Map<String, dynamic>),
      items: (data['items'] as List<dynamic>)
          .map((itemData) => Item.fromFirestore(itemData as Map<String, dynamic>))
          .toList(),
      totalAmount: (data['totalAmount'] as num).toDouble(),
      userId: data['userId'] as String? ?? '',
      status: data['status'] as String? ?? 'Sipariş Oluşturuldu',
      timestamp: data['timestamp'] == null ? Timestamp.now() : data['timestamp'] as Timestamp,
      id: doc.id, // Document ID

    );
  }
  Future<void> updateStatus(String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(id)
          .update({'status': newStatus});
    } catch (e) {
      throw Exception('Status update failed: $e');
    }
  }
}
