import 'package:flutter/material.dart';
import 'package:gemma4/router/router.dart';
import 'package:gemma4/presentation/view_models/chat_view_model.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ChatViewModel()),
    ],
    child: MaterialApp.router(
      routerConfig: AppRouter.router,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
    ),
  ),);
}



