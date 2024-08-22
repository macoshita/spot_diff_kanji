import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'game_mode.g.dart';

enum GameMode {
  easy(
    name: "かんたん",
    row: 5,
    column: 5,
  ),
  normal(
    name: "ふつう",
    row: 12,
    column: 8,
  ),
  oni(
    name: "おに",
    column: 50,
    row: 50,
  ),
  ;

  final String name;
  final int column;
  final int row;

  const GameMode({
    required this.name,
    required this.column,
    required this.row,
  });
}

@Riverpod(keepAlive: true)
class CurrentGameMode extends _$CurrentGameMode {
  @override
  GameMode build() => GameMode.easy;

  void change(GameMode mode) {
    state = mode;
  }
}
