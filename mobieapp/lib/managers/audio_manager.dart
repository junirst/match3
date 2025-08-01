import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

// Sound effect types - moved outside class as required by Dart
enum SfxType {
  button,
  enemyAttack,
  enemyHurt,
  playerAttackSword,
  playerDamaged,
  playerMagicSpell,
  starTwinkle, // For star matches
}

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  // Additional SFX players for concurrent sounds
  final List<AudioPlayer> _sfxPlayers = [];

  bool _isBgmEnabled = true;
  bool _isSfxEnabled = true;
  bool _isBgmPlaying = false;
  
  // BGM monitoring
  Timer? _bgmMonitorTimer;
  String _currentBgmPath = 'audio/bgm.mp3';

  // Sound effect file mapping
  final Map<SfxType, String> _sfxFiles = {
    SfxType.button: 'audio/button.mp3',
    SfxType.enemyAttack: 'audio/enemyattack.mp3',
    SfxType.enemyHurt: 'audio/enemyhurt.mp3',
    SfxType.playerAttackSword: 'audio/playerattacksword.mp3',
    SfxType.playerDamaged: 'audio/playerdamaged.m4a',
    SfxType.playerMagicSpell: 'audio/playermagicspell.mp3',
    SfxType.starTwinkle: 'audio/magical-twinkle.mp3', // Star match effect
  };

  // Getters for audio settings
  bool get isBgmEnabled => _isBgmEnabled;
  bool get isSfxEnabled => _isSfxEnabled;
  bool get isBgmPlaying => _isBgmPlaying;

  // Initialize audio manager
  Future<void> init() async {
    try {
      print('Initializing AudioManager...');
      
      // Set player modes with error handling
      try {
        await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
        await _bgmPlayer.setVolume(0.7);
        print('BGM player configured');
      } catch (e) {
        print('Error configuring BGM player: $e');
      }
      
      try {
        await _sfxPlayer.setReleaseMode(ReleaseMode.stop);
        await _sfxPlayer.setVolume(1.0);
        print('SFX player configured');
      } catch (e) {
        print('Error configuring SFX player: $e');
      }

      // Set up listeners to track playback state
      _bgmPlayer.onPlayerStateChanged.listen((PlayerState state) {
        _isBgmPlaying = state == PlayerState.playing;
        print('BGM Player State: $state');
      });

      // Handle completion events (backup for looping)
      _bgmPlayer.onPlayerComplete.listen((_) {
        print('BGM completed, restarting immediately...');
        _isBgmPlaying = false;
        if (_isBgmEnabled) {
          // Restart BGM immediately
          Future.delayed(Duration(milliseconds: 100), () {
            playBackgroundMusic();
          });
        }
      });

      // Handle duration events to ensure looping works
      _bgmPlayer.onDurationChanged.listen((Duration duration) {
        print('BGM Duration: $duration');
      });
      
      // Start BGM monitoring timer
      _startBgmMonitoring();
      
      // SFX player listeners for debugging
      _sfxPlayer.onPlayerStateChanged.listen((PlayerState state) {
        print('SFX Player State: $state');
      });
      
      _sfxPlayer.onPlayerComplete.listen((_) {
        print('SFX playback completed');
      });
      
      // Reduce number of additional SFX players to avoid conflicts
      for (int i = 0; i < 2; i++) {
        try {
          AudioPlayer player = AudioPlayer();
          await player.setReleaseMode(ReleaseMode.stop);
          await player.setVolume(1.0);
          _sfxPlayers.add(player);
        } catch (e) {
          print('Error creating additional SFX player $i: $e');
        }
      }
      
      print('AudioManager initialized successfully');
    } catch (e) {
      print('Error initializing AudioManager: $e');
    }
  }

  // Start BGM monitoring to prevent stops
  void _startBgmMonitoring() {
    _bgmMonitorTimer?.cancel();
    _bgmMonitorTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (_isBgmEnabled && !_isBgmPlaying) {
        print('BGM Monitor: BGM stopped, restarting...');
        playBackgroundMusic();
      }
    });
    print('BGM monitoring started');
  }

  // Stop BGM monitoring
  void _stopBgmMonitoring() {
    _bgmMonitorTimer?.cancel();
    _bgmMonitorTimer = null;
    print('BGM monitoring stopped');
  }

  // Get available SFX player
  AudioPlayer _getAvailableSfxPlayer() {
    // Check if main SFX player is available
    if (_sfxPlayer.state != PlayerState.playing) {
      return _sfxPlayer;
    }
    
    // Check additional players
    for (AudioPlayer player in _sfxPlayers) {
      if (player.state != PlayerState.playing) {
        return player;
      }
    }
    
    // If all busy, use the first additional player
    return _sfxPlayers.isNotEmpty ? _sfxPlayers[0] : _sfxPlayer;
  }

  // Play background music
  Future<void> playBackgroundMusic() async {
    if (!_isBgmEnabled) {
      print('BGM is disabled, not playing');
      return;
    }
    
    try {
      print('Starting BGM playback...');
      await _bgmPlayer.stop(); // Stop any existing playback
      await _bgmPlayer.play(AssetSource(_currentBgmPath));
      _isBgmPlaying = true;
      print('BGM started successfully');
      
      // Ensure monitoring is active
      if (_bgmMonitorTimer == null || !_bgmMonitorTimer!.isActive) {
        _startBgmMonitoring();
      }
    } catch (e) {
      print('Error playing background music: $e');
      _isBgmPlaying = false;
      
      // Retry after a short delay
      Future.delayed(Duration(seconds: 2), () {
        if (_isBgmEnabled) {
          print('Retrying BGM playback...');
          playBackgroundMusic();
        }
      });
    }
  }

  // Stop background music
  Future<void> stopBackgroundMusic() async {
    _stopBgmMonitoring();
    await _bgmPlayer.stop();
    _isBgmPlaying = false;
    print('BGM stopped and monitoring disabled');
  }

  // Pause background music
  Future<void> pauseBackgroundMusic() async {
    if (_isBgmPlaying) {
      _stopBgmMonitoring();
      await _bgmPlayer.pause();
      _isBgmPlaying = false;
      print('BGM paused and monitoring disabled');
    }
  }

  // Resume background music
  Future<void> resumeBackgroundMusic() async {
    if (_isBgmEnabled && !_isBgmPlaying) {
      await _bgmPlayer.resume();
      _isBgmPlaying = true;
      _startBgmMonitoring();
      print('BGM resumed and monitoring enabled');
    }
  }

  // Check and ensure BGM is playing
  Future<void> ensureBgmPlaying() async {
    if (_isBgmEnabled && !_isBgmPlaying) {
      print('BGM not playing, restarting...');
      await playBackgroundMusic();
    }
  }

  // Play sound effect (generic method with specific type)
  Future<void> playSfx(SfxType type) async {
    if (!_isSfxEnabled) return;
    
    String filePath = _sfxFiles[type] ?? 'audio/button.mp3';
    
    try {
      print('Playing SFX: $filePath');
      
      // Try to use the BGM file as a fallback to test audio system
      try {
        AudioPlayer testPlayer = AudioPlayer();
        await testPlayer.setReleaseMode(ReleaseMode.stop);
        await testPlayer.setVolume(0.3); // Lower volume for SFX
        await testPlayer.play(AssetSource('audio/bgm.mp3'));
        print('SFX played successfully using BGM file as test');
        
        // Auto-dispose after short time
        Future.delayed(Duration(milliseconds: 200), () {
          testPlayer.stop();
          testPlayer.dispose();
        });
        
      } catch (e) {
        print('Audio system completely unavailable: $e');
      }
      
    } catch (e) {
      print('Error in playSfx method: $e');
    }
  }

  // Specific sound effect methods for easy use
  Future<void> playButtonSound() async => await playSfx(SfxType.button);
  Future<void> playEnemyAttack() async => await playSfx(SfxType.enemyAttack);
  Future<void> playEnemyHurt() async => await playSfx(SfxType.enemyHurt);
  Future<void> playPlayerAttackSword() async => await playSfx(SfxType.playerAttackSword);
  Future<void> playPlayerDamaged() async => await playSfx(SfxType.playerDamaged);
  Future<void> playPlayerMagicSpell() async => await playSfx(SfxType.playerMagicSpell);
  Future<void> playStarTwinkle() async => await playSfx(SfxType.starTwinkle);

  // Legacy method for backward compatibility
  Future<void> playSfxLegacy() async => await playButtonSound();

  // Test audio files
  Future<void> testAllAudioFiles() async {
    print('=== Testing all audio files ===');
    AudioPlayer testPlayer = AudioPlayer();
    await testPlayer.setReleaseMode(ReleaseMode.stop);
    
    for (var entry in _sfxFiles.entries) {
      print('Testing ${entry.key}: ${entry.value}');
      try {
        await testPlayer.stop();
        await testPlayer.play(AssetSource(entry.value));
        await Future.delayed(Duration(milliseconds: 500)); // Let it play briefly
        await testPlayer.stop();
        print('✓ ${entry.key} works');
      } catch (e) {
        print('✗ ${entry.key} failed: $e');
      }
    }
    await testPlayer.dispose();
    print('=== Audio test completed ===');
  }

  // Alternative method to test with a different file
  Future<void> playSfxTest() async {
    if (!_isSfxEnabled) return;
    try {
      // Try using the same file as BGM for testing
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('audio/bgm.mp3'));
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
    print('BGM toggled: ${_isBgmEnabled ? "ON" : "OFF"}');
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
    _stopBgmMonitoring();
    await _bgmPlayer.dispose();
    await _sfxPlayer.dispose();
    for (AudioPlayer player in _sfxPlayers) {
      await player.dispose();
    }
    _sfxPlayers.clear();
    print('AudioManager disposed');
  }
}
