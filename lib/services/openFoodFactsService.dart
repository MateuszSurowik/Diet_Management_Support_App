import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenFoodFactsApi {
  static const String _baseUrl = 'https://world.openfoodfacts.org/api/v3';
  static const String _baseUrlForName =
      'https://world.openfoodfacts.org/api/v2';
  static const String _categoryByCountry = 'categories_tags_pl';

  /// Pobieranie produktu po kodzie kreskowym
  Future<Map<String, dynamic>?> getProductByBarcode(String barcode) async {
    final url = Uri.parse('$_baseUrl/product/${barcode}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['product'];
    } else {
      print('Błąd przy pobieraniu produktu: ${response.statusCode}');
      return null;
    }
  }

  /// Wyszukiwanie produktów według nazwy
  Future<List<dynamic>> searchProductsByName(String query) async {
    final url =
        Uri.parse('$_baseUrlForName/search?${_categoryByCountry}=${query}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['products'];
    } else {
      print('Błąd przy wyszukiwaniu produktów: ${response.statusCode}');
      return [];
    }
  }
}
