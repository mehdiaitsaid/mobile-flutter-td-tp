// server.js - Point d'entrée principal de l'API
const express = require('express');
const fs = require('fs');
const bodyParser = require('body-parser');
const path = require('path');

const app = express();
const PORT = 3000;

// Middleware pour parser le JSON
app.use(bodyParser.json());

// Middleware pour gérer les erreurs CORS (Cross-Origin Resource Sharing)
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  if (req.method === 'OPTIONS') {
    return res.sendStatus(200);
  }
  next();
});

// Chemins vers les fichiers de données
const DATA_DIR = path.join(__dirname, 'data');
const PRODUCTS_FILE = path.join(DATA_DIR, 'products.json');
const ORDERS_FILE = path.join(DATA_DIR, 'orders.json');

// Assurer que les fichiers existent
function ensureFilesExist() {
  try {
    // Créer le dossier data s'il n'existe pas
    if (!fs.existsSync(DATA_DIR)) {
      fs.mkdirSync(DATA_DIR, { recursive: true });
      console.log("Dossier 'data' créé avec succès");
    }
    
    // Créer le fichier products.json s'il n'existe pas
    if (!fs.existsSync(PRODUCTS_FILE)) {
      fs.writeFileSync(PRODUCTS_FILE, JSON.stringify([]), 'utf8');
      console.log("Fichier 'products.json' créé avec succès");
    }
    
    // Créer le fichier orders.json s'il n'existe pas
    if (!fs.existsSync(ORDERS_FILE)) {
      fs.writeFileSync(ORDERS_FILE, JSON.stringify([]), 'utf8');
      console.log("Fichier 'orders.json' créé avec succès");
    }
  } catch (error) {
    console.error("Erreur lors de la création des fichiers:", error);
    throw error;
  }
}

// Appeler la fonction au démarrage
ensureFilesExist();

// Récupération des données
function readProducts() {
    try {
      const data = fs.readFileSync(PRODUCTS_FILE, 'utf8');
      if (!data || data.trim() === '') {
        console.log("Fichier products.json vide ou corrompu, initialisation avec un tableau vide");
        return [];
      }
      return JSON.parse(data);
    } catch (error) {
      console.error("Erreur lors de la lecture des produits:", error);
      // Recréer le fichier avec un tableau vide
      fs.writeFileSync(PRODUCTS_FILE, JSON.stringify([]), 'utf8');
      return [];
    }
  }
  
  function readOrders() {
    try {
      const data = fs.readFileSync(ORDERS_FILE, 'utf8');
      if (!data || data.trim() === '') {
        console.log("Fichier orders.json vide ou corrompu, initialisation avec un tableau vide");
        return [];
      }
      return JSON.parse(data);
    } catch (error) {
      console.error("Erreur lors de la lecture des commandes:", error);
      // Recréer le fichier avec un tableau vide
      fs.writeFileSync(ORDERS_FILE, JSON.stringify([]), 'utf8');
      return [];
    }
  }
  
 // Au démarrage du serveur
function checkDataIntegrity() {
    try {
      // Vérifier products.json
      let productsData = fs.readFileSync(PRODUCTS_FILE, 'utf8');
      if (!productsData || productsData.trim() === '') {
        fs.writeFileSync(PRODUCTS_FILE, JSON.stringify([]), 'utf8');
        console.log("Fichier products.json réinitialisé");
      } else {
        // Essayer de parser pour vérifier l'intégrité
        JSON.parse(productsData);
      }
      
      // Vérifier orders.json
      let ordersData = fs.readFileSync(ORDERS_FILE, 'utf8');
      if (!ordersData || ordersData.trim() === '') {
        fs.writeFileSync(ORDERS_FILE, JSON.stringify([]), 'utf8');
        console.log("Fichier orders.json réinitialisé");
      } else {
        // Essayer de parser pour vérifier l'intégrité
        JSON.parse(ordersData);
      }
    } catch (error) {
      console.error("Erreur d'intégrité des données, réinitialisation des fichiers:", error);
      fs.writeFileSync(PRODUCTS_FILE, JSON.stringify([]), 'utf8');
      fs.writeFileSync(ORDERS_FILE, JSON.stringify([]), 'utf8');
    }
  }
  
  // Appelez cette fonction après ensureFilesExist()
  ensureFilesExist();
  checkDataIntegrity();

  function saveProductsSafely(products) {
    try {
      // Écrire d'abord dans un fichier temporaire
      const tempFile = `${PRODUCTS_FILE}.tmp`;
      fs.writeFileSync(tempFile, JSON.stringify(products, null, 2), 'utf8');
      
      // Puis renommer pour remplacer l'original (opération atomique)
      fs.renameSync(tempFile, PRODUCTS_FILE);
    } catch (error) {
      console.error("Erreur lors de la sauvegarde des produits:", error);
      throw error;
    }
  }
  
  function saveOrdersSafely(orders) {
    try {
      // Écrire d'abord dans un fichier temporaire
      const tempFile = `${ORDERS_FILE}.tmp`;
      fs.writeFileSync(tempFile, JSON.stringify(orders, null, 2), 'utf8');
      
      // Puis renommer pour remplacer l'original (opération atomique)
      fs.renameSync(tempFile, ORDERS_FILE);
    } catch (error) {
      console.error("Erreur lors de la sauvegarde des commandes:", error);
      throw error;
    }
  }

