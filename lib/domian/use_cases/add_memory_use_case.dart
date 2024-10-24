import '../../data/models/memory_model.dart';
import '../../data/repositrories/memory_repository.dart';


class AddMemoryUseCase {
  final MemoryRepository repository;

  AddMemoryUseCase(this.repository);

  Future<void> execute(MemoryModel memory) async {
    await repository.saveMemory(memory);
  }
}
