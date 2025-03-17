const express = require("express");
const cors = require("cors");
const fs = require("fs");

const app = express();
app.use(express.json());
app.use(cors());

const PORT = 3000;

// Load data from JSON file
const loadData = () => {
    return JSON.parse(fs.readFileSync("data.json", "utf8"));
};

// Save data to JSON file
const saveData = (data) => {
    fs.writeFileSync("data.json", JSON.stringify(data, null, 2));
};

// Test route
app.get("/", (req, res) => {
    res.send("API is running...");
});

app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});


// Load data
let data = loadData();

// Get all products
app.get("/produits", (req, res) => {
    res.json(data.produits);
});

// Get a single product by ID
app.get("/produits/:id", (req, res) => {
    const produit = data.produits.find(p => p.id === parseInt(req.params.id));
    produit ? res.json(produit) : res.status(404).json({ message: "Produit non trouvé" });
});

// Add a new product
app.post("/produits", (req, res) => {
    const { nom, prix, stock } = req.body;
    if (!nom || prix === undefined || stock === undefined) {
        return res.status(400).json({ message: "Données invalides" });
    }

    const newProduit = { id: data.produits.length + 1, nom, prix, stock };
    data.produits.push(newProduit);
    saveData(data);
    res.status(201).json(newProduit);
});

// Update a product
app.put("/produits/:id", (req, res) => {
    const produit = data.produits.find(p => p.id === parseInt(req.params.id));
    if (!produit) return res.status(404).json({ message: "Produit non trouvé" });

    const { nom, prix, stock } = req.body;
    if (nom) produit.nom = nom;
    if (prix !== undefined) produit.prix = prix;
    if (stock !== undefined) produit.stock = stock;

    saveData(data);
    res.json(produit);
});

// Delete a product
app.delete("/produits/:id", (req, res) => {
    const index = data.produits.findIndex(p => p.id === parseInt(req.params.id));
    if (index === -1) return res.status(404).json({ message: "Produit non trouvé" });

    data.produits.splice(index, 1);
    saveData(data);
    res.json({ message: "Produit supprimé" });
});

// Get all orders
app.get("/commandes", (req, res) => {
    res.json(data.commandes);
});

// Create a new order
app.post("/commandes", (req, res) => {
    const { produits } = req.body;
    if (!produits || !Array.isArray(produits) || produits.length === 0) {
        return res.status(400).json({ message: "Commande invalide" });
    }

    // Check if all products exist and stock is sufficient
    for (let item of produits) {
        const produit = data.produits.find(p => p.id === item.id);
        if (!produit || produit.stock < item.quantite) {
            return res.status(400).json({ message: `Stock insuffisant pour le produit ID ${item.id}` });
        }
    }

    // Deduct stock and create order
    produits.forEach(item => {
        const produit = data.produits.find(p => p.id === item.id);
        produit.stock -= item.quantite;
    });

    const newCommande = { id: data.commandes.length + 1, produits };
    data.commandes.push(newCommande);
    saveData(data);
    res.status(201).json(newCommande);
});

// Get a specific order
app.get("/commandes/:id", (req, res) => {
    const commande = data.commandes.find(c => c.id === parseInt(req.params.id));
    commande ? res.json(commande) : res.status(404).json({ message: "Commande non trouvée" });
});

// Delete an order
app.delete("/commandes/:id", (req, res) => {
    const index = data.commandes.findIndex(c => c.id === parseInt(req.params.id));
    if (index === -1) return res.status(404).json({ message: "Commande non trouvée" });

    data.commandes.splice(index, 1);
    saveData(data);
    res.json({ message: "Commande supprimée" });
});

// Delete a product
app.delete('/produits/:id', (req, res) => {
    const produitId = parseInt(req.params.id);
    const produitIndex = data.produits.findIndex(p => p.id === produitId);

    if (produitIndex === -1) {
        return res.status(404).json({ message: "Produit non trouvé" });
    }

    data.produits.splice(produitIndex, 1); // Remove product from array
    saveData(data); // Save the updated data

    res.status(200).json({ message: `Produit ${produitId} supprimé avec succès` });
});
