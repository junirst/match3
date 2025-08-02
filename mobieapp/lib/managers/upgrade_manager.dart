import '../utils/game_constants.dart';

class UpgradeManager {
  static UpgradeManager? _instance;
  static UpgradeManager get instance => _instance ??= UpgradeManager._();
  UpgradeManager._();

  // Current upgrade levels
  Map<String, int> _upgradeLevels = {
    'sword': 1,
    'heart': 1,
    'star': 1,
    'shield': 1,
  };

  // Base values for tiles using constants
  static const Map<String, int> _baseValues = {
    'sword': GameConstants.baseSwordDamage,
    'heart': GameConstants.baseHeartHeal,
    'star': GameConstants.baseStarPowerGain,
    'shield': GameConstants.baseShieldPoints,
  };

  // Removed loadUpgrades() method - all data should come from GameManager synchronization
  // Use syncWithUpgradeLevels() instead for proper data flow

  // Synchronize UpgradeManager with upgrade levels from GameManager
  void syncWithUpgradeLevels(Map<String, int> upgradeLevels) {
    _upgradeLevels = Map<String, int>.from(upgradeLevels);

    // Ensure all upgrade types exist with at least level 1
    for (String upgradeType in ['sword', 'heart', 'star', 'shield']) {
      if (!_upgradeLevels.containsKey(upgradeType)) {
        _upgradeLevels[upgradeType] = 1;
      }
    }

    print('UpgradeManager synced with levels: $_upgradeLevels');
  }

  int getUpgradeLevel(String tileType) {
    return _upgradeLevels[tileType] ?? 1;
  }

  // Get the effective value for a tile type based on upgrade level
  int getEffectiveValue(String tileType) {
    final baseValue = _baseValues[tileType] ?? 1;
    final upgradeLevel = _upgradeLevels[tileType] ?? 1;

    int effectiveValue;
    if (tileType == 'sword') {
      effectiveValue = _calculateSwordDamage(baseValue, upgradeLevel);
    } else if (tileType == 'heart') {
      effectiveValue = _calculateHeartHeal(baseValue, upgradeLevel);
    } else {
      // For star and shield, use simple increment
      effectiveValue = baseValue + (upgradeLevel - 1);
    }

    print(
      'UpgradeManager: $tileType level $upgradeLevel -> effective value $effectiveValue (base: $baseValue)',
    );
    return effectiveValue;
  }

  // Calculate sword damage with new formula:
  // 1 level = +1 damage, every 5 levels = +2 damage
  int _calculateSwordDamage(int baseValue, int level) {
    int totalBonus = 0;

    for (int i = 1; i < level; i++) {
      if (i % 5 == 0) {
        totalBonus += 2; // Every 5th level gives +2
      } else {
        totalBonus += 1; // Regular levels give +1
      }
    }

    return baseValue + totalBonus;
  }

  // Calculate heart healing with new formula:
  // 1 level = +5 health, every 5 levels = +10 health
  int _calculateHeartHeal(int baseValue, int level) {
    int totalBonus = 0;

    for (int i = 1; i < level; i++) {
      if (i % 5 == 0) {
        totalBonus += 10; // Every 5th level gives +10
      } else {
        totalBonus += 5; // Regular levels give +5
      }
    }

    return baseValue + totalBonus;
  }

  // Calculate permanent bonuses from upgrades
  int getPermanentHealthBonus() {
    int totalBonus = 0;
    for (String upgradeType in ['sword', 'heart', 'star', 'shield']) {
      final level = _upgradeLevels[upgradeType] ?? 1;
      totalBonus +=
          (level ~/ 5) *
          20; // Every 5 levels adds 20 permanent hearts (increased from 2)
    }
    return totalBonus;
  }

  int getPermanentDamageBonus() {
    int totalBonus = 0;
    for (String upgradeType in ['sword', 'heart', 'star', 'shield']) {
      final level = _upgradeLevels[upgradeType] ?? 1;
      totalBonus += (level ~/ 5) * 2; // Every 5 levels adds 2 permanent damage
    }
    return totalBonus;
  }

  int getPermanentPowerBonus() {
    int totalBonus = 0;
    for (String upgradeType in ['sword', 'heart', 'star', 'shield']) {
      final level = _upgradeLevels[upgradeType] ?? 1;
      totalBonus +=
          (level ~/ 5) * 5; // Every 5 levels adds 5 permanent max power
    }
    return totalBonus;
  }

  // Get effective values for each tile type
  int get effectiveSwordDamage => getEffectiveValue('sword');
  int get effectiveHeartHeal => getEffectiveValue('heart');
  int get effectiveStarPowerGain => getEffectiveValue('star');
  int get effectiveShieldPoints => getEffectiveValue('shield');

  // Update upgrade level (for UI synchronization)
  void updateUpgradeLevel(String tileType, int level) {
    _upgradeLevels[tileType] = level;
    print('UpgradeManager: Updated $tileType to level $level');
  }
}
