class UserStats {
  final int coins;
  final List<String> unlockedItems;
  final String equippedItem;

  const UserStats({
    this.coins = 0,
    this.unlockedItems = const ['default_duck'],
    this.equippedItem = 'default_duck',
  });

  UserStats copyWith({
    int? coins,
    List<String>? unlockedItems,
    String? equippedItem,
  }) {
    return UserStats(
      coins: coins ?? this.coins,
      unlockedItems: unlockedItems ?? this.unlockedItems,
      equippedItem: equippedItem ?? this.equippedItem,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'coins': coins,
      'unlockedItems': unlockedItems,
      'equippedItem': equippedItem,
    };
  }

  factory UserStats.fromMap(Map<String, dynamic> map) {
    return UserStats(
      coins: map['coins'] as int? ?? 0,
      unlockedItems: List<String>.from(map['unlockedItems'] ?? ['default_duck']),
      equippedItem: map['equippedItem'] as String? ?? 'default_duck',
    );
  }
}

class ShopItem {
  final String id;
  final String name;
  final String description;
  final int price;
  final String emoji;
  final String type; // 'hat', 'outfit', 'background'

  const ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.emoji,
    required this.type,
  });
}

class ShopCatalog {
  static const List<ShopItem> allItems = [
    ShopItem(
      id: 'default_duck',
      name: 'Classic Duck',
      description: 'The original yellow friend.',
      price: 0,
      emoji: '🦆',
      type: 'outfit',
    ),
    ShopItem(
      id: 'cool_shades',
      name: 'Cool Shades',
      description: 'Stay relaxed under pressure.',
      price: 50,
      emoji: '😎',
      type: 'hat',
    ),
    ShopItem(
      id: 'party_hat',
      name: 'Party Hat',
      description: 'Celebrate your wins!',
      price: 100,
      emoji: '🎉',
      type: 'hat',
    ),
    ShopItem(
      id: 'wizard_hat',
      name: 'Wizard Hat',
      description: 'Magically clearing tasks.',
      price: 250,
      emoji: '🧙‍♂️',
      type: 'hat',
    ),
    ShopItem(
      id: 'space_suit',
      name: 'Space Suit',
      description: 'Productivity to the moon!',
      price: 500,
      emoji: '👨‍🚀',
      type: 'outfit',
    ),
    ShopItem(
      id: 'crown',
      name: 'Golden Crown',
      description: 'Ruler of the To-Do list.',
      price: 1000,
      emoji: '👑',
      type: 'hat',
    ),
  ];
}
