class StockInsuffisantException implements Exception {
  String cause;
  StockInsuffisantException(this.cause);
}

class CommandeVideException implements Exception {
  String cause;
  CommandeVideException(this.cause);
}

class Produit {
  String nom;
  double prix;
  int stock;
  String categorie;

  Produit(this.nom, this.prix, this.stock, this.categorie);

  void afficherDetails() {
    print(
        "Produit: $nom | Prix: $prix DH | Stock: $stock | Catégorie: $categorie");
  }
}

class Commande {
  int id;
  Map<Produit, int> produits = {};
  double total = 0;

  Commande(this.id);

  void ajouterProduit(Produit produit, int quantite) {
    if (produit.stock < quantite) {
      throw StockInsuffisantException("Stock insuffisant pour ${produit.nom}");
    }
    produits[produit] = (produits[produit] ?? 0) + quantite;
    produit.stock -= quantite;
  }

  void calculerTotal() {
    total = produits.entries
        .fold(0, (sum, entry) => sum + (entry.key.prix * entry.value));
  }

  void afficherCommande() {
    if (produits.isEmpty) {
      throw CommandeVideException("La commande est vide !");
    }
    print("Commande ID: $id");
    produits.forEach((produit, quantite) {
      print("${produit.nom} x$quantite - ${produit.prix * quantite} DH");
    });
    print("Total: $total DH");
  }
}

List<Produit> produitsDisponibles = [
  Produit("iPhone", 100000, 5, "TELEPHONE"),
  Produit("Infinix", 15000, 3, "TELEPHONE"),
  Produit("Toshiba", 10000, 2, "PC"),
  Produit("Dell", 20000, 4, "PC"),
  Produit("AirPods", 1200, 10, "Accessoires"),
];

Produit? rechercherProduitParNom(String nom) {
  return produitsDisponibles.firstWhere(
      (p) => p.nom.toLowerCase() == nom.toLowerCase(),
      orElse: () => throw Exception("Produit non trouvé"));
}

List<Produit> produitsChers =
    produitsDisponibles.where((p) => p.prix > 50).toList();

Produit produitLePlusCher = produitsDisponibles
    .reduce((curr, next) => curr.prix > next.prix ? curr : next);

void appliquerRemiseSurCategorie(String categorie, double remise) {
  produitsDisponibles
      .where((p) => p.categorie == categorie)
      .forEach((p) => p.prix -= p.prix * remise);
}

List<double> transformerPrixProduits(double Function(double) transformation) {
  return produitsDisponibles
      .map<double>((p) => transformation(p.prix))
      .toList();
}

// MAIN
void main() {
  try {
    Commande commande1 = Commande(1);

    commande1.ajouterProduit(rechercherProduitParNom("iPhone")!, 2);
    commande1.ajouterProduit(rechercherProduitParNom("AirPods")!, 1);

    commande1.calculerTotal();

    commande1.afficherCommande();
  } catch (e) {
    print("Erreur : $e");
  }

  print("\nProduits plus de 60 DH :");
  produitsChers.forEach((p) => p.afficherDetails());

  print("\nProduit le plus cher :");
  produitLePlusCher.afficherDetails();

  appliquerRemiseSurCategorie("TELEPHONE", 0.10);
  print("\nPrix après remise de 10% sur les téléphones :");
  produitsDisponibles
      .where((p) => p.categorie == "TELEPHONE")
      .forEach((p) => p.afficherDetails());

  List<double> prixAvecTVA = transformerPrixProduits((prix) => prix * 1.2);
  print("\nPrix avec TVA (20%) : $prixAvecTVA");
}