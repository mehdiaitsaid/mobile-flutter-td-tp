// client.dart - Client Dart pour interagir avec l'API REST
import 'dart:convert';
import 'package:http/http.dart' as http;

// URL de base de l'API
const String baseUrl = 'http://localhost:3000/api';

// Modèle pour Produit
class Produit {
  String nom;
  double prix;
  int stock;
  String categorie;

  Produit({
    required this.nom, 
    required this.prix, 
    required this.stock, 
    required this.categorie
  });

  // Conversion depuis JSON
  factory Produit.fromJson(Map<String, dynamic> json) {
    return Produit(
      nom: json['nom'],
      prix: json['prix'].toDouble(),
      stock: json['stock'],
      categorie: json['categorie']
    );
  }

  // Conversion vers JSON
  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'prix': prix,
      'stock': stock,
      'categorie': categorie
    };
  }

  // Affichage des détails du produit
  void afficherDetails() {
    print('Produit: $nom');
    print('Prix: $prix');
    print('Stock: $stock');
    print('Catégorie: $categorie');
    print('------------------------');
  }
}

// Modèle pour un article de commande
class CommandeItem {
  String productName;
  int quantity;
  double unitPrice;

  CommandeItem({
    required this.productName,
    required this.quantity,
    required this.unitPrice
  });

  factory CommandeItem.fromJson(Map<String, dynamic> json) {
    return CommandeItem(
      productName: json['productName'],
      quantity: json['quantity'],
      unitPrice: json['unitPrice'].toDouble()
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice
    };
  }
}

// Modèle pour Commande
class Commande {
  int? id;  // Optionnel car l'API attribue l'ID
  List<CommandeItem> items;
  double total;

  Commande({
    this.id,
    required this.items,
    required this.total
  });

  factory Commande.fromJson(Map<String, dynamic> json) {
    var itemsList = (json['items'] as List)
        .map((item) => CommandeItem.fromJson(item))
        .toList();
    
    return Commande(
      id: json['id'],
      items: itemsList,
      total: json['total'].toDouble()
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList()
    };
  }

  // Affichage des détails de la commande
  void afficherCommande() {
    print('Commande #$id');
    print('------------------------');
    for (var item in items) {
      print('${item.productName} x ${item.quantity} = ${item.unitPrice * item.quantity}');
    }
    print('------------------------');
    print('Total: $total');
    print('------------------------');
  }
}

// Classe pour gérer les appels API
class ApiService {
  // GET tous les produits
  Future<List<Produit>> getProduits() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));
    
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Produit.fromJson(item)).toList();
    } else {
      throw Exception('Erreur lors de la récupération des produits: ${response.body}');
    }
  }
  
  // POST un nouveau produit
  Future<Produit> ajouterProduit(Produit produit) async {
    final response = await http.post(
      Uri.parse('$baseUrl/products'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(produit.toJson())
    );
    
    if (response.statusCode == 201) {
      return Produit.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur lors de l\'ajout du produit: ${response.body}');
    }
  }
  
  // GET toutes les commandes
  Future<List<Commande>> getCommandes() async {
    final response = await http.get(Uri.parse('$baseUrl/orders'));
    
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Commande.fromJson(item)).toList();
    } else {
      throw Exception('Erreur lors de la récupération des commandes: ${response.body}');
    }
  }
  
  // POST une nouvelle commande
  Future<Commande> ajouterCommande(Commande commande) async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(commande.toJson())
    );
    
    if (response.statusCode == 201) {
      return Commande.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur lors de l\'ajout de la commande: ${response.body}');
    }
  }
}

// Exemple d'utilisation
void main() async {
  final apiService = ApiService();
  
  // Démonstration des fonctionnalités
  try {
    // 1. Ajouter quelques produits
    print('Ajout de produits...');
    await apiService.ajouterProduit(Produit(
      nom: 'Smartphone XYZ', 
      prix: 1999.99, 
      stock: 50, 
      categorie: 'Phone'
    ));
    
    await apiService.ajouterProduit(Produit(
      nom: 'Laptop ABC', 
      prix: 5999.99, 
      stock: 20, 
      categorie: 'Computer'
    ));
    
    await apiService.ajouterProduit(Produit(
      nom: 'Écouteurs QWE', 
      prix: 299.99, 
      stock: 100, 
      categorie: 'Accessories'
    ));
    
    // 2. Récupérer et afficher tous les produits
    print('\nRécupération des produits...');
    var produits = await apiService.getProduits();
    
    print('\nListe des produits:');
    produits.forEach((produit) => produit.afficherDetails());
    
    // 3. Créer et ajouter une commande
    print('Création d\'une commande...');
    var nouvelleCommande = Commande(
      items: [
        CommandeItem(productName: 'Smartphone XYZ', quantity: 2, unitPrice: 1999.99),
        CommandeItem(productName: 'Écouteurs QWE', quantity: 1, unitPrice: 299.99)
      ],
      total: 0  // Le total sera calculé par le serveur
    );
    
    var commandeAjoutee = await apiService.ajouterCommande(nouvelleCommande);
    print('\nCommande ajoutée avec succès:');
    commandeAjoutee.afficherCommande();
    
    // 4. Récupérer et afficher toutes les commandes
    print('\nRécupération des commandes...');
    var commandes = await apiService.getCommandes();
    
    print('\nListe des commandes:');
    commandes.forEach((commande) => commande.afficherCommande());
    
    // 5. Manipulation des données avec des fonctions avancées
    print('\nManipulation des produits:');
    
    // Filter: Produits coûtant plus de 500
    var produitsCouteux = produits.where((p) => p.prix > 500).toList();
    print('\nProduits coûtant plus de 500:');
    produitsCouteux.forEach((p) => print('- ${p.nom}: ${p.prix}'));
    
    // Map: Liste formatée des noms de produits
    var nomsProduits = produits.map((p) => '${p.nom} (${p.categorie})').toList();
    print('\nListe des noms de produits:');
    nomsProduits.forEach((nom) => print('- $nom'));
    
    // Reduce: Produit le plus cher
    var produitPlusCher = produits.reduce((a, b) => a.prix > b.prix ? a : b);
    print('\nProduit le plus cher: ${produitPlusCher.nom} - ${produitPlusCher.prix}');
    
    // Fonction de haut niveau pour appliquer une remise
    List<Produit> appliquerRemise(List<Produit> produits, String categorie, double pourcentage) {
      return produits.map((p) {
          if (p.categorie == categorie) {
            var remise = p.prix * pourcentage / 100;
            p.prix = p.prix - remise;
          }
          return p;
        }).toList();
      }
    
    // Appliquer une remise de 10% sur les produits de catégorie "Phone"
    var produitsApresRemise = appliquerRemise(produits, 'Phone', 10);
    print('\nAppliquant une remise de 10% sur les produits "Phone":');
    produitsApresRemise.forEach((p) => print('- ${p.nom}: ${p.prix}'));
    
    // Fonction de haut niveau qui applique une transformation aux prix
    void transformerPrix(List<Produit> produits, double Function(double) transformateur) {
      for (var produit in produits) {
        produit.prix = transformateur(produit.prix);
      }
    }
    
    // Utilisation: appliquer un arrondi à l'entier inférieur
    transformerPrix(produits, (prix) => prix.floorToDouble());
    print('\nPrix arrondis à l\'entier inférieur:');
    produits.forEach((p) => print('- ${p.nom}: ${p.prix}'));
    
  } catch (e) {
    print('Erreur: $e');
  }
}