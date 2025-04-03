import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:mvvm/config/dependencies.dart';
import 'package:mvvm/main.dart';
import 'package:provider/provider.dart';

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((log) {
    print("[${log.level}] - [${log.loggerName}] - ${log.message}");
    if (log.stackTrace != null) {
      print(log.error);
      print(log.stackTrace);
    }
  });

  runApp(
    MultiProvider(
      providers: providersLocal,
      child: const MyApp(),
    ),
  );
}
