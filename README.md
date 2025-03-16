# Système de Gestion de Produits et Commandes

Ce projet implémente un système complet de gestion de produits et commandes avec une architecture client-serveur :
- Une API REST développée avec Express.js (Node.js)
- Un client développé en Dart pour interagir avec l'API
- Stockage de données dans des fichiers JSON

## Structure du Projet

```
.
├── api/                  # API REST Express.js
│   ├── server.js         # Point d'entrée de l'API
│   ├── package.json      # Dépendances Node.js
│   └── data/             # Dossier pour les fichiers JSON de données
│       ├── products.json # Stockage des produits
│       └── orders.json   # Stockage des commandes
│
└── client/               # Client Dart
    ├── lib/
    │   └── client.dart   # Code source du client Dart
    └── pubspec.yaml      # Dépendances Dart
```

## API REST (Express.js)

### Prérequis

- Node.js (v14 ou supérieur)
- npm (v6 ou supérieur)

### Installation

```bash
# Créer le dossier du projet
mkdir -p api
cd api

# Initialiser le projet
npm init -y

# Installer les dépendances
npm install express body-parser
npm install --save-dev nodemon
```

### Configuration du package.json

Ajoutez ces scripts à votre `package.json` :

```json
"scripts": {
  "start": "node server.js",
  "dev": "nodemon server.js"
}
```

### Lancement du serveur

```bash
# Mode production
npm start

# Mode développement avec rechargement automatique
npm run dev
```

### Résolution des problèmes courants

#### Erreur "Unexpected end of JSON input"

Si vous rencontrez cette erreur, cela signifie que les fichiers JSON sont corrompus :

```bash
# Supprimez les fichiers existants
rm -rf data/products.json data/orders.json

# Redémarrez le serveur
npm start
```

Le serveur va automatiquement recréer des fichiers JSON valides.

## Routes disponibles

### Produits

- **GET /api/products** - Récupérer tous les produits
  ```bash
  curl http://localhost:3000/api/products
  ```

- **POST /api/products** - Ajouter un nouveau produit
 

### Commandes

- **GET /api/orders** - Récupérer toutes les commandes
  ```bash
  curl http://localhost:3000/api/orders
  ```

- **POST /api/orders** - Créer une nouvelle commande
 

## Utilisation avec Postman

### Configuration des requêtes

1. **Ajouter un produit**
   - Méthode : **POST**
   - URL : `http://localhost:3000/api/products`
  
   

2. **Récupérer tous les produits**
   - Méthode : **GET**
   - URL : `http://localhost:3000/api/products`

3. **Ajouter une commande**
   - Méthode : **POST**
   - URL : `http://localhost:3000/api/orders`
   

4. **Récupérer toutes les commandes**
   - Méthode : **GET**
   - URL : `http://localhost:3000/api/orders`

## Client Dart

### Prérequis

- Dart SDK (version 2.19.0 ou supérieure)

### Installation

```bash
# Créer le dossier du projet
mkdir -p client
cd client

# Initialiser le projet Dart
dart create .

# Installer les dépendances
dart pub add http
```

### Configuration du pubspec.yaml

```yaml
name: api_client
description: Un client Dart pour interagir avec l'API REST Express

environment:
  sdk: '>=2.19.0 <3.0.0'

dependencies:
  http: ^0.13.5
```

### Exécution du client

```bash
dart run lib/client.dart
```

## Modèles de données

### Produit

```json
{
  "nom": "Smartphone XYZ",
  "prix": 1999.99,
  "stock": 50,
  "categorie": "Phone"
}
```

### Commande

```json
{
  "id": 1,
  "items": [
    {
      "productName": "Smartphone XYZ",
      "quantity": 2,
      "unitPrice": 1999.99
    },
    {
      "productName": "Écouteurs QWE",
      "quantity": 1,
      "unitPrice": 299.99
    }
  ],
  "total": 4299.97,
  "date": "2025-03-16T12:34:56.789Z"
}
```

## Fonctionnalités

### Côté API
- Stockage persistant dans des fichiers JSON
- Validation des données
- Gestion des exceptions (stock insuffisant, commande vide)
- Calcul automatique des totaux
- Mise à jour des stocks lors de la création de commandes
- Protection contre la corruption des fichiers JSON

### Côté Client
- Modèles POO (Produit, Commande)
- Méthodes d'affichage pour visualiser les données
- Utilisation de fonctions avancées sur les listes (filter, map, reduce)
- Fonctions de haut niveau et expressions lambda
- Gestion des exceptions

## Résolution des problèmes

### Erreur 500 (Internal Server Error)

Vérifiez les logs du serveur pour plus de détails. Causes courantes :
- Problème de permissions sur les fichiers
- Fichiers JSON corrompus
- Erreur de syntaxe dans le code

### Erreur 400 (Bad Request)

Ces erreurs sont attendues dans certains cas :
- Stock insuffisant pour un produit
- Commande vide
- Produit non trouvé

