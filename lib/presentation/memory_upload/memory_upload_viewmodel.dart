import 'package:flutter/material.dart';
import '../../data/models/memory_model.dart';
import '../../domian/use_cases/add_memory_use_case.dart';


class MemoryUploadViewModel extends ChangeNotifier {
  final AddMemoryUseCase addMemoryUseCase;

  MemoryUploadViewModel(this.addMemoryUseCase);

  Future<void> uploadMemory(String title, String filePath, String type) async {
    MemoryModel memory = MemoryModel(
      title: title,
      filePath: filePath,
      type: type,
      timestamp: DateTime.now(),
    );
    await addMemoryUseCase.execute(memory);
    notifyListeners();
  }
}