// Classes
class StockInsuffisantException extends Error {
  constructor(message) {
    super(message);
    this.name = "StockInsuffisantException";
  }
}

class CommandeVideException extends Error {
  constructor(message) {
    super(message);
    this.name = "CommandeVideException";
  }
}

// Route racine
app.get('/', (req, res) => {
  res.send('API de gestion de produits et commandes. Utilisez /api/products et /api/orders pour accéder aux données.');
});

// Routes pour les produits
app.get('/api/products', (req, res) => {
  try {
    console.log("GET /api/products - Récupération des produits");
    const products = readProducts();
    res.json(products);
  } catch (error) {
    console.error("Erreur dans GET /api/products:", error);
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/products', (req, res) => {
  try {
    console.log("POST /api/products - Ajout d'un produit:", req.body);
    const products = readProducts();
    const newProduct = req.body;
    
    // Validation
    if (!newProduct.nom || !newProduct.prix || !newProduct.stock || !newProduct.categorie) {
      return res.status(400).json({ error: "Tous les champs sont requis (nom, prix, stock, categorie)" });
    }
    
    // S'assurer que les types sont corrects
    newProduct.prix = parseFloat(newProduct.prix);
    newProduct.stock = parseInt(newProduct.stock);
    
    // Vérifier si le produit existe déjà
    const existingProduct = products.find(p => p.nom === newProduct.nom);
    if (existingProduct) {
      return res.status(400).json({ error: "Un produit avec ce nom existe déjà" });
    }
    
    products.push(newProduct);
    saveProducts(products);
    
    res.status(201).json(newProduct);
  } catch (error) {
    console.error("Erreur dans POST /api/products:", error);
    res.status(500).json({ error: error.message });
  }
});

// Routes pour les commandes
app.get('/api/orders', (req, res) => {
  try {
    console.log("GET /api/orders - Récupération des commandes");
    const orders = readOrders();
    res.json(orders);
  } catch (error) {
    console.error("Erreur dans GET /api/orders:", error);
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/orders', (req, res) => {
  try {
    console.log("POST /api/orders - Création d'une commande:", req.body);
    const orders = readOrders();
    const products = readProducts();
    const orderData = req.body;
    
    // Validation
    if (!orderData.items || orderData.items.length === 0) {
      throw new CommandeVideException("La commande ne peut pas être vide");
    }
    
    // Créer un nouvel ID pour la commande
    const newId = orders.length > 0 ? Math.max(...orders.map(o => o.id)) + 1 : 1;
    
    // Initialiser la nouvelle commande
    const newOrder = {
      id: newId,
      items: [],
      total: 0
    };
    
    // Traiter chaque article de la commande
    for (const item of orderData.items) {
      const productIndex = products.findIndex(p => p.nom === item.productName);
      
      if (productIndex === -1) {
        throw new Error(`Produit non trouvé: ${item.productName}`);
      }
      
      const product = products[productIndex];
      const quantity = parseInt(item.quantity);
      
      // Vérifier si le stock est suffisant
      if (product.stock < quantity) {
        throw new StockInsuffisantException(`Stock insuffisant pour ${product.nom}. Disponible: ${product.stock}, Demandé: ${quantity}`);
      }
      
      // Ajouter l'article à la commande
      newOrder.items.push({
        productName: product.nom,
        quantity: quantity,
        unitPrice: product.prix
      });
      
      // Mettre à jour le stock
      products[productIndex].stock -= quantity;
      
      // Ajouter au total
      newOrder.total += product.prix * quantity;
    }
    
    // Arrondir le total à 2 décimales
    newOrder.total = Math.round(newOrder.total * 100) / 100;
    
    // Ajouter la date de la commande
    newOrder.date = new Date().toISOString();
    
    // Sauvegarder les modifications
    orders.push(newOrder);
    saveOrders(orders);
    saveProducts(products);
    
    console.log("Commande créée avec succès:", newOrder);
    res.status(201).json(newOrder);
  } catch (error) {
    console.error("Erreur dans POST /api/orders:", error);
    if (error instanceof StockInsuffisantException || error instanceof CommandeVideException) {
      res.status(400).json({ error: error.message });
    } else {
      res.status(500).json({ error: error.message });
    }
  }
});

// Middleware pour gérer les routes non trouvées
app.use((req, res) => {
  res.status(404).json({ error: "Route non trouvée" });
});

// Middleware pour gérer les erreurs globales
app.use((err, req, res, next) => {
  console.error("Erreur non gérée:", err);
  res.status(500).json({ error: "Erreur interne du serveur", details: err.message });
});

// Démarrer le serveur
app.listen(PORT, () => {
  console.log(`Serveur démarré sur le port ${PORT}`);
  console.log(`API accessible à l'adresse: http://localhost:${PORT}`);
});

module.exports = app; // Pour les tests