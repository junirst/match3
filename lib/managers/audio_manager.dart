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
    // Set looping for background music
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);

    // Set up listeners to track playback state
    _bgmPlayer.onPlayerStateChanged.listen((PlayerState state) {
      _isBgmPlaying = state == PlayerState.playing;
    });

    // Handle completion events (backup for looping)
    _bgmPlayer.onPlayerComplete.listen((_) {
      if (_isBgmEnabled) {
        playBackgroundMusic(); // Restart if loop fails
      }
    });
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
    if (_isBgmPlaying) {
      await _bgmPlayer.pause();
    }
  }

  // Resume background music
  Future<void> resumeBackgroundMusic() async {
    if (_isBgmEnabled && !_isBgmPlaying) {
      await _bgmPlayer.resume();
    }
  }

  // Play sound effect (no looping for SFX)
  Future<void> playSfx() async {
    if (!_isSfxEnabled) return;
    try {
      print('Attempting to play SFX from: assets/audio/sfx.mp3');
      // Stop any currently playing SFX first
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('bgm/sfx.mp3'));
      print('SFX started successfully');
    } catch (e) {
      print('Error playing sound effect: $e');
      print('Troubleshooting steps:');
      print('1. Check if assets/audio/sfx.mp3 exists in your project');
      print('2. Verify pubspec.yaml includes: assets: - assets/audio/');
      print('3. Run "flutter clean" and "flutter pub get"');
      print('4. Ensure the audio file is not corrupted');
    }
  }

  // Alternative method to test with a different file
  Future<void> playSfxTest() async {
    if (!_isSfxEnabled) return;
    try {
      // Try using the same file as BGM for testing
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('bgm/bgm.mp3'));
      print('Test SFX (using BGM file) played successfully');
    } catch (e) {
      print('Error playing test SFX: $e');
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

  // Set volumes
  Future<void> setBgmVolume(double volume) async {
    await _bgmPlayer.setVolume(volume);
  }

  Future<void> setSfxVolume(double volume) async {
    await _sfxPlayer.setVolume(volume);
  }

  Future<void> setVolume(String type, double volume) async {
    switch (type) {
      case 'bgm':
        await setBgmVolume(volume);
        break;
      case 'sfx':
        await setSfxVolume(volume);
        break;
    }
  }

  // Dispose audio players
  Future<void> dispose() async {
    await _bgmPlayer.dispose();
    await _sfxPlayer.dispose();
  }
}