import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'audio_manager.dart';

class Match3Game extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  static const int gridSize = 5;
  late List<List<GameTile?>> grid;
  late final double tileSize;
  late final Vector2 gridOffset;
  final Random _random = Random();
  bool imagesLoaded = false;

  // Game state
  bool isPlayerTurn = true;
  bool isProcessingTurn = false;
  bool hasShieldProtection = false;
  GameTile? selectedTile;
  int score = 0;

  // Combat stats
  int enemyHealth = 100;
  int maxEnemyHealth = 100;
  int playerHealth = 100;
  int maxPlayerHealth = 100;
  int playerPower = 0;
  int maxPlayerPower = 50; // Sync with TowerGameplayScreen
  bool hasActiveMatches = false;
  bool canUsePower = false;

  // Callbacks
  Function(int tileType, int matchCount, int score)? onMatchCallback;
  Function()? onAllMatchesCompleteCallback;
  Function(int damage)? onMobAttackCallback;

  // Combo system
  int _comboCount = 0;
  int _cascadeCount = 0;

  // Assets
  final Map<int, String> tileSprites = {
    0: 'sword.png',
    1: 'shield.png',
    2: 'heart.png',
    3: 'star.png',
  };

  final List<Color> tileColors = [
    const Color(0xFFE0E0E0), // sword - silver
    const Color(0xFF90CAF9), // shield - blue
    const Color(0xFFEF9A9A), // heart - red
    const Color(0xFFFFF59D), // star - yellow
  ];

  @override
  Future<void> onLoad() async {
    camera.backdrop.removeAll(camera.backdrop.children);

    // Calculate responsive sizing
    final screenSize = size;
    tileSize = screenSize.x * 0.12;
    final totalGridWidth = gridSize * tileSize + (gridSize - 1) * 4;
    final totalGridHeight = gridSize * tileSize + (gridSize - 1) * 4;
    gridOffset = Vector2(
      (screenSize.x - totalGridWidth) / 2,
      (screenSize.y - totalGridHeight) / 2,
    );

    // Initialize grid
    grid = List.generate(gridSize, (i) => List.generate(gridSize, (j) => null));

    // Load sprites
    try {
      await Future.wait([
        images.load('sword.png'),
        images.load('shield.png'),
        images.load('heart.png'),
        images.load('star.png'),
      ]);
      imagesLoaded = tileSprites.values.every((img) => images.containsKey(img));
      print(imagesLoaded ? 'All sprites loaded' : 'Using fallback rendering');
    } catch (e) {
      print('Failed to load sprites: $e');
    }

    await _createInitialGrid();
  }

  @override
  Color backgroundColor() => const Color(0x00000000);

  Future<void> _createInitialGrid() async {
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        int tileType;
        do {
          tileType = _random.nextInt(4);
        } while (_wouldCreateMatch(row, col, tileType));
        final tile = GameTile(
          tileType: tileType,
          gridRow: row,
          gridCol: col,
          tileSize: tileSize,
          game: this,
        );
        tile.position = _calculateTilePosition(row, col);
        grid[row][col] = tile;
        add(tile);
      }
    }
    isProcessingTurn = false;
    hasActiveMatches = false;
    print(
      'Initial grid created: PlayerTurn=$isPlayerTurn, Processing=$isProcessingTurn',
    );
  }

  bool _wouldCreateMatch(int row, int col, int tileType) {
    // Check horizontal
    if (col >= 2 &&
        grid[row][col - 1]?.tileType == tileType &&
        grid[row][col - 2]?.tileType == tileType) {
      return true;
    }
    // Check vertical
    if (row >= 2 &&
        grid[row - 1][col]?.tileType == tileType &&
        grid[row - 2][col]?.tileType == tileType) {
      return true;
    }
    return false;
  }

  Vector2 _calculateTilePosition(int row, int col) {
    return Vector2(
      gridOffset.x + col * (tileSize + 4),
      gridOffset.y + row * (tileSize + 4),
    );
  }

  void setPlayerTurn(bool value) {
    isPlayerTurn = value;
    print('Set PlayerTurn=$isPlayerTurn');
  }

  void setProcessingTurn(bool value) {
    isProcessingTurn = value;
    print('Set Processing=$isProcessingTurn');
  }

  void onTileTapped(GameTile tile) {
    if (!isPlayerTurn || isProcessingTurn) {
      print(
        'Cannot interact: PlayerTurn=$isPlayerTurn, Processing=$isProcessingTurn',
      );
      return;
    }

    AudioManager().playSfx();

    if (selectedTile == null) {
      selectedTile = tile;
      tile.setSelected(true);
    } else if (selectedTile == tile) {
      selectedTile!.setSelected(false);
      selectedTile = null;
    } else if (_areAdjacent(selectedTile!, tile)) {
      _swapTiles(selectedTile!, tile);
      selectedTile!.setSelected(false);
      selectedTile = null;
    } else {
      selectedTile!.setSelected(false);
      selectedTile = tile;
      tile.setSelected(true);
    }
  }

  bool _areAdjacent(GameTile tile1, GameTile tile2) {
    final rowDiff = (tile1.gridRow - tile2.gridRow).abs();
    final colDiff = (tile1.gridCol - tile2.gridCol).abs();
    return (rowDiff == 1 && colDiff == 0) || (rowDiff == 0 && colDiff == 1);
  }

  Future<void> _swapTiles(GameTile tile1, GameTile tile2) async {
    setProcessingTurn(true);
    final pos1 = tile1.position.clone();
    final pos2 = tile2.position.clone();
    final row1 = tile1.gridRow;
    final col1 = tile1.gridCol;
    final row2 = tile2.gridRow;
    final col2 = tile2.gridCol;

    // Update grid and tile properties
    grid[row1][col1] = tile2;
    grid[row2][col2] = tile1;
    tile1.gridRow = row2;
    tile1.gridCol = col2;
    tile2.gridRow = row1;
    tile2.gridCol = col1;

    // Animate swap
    tile1.add(MoveEffect.to(pos2, EffectController(duration: 0.2)));
    tile2.add(MoveEffect.to(pos1, EffectController(duration: 0.2)));
    await Future.delayed(Duration(milliseconds: 250));

    // Check if swap creates matches
    if (!_hasMatchesAfterSwap()) {
      // Revert swap
      grid[row1][col1] = tile1;
      grid[row2][col2] = tile2;
      tile1.gridRow = row1;
      tile1.gridCol = col1;
      tile2.gridRow = row2;
      tile2.gridCol = col2;
      tile1.add(MoveEffect.to(pos1, EffectController(duration: 0.2)));
      tile2.add(MoveEffect.to(pos2, EffectController(duration: 0.2)));
      _showInvalidMoveAnimation(tile1, tile2);
      setProcessingTurn(false);
      setPlayerTurn(true);
    } else {
      await _processMatches();
    }
  }

  void _showInvalidMoveAnimation(GameTile tile1, GameTile tile2) {
    final shake = SequenceEffect([
      MoveByEffect(Vector2(-8, 0), EffectController(duration: 0.05)),
      MoveByEffect(Vector2(16, 0), EffectController(duration: 0.1)),
      MoveByEffect(Vector2(-8, 0), EffectController(duration: 0.05)),
    ]);
    tile1.add(shake);
    tile2.add(
      SequenceEffect([
        MoveByEffect(Vector2(-8, 0), EffectController(duration: 0.05)),
        MoveByEffect(Vector2(16, 0), EffectController(duration: 0.1)),
        MoveByEffect(Vector2(-8, 0), EffectController(duration: 0.05)),
      ]),
    );
  }

  Future<void> _processMatches() async {
    _comboCount = 0;
    _cascadeCount = 0;

    while (true) {
      final matches = _findMatches();
      if (matches.isEmpty) break;

      _comboCount++;
      _cascadeCount++;
      await _handleMatches(matches);
      await _applyGravity();
      await Future.delayed(Duration(milliseconds: 300));
    }

    // End player turn and trigger enemy turn
    setProcessingTurn(false);
    hasActiveMatches = false;
    if (onAllMatchesCompleteCallback != null) {
      onAllMatchesCompleteCallback!();
    }
    print('Cascade complete! Total cascades: $_cascadeCount');
  }

  List<List<GameTile>> _findMatches() {
    final matches = <List<GameTile>>[];
    final processed = <GameTile>{};

    // Horizontal matches
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize - 2; col++) {
        final tile = grid[row][col];
        if (tile == null || processed.contains(tile)) continue;

        final type = tile.tileType;
        final match = [tile];
        for (int c = col + 1; c < gridSize; c++) {
          final nextTile = grid[row][c];
          if (nextTile?.tileType == type && !processed.contains(nextTile)) {
            match.add(nextTile!);
          } else {
            break;
          }
        }
        if (match.length >= 3) {
          matches.add(match);
          processed.addAll(match);
        }
      }
    }

    // Vertical matches
    for (int col = 0; col < gridSize; col++) {
      for (int row = 0; row < gridSize - 2; row++) {
        final tile = grid[row][col];
        if (tile == null || processed.contains(tile)) continue;

        final type = tile.tileType;
        final match = [tile];
        for (int r = row + 1; r < gridSize; r++) {
          final nextTile = grid[r][col];
          if (nextTile?.tileType == type && !processed.contains(nextTile)) {
            match.add(nextTile!);
          } else {
            break;
          }
        }
        if (match.length >= 3) {
          matches.add(match);
          processed.addAll(match);
        }
      }
    }

    return matches;
  }

  Future<void> _handleMatches(List<List<GameTile>> matches) async {
    for (final match in matches) {
      final tileType = match[0].tileType;
      final matchCount = match.length;
      final points = matchCount * 100 * (_comboCount > 1 ? _comboCount : 1);
      score += points;

      // Only notify via callback, do not modify health or power
      if (onMatchCallback != null) {
        onMatchCallback!(tileType, matchCount, points);
      }

      for (final tile in match) {
        tile.add(
          SequenceEffect([
            ScaleEffect.to(Vector2.all(1.2), EffectController(duration: 0.1)),
            ScaleEffect.to(Vector2.all(0.0), EffectController(duration: 0.2)),
          ]),
        );
        await Future.delayed(Duration(milliseconds: 250));
        tile.removeFromParent();
        grid[tile.gridRow][tile.gridCol] = null;
      }
    }
  }

  Future<void> _applyGravity() async {
    for (int col = 0; col < gridSize; col++) {
      int emptyRow = gridSize - 1;
      for (int row = gridSize - 1; row >= 0; row--) {
        if (grid[row][col] != null) {
          if (row != emptyRow) {
            final tile = grid[row][col]!;
            grid[emptyRow][col] = tile;
            grid[row][col] = null;
            tile.gridRow = emptyRow;
            tile.add(
              MoveEffect.to(
                _calculateTilePosition(emptyRow, col),
                EffectController(duration: 0.3),
              ),
            );
          }
          emptyRow--;
        }
      }

      // Fill empty spaces
      for (int row = emptyRow; row >= 0; row--) {
        final newTile = GameTile(
          tileType: _random.nextInt(4),
          gridRow: row,
          gridCol: col,
          tileSize: tileSize,
          game: this,
        );
        newTile.position = Vector2(
          gridOffset.x + col * (tileSize + 4),
          gridOffset.y - (tileSize + 4) * (emptyRow - row + 1),
        );
        grid[row][col] = newTile;
        add(newTile);
        newTile.add(
          MoveEffect.to(
            _calculateTilePosition(row, col),
            EffectController(duration: 0.5),
          ),
        );
      }
    }
    await Future.delayed(Duration(milliseconds: 500));
  }

  Future<void> enemyTurn() async {
    if (enemyHealth <= 0) {
      setPlayerTurn(true);
      setProcessingTurn(false);
      print(
        'Enemy defeated, skipping enemy turn: PlayerTurn=$isPlayerTurn, Processing=$isProcessingTurn',
      );
      return;
    }

    setProcessingTurn(true);
    setPlayerTurn(false);
    print(
      'Starting enemy turn: PlayerTurn=$isPlayerTurn, Processing=$isProcessingTurn',
    );

    // Simple mob attack: deal random damage
    final baseDamage = _random.nextInt(15) + 5; // 5-20 damage
    if (onMobAttackCallback != null) {
      onMobAttackCallback!(baseDamage);
    }
  }

  void usePower() {
    if (!canUsePower || isProcessingTurn || !isPlayerTurn) {
      print(
        'Cannot use power: CanUse=$canUsePower, Processing=$isProcessingTurn, PlayerTurn=$isPlayerTurn',
      );
      return;
    }

    // Notify TowerGameplayScreen to handle power attack
    if (onMatchCallback != null) {
      onMatchCallback!(
        0,
        0,
        0,
      ); // Use tileType 0 with matchCount 0 to trigger power attack
    }
    setPlayerTurn(false);
    setProcessingTurn(true);
  }

  bool _hasMatchesAfterSwap() {
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize - 2; col++) {
        if (grid[row][col]?.tileType == grid[row][col + 1]?.tileType &&
            grid[row][col]?.tileType == grid[row][col + 2]?.tileType) {
          return true;
        }
      }
    }
    for (int col = 0; col < gridSize; col++) {
      for (int row = 0; row < gridSize - 2; row++) {
        if (grid[row][col]?.tileType == grid[row + 1][col]?.tileType &&
            grid[row][col]?.tileType == grid[row + 2][col]?.tileType) {
          return true;
        }
      }
    }
    return false;
  }
}

