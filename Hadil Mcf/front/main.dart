import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

const String baseUrl = "http://localhost:3000/api"; // API Base URL

Future<void> main() async {
  while (true) {
    displayMenu();
    String? choice = stdin.readLineSync();

    await executeChoice(choice);
  }
}

// Display the options menu
void displayMenu() {
  print("   II 📊 GESTION STOCK 📊 II   ");
  print("===============================");
  print("1️⃣ - 🔍 Voir tous les produits");
  print("2️⃣ - ➕ Créer un produit");
  print("3️⃣ - 📦 Vérifier les commandes");
  print("4️⃣ - 🛍️ Faire une commande");
  print("5️⃣ - 🚪 Quitter le programme");
  stdout.write("👉 Choisissez une option : ");
}

// Execute the user's choice
Future<void> executeChoice(String? choice) async {
  switch (choice) {
    case '1':
      await showProducts();
      break;
    case '2':
      await createProduct();
      break;
    case '3':
      await showOrders();
      break;
    case '4':
      await placeOrder();
      break;
    case '5':
      print("👋 Merci de votre visite. À bientôt !");
      exit(0);
    default:
      print("⚠️ Choix non valide. Veuillez réessayer.");
  }
}

/// ✅ Afficher tous les produits
Future<void> showProducts() async {
  final response = await _getRequest("$baseUrl/produits");

  if (response != null) {
    List<dynamic> productList = jsonDecode(response.body);
    if (productList.isEmpty) {
      print("⚠️ Aucuns produits disponibles.");
    } else {
      print("\n📝 Liste des produits disponibles :");
      for (var product in productList) {
        print(
            "🔹 ${product['nom']} (${product['categorie']}) - ${product['prix']} DH | Stock: ${product['stock']}");
      }
    }
  }
}

/// ✅ Créer un nouveau produit
Future<void> createProduct() async {
  stdout.write("🆕 Nom du produit : ");
  var name = stdin.readLineSync();

  stdout.write("💲 Prix : ");
  var price = double.tryParse(stdin.readLineSync() ?? "");

  stdout.write("📊 Stock : ");
  var stock = int.tryParse(stdin.readLineSync() ?? "");

  stdout.write("📁 Catégorie : ");
  var category = stdin.readLineSync();

  if (name == null || price == null || stock == null || category == null) {
    print("❌ Entrées incorrectes. Réessayez.");
    return;
  }

  Map<String, dynamic> newProduct = {
    "nom": name,
    "prix": price,
    "stock": stock,
    "categorie": category,
  };

  final response = await _postRequest("$baseUrl/produits", newProduct);
  if (response != null && response.statusCode == 201) {
    print("✅ Produit ajouté !");
  } else {
    print("❌ Erreur lors de l'ajout du produit.");
  }
}

/// ✅ Afficher toutes les commandes
Future<void> showOrders() async {
  final response = await _getRequest("$baseUrl/commandes");

  if (response != null) {
    List<dynamic> orderList = jsonDecode(response.body);
    if (orderList.isEmpty) {
      print("⚠️ Aucune commande trouvée.");
    } else {
      print("\n📝 Liste des commandes :");
      orderList.sort(
          (a, b) => b['id'].compareTo(a['id'])); // Sort by descending order
      for (var order in orderList) {
        print("\n🛒 Commande #${order['id']} | Total : ${order['total']} DH");
        print("📦 Détails des produits:");
        for (var item in order['produits']) {
          print("   - ${item['nom']} x${item['quantite']}");
        }
      }
    }
  }
}

/// ✅ Passer une commande
Future<void> placeOrder() async {
  List<Map<String, dynamic>> items = [];
  double totalPrice = 0.0;

  while (true) {
    stdout.write("📦 Nom du produit (ou 'fin' pour terminer) : ");
    String? productName = stdin.readLineSync();

    if (productName == null || productName.toLowerCase() == 'fin') break;

    stdout.write("📉 Quantité : ");
    int? quantity = int.tryParse(stdin.readLineSync() ?? "");

    if (quantity == null || quantity <= 0) {
      print("❌ Quantité non valide. Réessayez.");
      continue;
    }

    var product = await _findProductByName(productName);
    if (product == null) {
      print("❌ Produit non trouvé.");
      continue;
    }

    if (quantity > product['stock']) {
      print("❌ Stock insuffisant.");
      continue;
    }

    // Update stock
    product['stock'] -= quantity;
    await _updateProductStock(product['id'], product['stock']);

    totalPrice += product['prix'] * quantity;
    items.add({"nom": productName, "quantite": quantity});
  }

  if (items.isEmpty) {
    print("⚠️ Aucune commande enregistrée.");
    return;
  }

  int newOrderId = await _getNextOrderId();

  Map<String, dynamic> orderData = {
    "id": newOrderId,
    "produits": items,
    "total": totalPrice,
  };

  final response = await _postRequest("$baseUrl/commandes", orderData);
  if (response != null && response.statusCode == 201) {
    print("✅ Commande réussie !");
  } else {
    print("❌ Erreur lors de l'enregistrement de la commande.");
  }
}

/// ✅ Mettre à jour le stock d'un produit
Future<void> _updateProductStock(int id, int newStock) async {
  final response = await http.patch(
    Uri.parse("$baseUrl/produits/$id"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"stock": newStock}),
  );

  if (response.statusCode != 200) {
    print("⚠️ Problème de mise à jour du stock.");
  }
}

/// ✅ Trouver un produit par son nom
Future<Map<String, dynamic>?> _findProductByName(String name) async {
  final response = await _getRequest("$baseUrl/produits");
  if (response != null) {
    List<dynamic> productList = jsonDecode(response.body);
    return productList.firstWhere(
        (prod) => prod['nom'].toLowerCase() == name.toLowerCase(),
        orElse: () => null);
  }
  return null;
}

/// ✅ Obtenir l'identifiant de la prochaine commande
Future<int> _getNextOrderId() async {
  final response = await _getRequest("$baseUrl/commandes");
  if (response != null) {
    List<dynamic> orderList = jsonDecode(response.body);
    return orderList.isNotEmpty ? orderList.last['id'] + 1 : 1;
  }
  return 1;
}

/// ✅ Requête GET
Future<http.Response?> _getRequest(String url) async {
  try {
    final response = await http.get(Uri.parse(url));
    return response.statusCode == 200 ? response : null;
  } catch (e) {
    print("⚠️ Problème de connexion: $e");
  }
  return null;
}

/// ✅ Requête POST
Future<http.Response?> _postRequest(
    String url, Map<String, dynamic> body) async {
  try {
    return await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );
  } catch (e) {
    print("⚠️ Problème de connexion: $e");
  }
  return null;
}
