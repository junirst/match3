import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _isBgmEnabled = true;
  bool _isSfxEnabled = true;
  bool _isBgmPlaying = false;

  // Getters for audio settings
  bool get isBgmEnabled => _isBgmEnabled;
  bool get isSfxEnabled => _isSfxEnabled;
  bool get isBgmPlaying => _isBgmPlaying;

  // Initialize audio manager
  Future<void> init() async {
    // Set audio mode to ambient for background music
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
  }

  // Play background music
  Future<void> playBackgroundMusic() async {
    if (!_isBgmEnabled || _isBgmPlaying) return;

    try {
      await _bgmPlayer.play(AssetSource('lib/bgm/bgm.mp3'));
      _isBgmPlaying = true;
    } catch (e) {
      print('Error playing background music: $e');
    }
  }

  // Stop background music
  Future<void> stopBackgroundMusic() async {
    await _bgmPlayer.stop();
    _isBgmPlaying = false;
  }

  // Pause background music
  Future<void> pauseBackgroundMusic() async {
    await _bgmPlayer.pause();
  }

  // Resume background music
  Future<void> resumeBackgroundMusic() async {
    if (_isBgmEnabled) {
      await _bgmPlayer.resume();
    }
  }

  // Play sound effect
  Future<void> playSfx() async {
    if (!_isSfxEnabled) return;

    try {
      await _sfxPlayer.play(AssetSource('lib/bgm/sfx.mp3'));
    } catch (e) {
      print('Error playing sound effect: $e');
    }
  }

  // Toggle background music on/off
  void toggleBackgroundMusic() {
    _isBgmEnabled = !_isBgmEnabled;
    if (_isBgmEnabled) {
      playBackgroundMusic();
    } else {
      stopBackgroundMusic();
    }
  }

  // Toggle sound effects on/off
  void toggleSoundEffects() {
    _isSfxEnabled = !_isSfxEnabled;
  }

  // Set background music volume (0.0 to 1.0)
  Future<void> setBgmVolume(double volume) async {
    await _bgmPlayer.setVolume(volume);
  }

  // Set sound effects volume (0.0 to 1.0)
  Future<void> setSfxVolume(double volume) async {
    await _sfxPlayer.setVolume(volume);
  }

  // Dispose audio players
  Future<void> dispose() async {
    await _bgmPlayer.dispose();
    await _sfxPlayer.dispose();
  }
}
