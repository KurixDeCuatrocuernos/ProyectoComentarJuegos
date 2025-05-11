

class CommentaryValidator {

  bool containsSQLExpression(String text){
    RegExp regExp = RegExp(r'\b(select|delete|truncate|drop|update|insert|create|alter|union)\b', caseSensitive: false);
    return regExp.hasMatch(text);
  }

  String? isValidCommentary(String? text) {
    if (text == null || text.isEmpty || text.length<20) {
      return "This commentary is too short";
    } else if (text.length>800) {
      return "This commentary is too long";
    } else if (containsSQLExpression(text)) {
      return "This commentary contains a forbidden word";
    } else {
      return null;
    }
  }

  String? isValidTitle(String? text) {
    if (text == null || text.isEmpty || text.length<5) {
      return "This title is too short";
    } else if (text.length>30) {
      return "This title is too long (max 30 characters)";
    } else if (containsSQLExpression(text)) {
      return "This commentary contains a forbidden word";
    } else {
      return null;
    }
  }

  String? isValidValue(String? value) {
   if (value == null) {
     return "The value is null";
   } else if (int.tryParse(value) == null) {
     return "The Value is not a number";
   } else  if (int.parse(value) < 0) {
     return "You can't choose a value lower than 0";
   } else if (int.parse(value) > 100) {
     return "You cant choose a value bigger than 100";
   } else {
     return null;
   }
  }

  String? isValidId(String? text) {
    if (text == null || text.isEmpty) {
      return "A Comment must have an ID";
    } else if (text.length > 20) {
      return "The ID must have 20 characters at most";
    } else if (containsSQLExpression(text)) {
      return "The Id contains forbidden words";
    } else {
      return null;
    }
  }

  String? isValidGameId(String? text) {
    final parsed;
    if(text!=null) {
      parsed = int.tryParse(text);
    } else {
      parsed = null;
    }
    const maxInt64 = 9223372036854775807;

    if (text == null || text.isEmpty) {
      return "A Comment must have a GameId";
    } else if (parsed == null) {
      return "The GameId must be a Integer number";
    } else if (parsed < 0) {
      return "The Id mus be a positive number";
    } else if (parsed > maxInt64) {
      return "The ID is too long";
    } else if (containsSQLExpression(text)) {
      return "The Id contains forbidden words";
    } else {
      return null;
    }
  }

  String? isValidUserId(String? text) {
    if (text == null || text.isEmpty) {
      return "A Comment must have an ID";
    } else if (text.length > 50) {
      return "The ID must have 20 characters at most";
    } else if (containsSQLExpression(text)) {
      return "The Id contains forbidden words";
    } else {
      return null;
    }
  }

}