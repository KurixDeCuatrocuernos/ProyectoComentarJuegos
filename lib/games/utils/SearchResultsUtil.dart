import 'package:flutter/material.dart';
///This util bonds the SearchPlaceHolder and SearchResults classes in order to show the results on each page
class SearchResultsUtil extends ChangeNotifier {
  List<dynamic> _games = [];
  String _query = '';  // Añadir el campo de texto de búsqueda

  List<dynamic> get games => _games;
  String get query => _query;

  void updateResults(List<dynamic> results, String query) {
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