class GameTile extends RectangleComponent
    with TapCallbacks, HasGameRef<Match3Game> {
  int tileType;
  int gridRow;
  int gridCol;
  final double tileSize;
  final Match3Game game;
  bool _isSelected = false;
  late final RectangleComponent border;
  late final RectangleComponent selectionBorder;
  SpriteComponent? spriteComponent;
  TextComponent? fallbackText;

  GameTile({
    required this.tileType,
    required this.gridRow,
    required this.gridCol,
    required this.tileSize,
    required this.game,
  }) : super(size: Vector2(tileSize, tileSize));

  @override
  Future<void> onLoad() async {
    border = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = const Color(0xFF8D6E63)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    selectionBorder = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = Colors.yellow
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    selectionBorder.opacity = 0;

    add(border);
    add(selectionBorder);
    await _loadTileContent();
  }

  @override
  void onTapUp(TapUpEvent event) {
    game.onTileTapped(this);
  }

  Future<void> _loadTileContent() async {
    if (spriteComponent != null) {
      spriteComponent!.removeFromParent();
      spriteComponent = null;
    }
    if (fallbackText != null) {
      fallbackText!.removeFromParent();
      fallbackText = null;
    }

    final componentsToRemove = children
        .where(
          (c) => c is RectangleComponent && c != border && c != selectionBorder,
        )
        .toList();
    for (final component in componentsToRemove) {
      component.removeFromParent();
    }

    if (game.imagesLoaded &&
        game.images.containsKey(game.tileSprites[tileType]!)) {
      try {
        final sprite = Sprite(
          game.images.fromCache(game.tileSprites[tileType]!),
        );
        spriteComponent = SpriteComponent(
          sprite: sprite,
          size: Vector2(tileSize * 0.8, tileSize * 0.8),
          position: Vector2(tileSize * 0.1, tileSize * 0.1),
        );
        add(spriteComponent!);
        return;
      } catch (e) {
        print('Failed to load sprite for tile $tileType: $e');
      }
    }

    // Fallback rendering
    final labels = ['SW', 'SH', 'HT', 'ST'];
    add(
      RectangleComponent(
        size: Vector2(tileSize * 0.8, tileSize * 0.8),
        position: Vector2(tileSize * 0.1, tileSize * 0.1),
        paint: Paint()..color = game.tileColors[tileType],
      ),
    );
    fallbackText = TextComponent(
      text: labels[tileType],
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: tileSize * 0.3,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(tileSize * 0.3, tileSize * 0.35),
    );
    add(fallbackText!);
  }

  void setSelected(bool selected) {
    _isSelected = selected;
    selectionBorder.opacity = selected ? 1.0 : 0.0;
  }
}
