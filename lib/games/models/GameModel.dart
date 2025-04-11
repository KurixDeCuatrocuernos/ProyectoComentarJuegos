
// Por ahora no se ha usado este modelo
class GameModel {
  final String _id;
  final String _name;
  final List<String> _genres;
  final double _rating;
  final String _cover;

  /// Constructor for GameModel
  GameModel({
    required String id,
    required String name,
    required List<String> genres,
    required double rating,
    required String cover,
  }) : _id = id, _name = name, _genres = genres, _rating = rating, _cover = cover;

  /// Getters
  String get id => _id;
  String get name => _name;
  List<String> get genres => List.unmodifiable(_genres);
  double get rating => _rating;
  String get cover => _cover;
  /// Setters
  set _id (String id){
    _id = id;
  }
  set _name(String name) {
    _name = name;
  }
  set _genres (List<String> genres) {
    _genres = genres;
  }
  set _rating (double rating){
    _rating = rating;
  }
  set _cover (String cover) {
    _cover = cover;
  }

  /// Constructor factory for de API data
  factory GameModel.fromJson(Map<String, dynamic> json) {

    List<String>? genreNames = [];

    if (json['genres'] != null) {
      genreNames = List<String>.from(json['genres'].map((genre) => genre['name']));
    }

    String coverUrl = json['cover'] != null
        ? 'https:${json['cover']['url']}'  // Añades https: a la URL de la imagen
        : '';

    return GameModel(
        id: json['id'] ?? 'Unknown',
        name: json['name'] ?? 'Unknown',
        genres: genreNames,
        rating: (json ['rating'] ?? 0).toDouble(),
        cover: coverUrl,
    );
  }

}