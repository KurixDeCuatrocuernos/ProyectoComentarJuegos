
// Por ahora no se ha usado este modelo
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
/// Esta clase es el Modelo para instanciar objetos Game, de cara a sustituir los Map<String,dynamic> para implementar el patron MVVM.
class GameModel {
  final int id;
  final String name;
  final String? summary;
  final double? rating;
  final int coverId;
  final String? url;
  final Timestamp? first_release_date;

  /// Metodo constructor de GameModel
  GameModel({
    required this.id,
    required this.name,
    this.summary,
    this.rating,
    required this.coverId,
    this.first_release_date,
    this.url,
  });
  /// Este Metodo devuelve un GameModel a partir de un Map<String, dynamic>
  factory GameModel.fromMap(Map<String, dynamic> map) {
    if (map['id'] == null || map['id'] is! int) {
      throw ArgumentError("El parámetro id del juego es inválido");
    }
    if (map['name'] == null || map['name'] is! String) {
      throw ArgumentError("El parámetro name del juego es inválido");
    }
    if (map['cover'] == null || map['cover'] is! int) {
      throw ArgumentError("El parámetro cover (coverId) del juego es inválido");
    }

    String? summary;
    if (map['summary'] is String) {
      summary = map['summary'];
    } else if (map['summary'] != null) {
      summary = map['summary'].toString();
    }

    Timestamp? releaseDate;
    if (map.containsKey('first_release_date')) {
      if (map['first_release_date'] is Timestamp) {
        releaseDate = map['first_release_date'];
      } else if (map['first_release_date'] is int) {
        releaseDate = Timestamp.fromMillisecondsSinceEpoch(map['first_release_date']);
      } else {
        throw ArgumentError("El parámetro first_release_date no es Timestamp");
      }
    }

    String? url;
    if (map.containsKey('url')) {
      if (map['url'] is String) {
        url = map['url'];
      } else {
        throw ArgumentError("El parámetro url del juego no es String");
      }
    }

    final rating = (map['rating'] as num?)?.toDouble() ?? Random().nextDouble();

    return GameModel(
      id: map['id'] as int,
      name: map['name'] as String,
      summary: summary,
      rating: rating,
      coverId: map['cover'] as int,
      first_release_date: releaseDate,
      url: url,
    );
  }
  /// Este Metodo devuelve un Map<String,dynamic> a partir del GameModel
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'rating': rating,
    'summary': summary,
    'cover': coverId,
    if (url != null) 'url': url,
  };

}