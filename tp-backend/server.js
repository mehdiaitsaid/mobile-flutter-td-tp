const express = require('express');
const bodyParser = require('body-parser');
const fs = require('fs');

const app = express();
const port = 3000;

// استخدام body-parser لتحليل JSON في طلبات POST
app.use(bodyParser.json());

// تحميل البيانات من ملف JSON
const loadData = () => {
  const data = fs.readFileSync('data.json', 'utf8');
  return JSON.parse(data);
};

// حفظ البيانات في ملف JSON
const saveData = (data) => {
  fs.writeFileSync('data.json', JSON.stringify(data, null, 2));
};

// اختبار عمل الخادم
app.get('/', (req, res) => {
  res.send('API Backend fonctionne!');
});

app.listen(port, () => {
  console.log(`Serveur API démarré sur http://localhost:${port}`);
});
// مسار GET للحصول على جميع المنتجات
app.get('/products', (req, res) => {
    const data = loadData();
    res.json(data.products);
  });
  
  // مسار POST لإضافة منتج جديد
  app.post('/products', (req, res) => {
    const data = loadData();
    const newProduct = req.body;
    data.products.push(newProduct);
    saveData(data);
    res.status(201).send('Produit ajouté');
  });
  
  // مسار GET للحصول على جميع الطلبات
  app.get('/orders', (req, res) => {
    const data = loadData();
    res.json(data.orders);
  });
  
  // مسار POST لإضافة طلب جديد
  app.post('/orders', (req, res) => {
    const data = loadData();
    const newOrder = req.body;
    data.orders.push(newOrder);
    saveData(data);
    res.status(201).send('Commande créée');
  });