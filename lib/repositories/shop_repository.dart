import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_stats.dart';

class ShopRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _userStatsDoc() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return _firestore.collection('users').doc(user.uid).collection('stats').doc('wallet');
  }

  Stream<UserStats> watchUserStats() {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return Stream.value(const UserStats());
      
      return _userStatsDoc().snapshots().map((snapshot) {
        if (!snapshot.exists) return const UserStats();
        return UserStats.fromMap(snapshot.data()!);
      });
    } catch (e) {
      return Stream.value(const UserStats());
    }
  }

  Future<void> addCoins(int amount) async {
    try {
      final docRef = _userStatsDoc();
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        final currentStats = snapshot.exists 
            ? UserStats.fromMap(snapshot.data()!) 
            : const UserStats();
        
        final newStats = currentStats.copyWith(coins: currentStats.coins + amount);
        transaction.set(docRef, newStats.toMap());
      });
    } catch (e) {
      print('Error adding coins: $e');
    }
  }

  Future<bool> unlockItem(String itemId, int price) async {
    try {
      final docRef = _userStatsDoc();
      return await _firestore.runTransaction<bool>((transaction) async {
        final snapshot = await transaction.get(docRef);
        final currentStats = snapshot.exists 
            ? UserStats.fromMap(snapshot.data()!) 
            : const UserStats();

        if (currentStats.coins < price) return false;
        if (currentStats.unlockedItems.contains(itemId)) return true;

        final newStats = currentStats.copyWith(
          coins: currentStats.coins - price,
          unlockedItems: [...currentStats.unlockedItems, itemId],
        );
        
        transaction.set(docRef, newStats.toMap());
        return true;
      });
    } catch (e) {
      print('Error unlocking item: $e');
      return false;
    }
  }

  Future<void> equipItem(String itemId) async {
    try {
      await _userStatsDoc().update({'equippedItem': itemId});
    } catch (e) {
       print('Error equipping item: $e');
    }
  }
}
