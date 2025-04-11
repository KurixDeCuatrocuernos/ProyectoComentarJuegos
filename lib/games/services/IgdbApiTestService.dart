import 'dart:convert';

class IgdbApiTestService {
  // Datos de ejemplo (simulando la respuesta de la API)
  IgdbApiTestService();

  final List<Map<String, dynamic>> _mockData = [
    {
      'id':'1',
      'name': 'The Witcher 3: Wild Hunt',
      'genres': [{'name': 'Action RPG'}, {'name': 'Adventure'}],
      'rating': 9.5,
    },
    {
      'id':'2',
      'name': 'Cyberpunk 2077',
      'genres': [{'name': 'Action RPG'}, {'name': 'Shooter'}],
      'rating': 7.5,
    },
    {
      'id':'3',
      'name': 'Super Mario Odyssey',
      'genres': [{'name': 'Platformer'}, {'name': 'Adventure'}],
      'rating': 9.2,
    },
    {
      'id':'4',
      'name': 'Dark Souls III',
      'genres': [{'name': 'Action RPG'}, {'name': 'Adventure'}],
      'rating': 9.7,
    },
    {

      'id':'5',
      'name': 'Hollow Knight',
      'genres': [{'name': 'Metroidvania'}, {'name': 'Action'}],
      'rating': 9.4,
    },
  ];

  // Método que simula la búsqueda de juegos usando los datos locales
  Future<List<Map<String, dynamic>>> getGames(String query) async {
    // Simula un pequeño retraso (como si fuera una llamada HTTP)
    await Future.delayed(Duration(seconds: 1));
    print("Fetching data");

    // Filtra los juegos que coincidan con el nombre
    List<Map<String, dynamic>> result = _mockData
        .where((game) => game['name']?.toLowerCase().contains(query.toLowerCase()) ?? false)
        .take(6) // limit the results
        .toList();

    if (result.isNotEmpty) {
      print('Juegos encontrados: $result');
      return result;
    } else {
      throw Exception('No se encontraron juegos que coincidan con "$query"');
    }
  }
}