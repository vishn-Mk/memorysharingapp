class MemoryModel {
  final String title;
  final String filePath;
  final String type; // Can be 'image', 'video', or 'audio'
  final DateTime timestamp;

  MemoryModel({
    required this.title,
    required this.filePath,
    required this.type,
    required this.timestamp,
  });

  // Convert a MemoryModel into a Map.
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'filePath': filePath,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Convert a Map into a MemoryModel.
  factory MemoryModel.fromMap(Map<String, dynamic> map) {
    return MemoryModel(
      title: map['title'],
      filePath: map['filePath'],
      type: map['type'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
