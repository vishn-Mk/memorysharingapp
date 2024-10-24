import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/memory_model.dart';

class MemoryRepository {
  static const String memoryListKey = 'memory_list';

  // Save memory to SharedPreferences
  Future<void> saveMemory(MemoryModel memory) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedMemories = prefs.getStringList(memoryListKey) ?? [];
    savedMemories.add(jsonEncode(memory.toMap()));
    await prefs.setStringList(memoryListKey, savedMemories);
  }

  // Load all memories from SharedPreferences
  Future<List<MemoryModel>> loadMemories() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedMemories = prefs.getStringList(memoryListKey) ?? [];
    return savedMemories
        .map((memoryString) => MemoryModel.fromMap(jsonDecode(memoryString)))
        .toList();
  }

  // Delete a specific memory from SharedPreferences
  Future<void> deleteMemory(MemoryModel memory) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedMemories = prefs.getStringList(memoryListKey) ?? [];
    savedMemories.removeWhere((item) =>
    MemoryModel.fromMap(jsonDecode(item)).filePath == memory.filePath);
    await prefs.setStringList(memoryListKey, savedMemories);
  }
}
