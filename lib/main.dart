import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // return ShadApp();
    return ShadApp.custom(
      themeMode: ThemeMode.dark,
      darkTheme: ShadThemeData(
        brightness: Brightness.dark,
        colorScheme: const ShadSlateColorScheme.dark(),
      ),
      appBuilder: (context) {
        return MaterialApp(
          theme: ThemeData(),
          builder: (context, child) {
            return ShadAppBuilder(child: child ?? const SizedBox.shrink());
          },
        debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
