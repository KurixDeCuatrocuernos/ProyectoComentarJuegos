import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:game_box/repository/UserRepository.dart';
import 'package:game_box/viewModels/UserViewModel.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';

import '../routes/AppRoutes.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Esta clase permite mostrar la imagen de usuario a partir de la uid proporcionada mediante una llamada a Gravatar
class UserImage extends StatefulWidget {
  final String uid;
  final double size;
  const UserImage({super.key, required this.size, required this.uid});

  @override
  _UserImageState createState() => _UserImageState();
}

class _UserImageState extends State<UserImage> {
  String gravatarAttr = 'mp';
  String? email = "usuario@correo.com";

  @override
  void initState() {
    super.initState();
    _loadUserImage(widget.uid);
    _getEmail();
  }

  Future<void> _loadUserImage(String uid) async {
    String? image = await context.read<UserViewModel>().loadUserImageById(uid);
    if (image != null && mounted) {
      setState(() {
        gravatarAttr = image;
      });
    } else {
      setState(() {
        gravatarAttr = 'mp';
      });
    }
  }

  String _generateGravatarUrl(String email, String gravatarAttr) {
    // print('ATRIBUTO PARA GRAVATAR: $gravatarAttr');
    final bytes = utf8.encode(email.trim().toLowerCase());
    final digest = md5.convert(bytes);
    // print("IMAGEN GUARDADA: https://www.gravatar.com/avatar/${digest.toString()}?s=${widget.size}&d=$gravatarAttr");
    return 'https://www.gravatar.com/avatar/${digest.toString()}?s=${widget.size}&d=$gravatarAttr';
  }

  Future<String?> _getEmail() async {
    String? mail = await context.read<UserViewModel>().getUserEmailById(widget.uid);
    if (mail != null) {
      setState(() {
        email = mail;
      });
    }
  }

  Widget takeUserImage(String gravatarAttr, double sizes) {
    if (email != null) {
      String gravatarUrl = _generateGravatarUrl(email!, gravatarAttr);
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
      return Icon(Icons.account_circle_rounded, size: sizes);
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

