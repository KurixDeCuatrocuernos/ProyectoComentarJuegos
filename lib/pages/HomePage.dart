
import 'package:flutter/material.dart';

import '../components/Header.dart';
import '../components/ToolBar.dart';

class HomePage extends StatelessWidget{
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      bottomNavigationBar: ToolBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Centra los objetos horizontalmente
        children: [
          SizedBox(
              child: Header(),
          ),
          SizedBox(
            height: 10,
          ),

          ///In this Expanded goes every section
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                color: Colors.white,
                width: double.infinity,
                child: Column(
                  children: List.generate(
                    50, // Número de elementos para simular mucho contenido
                        (index) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Elemento $index',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(
            height: 10,
          ),
        ],
      ),

    );
  } //build
} //HomePage