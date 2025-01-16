import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:google_fonts/google_fonts.dart';
import 'chatprovider.dart';
import 'package:uuid/uuid.dart';

class TicketChatPage extends ConsumerWidget {
  final String ticketId;

  const TicketChatPage({super.key, required this.ticketId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesStream = ref.watch(messagesProvider(ticketId));
    final sendMessageService = ref.read(sendMessageProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF273847),
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'Chat Support',
          style: GoogleFonts.poppins(
            color: Colors.white,
          ),
        ),
      ),
      body: messagesStream.when(
        data: (messages) {
          final chatMessages = messages.map((message) {
            final isUserMessage = message['isUser'] ?? false;
            return types.TextMessage(
              id: const Uuid().v4(),
              author: types.User(
                id: isUserMessage ? 'user' : 'support',
                firstName: isUserMessage ? 'You' : 'Support',
              ),
              text: message['text'] ?? '',
              createdAt:
                  (message['timestamp'] as DateTime?)?.millisecondsSinceEpoch,
            );
          }).toList();

          return Chat(
            messages: chatMessages,
            onSendPressed: (partialMessage) async {
              final text = partialMessage.text.trim();
              if (text.isNotEmpty) {
                try {
                  await sendMessageService.sendMessage(ticketId, text);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to send message.')),
                  );
                }
              }
            },
            user: const types.User(id: 'user', firstName: 'You'),
            theme: DefaultChatTheme(
              bubbleMargin: EdgeInsets.all(10),
              inputBackgroundColor: const Color(0xFF273847),
              primaryColor: Color(0xFF273847),
              inputTextColor: Colors.white,
              inputTextStyle:
                  const TextStyle(fontSize: 16, color: Colors.white),
              inputTextCursorColor: Colors.white,
              sentMessageBodyTextStyle: const TextStyle(
                color: Colors.white,
              ),
              receivedMessageBodyTextStyle: const TextStyle(
                color: Colors.white,
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
