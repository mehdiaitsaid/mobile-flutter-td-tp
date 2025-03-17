import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

const String apiUrl = 'http://localhost:3000';

class Produit {
  int id;
  String nom;
  double prix;
  int stock;

  Produit({
    required this.id,
    required this.nom,
    required this.prix,
    required this.stock,
  });

  // Convert Produit to JSON for POST requests
  Map<String, dynamic> toJson() => {'nom': nom, 'prix': prix, 'stock': stock};

  // Convert JSON to Produit object
  factory Produit.fromJson(Map<String, dynamic> json) {
    return Produit(
      id: json['id'],
      nom: json['nom'],
      prix: json['prix'],
      stock: json['stock'],
    );
  }
}

class Commande {
  int id;
  List<Map<String, dynamic>> produits;

  Commande({required this.id, required this.produits});

  // Convert Commande to JSON for POST requests
  Map<String, dynamic> toJson() => {'produits': produits};

  // Convert JSON to Commande object
  factory Commande.fromJson(Map<String, dynamic> json) {
    return Commande(
      id: json['id'],
      produits: List<Map<String, dynamic>>.from(json['produits']),
    );
  }
}

Future<List<Produit>> getProduits() async {
  final response = await http.get(Uri.parse('$apiUrl/produits'));

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((p) {
      // Ensure 'prix' is a double
      p['prix'] =
          (p['prix'] is int) ? (p['prix'] as int).toDouble() : p['prix'];
      return Produit.fromJson(p);
    }).toList();
  } else {
    throw Exception('Failed to load products');
  }
}

Future<List<Commande>> getCommandes() async {
  final response = await http.get(Uri.parse('$apiUrl/commandes'));

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((c) => Commande.fromJson(c)).toList();
  } else {
    throw Exception('Failed to load orders');
  }
}

Future<Produit> createProduit(Produit produit) async {
  final response = await http.post(
    Uri.parse('$apiUrl/produits'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(produit.toJson()),
  );

  if (response.statusCode == 201) {
    return Produit.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to create product');
  }
}

Future<Commande> createCommande(List<Map<String, dynamic>> produits) async {
  final response = await http.post(
    Uri.parse('$apiUrl/commandes'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'produits': produits}),
  );

  if (response.statusCode == 201) {
    return Commande.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to create order');
  }
}

void printMenu() {
  print('\n🎮 Welcome to the KOZYGAMING Shop! 🎮');
  print('1. View Products 🖱️');
  print('2. View Orders 📦');
  print('3. Add a Product 🖥️');
  print('4. Create an Order 🛒');
  print('5. Exit 🚪');
  print('Please select an option:');
}

Future<void> main() async {
  bool running = true;

  while (running) {
    printMenu();
    String? choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        // View Products
        try {
          List<Produit> produits = await getProduits();
          if (produits.isEmpty) {
            print('No products available. 🛑');
          } else {
            print('📦 List of Products:');
            for (var p in produits) {
              print('${p.nom} - Price: ${p.prix}€ - Stock: ${p.stock}');
            }
          }
        } catch (e) {
          print('Error fetching products: ❌ $e');
        }
        break;

      case '2':
        // View Orders
        try {
          List<Commande> commandes = await getCommandes();
          if (commandes.isEmpty) {
            print('No orders available. 🛑');
          } else {
            print('📦 List of Orders:');
            for (var c in commandes) {
              print('Order ID: ${c.id}');
              print('Products in this order:');
              for (var p in c.produits) {
                print('  Product ID: ${p["id"]} - Quantity: ${p["quantite"]}');
              }
            }
          }
        } catch (e) {
          print('Error fetching orders: ❌ $e');
        }
        break;

      case '3':
        // Add a Product
        try {
          print('🖥️ Enter Product Name:');
          String? name = stdin.readLineSync();

          print('💰 Enter Product Price:');
          double? price = double.tryParse(
            stdin.readLineSync() ?? '',
          ); // Parse price as double

          print('📦 Enter Product Stock:');
          int? stock = int.tryParse(stdin.readLineSync() ?? '');

          if (name == null || price == null || stock == null) {
            print('⚠️ Invalid input. Product not added.');
            break;
          }

          Produit newProduit = Produit(
            id: 0,
            nom: name,
            prix: price,
            stock: stock,
          );
          Produit createdProduit = await createProduit(newProduit);
          print(
            '✅ Product added: ${createdProduit.nom} with price ${createdProduit.prix}€ and stock ${createdProduit.stock} 🏷️',
          );
        } catch (e) {
          print('Error creating product: ❌ $e');
        }
        break;

      case '4':
        // Create an Order
        try {
          List<Produit> produits = await getProduits();
          if (produits.isEmpty) {
            print('❌ No products available to order.');
            break;
          }

          print(
            '🛒 Enter Product ID and Quantity to order (e.g., 1 2 for Product 1 with Quantity 2):',
          );
          String? input = stdin.readLineSync();
          List<String> inputs = input?.split(' ') ?? [];

          if (inputs.length != 2) {
            print('⚠️ Invalid input. Order not created.');
            break;
          }

          int productId = int.tryParse(inputs[0]) ?? -1;
          int quantity = int.tryParse(inputs[1]) ?? -1;

          if (productId == -1 || quantity == -1) {
            print('⚠️ Invalid product ID or quantity.');
            break;
          }

          var selectedProduit = produits.firstWhere(
            (p) => p.id == productId,
            orElse: () => throw Exception('Product not found'),
          );

          if (selectedProduit.stock < quantity) {
            print('❌ Not enough stock available.');
            break;
          }

          selectedProduit.stock -= quantity; // Deduct stock
          List<Map<String, dynamic>> orderProducts = [
            {'id': selectedProduit.id, 'quantite': quantity},
          ];
          Commande commande = await createCommande(orderProducts);
          print('✅ Order created with ID: ${commande.id} 🛒');
        } catch (e) {
          print('Error creating order: ❌ $e');
        }
        break;

      case '5':
        running = false;
        print('👋 Thank you for visiting! Have a great day! 🌟');
        break;

      default:
        print('⚠️ Invalid choice, please select again.');
        break;
    }
  }
}
