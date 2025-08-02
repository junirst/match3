import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../managers/audio_manager.dart';
import '../managers/game_manager.dart';

class OutfitScreen extends StatefulWidget {
  const OutfitScreen({super.key});

  @override
  State<OutfitScreen> createState() => _OutfitScreenState();
}

class _OutfitScreenState extends State<OutfitScreen> {
  String _currentLanguage = 'English';
  String _equippedWeapon = 'Sword'; // Default equipped weapon

  final Map<String, Map<String, String>> _translations = {
    'English': {
      'weapons': 'WEAPONS',
      'confirmPurchase': 'Confirm Purchase',
      'purchaseFor': 'Purchase for',
      'coins': 'coins',
      'confirm': 'CONFIRM',
      'refuse': 'REFUSE',
      'notEnoughCoins': 'Not enough coins!',
      'purchaseSuccess': 'Purchase successful!',
      'equip': 'EQUIP',
      'unequip': 'UNEQUIP',
      'equipped': 'EQUIPPED',
    },
    'Spanish': {
      'weapons': 'ARMAS',
      'confirmPurchase': 'Confirmar Compra',
      'purchaseFor': 'Comprar por',
      'coins': 'monedas',
      'confirm': 'CONFIRMAR',
      'refuse': 'RECHAZAR',
      'notEnoughCoins': '¡No tienes suficientes monedas!',
      'purchaseSuccess': '¡Compra exitosa!',
      'equip': 'EQUIPAR',
      'unequip': 'DESEQUIPAR',
      'equipped': 'EQUIPADO',
    },
    'Vietnamese': {
      'weapons': 'VŨ KHÍ',
      'confirmPurchase': 'Xác Nhận Mua Hàng',
      'purchaseFor': 'Mua với giá',
      'coins': 'xu',
      'confirm': 'XÁC NHẬN',
      'refuse': 'TỪ CHỐI',
      'notEnoughCoins': 'Không đủ xu!',
      'purchaseSuccess': 'Mua thành công!',
      'equip': 'TRANG BỊ',
      'unequip': 'HỦY TRANG BỊ',
      'equipped': 'ĐÃ TRANG BỊ',
    },
  };

  final List<Map<String, dynamic>> _items = [
    {
      'name': 'Sword',
      'price': 100,
      'owned': true, // Default weapon is owned
      'image': 'assets/images/items/SwordHand.png',
      'description': 'Standard weapon with no special effects',
    },
    {
      'name': 'Dagger',
      'price': 150,
      'owned': false,
      'image': 'assets/images/items/Dagger.png',
      'description': 'Passive: Gain +10 HP every 5 heart matches',
    },
    {
      'name': 'Hand',
      'price': 200,
      'owned': false,
      'image': 'assets/images/items/Hand.png',
      'description': 'Passive: Power attacks deal double damage',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference();
  }

  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final language = prefs.getString('language') ?? 'English';
    final gameManager = Provider.of<GameManager>(context, listen: false);

    setState(() {
      _currentLanguage = language;
      _equippedWeapon = gameManager.equippedWeapon;

      // Load weapon ownership status from GameManager
      final ownedWeaponsList = gameManager.ownedWeapons;
      for (int i = 0; i < _items.length; i++) {
        final weaponName = _items[i]['name'].toString();
        _items[i]['owned'] = ownedWeaponsList.contains(weaponName);
      }
    });
  }

  String _translate(String key) {
    return _translations[_currentLanguage]?[key] ?? key;
  }

  IconData _getItemIcon(String itemName) {
    switch (itemName) {
      case 'Sword':
        return Icons.construction;
      case 'Dagger':
        return Icons.sports_tennis;
      case 'Hand':
        return Icons.gesture;
      default:
        return Icons.inventory;
    }
  }

