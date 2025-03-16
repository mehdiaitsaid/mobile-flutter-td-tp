const express = require("express");
const fs = require("fs");
const cors = require("cors");
const bodyParser = require("body-parser");

const app = express();
const PORT = 3000;
const DATA_FILE = "db.json";

app.use(cors());
app.use(bodyParser.json());

// Chargement des données depuis le fichier JSON
const lireDonnees = () => {
    try {
        return JSON.parse(fs.readFileSync(DATA_FILE, "utf-8"));
    } catch (error) {
        throw new Error("Erreur de lecture des données : " + error.message);
    }
};

const sauvegarderDonnees = (donnees) => {
    try {
        fs.writeFileSync(DATA_FILE, JSON.stringify(donnees, null, 2));
    } catch (error) {
        throw new Error("Erreur de sauvegarde des données : " + error.message);
    }
};

// Initialiser le fichier JSON s'il est vide
if (!fs.existsSync(DATA_FILE)) {
    sauvegarderDonnees({ produits: [], commandes: [] });
}

// Routers pour les produits
const routerProduits = express.Router();

// Route GET pour récupérer tous les produits
routerProduits.get("/", (req, res) => {
    try {
        const data = lireDonnees();
        res.json(data.produits);
    } catch (error) {
        res.status(500).send({ message: error.message });
    }
});

// Route POST pour ajouter un produit
routerProduits.post("/", (req, res) => {
    const nouveauProduit = req.body;
    if (!nouveauProduit.nom || !nouveauProduit.prix) {
        return res.status(400).send({ message: "Nom et prix du produit sont requis." });
    }
    
    try {
        const data = lireDonnees();
        data.produits.push(nouveauProduit);
        sauvegarderDonnees(data);
        res.status(201).json(nouveauProduit);
    } catch (error) {
        res.status(500).send({ message: error.message });
    }
});

// Ajouter les routes des produits à l'application
app.use("/api/produits", routerProduits);

// Routers pour les commandes
const routerCommandes = express.Router();

// Route GET pour récupérer toutes les commandes
routerCommandes.get("/", (req, res) => {
    try {
        const data = lireDonnees();
        res.json(data.commandes);
    } catch (error) {
        res.status(500).send({ message: error.message });
    }
});

// Route POST pour créer une commande
routerCommandes.post("/", (req, res) => {
    const nouvelleCommande = req.body;
    if (!nouvelleCommande.produits || nouvelleCommande.produits.length === 0) {
        return res.status(400).send({ message: "Produits sont requis pour créer une commande." });
    }
    
    try {
        const data = lireDonnees();
        data.commandes.push(nouvelleCommande);
        sauvegarderDonnees(data);
        res.status(201).json(nouvelleCommande);
    } catch (error) {
        res.status(500).send({ message: error.message });
    }
});

// Ajouter les routes des commandes à l'application
app.use("/api/commandes", routerCommandes);

// Démarrer le serveur
app.listen(PORT, () => {
    console.log(`Serveur lancé sur http://localhost:${PORT}`);
});