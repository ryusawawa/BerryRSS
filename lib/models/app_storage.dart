import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'rss_node.dart';

class AppStorage {
  static const _keyNodes = 'berry_rss_nodes';
  static const _keyUserName = 'berry_user_name';
  static const _keyUserAvatar = 'berry_user_avatar';
  static const _keyCustomUrl = 'berry_custom_url';

  static Future<List<RssNode>> loadNodes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_keyNodes);
    if (data == null || data.isEmpty) return [];
    try {
      final List rawList = jsonDecode(data);
      return rawList.map((e) => RssNode.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveNodes(List<RssNode> nodes) async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = nodes.map((e) => e.toJson()).toList();
    await prefs.setString(_keyNodes, jsonEncode(rawList));
  }

  static Future<String> loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName) ?? 'Berry User';
  }

  static Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserName, name);
  }

  static Future<String?> loadUserAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserAvatar);
  }

  static Future<void> saveUserAvatar(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserAvatar, path);
  }

  static Future<String> loadCustomUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCustomUrl) ?? 'https://www.startpage.com/';
  }

  static Future<void> saveCustomUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCustomUrl, url);
  }
}
