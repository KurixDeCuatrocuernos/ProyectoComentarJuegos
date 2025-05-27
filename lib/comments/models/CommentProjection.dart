

import 'package:game_box/comments/models/CommentaryModel.dart';

class CommentProjection {
  final CommentaryModel comment;
  final String userId;

  CommentProjection({required this.comment, required this.userId});
}