import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

const String apiUrl = "http://localhost:3000"; // Modifier si nécessaire

Future<void> main() async {
  while (true) {
    print("\n=================================");
    print("       📦 GESTION STOCK 📦       ");
    print("=================================");
    print("1️⃣ - 📜 Afficher tous les produits");
    print("2️⃣ - ➕ Ajouter un produit");
    print("3️⃣ - 📦 Afficher toutes les commandes");
    print("4️⃣ - 🛒 Ajouter une commande");
    print("5️⃣ - ❌ Quitter");
    stdout.write("👉 Choisissez une option : ");

    String? choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        await fetchProducts();
        break;
      case '2':
        await addProduct();
        break;
      case '3':
        await fetchOrders();
        break;
      case '4':
        await addOrder();
        break;
      case '5':
        print("👋 Programme terminé.");
        exit(0);
      default:
        print("⚠️ Option invalide. Veuillez réessayer.");
    }
  }
}

/// ✅ Récupérer et afficher tous les produits
Future<void> fetchProducts() async {
  final response = await _sendGetRequest("$apiUrl/produits");

  if (response != null) {
    List<dynamic> products = jsonDecode(response.body);
    if (products.isEmpty) {
      print("📦 Aucun produit disponible.");
    } else {
      print("\n📜 Liste des produits disponibles:");
      for (var product in products) {
        print(
            "🔹 ${product['nom']} (${product['categorie']}) - ${product['prix']} DH | Stock: ${product['stock']}");
      }
    }
  }
}

/// ✅ Ajouter un produit
Future<void> addProduct() async {
  stdout.write("📝 Nom du produit : ");
  String? name = stdin.readLineSync();

  stdout.write("💰 Prix : ");
  double? price = double.tryParse(stdin.readLineSync() ?? "");

  stdout.write("📦 Stock : ");
  int? stock = int.tryParse(stdin.readLineSync() ?? "");

  stdout.write("📁 Catégorie : ");
  String? category = stdin.readLineSync();

  if (name == null || price == null || stock == null || category == null) {
    print("❌ Données invalides. Veuillez réessayer.");
    return;
  }

  Map<String, dynamic> product = {
    "nom": name,
    "prix": price,
    "stock": stock,
    "categorie": category,
  };

  final response = await _sendPostRequest("$apiUrl/produits", product);
  if (response != null && response.statusCode == 201) {
    print("✅ Produit ajouté avec succès !");
  } else {
    print("❌ Erreur lors de l'ajout du produit.");
  }
}

/// ✅ Afficher toutes les commandes
Future<void> fetchOrders() async {
  final response = await _sendGetRequest("$apiUrl/commandes");

  if (response != null) {
    List<dynamic> orders = jsonDecode(response.body);
    if (orders.isEmpty) {
      print("📦 Aucune commande disponible.");
    } else {
      print("\n📜 Liste des commandes:");
      orders.sort(
          (a, b) => b['id'].compareTo(a['id'])); // Tri par ordre décroissant
      for (var order in orders) {
        print("\n🛒 Commande #${order['id']} | Total: ${order['total']} DH");
        print("📦 Produits:");
        for (var item in order['produits']) {
          print("   - ${item['nom']} x${item['quantite']}");
        }
      }
    }
  }
}

/// ✅ Ajouter une commande
Future<void> addOrder() async {
  List<Map<String, dynamic>> produits = [];
  double total = 0.0;

  while (true) {
    stdout.write("🛒 Nom du produit (ou 'fin' pour terminer) : ");
    String? name = stdin.readLineSync();

    if (name == null || name.toLowerCase() == 'fin') break;

    stdout.write("📦 Quantité : ");
    int? quantity = int.tryParse(stdin.readLineSync() ?? "");

    if (quantity == null || quantity <= 0) {
      print("❌ Quantité invalide. Réessayez.");
      continue;
    }

    var product = await _getProductByName(name);
    if (product == null) {
      print("❌ Produit introuvable.");
      continue;
    }

    if (quantity > product['stock']) {
      print("❌ Stock insuffisant.");
      continue;
    }

    // Mise à jour du stock
    product['stock'] -= quantity;
    await _updateProductStock(product['id'], product['stock']);

    total += product['prix'] * quantity;
    produits.add({"nom": name, "quantite": quantity});
  }

  if (produits.isEmpty) {
    print("❌ Aucune commande enregistrée.");
    return;
  }

  int newOrderId = await _getNextOrderId();

  Map<String, dynamic> order = {
    "id": newOrderId,
    "produits": produits,
    "total": total,
  };

  final response = await _sendPostRequest("$apiUrl/commandes", order);
  if (response != null && response.statusCode == 201) {
    print("✅ Commande ajoutée avec succès !");
  } else {
    print("❌ Erreur lors de l'ajout de la commande.");
  }
}

/// ✅ Mettre à jour le stock d'un produit
Future<void> _updateProductStock(int id, int newStock) async {
  final response = await http.patch(
    Uri.parse("$apiUrl/produits/$id"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"stock": newStock}),
  );

  if (response.statusCode != 200) {
    print("⚠️ Erreur de mise à jour du stock.");
  }
}

/// ✅ Obtenir un produit par son nom
Future<Map<String, dynamic>?> _getProductByName(String name) async {
  final response = await _sendGetRequest("$apiUrl/produits");
  if (response != null) {
    List<dynamic> products = jsonDecode(response.body);
    return products.firstWhere(
        (prod) => prod['nom'].toLowerCase() == name.toLowerCase(),
        orElse: () => null);
  }
  return null;
}

/// ✅ Obtenir l'ID de la prochaine commande
Future<int> _getNextOrderId() async {
  final response = await _sendGetRequest("$apiUrl/commandes");
  if (response != null) {
    List<dynamic> orders = jsonDecode(response.body);
    return orders.isNotEmpty ? orders.last['id'] + 1 : 1;
  }
  return 1;
}

/// ✅ Requête GET
Future<http.Response?> _sendGetRequest(String url) async {
  try {
    final response = await http.get(Uri.parse(url));
    return response.statusCode == 200 ? response : null;
  } catch (e) {
    print("⚠️ Erreur réseau: $e");
  }
  return null;
}

/// ✅ Requête POST
Future<http.Response?> _sendPostRequest(
    String url, Map<String, dynamic> body) async {
  try {
    return await http.post(Uri.parse(url),
        headers: {"Content-Type": "application/json"}, body: jsonEncode(body));
  } catch (e) {
    print("⚠️ Erreur réseau: $e");
  }
  return null;
}
