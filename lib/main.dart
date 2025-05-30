import 'package:m3u8_downloader/pages/home.dart';
import 'package:m3u8_downloader/pages/settings.dart';
import 'package:m3u8_downloader/pages/download.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  const fixedSize = Size(1000, 800);

  WindowOptions windowOptions = WindowOptions(
    size: fixedSize,
    minimumSize: fixedSize, // Prevent resizing smaller
    maximumSize: fixedSize, // Prevent resizing larger
    center: true,
    // backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setMaximizable(false); // Disable maximize button
    await windowManager.show();
    await windowManager.focus();
  });

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // Initialize sqflite for desktop platforms
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // return ShadApp();
    return MaterialApp(
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/home': (context) => const HomePage(),
        '/settings': (context) => const SettingsPage(),
        '/downloads': (context) => const DownloadPage(),
      },
    );
  }
}
