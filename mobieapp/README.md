# Match-3 Game Mechanics

## Enemy Damage
- **Enemy attacks** occur after the player's turn ends (after all matches and cascades are processed).
- The enemy deals **scaling damage** that increases with each turn:
  - Turn 1: 5 damage
  - Turn 2: 10 damage  
  - Turn 3: 15 damage
  - And so on, increasing by 5 damage each turn
  - **Maximum damage**: 50 (reached on turn 10 and maintained thereafter)
- Enemy attacks are triggered automatically and play a sound effect.
- If the enemy's health is zero or below, the enemy turn is skipped.

## Combo / Stacking Tiles
- **Combos** (cascades) happen when new matches are formed after tiles fall to fill empty spaces.
- Each time a new set of matches is found in a single turn (including cascades), the combo count increases.
- The score for each match is multiplied by the current combo count (e.g., 2nd combo = double points).
- All matches in a cascade are processed before the enemy's turn.

## Tile Types and Their Effects
- There are four tile types:
  - **Sword** (tileType 0):
    - **Effect**: Deals damage to enemies
    - **Base damage**: 10 per set of 3 tiles
    - **Bonus**: +2 damage for each tile beyond 3 (e.g., 4-match = 12 damage, 5-match = 14 damage)
    - Plays a sword attack sound
  - **Shield** (tileType 1):
    - **Effect**: Stores shield points for damage blocking
    - **Shield points**: Each tile contributes 1 point (3-match = 3 points, 4-match = 4 points, etc.)
    - **Blocking**: When you have 10+ shield points, the next enemy attack is completely blocked
    - **Reset**: Shield points reset to 0 after blocking an attack
    - Displays as blue 🛡️X counter in UI
  - **Heart** (tileType 2):
    - **Effect**: Heals the player
    - **Base healing**: 5 HP per set of 3 tiles
    - **Bonus**: +2 HP for each tile beyond 3 (e.g., 4-match = 7 HP, 5-match = 9 HP)
    - **Excess health**: Any healing beyond max HP (100) becomes excess health that absorbs damage
    - **Excess priority**: Excess health absorbs damage before main HP (but after shield blocking)
    - Displays as green (+X) counter next to health bar
  - **Star** (tileType 3):
    - **Effect**: Generates power points for special attacks
    - **Base power**: 5 points per set of 3 tiles
    - **Bonus**: +2 points for each tile beyond 3
    - **Power attack**: When power bar is full (50 points), can unleash a devastating attack
    - Plays a magical twinkle sound
- **Matching 3 or more tiles** of the same type in a row or column triggers their effect and awards points.
- L and T shaped matches are merged and counted as a single match.

## Damage Priority System
When the player takes damage, it is absorbed in the following order:
1. **Shield Protection**: If player has 10+ shield points, ALL damage is blocked and shield resets to 0
2. **Excess Health**: Any remaining damage is absorbed by excess health first
3. **Main Health**: Finally, any remaining damage affects the main health bar

This creates a strategic layering system where players can build up multiple forms of protection.

## Scoring
- Each tile in a match is worth 100 points.
- The score is multiplied by the combo count if multiple cascades occur in a single turn.

## Power Usage
- When the player can use a special power, it is triggered via the UI and not by matching tiles.
- Power usage plays a magic spell sound and notifies the game logic for a power attack.

---
For more details, see the code in `lib/core/flame_match3_game.dart`.
# match3

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
