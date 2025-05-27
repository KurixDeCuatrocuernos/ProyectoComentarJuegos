import 'package:flutter/material.dart';

import '../models/GameModel.dart';
///This util bonds the SearchPlaceHolder and SearchResults classes in order to show the results on each page
class SearchResultsUtil extends ChangeNotifier {
  List<GameModel> _games = [];
  String _query = '';  // Añadir el campo de texto de búsqueda

  List<GameModel> get games => _games;
  String get query => _query;

  void updateResults(List<GameModel> results, String query) {
    _games = results;
    _query = query;
    notifyListeners();
  }

  void clearResults() {
    _games = [];
    _query = '';
    notifyListeners();
  }
}