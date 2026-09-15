import 'dart:async';
import 'package:flutter/material.dart';
import 'package:product_catalog_app/api/product_api.dart';
import 'package:product_catalog_app/model/product_model.dart';
import 'package:product_catalog_app/ui/product_detail.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final ProductAPI _api = ProductAPI();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<Product> _products = [];
  bool _isLoading = false;
  bool _hasError = false;
  bool _hasMore = false;
  bool _isSearching = false;
  int skip = 0;
  final int limit = 20;

  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadProducts();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMoreProducts();
      }
    });

    _searchController.addListener(_onSearchChanged);
  }

  void _loadProducts() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      _products = await _api.fetchProducts(limit: limit, skip: skip);
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

  Future<void> _loadMoreProducts() async {
    if (_hasMore) {
      return;
    }

    if (_isSearching) {
      return;
    }

    setState(() {
      _hasMore = true;
    });

    try {
      skip += limit;
      final moreProducts = await _api.fetchProducts(limit: limit, skip: skip);
      setState(() {
        _products.addAll(moreProducts);
        _hasMore = false;
      });
    } catch (e) {
      setState(() {
        _hasMore = false;
      });
    }
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      final query = _searchController.text.trim();
      if (query.isEmpty) {
        skip = 0;
        _loadProducts();
      } else {
        _searchProducts(query);
      }
    });
  }

  Future<void> _searchProducts(String query) async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _isSearching = true;
    });

    try {
      _products = await _api.searchProducts(query);
      setState(() {
        _isLoading = false;
        _hasMore = false;
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
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Product Catalog',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _isSearching = false;
                            skip = 0;
                          });
                          _loadProducts();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: const CircularProgressIndicator())
                : _hasError
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Failed to load products'),
                      ElevatedButton(
                        onPressed: _loadProducts,
                        child: Text('Retry'),
                      ),
                    ],
                  )
                : _products.isEmpty
                ? const Text('No products found')
                : RefreshIndicator(
                    onRefresh: () async {
                      skip = 0;
                      final query = _searchController.text.trim();
                      if (query.isEmpty) {
                        _loadProducts();
                      } else {
                        _searchProducts(query);
                      }
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: _products.length + 1,
                      itemBuilder: (context, index) {
                        if (index == _products.length) {
                          return _hasMore
                              ? const Center(child: CircularProgressIndicator())
                              : Center(
                                  child: const Text(
                                    'No more products',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                        }

                        final product = _products[index];

                        return Card(
                          margin: const EdgeInsets.all(6.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: FadeInImage.assetNetwork(
                              placeholder: 'assets/img_placeholder.png',
                              image: product.thumbnail,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              imageErrorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image),
                            ),
                            title: Text(
                              product.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'RM${product.price}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.grey,
                              size: 16,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProductDetailPage(productId: product.id),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
