import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spot_diff_kanji/features/game_mode.dart';
import 'package:spot_diff_kanji/features/quiz.dart';
import 'package:spot_diff_kanji/title_screen.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

part 'game_screen.g.dart';

enum _Scene {
  start,
  gaming,
  result,
}

@riverpod
class _CurrentScene extends _$CurrentScene {
  @override
  _Scene build() => _Scene.start;

  void start() {
    state = _Scene.gaming;
  }

  void end() {
    state = _Scene.result;
  }
}

@riverpod
class _Stopwatch extends _$Stopwatch {
  @override
  String build() {
    ref.onDispose(() {
      _timer?.cancel();
    });

    return "00:00.000";
  }

  Timer? _timer;
  final _stopwatch = Stopwatch();

  void start() {
    _stopwatch
      ..reset()
      ..start();
    _timer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      final duration = _stopwatch.elapsed;
      state = "${duration.inMinutes.toString().padLeft(2, "0")}"
          ":${(duration.inSeconds % 60).toString().padLeft(2, "0")}"
          ".${(duration.inMilliseconds % 1000).toString().padLeft(3, "0")}";
    });
  }

  void stop() {
    _stopwatch.stop();
    _timer?.cancel();
  }
}

class GameScreen extends HookConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final padding = MediaQuery.paddingOf(context);
    final scene = ref.watch(_currentSceneProvider);
    ref.watch(_stopwatchProvider.notifier);
    ref.watch(_helpModeProvider.notifier);
    return Scaffold(
      body: Stack(
        children: [
          if (scene == _Scene.start) const Center(child: _Start()),
          if (scene == _Scene.gaming) const _Table(),
          Positioned(
            bottom: 16 + padding.bottom,
            left: 16 + padding.left,
            child: const _Timer(),
          ),
          if (scene == _Scene.result) Center(child: _Result()),
        ],
      ),
    );
  }
}

class _Start extends HookConsumerWidget {
  const _Start();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countdown = useState(3);

    useEffect(() {
      final timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (countdown.value == 0) {
          ref.read(_currentSceneProvider.notifier).start();
          ref.read(_stopwatchProvider.notifier).start();
          timer.cancel();
        } else {
          countdown.value--;
        }
      });
      return timer.cancel;
    }, const []);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "ちがう漢字を\nタップ！",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displayMedium,
        ),
        const Gap(16),
        Text(
          countdown.value.toString(),
          style: Theme.of(context).textTheme.displayLarge,
        ),
      ],
    );
  }
}

class _Result extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "正解！",
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const Gap(16),
            Text(
              "かかった時間: ${ref.watch(_stopwatchProvider)}",
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const Gap(16),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) {
                    return const TitleScreen();
                  },
                ));
              },
              child: const Text("タイトルへ"),
            ),
          ],
        ),
      ),
    );
  }
}

class _Timer extends HookConsumerWidget {
  const _Timer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final time = ref.watch(_stopwatchProvider);

    return GestureDetector(
      onDoubleTap: () {
        ref.read(_helpModeProvider.notifier).toggle();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "おたすけモード: ${ref.read(_helpModeProvider) ? "ON" : "OFF"}",
            ),
          ),
        );
      },
      child: Text(
        time,
        style: Theme.of(context).textTheme.displayMedium,
      ),
    );
  }
}

@riverpod
({int row, int column}) _answerPosition(_AnswerPositionRef ref) {
  final mode = ref.watch(currentGameModeProvider);

  return (
    row: Random().nextInt(mode.row),
    column: Random().nextInt(mode.column),
  );
}

@riverpod
class _HelpMode extends _$HelpMode {
  @override
  bool build() => false;

  void toggle() {
    state = !state;
  }
}

class _Table extends HookConsumerWidget {
  const _Table();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final padding = MediaQuery.paddingOf(context);
    final mode = ref.watch(currentGameModeProvider);
    final quiz = ref.watch(quizProvider);
    final answerPosition = ref.watch(_answerPositionProvider);

    return TableView.builder(
      cellBuilder: (BuildContext context, TableVicinity vicinity) {
        final isAnswer = vicinity.row == answerPosition.row &&
            vicinity.column == answerPosition.column;

        return TableViewCell(
          child: Center(
            child: isAnswer
                ? const _Answer()
                : Text(
                    quiz.t,
                    style: const TextStyle(fontSize: 32),
                  ),
          ),
        );
      },
      columnCount: mode.column,
      columnBuilder: (int column) {
        return TableSpan(
          extent: const FixedTableSpanExtent(48),
          padding: SpanPadding(
            leading: column == 0 ? padding.left : 0,
            trailing: column == mode.column - 1 ? padding.right : 0,
          ),
        );
      },
      rowCount: mode.row,
      rowBuilder: (int row) {
        return TableSpan(
          extent: const FixedTableSpanExtent(48),
          padding: SpanPadding(
            leading: row == 0 ? padding.top : 0,
            trailing: row == mode.row - 1 ? padding.bottom + 100 : 0,
          ),
        );
      },
      diagonalDragBehavior: DiagonalDragBehavior.free,
    );
  }
}

class _Answer extends HookConsumerWidget {
  const _Answer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quiz = ref.watch(quizProvider);
    final helpMode = ref.watch(_helpModeProvider);

    final controller = useAnimationController(
      duration: const Duration(milliseconds: 500),
    );

    final curve = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    );
    final fadeOutAnimation = Tween(begin: 1.0, end: 0.0).animate(curve);
    final scaleOutAnimation = Tween(begin: 1.0, end: 3.0).animate(curve);

    return GestureDetector(
      onTap: () async {
        ref.read(_stopwatchProvider.notifier).stop();
        await controller.forward();
        if (!context.mounted) return;
        ref.read(_currentSceneProvider.notifier).end();
      },
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Transform.scale(
            scale: scaleOutAnimation.value,
            child: FadeTransition(
              opacity: fadeOutAnimation,
              child: child,
            ),
          );
        },
        child: Transform.scale(
          scale: helpMode ? 3.0 : 1.0,
          child: Text(
            quiz.a,
            style: TextStyle(
              fontSize: 32,
              color: helpMode ? Colors.red : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
