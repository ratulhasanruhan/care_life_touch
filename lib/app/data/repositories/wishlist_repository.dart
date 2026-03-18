import 'package:get/get.dart';
import '../models/wishlist_model.dart';
import '../providers/api_provider.dart';

class WishlistRepository {
  WishlistRepository({ApiProvider? apiProvider})
      : _api = apiProvider ??
            (Get.isRegistered<ApiProvider>()
                ? Get.find<ApiProvider>()
                : Get.put(ApiProvider(), permanent: true));

  final ApiProvider _api;

  Future<WishlistSnapshot> toggleWishlist(String productId) async {
    final response = await _api.postData(
      '/wishlist-toggle',
      body: {'productId': productId},
    );
    return _snapshotFromResponse(response);
  }

  Future<WishlistSnapshot> getWishlist({int? page, int? limit}) async {
    final query = <String, dynamic>{
      if (page != null) 'page': page,
      if (limit != null) 'limit': limit,
    };
    final response = await _api.getData(
      '/wishlist',
      query: query.isEmpty ? null : query,
    );
    return _snapshotFromResponse(response);
  }

  Future<void> removeFromWishlist(String productId) async {
    await _api.deleteData('/wishlist/$productId');
  }

  Future<void> clearWishlist() async {
    await _api.deleteData('/wishlist');
  }

  WishlistSnapshot _snapshotFromResponse(dynamic response) {
    final map = _toMap(response);
    if (map == null) {
      return WishlistSnapshot(items: [], totalCount: 0);
    }
    return WishlistSnapshot.fromJson(map);
  }

  Map<String, dynamic>? _toMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    return null;
  }
}


