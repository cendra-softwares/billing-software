import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seo_biling/features/auth/presentation/providers/theme_provider.dart';

class AppTitleBar extends ConsumerWidget {
  const AppTitleBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    return WindowTitleBarBox(
      child: Container(
        color: theme.primaryColor,
        child: Row(
          children: [
            Expanded(child: MoveWindow()),
            const WindowButtons(),
          ],
        ),
      ),
    );
  }
}

class WindowButtons extends ConsumerWidget {
  const WindowButtons({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final buttonColors = WindowButtonColors(
      iconNormal: theme.colorScheme.onPrimary,
      mouseOver: theme.colorScheme.primaryContainer,
      mouseDown: theme.colorScheme.secondaryContainer,
      iconMouseOver: theme.colorScheme.onPrimaryContainer,
    );

    final closeButtonColors = WindowButtonColors(
        mouseOver: const Color(0xFFD32F2F),
        mouseDown: const Color(0xFFB71C1C),
        iconNormal: theme.colorScheme.onPrimary,
        iconMouseOver: Colors.white);

    return Row(
      children: [
        MinimizeWindowButton(colors: buttonColors),
        MaximizeWindowButton(colors: buttonColors),
        CloseWindowButton(colors: closeButtonColors),
      ],
    );
  }
}