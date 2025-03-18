import 'dart:convert';
import 'package:http/http.dart' as http;

class Product {
  final int id;
  final String name;
  final double price;

  Product({required this.id, required this.name, required this.price});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(id: json['id'], name: json['name'], price: json['price']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'price': price};
  }
}

class Order {
  final int id;
  final int productId;
  final int quantity;
  final double totalPrice;

  Order({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.totalPrice,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      productId: json['product_id'],
      quantity: json['quantity'],
      totalPrice: json['total_price'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'quantity': quantity,
      'total_price': totalPrice,
    };
  }
}

class ApiClient {
  final String baseUrl;

  ApiClient({required this.baseUrl});

  // Récupérer tous les produits
  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  // Ajouter un produit
  Future<Product> addProduct(Product product) async {
    final response = await http.post(
      Uri.parse('$baseUrl/products'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(product.toJson()),
    );

    if (response.statusCode == 201) {
      return Product.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add product');
    }
  }

  // Récupérer toutes les commandes
  Future<List<Order>> fetchOrders() async {
    final response = await http.get(Uri.parse('$baseUrl/orders'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Order.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load orders');
    }
  }

  // Ajouter une commande
  Future<Order> addOrder(Order order) async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(order.toJson()),
    );

    if (response.statusCode == 201) {
      return Order.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add order');
    }
  }
}

void main() async {
  final apiClient = ApiClient(baseUrl: 'http://localhost:3000');

  // Exemple de récupération de produits
  try {
    List<Product> products = await apiClient.fetchProducts();
    print('Products:');
    for (var product in products) {
      print(
        'ID: ${product.id}, Name: ${product.name}, Price: \$${product.price}',
      );
    }
  } catch (e) {
    print('Error fetching products: $e');
  }

  // Exemple d'ajout de produit
  try {
    Product newProduct = Product(id: 0, name: 'New Product', price: 19.99);
    Product addedProduct = await apiClient.addProduct(newProduct);
    print('Added Product: ${addedProduct.name}');
  } catch (e) {
    print('Error adding product: $e');
  }

  // Exemple de récupération de commandes
  try {
    List<Order> orders = await apiClient.fetchOrders();
    print('Orders:');
    for (var order in orders) {
      print(
        'Order ID: ${order.id}, Product ID: ${order.productId}, Quantity: ${order.quantity}, Total Price: \$${order.totalPrice}',
      );
    }
  } catch (e) {
    print('Error fetching orders: $e');
  }

  // Exemple d'ajout de commande
  try {
    Order newOrder = Order(id: 0, productId: 1, quantity: 2, totalPrice: 39.98);
    Order addedOrder = await apiClient.addOrder(newOrder);
    print('Added Order with ID: ${addedOrder.id}');
  } catch (e) {
    print('Error adding order: $e');
  }
}
