import '../../data/models/memory_model.dart';
import '../../data/repositrories/memory_repository.dart';


class DeleteMemoryUseCase {
  final MemoryRepository repository;

  DeleteMemoryUseCase(this.repository);

  Future<void> execute(MemoryModel memory) async {
    await repository.deleteMemory(memory);
  }
}
