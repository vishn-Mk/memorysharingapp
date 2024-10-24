import 'package:flutter/material.dart';
import '../../data/models/memory_model.dart';
import '../../domian/use_cases/get_memory_use_case.dart';


class MemoryListViewModel extends ChangeNotifier {
  final GetMemoriesUseCase getMemoriesUseCase;
  List<MemoryModel> memories = [];

  MemoryListViewModel(this.getMemoriesUseCase);

  Future<void> loadMemories() async {
    memories = await getMemoriesUseCase.execute();
    notifyListeners();
  }
}
