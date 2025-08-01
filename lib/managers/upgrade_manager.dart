import 'package:shared_preferences/shared_preferences.dart';
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

  Future<void> loadUpgrades() async {
    final prefs = await SharedPreferences.getInstance();
    _upgradeLevels['sword'] = prefs.getInt('upgrade_sword') ?? 1;
    _upgradeLevels['heart'] = prefs.getInt('upgrade_heart') ?? 1;
    _upgradeLevels['star'] = prefs.getInt('upgrade_star') ?? 1;
    _upgradeLevels['shield'] = prefs.getInt('upgrade_shield') ?? 1;
  }

  int getUpgradeLevel(String tileType) {
    return _upgradeLevels[tileType] ?? 1;
  }

  // Get the effective value for a tile type based on upgrade level
  int getEffectiveValue(String tileType) {
    final baseValue = _baseValues[tileType] ?? 1;
    final upgradeLevel = _upgradeLevels[tileType] ?? 1;
    // Each upgrade level adds +1 to the base value
    return baseValue + (upgradeLevel - 1);
  }

  // Get effective values for each tile type
  int get effectiveSwordDamage => getEffectiveValue('sword');
  int get effectiveHeartHeal => getEffectiveValue('heart');
  int get effectiveStarPowerGain => getEffectiveValue('star');
  int get effectiveShieldPoints => getEffectiveValue('shield');

  // Update upgrade level (for UI synchronization)
  void updateUpgradeLevel(String tileType, int level) {
    _upgradeLevels[tileType] = level;
  }
}
