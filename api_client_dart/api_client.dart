import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  var url = Uri.parse(
    'http://localhost:3000/products',
  ); // Remplace par l'URL de ton API
  var response = await http.get(url);

  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    print('Réponse de l\'API : $data');
  } else {
    print('Erreur de la requête: ${response.statusCode}');
  }
}
