import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class CommentaryController extends GetxController {
  TextEditingController commentController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController userIdController = TextEditingController();
  TextEditingController gameIdController = TextEditingController();
  TextEditingController idController = TextEditingController();
  TextEditingController valueController = TextEditingController();
  var sliderController = 50.obs;
  String _collectionC = 'comments';
  String _collectionG = 'games';
}