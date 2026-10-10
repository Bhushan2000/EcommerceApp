import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyWishlist = 'aura_wishlist_ids';
  static const String _keyThemeMode = 'aura_is_dark_mode';

  static Future<List<String>> getWishlistIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyWishlist) ?? [];
  }

  static Future<void> saveWishlistIds(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyWishlist, ids);
  }

  static Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyThemeMode) ?? false;
  }

  static Future<void> setDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyThemeMode, isDark);
  }
}
