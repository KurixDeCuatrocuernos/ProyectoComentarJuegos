
// Por ahora no se ha usado este modelo
import 'package:cloud_firestore/cloud_firestore.dart';

class GameModel {
  final int _id;
  final String _name;
  final String _summary;
  final double _rating;
  final int _coverId;
  final String _coverURL;
  final Timestamp _date;

  /// Constructor for GameModel
  GameModel({
    required int id,
    required String name,
    required String summary,
    required double rating,
    required int coverId,
    required String coverURL,
    required Timestamp date,
  }) : _id = id, _name = name, _summary = summary, _rating = rating, _coverId = coverId, _coverURL = coverURL, _date = date;

  /// Getters
  int get id => _id;
  String get name => _name;
  String get summary => _summary;
  double get rating => _rating;
  int get cover => _coverId;
  String get coverURL => _coverURL;
  Timestamp get date => _date;
  /// Setters
  set _id (int id){
    _id = id;
  }
  set _name(String name) {
    _name = name;
  }
  set _summary(String summary) {
    _summary = summary;
  }
  set _rating (double rating){
    _rating = rating;
  }
  set _coverId (int coverId) {
    _coverId = coverId;
  }
  set _coverURL (String coverURL) {
    _coverURL = coverURL;
  }
  set _date (Timestamp date) {
    _date = date;
  }

}