  void _showPurchaseDialog(int itemIndex) {
    AudioManager().playButtonSound();
    final item = _items[itemIndex];
    final price = item['price'] as int;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.9),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _translate('confirmPurchase'),
                  style: const TextStyle(
                    fontFamily: 'Bungee',
                    fontSize: 24,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 2,
                        color: Colors.black,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '${_translate('purchaseFor')} $price ${_translate('coins')}',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 2,
                        color: Colors.black,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () => _confirmPurchase(itemIndex),
                      child: Image.asset(
                        'assets/images/ui/confirm.png',
                        height: 60,
                        width: 100,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 60,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                _translate('confirm'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Image.asset(
                        'assets/images/ui/refuse.png',
                        height: 60,
                        width: 100,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 60,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                _translate('refuse'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmPurchase(int itemIndex) async {
    AudioManager().playButtonSound();
    final item = _items[itemIndex];
    final price = item['price'] as int;
    final weaponName = item['name'] as String;

    Navigator.of(context).pop(); // Close dialog

    final gameManager = context.read<GameManager>();
    final success = await gameManager.purchaseWeapon(weaponName, price);

    if (success) {
      setState(() {
        _items[itemIndex]['owned'] = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_translate('purchaseSuccess')),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_translate('notEnoughCoins')),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _equipWeapon(String weaponName) async {
    final gameManager = context.read<GameManager>();
    final success = await gameManager.equipWeapon(weaponName);

    if (success) {
      setState(() {
        _equippedWeapon = weaponName;
      });
    }
  }

  void _onEquipPressed(int itemIndex) {
    AudioManager().playButtonSound();
    final weaponName = _items[itemIndex]['name'] as String;

    if (_equippedWeapon == weaponName) {
      // Unequip current weapon (revert to default Sword)
      _equipWeapon('Sword');
    } else {
      // Equip selected weapon
      _equipWeapon(weaponName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/backgrounds/backgroundshop.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[800],
                  child: const Center(
                    child: Text(
                      'Background image not found',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),

          // Top Bar
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Custom Image Label with "WEAPONS"
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      'assets/images/ui/frame.png',
                      height: screenWidth * 0.25,
                      width: screenWidth * 0.5,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: screenWidth * 0.2,
                          width: screenWidth * 0.5,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        );
                      },
                    ),
                    Text(
                      _translate('weapons'),
                      style: TextStyle(
                        fontFamily: 'Bungee',
                        fontSize: screenWidth * 0.07,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: const [
                          Shadow(offset: Offset(-1, -1), color: Colors.black),
                          Shadow(offset: Offset(1, -1), color: Colors.black),
                          Shadow(offset: Offset(-1, 1), color: Colors.black),
                          Shadow(offset: Offset(1, 1), color: Colors.black),
                          Shadow(
                            offset: Offset(0, 0),
                            color: Colors.black,
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Coin Count
                Row(
                  children: [
                    Text(
                      '${context.watch<GameManager>().currentCoins}',
                      style: TextStyle(
                        fontSize: screenWidth * 0.06,
                        color: Colors.white,
                        shadows: const [
                          Shadow(
                            blurRadius: 2,
                            color: Colors.black,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.monetization_on,
                      color: Colors.amber,
                      size: screenWidth * 0.08,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Center Grid with 3 items
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 140, bottom: 100),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildItemRow(context, 0, 1),
                  const SizedBox(height: 40),
                  // Single item centered in second row
                  buildItemCard(context, 2),
                ],
              ),
            ),
          ),

          // Bottom back button
          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                AudioManager().playButtonSound();
                if (Navigator.of(context).canPop()) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushReplacementNamed(context, '/shop');
                }
              },
              child: Image.asset(
                'assets/images/ui/backbutton.png',
                height: screenWidth * 0.18,
                width: screenWidth * 0.18,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: screenWidth * 0.18,
                    width: screenWidth * 0.18,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: screenWidth * 0.09,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildItemRow(BuildContext context, int index1, int index2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        buildItemCard(context, index1),
        buildItemCard(context, index2),
      ],
    );
  }

  Widget buildItemCard(BuildContext context, int itemIndex) {
    final screenWidth = MediaQuery.of(context).size.width;
    final item = _items[itemIndex];
    final isOwned = item['owned'] as bool;

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'assets/images/ui/itemslot.png',
                  height: screenWidth * 0.25,
                  width: screenWidth * 0.25,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: screenWidth * 0.25,
                      width: screenWidth * 0.25,
                      decoration: BoxDecoration(
                        color: isOwned ? Colors.green[700] : Colors.grey[600],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    );
                  },
                ),
                // Weapon image inside the slot
                Image.asset(
                  item['image'],
                  height: screenWidth * 0.18,
                  width: screenWidth * 0.18,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      _getItemIcon(item['name']),
                      color: Colors.white,
                      size: screenWidth * 0.12,
                    );
                  },
                ),
              ],
            ),
            if (!isOwned)
              Positioned(
                bottom: 6,
                right: 6,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${item['price']}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.04,
                        shadows: const [
                          Shadow(
                            blurRadius: 2,
                            color: Colors.black,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 3),
                    Icon(
                      Icons.monetization_on,
                      color: Colors.amber,
                      size: screenWidth * 0.045,
                    ),
                  ],
                ),
              ),
            if (isOwned)
              Positioned(
                bottom: 6,
                right: 6,
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: screenWidth * 0.06,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (!isOwned)
          GestureDetector(
            onTap: () => _showPurchaseDialog(itemIndex),
            child: Image.asset(
              'assets/images/ui/buybutton.png',
              height: screenWidth * 0.16,
              width: screenWidth * 0.16,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: screenWidth * 0.16,
                  width: screenWidth * 0.16,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(
                    Icons.shopping_cart,
                    color: Colors.white,
                    size: screenWidth * 0.09,
                  ),
                );
              },
            ),
          )
        else if (_equippedWeapon == item['name'])
          // Show "EQUIPPED" status for currently equipped weapon
          Container(
            height: screenWidth * 0.16,
            width: screenWidth * 0.16,
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(
              child: Text(
                _translate('equipped'),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.025,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        else
          // Show equip button for owned but not equipped weapons
          GestureDetector(
            onTap: () => _onEquipPressed(itemIndex),
            child: Container(
              height: screenWidth * 0.16,
              width: screenWidth * 0.16,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: Text(
                  _translate('equip'),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.03,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: 8),
        // Weapon description
        Container(
          width: screenWidth * 0.3,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Text(
            item['description'] ?? '',
            style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.02),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
