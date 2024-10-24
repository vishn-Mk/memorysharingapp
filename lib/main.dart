import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './presentation/memory_list/memory_list_screen.dart';
import './presentation/memory_upload/memory_upload_screen.dart';

import './presentation/memory_list/memory_list_viewmodel.dart';
import './presentation/memory_upload/memory_upload_viewmodel.dart';
import 'data/repositrories/memory_repository.dart';
import 'domian/use_cases/add_memory_use_case.dart';
import 'domian/use_cases/get_memory_use_case.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final memoryRepository = MemoryRepository();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MemoryListViewModel(GetMemoriesUseCase(memoryRepository)),
        ),
        ChangeNotifierProvider(
          create: (_) => MemoryUploadViewModel(AddMemoryUseCase(memoryRepository)),
        ),
      ],
      child: MaterialApp(debugShowCheckedModeBanner: false,
        title: 'Memory Sharing App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MemoryListScreen(),
      ),
    );
  }
}
