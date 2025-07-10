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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        // App came back to foreground, resume music
        AudioManager().resumeBackgroundMusic();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // App went to background, pause music
        AudioManager().pauseBackgroundMusic();
        break;
      case AppLifecycleState.detached:
        // App is being terminated
        AudioManager().stopBackgroundMusic();
        break;
      case AppLifecycleState.hidden:
        // App is hidden
        AudioManager().pauseBackgroundMusic();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
