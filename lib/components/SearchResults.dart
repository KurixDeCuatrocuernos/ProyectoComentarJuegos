
import 'package:flutter/material.dart';
import 'package:game_box/games/utils/SearchResultsUtil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';

import '../games/models/GameModel.dart';
import '../routes/AppRoutes.dart';

class SearchResults extends StatelessWidget {
  SearchResults({super.key});
  ///Modificar este Map por GameModel y revisar su funcionamiento
  void _gameRedirect(GameModel game) {
    Get.offAllNamed(Routes.game, arguments: game);
  }

  @override
  Widget build(BuildContext context) {
    final searchResultsUtil = Provider.of<SearchResultsUtil>(context);
    final games = searchResultsUtil.games;
    final query = searchResultsUtil.query;

    // Oculta el componente si no hay resultados o el texto de búsqueda está vacío
    if (games.isEmpty || query.isEmpty) return SizedBox.shrink();

    return Positioned(
      top: kToolbarHeight + 50, // Ajusta esta altura en función del tamaño del header y la barra
      left: 0,
      right: 0,
      child: Material(
        elevation: 5, // Para que se vea encima del contenido
        child: Container(
          color: Colors.grey,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: ListView.builder(
              shrinkWrap: true, // Evita que ocupe toda la pantalla
              itemCount: games.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: TextButton(
                    style: ButtonStyle(
                    ),
                    onPressed: () {
                      _gameRedirect(games[index]);
                    },
                    child: Text(games[index].name),
                  ),
                  ///subtitle: Text(games[index]['id']), id is a String type
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}