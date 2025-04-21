
import 'package:flutter/material.dart';
import 'package:game_box/components/SearchPlaceholder.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../routes/AppRoutes.dart';

class ToolBar extends StatelessWidget{
  final VoidCallback onMenuPressed;
  ToolBar({super.key, required this.onMenuPressed});
  

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100,
      color: Colors.black,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(Icons.view_headline_sharp),
            color: Colors.white,
            iconSize: 25,
            onPressed: onMenuPressed,
          ),
          IconButton(
              onPressed: () { Get.offAllNamed(Routes.home);},
              icon: Icon(Icons.home),
              color: Colors.white,
              iconSize: 30,
          ),
          IconButton(
            onPressed: () { Get.offAllNamed(Routes.comments); },
            icon: Icon(Icons.star),
            iconSize: 30,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}