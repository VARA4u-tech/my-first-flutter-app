import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_stats.dart';
import '../repositories/shop_repository.dart';

final shopRepositoryProvider = Provider<ShopRepository>((ref) => ShopRepository());

final userStatsProvider = StreamProvider<UserStats>((ref) {
  final repo = ref.watch(shopRepositoryProvider);
  return repo.watchUserStats();
});
