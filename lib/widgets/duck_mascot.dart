import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../providers/task_provider.dart';

class DuckMascot extends ConsumerWidget {
  const DuckMascot({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mood = ref.watch(duckMoodProvider);
    String assetName;

    switch (mood) {
      case DuckMood.cool:
        assetName = 'assets/images/duck_cool.svg';
        break;
      case DuckMood.sleepy:
        assetName = 'assets/images/duck_sleepy.svg';
        break;
      case DuckMood.party:
        assetName = 'assets/images/duck_party.svg';
        break;
      case DuckMood.neutral:
      default:
        assetName = 'assets/images/duck.svg';
        break;
    }

    return AnimatedSwitcher( // Smooth transition between moods
      duration: const Duration(milliseconds: 500),
      child: SvgPicture.asset(
        assetName,
        key: ValueKey<String>(assetName),
        height: 150,
      ),
    );
  }
}
