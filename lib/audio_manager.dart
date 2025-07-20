import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _mainPlayer = AudioPlayer();

  bool _isBgmEnabled = true;
  bool _isSfxEnabled = true;
  bool _isMainEnabled = true;
  bool _isBgmPlaying = false;

  // Getters for audio settings
  bool get isBgmEnabled => _isBgmEnabled;
  bool get isSfxEnabled => _isSfxEnabled;
  bool get isMainEnabled => _isMainEnabled;
  bool get isBgmPlaying => _isBgmPlaying;

  // Initialize audio manager
  Future<void> init() async {
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _mainPlayer.setReleaseMode(ReleaseMode.loop);
  }

  // Play background music
  Future<void> playBackgroundMusic() async {
    if (!_isBgmEnabled || _isBgmPlaying) return;
    try {
      await _bgmPlayer.play(AssetSource('bgm/bgm.mp3'));
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
      print('Attempting to play SFX from: assets/bgm/sfx.mp3');
      await _sfxPlayer.play(AssetSource('bgm/sfx.mp3'));
    } catch (e) {
      print('Error playing sound effect: $e');
    }
  }

  // Play main sound
  Future<void> playMain() async {
    if (!_isMainEnabled) return;
    try {
      await _mainPlayer.play(AssetSource('bgm/main.mp3'));
    } catch (e) {
      print('Error playing main sound: $e');
    }
  }

  // Stop main sound
  Future<void> stopMain() async {
    await _mainPlayer.stop();
  }

  // Pause main sound
  Future<void> pauseMain() async {
    await _mainPlayer.pause();
  }

  // Resume main sound
  Future<void> resumeMain() async {
    if (_isMainEnabled) {
      await _mainPlayer.resume();
    }
  }

  // Toggle background music
  void toggleBackgroundMusic() {
    _isBgmEnabled = !_isBgmEnabled;
    if (_isBgmEnabled) {
      playBackgroundMusic();
    } else {
      stopBackgroundMusic();
    }
  }

  // Toggle sound effects
  void toggleSoundEffects() {
    _isSfxEnabled = !_isSfxEnabled;
  }

  // Toggle main sound
  void toggleMain() {
    _isMainEnabled = !_isMainEnabled;
    if (_isMainEnabled) {
      playMain();
    } else {
      stopMain();
    }
  }

  // Set volumes
  Future<void> setBgmVolume(double volume) async {
    await _bgmPlayer.setVolume(volume);
  }

  Future<void> setSfxVolume(double volume) async {
    await _sfxPlayer.setVolume(volume);
  }

  Future<void> setMainVolume(double volume) async {
    await _mainPlayer.setVolume(volume);
  }

  Future<void> setVolume(String type, double volume) async {
    switch (type) {
      case 'bgm':
        await setBgmVolume(volume);
        break;
      case 'sfx':
        await setSfxVolume(volume);
        break;
      case 'main':
        await setMainVolume(volume);
        break;
    }
  }

  // Dispose audio players
  Future<void> dispose() async {
    await _bgmPlayer.dispose();
    await _sfxPlayer.dispose();
    await _mainPlayer.dispose();
  }
}