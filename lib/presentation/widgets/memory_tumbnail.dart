import 'package:flutter/material.dart';
import 'dart:io';

class MemoryThumbnail extends StatelessWidget {
  final String filePath;
  final String type; // Can be 'image', 'video', 'audio'

  MemoryThumbnail({required this.filePath, required this.type});

  @override
  Widget build(BuildContext context) {
    if (type == 'image') {
      return Image.file(File(filePath), fit: BoxFit.cover);
    } else if (type == 'video') {
      return Icon(Icons.videocam, size: 40);
    } else if (type == 'audio') {
      return Icon(Icons.audiotrack, size: 40);
    }
    return SizedBox.shrink();
  }
}
