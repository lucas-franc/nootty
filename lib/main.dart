import 'package:flutter/material.dart';
import 'package:nootty/home_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderScope;

void main() {
  runApp(const ProviderScope(child: NoottyApp()));
}

class NoottyApp extends StatelessWidget {
  const NoottyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.primaries.first),
        useMaterial3: true,
      ),
      home: const HomeView(),
    );
  }
}
