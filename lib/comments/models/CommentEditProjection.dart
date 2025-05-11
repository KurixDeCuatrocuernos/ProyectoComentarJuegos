

class CommentEditProjection {

  final String title;
  final String body;
  final int value;

  CommentEditProjection({
    required this.title,
    required this.body,
    required this.value
  });

  factory CommentEditProjection.fromMap(Map<String, dynamic> map) {

    if (map['title'] == null) {
      throw ArgumentError("falta el title de la proyeccion para editar el comentario");
    }
    if (map['body'] == null) {
      throw ArgumentError("falta el body de la proyeccion para editar el comentario");
    }
    if (map['value'] == null) {
      throw ArgumentError("falta el value de la proyeccion para editar el comentario");
    }

    return CommentEditProjection(
      title: map['title'],
      body: map['body'],
      value: map['value'],
    );

  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'body': body,
    'value': value,
  };

}