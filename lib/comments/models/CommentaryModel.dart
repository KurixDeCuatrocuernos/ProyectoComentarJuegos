
import 'package:cloud_firestore/cloud_firestore.dart';

/// Clase para instanciar objetos Commentary de cara a sustituior los Map<String, dynamic> para implementar el patron MVVM
class CommentaryModel {
  final String id;
  final String title;
  final String body;
  final String userId;
  final int gameId;
  final int value;
  final Timestamp? createdAt;
  final int? status;

  /// Metodo constructor para CommentaryModel
  CommentaryModel({
    required this.id,
    required this.title,
    required this.body,
    required this.value,
    required this.userId,
    required this.gameId,
    this.createdAt,
    this.status,
  });

  /// Metodo para convertir un Map<String, dynamic> en un CommentaryModel
  factory CommentaryModel.fromMap(Map<String, dynamic> map) {
    if (map['id'] == null) {
      throw ArgumentError("Falta el id de comentario");
    }
    if (map['title'] == null) {
      throw ArgumentError("Falta el title de comentario");
    }
    if (map['body'] == null) {
      throw ArgumentError("Falta el body de comentario");
    }
    if (map['value'] == null) {
      throw ArgumentError("Falta el value de comentario");
    }
    if (map['userId'] == null) {
      throw ArgumentError("Falta el userId de comentario");
    }
    if (map['gameId'] == null) {
      throw ArgumentError("Falta el gameId de comentario");
    }
    if (map['createdAt'] == null) {
      print("Falta el createdAt de comentario");
    }

    return CommentaryModel(
      id: map['id'],
      title: map['title'],
      body: map['body'],
      value: map['value'],
      userId: map['userId'],
      gameId: map['gameId'],
      createdAt: map['createdAt'],
      status: map['status'],
    );
  }
  /// Metodo para convertir CommentaryModel en un Map<String,dynamic>
  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'body': body,
    'value': value,
    'userId': userId,
    'gameId':gameId,
    if(createdAt != null) 'createdAt': createdAt,
    if(status != null) 'status': status,
  };
}
