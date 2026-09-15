import 'dart:async';
import 'package:flutter/material.dart';
import 'package:product_catalog_app/api/product_api.dart';
import 'package:product_catalog_app/model/product_model.dart';
import 'package:product_catalog_app/ui/widgets/product_card_widget.dart';
import 'package:product_catalog_app/ui/widgets/search_bar_widget.dart';

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
          CatalogSearchBar(
            controller: _searchController,
            onClear: () {
              _searchController.clear();
              setState(() {
                _isSearching = false;
                skip = 0;
              });
              _loadProducts();
            },
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

                        return ProductCard(product: _products[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
