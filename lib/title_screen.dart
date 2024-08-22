import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spot_diff_kanji/features/game_mode.dart';
import 'package:spot_diff_kanji/game_screen.dart';

class TitleScreen extends HookConsumerWidget {
  const TitleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "漢字さがし",
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const Gap(32),
            for (final mode in GameMode.values) _StartButton(mode),
          ],
        ),
      ),
    );
  }
}

class _StartButton extends HookConsumerWidget {
  const _StartButton(this.mode);

  final GameMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return OutlinedButton(
      style: theme.outlinedButtonTheme.style,
      onPressed: () {
        ref.read(currentGameModeProvider.notifier).change(mode);
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) {
            return const GameScreen();
          },
        ));
      },
      child: Text(mode.name),
    );
  }
}
