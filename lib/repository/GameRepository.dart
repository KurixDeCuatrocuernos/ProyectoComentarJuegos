

import 'package:cloud_firestore/cloud_firestore.dart';

class GameRepository {
  final String _collection = 'games';

  Future<Map<String,dynamic>?> getGameById(int id) async {
    try {
      final DocumentSnapshot response = await FirebaseFirestore.instance
          .collection(_collection)
          .doc(id.toString())
          .get();
      if (response.exists) {
        return response.data() as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (error) {
      print('HUBO UN ERROR AL BUSCAR EL JUEGO EN LA BASE DE DATOS');
      return null;
    }
  }
}