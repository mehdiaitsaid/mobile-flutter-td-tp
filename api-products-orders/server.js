const express = require('express');
const fs = require('fs');
const app = express();
const port = 3000;

app.use(express.json()); // Pour parser les données JSON dans les requêtes

// Fonction pour vérifier si le fichier existe
function checkIfFileExists(filePath) {
  return fs.existsSync(filePath);
}

// Route GET pour récupérer tous les produits
app.get('/products', (req, res) => {
  fs.readFile('./products.json', (err, data) => {
    if (err) return res.status(500).json({ message: 'Erreur de lecture des produits', error: err.message });
    res.json(JSON.parse(data));
  });
});

// Route POST pour ajouter un nouveau produit
app.post('/products', (req, res) => {
  const newProduct = req.body;
  fs.readFile('./products.json', (err, data) => {
    if (err) return res.status(500).json({ message: 'Erreur de lecture des produits', error: err.message });
    const products = JSON.parse(data);
    newProduct.id = products.length + 1; // Générer un ID unique
    products.push(newProduct);
    fs.writeFile('./products.json', JSON.stringify(products, null, 2), (err) => {
      if (err) return res.status(500).json({ message: 'Erreur d\'écriture des produits', error: err.message });
      res.status(201).json(newProduct);
    });
  });
});

// Route GET pour récupérer toutes les commandes
app.get('/orders', (req, res) => {
  fs.readFile('./orders.json', (err, data) => {
    if (err) return res.status(500).json({ message: 'Erreur de lecture des commandes', error: err.message });
    res.json(JSON.parse(data));
  });
});

// Route POST pour ajouter une nouvelle commande
app.post('/orders', (req, res) => {
  const newOrder = req.body;
  fs.readFile('./products.json', (err, data) => {
    if (err) return res.status(500).json({ message: 'Erreur de lecture des produits', error: err.message });

    const products = JSON.parse(data);
    const product = products.find(p => p.id === newOrder.product_id);

    if (!product) return res.status(404).json({ message: 'Produit non trouvé' });

    newOrder.id = Math.floor(Math.random() * 1000) + 1; // ID aléatoire pour la commande
    newOrder.total_price = product.price * newOrder.quantity; // Calcul du prix total

    // Vérifier si le fichier orders.json existe
    if (!checkIfFileExists('./orders.json')) {
      // Si le fichier n'existe pas, le créer
      fs.writeFile('./orders.json', JSON.stringify([], null, 2), (err) => {
        if (err) {
          console.error('Erreur de création du fichier orders.json:', err.message);
          return res.status(500).json({ message: 'Erreur de création du fichier orders.json', error: err.message });
        }
      });
    }

    // Lire les commandes existantes
    fs.readFile('./orders.json', (err, data) => {
      if (err) {
        console.error('Erreur de lecture du fichier orders.json:', err.message);
        return res.status(500).json({ message: 'Erreur de lecture des commandes', error: err.message });
      }

      const orders = JSON.parse(data);
      orders.push(newOrder);

      // Écrire les nouvelles commandes dans le fichier
      fs.writeFile('./orders.json', JSON.stringify(orders, null, 2), (err) => {
        if (err) {
          console.error('Erreur d\'écriture dans orders.json:', err.message);
          return res.status(500).json({ message: 'Erreur d\'écriture des commandes', error: err.message });
        }
        res.status(201).json(newOrder);
      });
    });
  });
});

// Démarre le serveur
app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});

