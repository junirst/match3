# match3

A new Flutter project implementing classic Match-3 game mechanics with RPG elements.

## Game Mechanics

- **Enemy Damage**: The enemy attacks after each player turn, with increasing damage each round (max 50).
- **Combos/Cascades**: Matching tiles can cause cascades, increasing your score multiplier.
- **Tile Types**:
  - **Sword**: Deals damage to enemies.
  - **Shield**: Builds shield points to block attacks.
  - **Heart**: Heals the player, can generate excess health.
  - **Star**: Charges special power attacks.

## Damage Priority

1. Shield blocks damage if 10+ points.
2. Excess health absorbs damage next.
3. Remaining damage reduces main health.

## Scoring

- 100 points per tile matched.
- Score is multiplied for each cascade combo.

## Power Usage

- Special powers are triggered via UI when the power bar is full.

## Getting Started

This project is a starting point for a Flutter application.

### Resources

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
- [Flutter documentation](https://docs.flutter.dev/)

### Running the Game

1. Install Flutter: [Flutter Install Guide](https://docs.flutter.dev/get-started/install)
2. Clone the repository:
   ```bash
   git clone https://github.com/junirst/match3.git
   ```
3. Navigate to the main app directory (e.g., `/mobieapp`).
4. Run the app:
   ```bash
   flutter run
   ```

## Customization

- Launch screen images can be customized in `mobieapp/ios/Runner/Assets.xcassets/LaunchImage.imageset/`.

## License

(Add your license notice here.)

---

*For more details, review the code in `lib/core/flame_match3_game.dart`.*
