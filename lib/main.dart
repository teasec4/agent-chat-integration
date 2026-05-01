import 'package:flutter/material.dart';
import 'package:gemma4/data/implementation/chat_repository_impl.dart';
import 'package:gemma4/data/implementation/list_chat_repository_impl.dart';
import 'package:gemma4/presentation/view_models/list_chat_view_model.dart';
import 'package:gemma4/providers/isar_db_provider.dart';
import 'package:gemma4/router/router.dart';
import 'package:gemma4/presentation/view_models/chat_view_model.dart';
import 'package:gemma4/service/api/gemma_api_service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final isar = await IsarDbProvider().open();
  final aiService = GemmaApiService();

  final chatRepository = ChatRepositoryImpl(
    aiService: aiService,
    isar: isar,
  );
  final listChatRepository = ListChatRepositoryImpl(isar);

  // Need late variable for the callback chain
  late final ListChatViewModel listChatVm;
  final chatVm = ChatViewModel(
    chatRepository,
    aiService,
    onTitleGenerated: () => listChatVm.loadChats(),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: chatVm,
        ),
        ChangeNotifierProvider<ListChatViewModel>(
          create: (_) => listChatVm = ListChatViewModel(listChatRepository),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: AppRouter.router,
        title: 'Gemma Chat',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
      ),
    ),
  );
}
