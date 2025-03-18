import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> getProducts(String baseUrl) async {
  print('\n🔄 Fetching products from $baseUrl/products...');
  try {
    final response = await http.get(Uri.parse('$baseUrl/products'));
    
    if (response.statusCode == 200) {
      List<dynamic> products = jsonDecode(response.body);
      print('\n✅ Products retrieved successfully!');
      if (products.isNotEmpty) {
        for (var product in products) {
          print('- 🛍️ Name: ${product['name']}, 💰 Price: \$${product['price']}');
        }
      } else {
        print('\n⚠️ No products found.');
      }
    } else {
      print('\n❌ Error ${response.statusCode}: Failed to fetch products.');
    }
  } catch (e) {
    print('\n🚨 Exception occurred while fetching products: $e');
  }
}

Future<void> addProduct(String baseUrl, Map<String, dynamic> product) async {
  print('\n➕ Adding product: ${product['name']} (Price: \$${product['price']})');
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/products'),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: jsonEncode(product),
    );

    if (response.statusCode == 201) {
      print('\n✅ Product added successfully!');
    } else {
      print('\n❌ Error ${response.statusCode}: Failed to add product. Response: ${response.body}');
    }
  } catch (e) {
    print('\n🚨 Exception occurred while adding product: $e');
  }
}

Future<void> getOrders(String baseUrl) async {
  print('\n🔄 Fetching orders from $baseUrl/orders...');
  try {
    final response = await http.get(Uri.parse('$baseUrl/orders'));
    
    if (response.statusCode == 200) {
      List<dynamic> orders = jsonDecode(response.body);
      print('\n✅ Orders retrieved successfully!');
      if (orders.isNotEmpty) {
        for (var order in orders) {
          print('- 📦 Product: ${order['product']}, 🛒 Quantity: ${order['quantity']}');
        }
      } else {
        print('\n⚠️ No orders found.');
      }
    } else {
      print('\n❌ Error ${response.statusCode}: Failed to fetch orders.');
    }
  } catch (e) {
    print('\n🚨 Exception occurred while fetching orders: $e');
  }
}

Future<void> addOrder(String baseUrl, Map<String, dynamic> order) async {
  print('\n🛍️ Placing an order for ${order['product']} (Quantity: ${order['quantity']})');
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: jsonEncode(order),
    );

    if (response.statusCode == 201) {
      print('\n✅ Order placed successfully!');
    } else {
      print('\n❌ Error ${response.statusCode}: Failed to place order. Response: ${response.body}');
    }
  } catch (e) {
    print('\n🚨 Exception occurred while placing order: $e');
  }
}

void main() async {
  final String baseUrl = 'http://localhost:3000';
  print('\n🚀 Starting Dart API Client...');

  // Fetch all products
  await getProducts(baseUrl);

  // Add a new product
  final newProduct = {'name': 'Produit 1', 'price': 100};
  await addProduct(baseUrl, newProduct);

  // Fetch all orders
  await getOrders(baseUrl);

  // Add a new order
  final newOrder = {'product': 'Produit 1', 'quantity': 2};
  await addOrder(baseUrl, newOrder);

  print('\n🎉 API Client Execution Completed!');
}