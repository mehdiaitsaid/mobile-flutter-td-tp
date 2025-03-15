const express = require("express");
const fs = require("fs");
const cors = require("cors");
const bodyParser = require("body-parser");

const app = express();
const PORT = 3000;
const DATA_FILE = "db.json";

app.use(cors());
app.use(bodyParser.json());

// Charger les données depuis le fichier JSON
function lireDonnees() {
    return JSON.parse(fs.readFileSync(DATA_FILE, "utf-8"));
}

function sauvegarderDonnees(donnees) {
    fs.writeFileSync(DATA_FILE, JSON.stringify(donnees, null, 2));
}

// Initialiser le fichier JSON si vide
if (!fs.existsSync(DATA_FILE)) {
    sauvegarderDonnees({ produits: [], commandes: [] });
}

// Route GET pour récupérer tous les produits
app.get("/produits", (req, res) => {
    const data = lireDonnees();
    res.json(data.produits);
});

// Route POST pour ajouter un produit
app.post("/produits", (req, res) => {
    const data = lireDonnees();
    const nouveauProduit = req.body;
    data.produits.push(nouveauProduit);
    sauvegarderDonnees(data);
    res.status(201).send("✅ Produit ajouté avec succès !");
});


// Route GET pour récupérer toutes les commandes
app.get("/commandes", (req, res) => {
    const data = lireDonnees();
    res.json(data.commandes);
});

// Route POST pour créer une commande
app.post("/commandes", (req, res) => {
    const data = lireDonnees();
    const nouveauProduit = req.body;
    data.produits.push(nouveauProduit);
    sauvegarderDonnees(data);
    res.status(201).send("✅ Commande ajoutée avec succès !");
});


app.listen(PORT, () => {
    console.log(`✅ Serveur lancé sur http://localhost:${PORT}`);
});
