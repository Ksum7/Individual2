import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class DiscoModel{
  bool _isEnabled;
  late Timer _colorTimer;
  final AudioPlayer _audioPlayer = AudioPlayer()..setSourceAsset("audio/disco.mp3")..setReleaseMode(ReleaseMode.loop);
  Color color = Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(0.6);
  DiscoModel() : _isEnabled = false;
  bool get isEnabled => _isEnabled;

  Future<void> dispose() {
    return _audioPlayer.dispose();
  }

  set isEnabled(bool value) {
    if (value == _isEnabled){
      return;
    }
    if (_isEnabled){
      _audioPlayer.pause();
      _colorTimer.cancel();
      _isEnabled = false;
    } else {
      _audioPlayer.resume();
      _colorTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
          color = Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(0.6);
        }
      );
      _isEnabled = true;
    }
  }
}
