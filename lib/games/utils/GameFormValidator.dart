

class GameFormValidator {

  /// Devuelve true si contiene caracteres no alfanumericos y false si no los contiene
  bool _containsNoAlfanumeric(String texto) {
    final alfanumerico = RegExp(r'^[a-zA-Z0-9 _\-\:\.\,áéíóúüÁÉÍÓÚÜñÑ]+$');
    return !alfanumerico.hasMatch(texto);
  }

  bool _containsSQLExpression(String text){
    RegExp regExp = RegExp(r'\b( select | delete | truncate | drop | update | insert | create | alter | union )\b', caseSensitive: false);
    return regExp.hasMatch(text);
  }

  bool _isDouble(String text) {
    return double.tryParse(text) != null;
  }

  bool _isInt(String text) {
    return int.tryParse(text) != null;
  }

  bool _isValidImageUrl(String url) {
    final uri = Uri.tryParse(url);
    final hasValidExtension = url.toLowerCase().endsWith('.png') ||
        url.toLowerCase().endsWith('.jpg') ||
        url.toLowerCase().endsWith('.jpeg') ||
        url.toLowerCase().endsWith('.gif') ||
        url.toLowerCase().endsWith('.webp');
    return uri != null && uri.hasAbsolutePath && hasValidExtension;
  }

  String? isValidId(String? text) {
    if (text == null || text.isEmpty) {
      return "A game must have a rating";
    } else if (!_isInt(text)) {
      return "This is not a number";
    } else {
      return null;
    }
  }

  String? isValidCover(String? text) {
    if (text == null || text.isEmpty) {
      return "A game must have a cover";
    } else if (!_isInt(text)) {
      return "Tis isn't a number";
    } else {
      return null;
    }
  }

  String? isValidName(String? text) {
    if (text == null || text.isEmpty) {
      return "This title is too short";
    }  else if (_containsNoAlfanumeric(text)) {
      return "This title contains invalid characters";
    } else if (_containsSQLExpression(text)) {
      return "This title contains a forbidden word";
    } else {
      return null;
    }
  }

  String? isValidSummary(String? text) {
    if (text == null || text.isEmpty) {
      return "This summary is too short";
    }  else if (_containsNoAlfanumeric(text)) {
      return "This summary contains invalid characters";
    } else if (_containsSQLExpression(text)) {
      return "This summary contains a forbidden word";
    } else {
      return null;
    }
  }

  String? isValidRating(String? text) {
    if (text == null || text.isEmpty) {
      return "A game must have a rating";
    } else if (!_isDouble(text)) {
      return "This is not a number (use . instead , for decimals)";
    } else if (double.parse(text) > 100 || double.parse(text) < 0) {
      return "The rating must be a value between 100 and 0";
    } else {
      return null;
    }
  }

  String? isValidUrl(String? text) {
    if (text == null || text.isEmpty) {
      return "This url is too short";
    } else if (_isValidImageUrl(text)) {
      return "This url is not a valid image";
    } else {
      return null;
    }
  }

}