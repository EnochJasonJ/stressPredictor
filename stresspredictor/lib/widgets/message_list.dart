import 'package:flutter/material.dart';
import 'package:stresspredictor/core/theme/app_colors.dart';

/// Message list widget - displays a list of chat messages.
/// Used in the home screen for displaying the conversation.
class MessageList extends StatelessWidget {
  const MessageList({super.key, required this.messages});

  final List<String> messages;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 48,
              
            ),
            SizedBox(height: 12),
            Text(
              'No messages yet',
              style: TextStyle(
                fontSize: 14,
                
              ),
            ),
            Text(
              'Start a conversation about your stress',
              style: TextStyle(
                fontSize: 12,
                
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        return Align(
          alignment: Alignment.centerRight,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              messages[index],
              style: const TextStyle(
                fontSize: 14,
                
              ),
            ),
          ),
        );
      },
    );
  }
}