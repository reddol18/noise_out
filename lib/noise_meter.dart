library noise_meter;

import 'dart:async';
import 'dart:core';
import 'dart:math';
import 'package:audio_streamer/audio_streamer.dart';
import 'package:flutter/services.dart';

/// Holds a decibel value for a noise level reading.
class NoiseReading {
  late double _meanDecibel, _maxDecibel;
  double abs(double n) {
    return sqrt(n * n);
  }

  NoiseReading(List<double> volumes) {
    // sorted volumes such that the last element is max amplitude
    // compute average peak-amplitude using the min and max amplitude
    double hold = 0.9999;
    double tresh = 0.7;
    double env = 0.0;
    double sum = 0.0;
    double maxAmp = pow(2, 15) + 0.0;
    int pc = 0;
    for(int i=0;i<volumes.length;i++) {
      double tmp = abs(volumes[i]);
      //env = env * hold + tmp * (1-hold);
      //if (env <= tresh) {
        sum += tmp * maxAmp;
        pc++;
      //}
    }
    volumes.sort();
    double max = volumes.last;
    double rms = sum / pc;
    if (pc > 0) {
      _maxDecibel = 20 * (log(max * maxAmp) * log10e);
      _meanDecibel = 20 * (log(rms) / ln10);
    } else {
      _maxDecibel = 20 * (log(max) * log10e);
      _meanDecibel = _maxDecibel;
    }
  }

  /// Maximum measured decibel reading.
  double get maxDecibel => _maxDecibel;

  /// Mean decibel across readings.
  double get meanDecibel => _meanDecibel;

  @override
  String toString() =>
      '$runtimeType - meanDecibel: $meanDecibel, maxDecibel: $maxDecibel';
}

/// A [NoiseMeter] provides continous access to noise reading via the [noiseStream].
class NoiseMeter {
  AudioStreamer _streamer = AudioStreamer();
  late StreamController<NoiseReading> _controller;
  Stream<NoiseReading>? _stream;

  // The error callback function.
  Function? onError;

  /// Create a [NoiseMeter].
  /// The [onError] callback must be of type `void Function(Object error)`
  /// or `void Function(Object error, StackTrace)`.
  NoiseMeter([this.onError]);

  /// The rate at which the audio is sampled
  static int get sampleRate => AudioStreamer.sampleRate;

  /// The stream of noise readings.
  Stream<NoiseReading> get noiseStream {
    if (_stream == null) {
      _controller = StreamController<NoiseReading>.broadcast(
          onListen: _start, onCancel: _stop);
      _stream = (onError != null)
          ? _controller.stream.handleError(onError!)
          : _controller.stream;
    }
    return _stream!;
  }

  /// Whenever an array of PCM data comes in,
  /// they are converted to a [NoiseReading],
  /// and then send out via the stream
  void _onAudio(List<double> buffer) => _controller.add(NoiseReading(buffer));

  void _onInternalError(PlatformException e) {
    _stream = null;
    _controller.addError(e);
  }

  /// Start noise monitoring.
  /// This will trigger a permission request
  /// if it hasn't yet been granted
  void _start() async {
    try {
      _streamer.start(_onAudio, _onInternalError);
    } catch (error) {
      print(error);
    }
  }

  /// Stop noise monitoring
  void _stop() async => await _streamer.stop();
}
