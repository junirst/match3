import 'package:flutter/material.dart';
import 'audio_manager.dart';

class AudioLifecycleManager extends StatefulWidget {
  final Widget child;

  const AudioLifecycleManager({Key? key, required this.child})
      : super(key: key);

  @override
  _AudioLifecycleManagerState createState() => _AudioLifecycleManagerState();
}

class _AudioLifecycleManagerState extends State<AudioLifecycleManager>
    with WidgetsBindingObserver {
  final AudioManager _audioManager = AudioManager();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeAudio();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _audioManager.dispose();
    super.dispose();
  }

  Future<void> _initializeAudio() async {
    await _audioManager.init();
    if (_audioManager.isBgmEnabled && !_audioManager.isBgmPlaying) {
      await _audioManager.playBackgroundMusic();
    }
    if (_audioManager.isMainEnabled) {
      await _audioManager.playMain();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        if (_audioManager.isBgmEnabled) {
          _audioManager.resumeBackgroundMusic();
        }
        if (_audioManager.isMainEnabled) {
          _audioManager.resumeMain();
        }
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _audioManager.pauseBackgroundMusic();
        _audioManager.pauseMain();
        break;
      case AppLifecycleState.detached:
        _audioManager.stopBackgroundMusic();
        _audioManager.stopMain();
        break;
      case AppLifecycleState.hidden:
        _audioManager.pauseBackgroundMusic();
        _audioManager.pauseMain();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}