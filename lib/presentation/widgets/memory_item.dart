import 'package:flutter/material.dart';
import '../../data/models/memory_model.dart';

import 'memory_tumbnail.dart';

class MemoryItem extends StatelessWidget {
  final MemoryModel memory;

  MemoryItem({required this.memory});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: MemoryThumbnail(filePath: memory.filePath, type: memory.type),
      title: Text(memory.title),
      subtitle: Text(memory.timestamp.toString()),
      onTap: () {
        // Handle tap to view or play the memory
      },
    );
  }
}
