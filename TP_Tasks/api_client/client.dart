import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<List<dynamic>> fetchData(String url) async {
  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print(
          'Erreur ${response.statusCode}: Impossible de récupérer les données.');
    }
  } catch (e) {
    print('Erreur lors de la requête GET: $e');
  }
  return [];
}

Future<void> postData(String url, Map<String, dynamic> data) async {
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      print('Données envoyées avec succès');
    } else {
      print(
          'Erreur ${response.statusCode}: Impossible d\'ajouter les données.');
    }
  } catch (e) {
    print('Erreur lors de la requête POST: $e');
  }
}

Future<void> getProducts(String baseUrl) async {
  final products = await fetchData('$baseUrl/products');
  if (products.isNotEmpty) {
    print('Produits disponibles:');
    for (var product in products) {
      print('Nom: ${product['name']}, Prix: ${product['price']}');
    }
  } else {
    print('Aucun produit disponible.');
  }
}

Future<void> addProduct(String baseUrl, Map<String, dynamic> product) async {
  await postData('$baseUrl/products', product);
}

Future<void> getOrders(String baseUrl) async {
  final orders = await fetchData('$baseUrl/orders');
  if (orders.isNotEmpty) {
    print('Commandes disponibles:');
    for (var order in orders) {
      print('Produit: ${order['product']}, Quantité: ${order['quantity']}');
    }
  } else {
    print('Aucune commande disponible.');
  }
}

Future<void> addOrder(String baseUrl, Map<String, dynamic> order) async {
  await postData('$baseUrl/orders', order);
}

void main() async {
  final String baseUrl = 'http://localhost:3000';

  await getProducts(baseUrl);

  final newProduct = {'name': 'Produit 2', 'price': 150};
  await addProduct(baseUrl, newProduct);

  await getOrders(baseUrl);

  final newOrder = {'product': 'Produit 2', 'quantity': 3};
  await addOrder(baseUrl, newOrder);
}
