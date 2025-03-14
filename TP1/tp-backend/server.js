const express = require('express');
const bodyParser = require('body-parser');
const fs = require('fs');

const app = express();
const port = 3000;

app.use(bodyParser.json());

const loadData = () => {
  try {
    const data = fs.readFileSync('data.json', 'utf8');
    return JSON.parse(data);
  } catch (error) {
    console.error('Erreur de lecture du fichier data.json:', error);
    return { products: [], orders: [] };
  }
};

const saveData = (data) => {
  try {
    fs.writeFileSync('data.json', JSON.stringify(data, null, 2));
  } catch (error) {
    console.error('Erreur d\'écriture dans data.json:', error);
  }
};

app.get('/', (req, res) => {
  res.send('API Backend fonctionne!');
});

app.get('/products', (req, res) => {
  const data = loadData();
  res.json(data.products);
});

app.post('/products', (req, res) => {
  const data = loadData();
  const newProduct = req.body;

  if (!newProduct.name || !newProduct.price) {
    return res.status(400).send('Nom et prix du produit requis.');
  }

  const productExists = data.products.some(product => product.name === newProduct.name);
  if (productExists) {
    return res.status(400).send('Produit déjà existant.');
  }

  data.products.push(newProduct);
  saveData(data);
  res.status(201).send('Produit ajouté.');
});

app.get('/orders', (req, res) => {
  const data = loadData();
  res.json(data.orders);
});

app.post('/orders', (req, res) => {
  const data = loadData();
  const newOrder = req.body;

  if (!newOrder.product || !newOrder.quantity) {
    return res.status(400).send('Produit et quantité requis.');
  }

  const productExists = data.products.some(product => product.name === newOrder.product);
  if (!productExists) {
    return res.status(400).send('Produit introuvable.');
  }

  data.orders.push(newOrder);
  saveData(data);
  res.status(201).send('Commande créée.');
});

app.listen(port, () => {
  console.log(`Serveur API démarré sur http://localhost:${port}`);
});
