import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // GET PRODUCTS STREAM
  Stream<List<ProductModel>> getProducts() {
    return _firestore.collection('products').snapshots().map(
      (snapshot) {
        return snapshot.docs.map((doc) {
          return ProductModel.fromJson(doc.data());
        }).toList();
      },
    );
  }
}