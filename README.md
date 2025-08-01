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
    - Plays a sword attack sound.
    - Notifies the game logic for a sword match (actual damage or effect handled externally).
  - **Shield** (tileType 1):
    - Plays a button sound.
    - Notifies the game logic for a shield match (actual effect handled externally).
  - **Heart** (tileType 2):
    - Plays a button sound.
    - Notifies the game logic for a heart match (actual effect handled externally).
  - **Star** (tileType 3):
    - Plays a magical twinkle sound.
    - Notifies the game logic for a star match (actual effect handled externally).
- **Matching 3 or more tiles** of the same type in a row or column triggers their effect and awards points.
- L and T shaped matches are merged and counted as a single match.

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
