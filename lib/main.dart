import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'providers/audio_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();
  await container.read(audioHandlerProvider.future);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MusixPlayerApp(),
    ),
  );
}
