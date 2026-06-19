// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/chat/widgets/reaction_picker.dart
// ARVIND PARTY - REACTION / EMOJI PICKER WIDGET
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

class ReactionPicker extends StatelessWidget {
  final Function(String) onReactionSelected;
  final bool isEmojiPicker;

  const ReactionPicker({
    super.key,
    required this.onReactionSelected,
    this.isEmojiPicker = false,
  });

  static const List<String> quickReactions = ['👍', '❤️', '😂', '😮', '😢', '🙏'];
  static const List<String> allEmojis = ['😀', '😄', '😁', '😆', '😅', '😂', '🤣', '🥲', '☺️', '😊', '😇', '🙂', '🙃', '😉', '😌', '😍', '🥰', '😘', '😗', '😙', '😚', '😋', '😛', '😝', '😜', '🤪', '🤨', '🧐', '🤓', '😎'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: isEmojiPicker ? 300 : 120,
      child: isEmojiPicker
          ? GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6, mainAxisSpacing: 8, crossAxisSpacing: 8),
              itemCount: allEmojis.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => onReactionSelected(allEmojis[index]),
                  child: Center(child: Text(allEmojis[index], style: const TextStyle(fontSize: 32))),
                );
              },
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: quickReactions.map((emoji) => GestureDetector(
                onTap: () => onReactionSelected(emoji),
                child: Text(emoji, style: const TextStyle(fontSize: 40)),
              )).toList(),
            ),
    );
  }
}