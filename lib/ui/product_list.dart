import 'package:flutter/material.dart';
import 'package:product_catalog_app/api/product_api.dart';
import 'package:product_catalog_app/model/product_model.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final ProductAPI _api = ProductAPI();
  List<Product> _products = [];
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      _products = await _api.fetchProducts();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Catalog', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _hasError
                ? ElevatedButton(
                    onPressed: _loadProducts,
                    child: Text('Failed to load products')
                  )
                : ListView.builder(
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      return ListTile(
                        leading: Image.network(product.thumbnail),
                        title: Text(product.title),
                        subtitle: Text('RM${product.price}'),
                        onTap: () {},
                      );
                    },
                  ),
      ),

    );
  }
}
