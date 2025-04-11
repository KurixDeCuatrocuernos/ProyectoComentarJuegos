
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_box/games/services/IgdbApiRepository.dart';
import 'package:game_box/games/services/IgdbApiTestService.dart';
import 'package:provider/provider.dart';

import '../games/utils/SearchResultsUtil.dart';

class SearchPlaceholder extends StatefulWidget {
  const SearchPlaceholder({super.key});

  @override
  _SearchPlaceholderState createState() => _SearchPlaceholderState();
}

class _SearchPlaceholderState extends State<SearchPlaceholder> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _clearResults();
      }
    });
  }

  void _clearResults() {
    Provider.of<SearchResultsUtil>(context, listen: false).clearResults();
  }

  void _searchGames(BuildContext context, String query) async {
    try {
      if (query.isEmpty) {
        _clearResults();
        return;
      }
      var games;
      if(kIsWeb) {
        games = await Provider.of<IgdbApiRepository>(context, listen: false).getGamesOnWeb(query);
      } else {
        games = await Provider.of<IgdbApiRepository>(context, listen: false).getGames(query);
      }
      Provider.of<SearchResultsUtil>(context, listen: false).updateResults(games, query);
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: KeyboardListener(
          focusNode: FocusNode(),
          onKeyEvent: (event) {
            if (event.logicalKey == LogicalKeyboardKey.escape) {
              _clearResults();
              FocusScope.of(context).unfocus();
            }
          },
          child: SizedBox(
            width: kIsWeb ? 300 : 200,
            height: 80,
            child: TextField(
              focusNode: _focusNode,
              onChanged: (query) => _searchGames(context, query),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey,
                labelText: 'Search Game',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.black,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}