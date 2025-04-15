
class CommentaryModel {
  late String _id;
  late String _title;
  late String _body;
  late String _userId;
  late int _gameId;

  /// EMPTY CONSTRUCTOR
  CommentaryModel();
  /// CONSTRUCTOR
  CommentaryModel.named({
    required String id,
    required String title,
    required String body,
    required String userId,
    required int gameId,
  })  : _id = id,
        _title = title,
        _body = body,
        _userId = userId,
        _gameId = gameId;
  /// GETTERS
  String get id => _id;
  String get title => _title;
  String get body => _body;
  String get userId => _userId;
  int get gameId => _gameId;
  /// SETTERS
  set id(String value) => _id = value;
  set title(String value) => _title = value;
  set body(String value) => _body = value;
  set userId(String value) => _userId = value;
  set gameId(int value) => _gameId = value;
}
