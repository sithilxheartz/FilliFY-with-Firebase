import 'package:fillify_with_firebase/cart.dart';
import 'package:fillify_with_firebase/customer_register_page.dart';
import 'package:fillify_with_firebase/oil_shop_module.dart/product_model.dart';
import 'package:fillify_with_firebase/oil_shop_module.dart/product_service.dart';
import 'package:fillify_with_firebase/cart_service.dart';
import 'package:flutter/material.dart';
import 'package:fillify_with_firebase/shared/custom_button.dart';

class ProductMenuPage extends StatefulWidget {
  @override
  _ProductMenuPageState createState() => _ProductMenuPageState();
}

class _ProductMenuPageState extends State<ProductMenuPage> {
  final ProductService _productService = ProductService();
  final CartService _cartService = CartService();
  List<Product> _products = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  // Fetch all products
  void _fetchProducts() {
    _productService.getProductsStream().listen((products) {
      setState(() {
        _products = products;
      });
    });
  }

  // Filter products by search query
  void _filterProducts(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  // Show cart page when shopping cart icon is tapped
  void _navigateToCart(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartPage(cartService: _cartService),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          title: Text("Product Menu", style: TextStyle(fontSize: 24)),
          actions: [
            IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () => _navigateToCart(context), // Navigate to CartPage
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              SizedBox(height: 10),
              Text(
                "FilliFY Oil Shop",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              Text(
                "Explore our premium product range.",
                style: TextStyle(color: Colors.white70, fontSize: 13.5),
              ),
              SizedBox(height: 20),
              // Search Bar
              TextField(
                onChanged: _filterProducts,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  labelText: 'Search Products',
                  labelStyle: const TextStyle(fontSize: 13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  filled: false,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 12.0,
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Product Grid
              Expanded(
                child:
                    _products.isEmpty
                        ? Center(child: CircularProgressIndicator())
                        : GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 0.59,
                              ),
                          itemCount: _products.length,
                          itemBuilder: (context, index) {
                            final product = _products[index];

                            // Apply search filter
                            if (_searchQuery.isNotEmpty &&
                                !product.name.toLowerCase().contains(
                                  _searchQuery.toLowerCase(),
                                )) {
                              return SizedBox.shrink();
                            }

                            return ProductCard(
                              product: product,
                              cartService: _cartService,
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CustomerRegisterPage()),
            );
          },
          backgroundColor:
              Colors.deepPurple, // You can change this to match your theme
          tooltip: 'Go to Cart',
          child: Icon(Icons.shopping_cart, size: 28, color: Colors.white),
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final CartService cartService;

  const ProductCard({
    Key? key,
    required this.product,
    required this.cartService,
  }) : super(key: key);

  // Show product details in Modal Bottom Sheet
  void _showProductDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the modal to be scrollable
      builder: (BuildContext context) {
        return ProductDetailModal(product: product, cartService: cartService);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showProductDetails(context), // Show modal on tap
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 10,
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              child: Image.network(
                product.imgUrl,
                fit: BoxFit.cover,
                height: 120,
                width: double.infinity,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 15),
                  Text(
                    product.name,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Brand: ${product.brand}',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Size: ${product.size}',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Rs. ${product.price}',
                    style: TextStyle(fontSize: 16, color: Colors.green),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'In Stock ${product.quantity}',
                        style: TextStyle(fontSize: 14),
                      ),
                      IconButton(
                        icon: Icon(Icons.add_shopping_cart, size: 20),
                        onPressed: () {
                          cartService.addProduct(
                            product,
                          ); // Add to cart functionality
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductDetailModal extends StatelessWidget {
  final Product product;
  final CartService cartService;

  const ProductDetailModal({
    Key? key,
    required this.product,
    required this.cartService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15.0),
      height: MediaQuery.of(context).size.height * 0.8, // Adjust modal height
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              height: 5,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey[400], // The notch color
                borderRadius: BorderRadius.circular(20),
              ),
              margin: EdgeInsets.only(top: 5), // Space above the notch
            ),
          ),
          SizedBox(height: 15),
          Center(
            child: Text(
              product.name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              product.imgUrl,
              fit: BoxFit.cover,
              height: 220,
              width: double.infinity,
            ),
          ),
          SizedBox(height: 15),
          Text(
            '${product.description}',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          SizedBox(height: 10),
          Text(
            'Rs. ${product.price}',
            style: TextStyle(
              fontSize: 22,
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'In Stock ${product.quantity}',
                style: TextStyle(fontSize: 18),
              ),
              IconButton(
                icon: Icon(Icons.add_shopping_cart),
                onPressed: () {
                  cartService.addProduct(
                    product,
                  ); // Add to cart functionality here
                },
              ),
            ],
          ),
          Text(
            'Brand: ${product.brand}',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          SizedBox(height: 10),
          Text(
            'Size: ${product.size}',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 20.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 0,
                  backgroundColor: Colors.blue,
                ),
                child: Center(
                  child: Text(
                    "Add to Cart",
                    style: const TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
