import 'package:api_client/api_fonctions.dart';

void main() async {
  // Base URL for the server
  final String baseUrl = 'http://localhost:3000';

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
}