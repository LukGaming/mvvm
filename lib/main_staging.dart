import 'package:flutter/material.dart';
import 'package:mvvm/config/dependencies.dart';
import 'package:mvvm/main.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: providersRemote,
      child: const MyApp(),
    ),
  );
}
