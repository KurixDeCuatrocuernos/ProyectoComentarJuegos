import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:game_box/components/GameImage.dart';
import 'package:game_box/viewModels/GameViewModel.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';

import '../games/models/GameModel.dart';
import '../routes/AppRoutes.dart';

class CommentedGamesListComponent extends StatefulWidget {
  final User? user;

  const CommentedGamesListComponent({super.key, required this.user});

  @override
  State<CommentedGamesListComponent> createState() => _CommentedGamesListComponent();
}

class _CommentedGamesListComponent extends State<CommentedGamesListComponent> {
  late Future<List<GameModel>?> _future;

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<GameViewModel>();
    if (viewModel.getListCommentedGames().isEmpty) {
      _future = viewModel.getAllGamesFromRepository(widget.user!.uid);
    } else {
      _future = Future.value(viewModel.getListCommentedGames());
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentedGames = context.watch<GameViewModel>().getListCommentedGames();

    return Container(
      width: MediaQuery.of(context).size.width * 1.0,
      color: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GAMES YOU HAVE COMMENTED',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          commentedGames.isNotEmpty
              ? _buildGamesList(commentedGames)
              : FutureBuilder<List<GameModel>?>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text('No hay juegos', style: TextStyle(color: Colors.white));
              } else {
                return _buildGamesList(snapshot.data!);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGamesList(List<GameModel> games) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: games
            .where((game) => game.coverId != null)
            .map((game) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: SizedBox(
            width: 64,
            height: 128,
            child: GestureDetector(
              child: GameImage(game: game),
              onTap: () {
                Get.toNamed(Routes.game, arguments: game);
              },
            ),
          ),
        ))
            .toList(),
      ),
    );
  }
}

