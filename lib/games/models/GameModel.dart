
// Por ahora no se ha usado este modelo
import 'package:cloud_firestore/cloud_firestore.dart';
/// Esta clase es el Modelo para instanciar objetos Game, de cara a sustituir los Map<String,dynamic> para implementar el patron MVVM.
class GameModel {
  final int id;
  final String name;
  final String summary;
  final double rating;
  final int coverId;
  final String? url;
  final Timestamp date;

  /// Metodo constructor de GameModel
  GameModel({
    required this.id,
    required this.name,
    required this.summary,
    required this.rating,
    required this.coverId,
    required this.date,
    this.url,
  });
  /// Este Metodo devuelve un GameModel a partir de un Map<String, dynamic>
  factory GameModel.fromMap(Map<String, dynamic> map) {
    return GameModel(
      id: map['id'],
      name: map['name'],
      summary: map['summary'],
      rating: map['rating'],
      coverId: map['coverId'],
      date: map['date'],
      url: map['url'],
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