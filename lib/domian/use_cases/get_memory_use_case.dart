import '../../data/models/memory_model.dart';
import '../../data/repositrories/memory_repository.dart';


class GetMemoriesUseCase {
  final MemoryRepository repository;

  GetMemoriesUseCase(this.repository);

  Future<List<MemoryModel>> execute() async {
    return await repository.loadMemories();
  }
}
