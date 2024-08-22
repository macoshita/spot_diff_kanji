import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spot_diff_kanji/features/game_mode.dart';

part 'quiz.g.dart';

typedef Quiz = ({
  GameMode mode,
  String t,
  String a,
});

const _quizList = <Quiz>[
  (
    mode: GameMode.easy,
    t: "巳",
    a: "巴",
  ),
  (
    mode: GameMode.normal,
    t: "鳥",
    a: "烏",
  ),
  (
    mode: GameMode.oni,
    t: "日",
    a: "曰",
  )
];

@riverpod
Quiz quiz(QuizRef ref) {
  final mode = ref.watch(currentGameModeProvider);
  final list = _quizList.where((q) => q.mode == mode).toList();
  list.shuffle();
  return list.first;
}
