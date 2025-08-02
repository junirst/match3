/// Game constants and configuration values
class GameConstants {
  // Grid configuration
  static const int gridSize = 8;
  static const int minMatchLength = 3;

  // Player stats
  static const int maxPlayerHealth = 100;
  static const int maxPowerPoints = 50;
  static const int shieldBlockThreshold = 10;

  // Base tile values (can be upgraded)
  static const int baseSwordDamage = 10;
  static const int baseHeartHeal = 5;
  static const int baseStarPowerGain = 5;
  static const int baseShieldPoints = 3;
  static const int basePowerAttackDamage = 50;

  // Enemy configuration (nerfed)
  static const int baseEnemyDamage = 3; // Reduced from 5 to 3
  static const int enemyDamageIncrement = 2; // Reduced from 5 to 2
  static const int maxEnemyDamage = 25; // Reduced from 50 to 25

  // Weapon passive values
  static const int daggerBonusHealing = 10;
  static const int daggerHeartThreshold = 5;
  static const double handPowerMultiplier = 2.0;

  // Animation and UI
  static const int animationDurationMs = 300;
  static const int cascadeDelayMs = 500;
  static const double tileAnimationScale = 1.2;

  // Audio
  static const double defaultVolume = 0.7;
  static const double sfxVolume = 0.5;

  // Upgrade system
  static const int maxUpgradeLevel = 15; // Increased from 4 to 15
  static const int upgradeValueIncrement = 1;

  // Private constructor to prevent instantiation
  GameConstants._();
}
