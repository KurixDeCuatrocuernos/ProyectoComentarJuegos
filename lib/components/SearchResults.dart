
import 'package:flutter/material.dart';
import 'package:game_box/games/utils/SearchResultsUtil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';

import '../routes/AppRoutes.dart';

class SearchResults extends StatelessWidget {
  SearchResults({super.key});

  void _gameRedirect(Map<String, dynamic> game) {
    Get.toNamed(Routes.game, arguments: game);
  }

  @override
  Widget build(BuildContext context) {
    final searchResultsUtil = Provider.of<SearchResultsUtil>(context);
    final games = searchResultsUtil.games;
    final query = searchResultsUtil.query;

    // Oculta el componente si no hay resultados o el texto de búsqueda está vacío
    if (games.isEmpty || query.isEmpty) return SizedBox.shrink();

    return Positioned(
      top: 110, // Ajusta esta altura según el tamaño del header y la barra
      left: 0,
      right: 0,
      child: Material(
        elevation: 5, // Para que se vea encima del contenido
        child: Container(
          color: Colors.grey,
          child: ListView.builder(
            shrinkWrap: true, // Evita que ocupe toda la pantalla
            itemCount: games.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: TextButton(
                  child: Text(games[index]['name']),
                  style: ButtonStyle(
                  ),
                  onPressed: () {_gameRedirect(games[index]);},
                ),
                ///subtitle: Text(games[index]['id']), id is a String type
              );
            },
          ),
        ),
      ),
    );
  }
}