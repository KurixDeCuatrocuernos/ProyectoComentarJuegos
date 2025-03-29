
import 'package:flutter/material.dart';

class Loadingpage extends StatelessWidget{
  const Loadingpage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}