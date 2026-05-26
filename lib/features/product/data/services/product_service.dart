import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductService {
  final _db = FirebaseFirestore.instance;
  static const int _pageSize = 20;

  // Real-time stream for home screen (first page only)
  Stream<List<ProductModel>> getProducts() {
    return _db
        .collection('products')
        .limit(_pageSize)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ProductModel.fromJson({...d.data(), 'id': d.id}))
            .toList());
  }

  // Paginated fetch for load-more.
  // Returns both the product list and the last DocumentSnapshot so the caller
  // can pass it back as [lastDoc] on the next call.
  Future<ProductPage> getProductsPage({DocumentSnapshot? lastDoc}) async {
    Query q = _db
        .collection('products')
        .orderBy(FieldPath.documentId)
        .limit(_pageSize);
    if (lastDoc != null) q = q.startAfterDocument(lastDoc);
    final snap = await q.get();
    final products = snap.docs
        .map((d) => ProductModel.fromJson({...d.data() as Map, 'id': d.id}))
        .toList();
    return ProductPage(
      products: products,
      lastDoc: snap.docs.isNotEmpty ? snap.docs.last : null,
      hasMore: snap.docs.length == _pageSize,
    );
  }
}

/// Result of a paginated products fetch.
class ProductPage {
  final List<ProductModel> products;
  final DocumentSnapshot? lastDoc;
  final bool hasMore;

  const ProductPage({
    required this.products,
    required this.lastDoc,
    required this.hasMore,
  });
}
