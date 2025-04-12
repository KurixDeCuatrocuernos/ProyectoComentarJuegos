

class CommentaryValidator {

  bool containsNonAlphanumeric(String text){
    RegExp regExp = RegExp(r'[^a-zA-Z0-9 ]');
    return regExp.hasMatch(text);
  }
  bool containsSQLExpression(String text){
    RegExp regExp = RegExp(r'\b(select|delete|truncate|drop|update|insert|create|alter|union)\b', caseSensitive: false);
    return regExp.hasMatch(text);
  }

  String? isValidCommentary(String? text) {
    if (text == null || text.isEmpty || text.length<20) {
      return "This commentary is too short";
    } else if (containsNonAlphanumeric(text)){
      return "This commentary contains invalid characters";
    } else if (containsSQLExpression(text)) {
      return "This commentary contains a forbidden word";
    } else {
      return null;
    }
  }

  String? isValidTitle(String? text) {
    if (text == null || text.isEmpty || text.length<20) {
      return "This title is too short";
    } else if (text.length>50) {
      return "This title is too long";
    } else if (containsNonAlphanumeric(text)) {
      return "This commentary contains invalid characters";
    } else if (containsSQLExpression(text)) {
      return "This commentary contains a forbidden word";
    } else {
      return null;
    }
  }

  String? isValidValue(int value) {
    if (value < 0) {
      return "You can't choose a value lower than 0";
    } else if (value > 100) {
      return "You cant choose a value bigger than 100";
    } else {
      return null;
    }
  }

}