import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final String category;
  final String subcategory;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.subcategory,
  });


}
