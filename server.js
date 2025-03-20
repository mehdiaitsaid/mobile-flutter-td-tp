const express = require('express');
const bodyParser = require('body-parser');
const fs = require('fs');

const app = express();
const port = 3000;

app.use(bodyParser.json());

const loadData = () => {
  if (!fs.existsSync('data.json')) {
    fs.writeFileSync('data.json', JSON.stringify({ products: [], orders: [] }, null, 2));
  }
  return JSON.parse(fs.readFileSync('data.json', 'utf8'));
};

const saveData = (data) => {
  fs.writeFileSync('data.json', JSON.stringify(data, null, 2));
};

app.get('/', (req, res) => {
  res.send('API Backend fonctionne !');
});

app.listen(port, () => {
  console.log(`Serveur API démarré sur http://localhost:${port}`);
});
// Route GET pour récupérer tous les produits
app.get('/products', (req, res) => {
    const data = loadData();
    res.json(data.products);
  });
  
  // Route POST pour ajouter un nouveau produit
  app.post('/products', (req, res) => {
    const data = loadData();
    const newProduct = req.body;
    data.products.push(newProduct);
    saveData(data);
    res.status(201).json({ message: 'Produit ajoute avec succes' });
  });
  
  // Route GET pour récupérer toutes les commandes
  app.get('/orders', (req, res) => {
    const data = loadData();
    res.json(data.orders);
  });
  
  // Route POST pour ajouter une commande
  app.post('/orders', (req, res) => {
    const data = loadData();
    const newOrder = req.body;
    data.orders.push(newOrder);
    saveData(data);
    res.status(201).json({ message: 'Commande cree avec succes' });
  });
  