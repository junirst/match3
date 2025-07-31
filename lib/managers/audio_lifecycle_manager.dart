import 'package:flutter/material.dart';
import '../managers/audio_manager.dart';

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
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        if (_audioManager.isBgmEnabled) {
          _audioManager.resumeBackgroundMusic();
        }
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _audioManager.pauseBackgroundMusic();
        break;
      case AppLifecycleState.detached:
        _audioManager.stopBackgroundMusic();
        break;
      case AppLifecycleState.hidden:
        _audioManager.pauseBackgroundMusic();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}