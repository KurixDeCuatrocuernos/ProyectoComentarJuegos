import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../games/services/IgdbApiRepository.dart';

class GameImage extends StatelessWidget {
  final Map<String, dynamic> game;
  const GameImage({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: Provider.of<IgdbApiRepository>(context, listen: false).getCover(game['cover'] ?? ''),  // Usamos el 'cover' como identificador del juego
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Muestra un cargando mientras se obtiene la imagen
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          return Image.network(snapshot.data!); // Muestra la imagen una vez se haya obtenido la URL
        } else {
          return Text('Imagen no disponible');
        }
      },
    );
  }
}
