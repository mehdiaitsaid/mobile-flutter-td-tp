import 'dart:convert';
import 'package:http/http.dart' as http;

const String apiUrl = "http://localhost:3000";

class APIClient {
  // 📌 Récupérer tous les produits
  static Future<List<dynamic>> getProduits() async {
    final response = await http.get(Uri.parse("$apiUrl/produits"));
    return jsonDecode(response.body);
  }

  // 📌 Ajouter un produit
  static Future<void> ajouterProduit(Map<String, dynamic> produit) async {
    await http.post(
      Uri.parse("$apiUrl/produits"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(produit),
    );
  }

  // 📌 Récupérer toutes les commandes
  static Future<List<dynamic>> getCommandes() async {
    final response = await http.get(Uri.parse("$apiUrl/commandes"));
    return jsonDecode(response.body);
  }

  // 📌 Ajouter une commande
  static Future<void> ajouterCommande(Map<String, dynamic> commande) async {
    await http.post(
      Uri.parse("$apiUrl/commandes"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(commande),
    );
  }
}
