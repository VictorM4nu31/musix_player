import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:just_waveform/just_waveform.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../data/models/song_model.dart';

/// Cached offline waveform extraction (static, not realtime FFT).
class WaveformService {
  WaveformService();

  Directory? _cacheDir;
  final Map<int, WaveformData> _memory = {};
  final Map<int, Future<WaveformData?>> _inflight = {};

  Future<Directory> _dir() async {
    if (_cacheDir != null) return _cacheDir!;
    final root = await getApplicationSupportDirectory();
    final dir = Directory(p.join(root.path, 'waveforms'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    _cacheDir = dir;
    return dir;
  }

  /// Returns extracted or synthetic waveform samples normalized 0–1.
  Future<WaveformData?> getWaveform(SongModel song) {
    final cached = _memory[song.id];
    if (cached != null) return SynchronousFuture(cached);

    return _inflight.putIfAbsent(song.id, () async {
      try {
        final data = await _loadOrExtract(song);
        if (data != null) {
          _memory[song.id] = data;
          _trimMemory();
        }
        return data;
      } finally {
        _inflight.remove(song.id);
      }
    });
  }

  Future<WaveformData?> _loadOrExtract(SongModel song) async {
    final dir = await _dir();
    final outFile = File(p.join(dir.path, '${song.id}.wave'));

    if (await outFile.exists() && await outFile.length() > 32) {
      try {
        final wave = await JustWaveform.parse(outFile);
        return WaveformData.fromJustWaveform(wave);
      } catch (_) {
        // Corrupt cache — regenerate.
      }
    }

    final path = song.filePath.trim();
    if (path.isNotEmpty) {
      final audioFile = File(path);
      if (await audioFile.exists()) {
        try {
          final extracted = await _extractFile(audioFile, outFile);
          if (extracted != null) return extracted;
        } catch (_) {
          // Fall through to synthetic.
        }
      }
    }

    return WaveformData.synthetic(
      songId: song.id,
      duration: song.duration,
    );
  }

  Future<WaveformData?> _extractFile(File audioIn, File waveOut) async {
    final completer = Completer<WaveformData?>();
    StreamSubscription<WaveformProgress>? sub;

    sub = JustWaveform.extract(
      audioInFile: audioIn,
      waveOutFile: waveOut,
      zoom: const WaveformZoom.pixelsPerSecond(48),
    ).listen(
      (progress) {
        if (progress.waveform != null && !completer.isCompleted) {
          completer.complete(
            WaveformData.fromJustWaveform(progress.waveform!),
          );
        }
      },
      onError: (Object e, StackTrace st) {
        if (!completer.isCompleted) completer.complete(null);
      },
      onDone: () {
        if (!completer.isCompleted) completer.complete(null);
      },
      cancelOnError: true,
    );

    final result = await completer.future.timeout(
      const Duration(seconds: 20),
      onTimeout: () => null,
    );
    await sub.cancel();
    return result;
  }

  void _trimMemory() {
    if (_memory.length <= 24) return;
    final keys = _memory.keys.take(_memory.length - 20).toList();
    for (final k in keys) {
      _memory.remove(k);
    }
  }

  void evict(int songId) {
    _memory.remove(songId);
  }
}

@immutable
class WaveformData {
  const WaveformData({
    required this.samples,
    required this.duration,
    this.isSynthetic = false,
  });

  final List<double> samples;
  final Duration duration;
  final bool isSynthetic;

  factory WaveformData.fromJustWaveform(Waveform wave) {
    final pixels = wave.length;
    if (pixels <= 0) {
      return WaveformData.synthetic(songId: 0, duration: wave.duration);
    }

    // Downsample pixel peaks to a render-friendly size.
    const target = 120;
    final step = math.max(1, pixels ~/ target);
    final peaks = <double>[];
    var maxAbs = 1.0;
    for (var i = 0; i < pixels; i += step) {
      final v = math.max(wave.getPixelMax(i).abs(), wave.getPixelMin(i).abs())
          .toDouble();
      peaks.add(v);
      if (v > maxAbs) maxAbs = v;
    }
    final samples = peaks
        .map((v) => (v / maxAbs).clamp(0.0, 1.0))
        .toList(growable: false);
    return WaveformData(samples: samples, duration: wave.duration);
  }

  factory WaveformData.synthetic({
    required int songId,
    required Duration duration,
  }) {
    const n = 96;
    final samples = List<double>.generate(n, (i) {
      final t = i / (n - 1);
      final seed = songId * 0.013 + i * 0.17;
      final envelope = math.sin(t * math.pi).clamp(0.15, 1.0);
      final a = 0.35 + 0.35 * math.sin(seed * 2.1);
      final b = 0.2 * math.sin(seed * 5.7 + t * 8);
      return ((a + b) * envelope).clamp(0.08, 1.0);
    });
    return WaveformData(
      samples: samples,
      duration: duration,
      isSynthetic: true,
    );
  }
}
