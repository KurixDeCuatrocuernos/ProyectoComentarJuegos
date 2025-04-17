import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:game_box/repository/UserRepository.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../routes/AppRoutes.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class UserImage extends StatefulWidget {
  final double size;
  final bool editing;
  const UserImage({super.key, required this.size, this.editing = false});

  @override
  _UserImageState createState() => _UserImageState();
}

class _UserImageState extends State<UserImage> {
  String gravatarAttr = 'mp';

  @override
  void initState() {
    super.initState();
    _loadUserImage();
  }

  Future<void> _loadUserImage() async {
    UserRepository _userRepo = UserRepository();
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? image = await _userRepo.getUserImageByUid(user.uid);
      if (image != null && mounted) {
        setState(() {
          gravatarAttr = image;
        });
      }
    }
  }

  String _generateGravatarUrl(String email, String gravatarAttr) {
    // print('ATRIBUTO PARA GRAVATAR: $gravatarAttr');
    final bytes = utf8.encode(email.trim().toLowerCase());
    final digest = md5.convert(bytes);
    // print("IMAGEN GUARDADA: https://www.gravatar.com/avatar/${digest.toString()}?s=${widget.size}&d=$gravatarAttr");
    return 'https://www.gravatar.com/avatar/${digest.toString()}?s=${widget.size}&d=$gravatarAttr';
  }

  Widget takeUserImage(String gravatarAttr, double sizes) {
    String? email = FirebaseAuth.instance.currentUser?.email;
    if (email != null) {
      String gravatarUrl = _generateGravatarUrl(email, gravatarAttr);
      return ClipOval(
        child: Image.network(
          gravatarUrl,
          width: sizes,
          height: sizes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.account_circle, size: sizes);
          },
        ),
      );
    } else {
      return Icon(Icons.account_circle, size: sizes);
    }
  }

  void _profileRedirection() {
    Get.toNamed(Routes.profile);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
          _profileRedirection();
      },
      icon: takeUserImage(gravatarAttr, widget.size),
      iconSize: widget.size + 10.0,
    );
  }
}

