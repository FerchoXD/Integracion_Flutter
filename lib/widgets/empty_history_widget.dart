import 'package:flutter/material.dart';
import 'package:flutter_gemini/providers/chat_provider.dart';
import 'package:provider/provider.dart';

class EmptyHistoryWidget extends StatelessWidget {
  const EmptyHistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () async {
          final chatProvider = context.read<ChatProvider>();
          await chatProvider.prepareChatRoom(
            isNewChat: true,
            chatID: '',
          );
          chatProvider.setCurrentIndex(newIndex: 1);
          chatProvider.pageController.jumpToPage(1);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'No hay chats disponibles, toca para iniciar uno',
            ),
          ),
        ),
      ),
    );
  }
}
