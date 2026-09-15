import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:product_catalog_app/model/product_model.dart';

class ProductAPI {
  static const baseURL = 'https://dummyjson.com/products';

  Future<List<Product>> fetchProducts({int limit = 20, int skip = 0}) async {
    final response = await http.get(Uri.parse('$baseURL?limit=$limit&skip=$skip'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final products = data['products'] as List<dynamic>;
      return products.map((product) => Product.fromJson(product)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<Product> fetchProductDetails(int productId) async {
    final response = await http.get(Uri.parse('$baseURL/$productId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Product.fromJson(data);
    } else {
      throw Exception('Failed to load product details');
    }
  }

  Future<List<Product>> searchProducts(String query) async {
    final response = await http.get(Uri.parse('$baseURL/search?q=$query'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final products = data['products'] as List<dynamic>;
      return products.map((product) => Product.fromJson(product)).toList();
    } else {
      throw Exception('Failed to search products');
    }
  }
}