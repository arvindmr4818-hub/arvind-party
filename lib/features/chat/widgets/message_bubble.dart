// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/chat/widgets/message_bubble.dart
// ARVIND PARTY - MESSAGE BUBBLE WIDGET (Reactions, Reply, Delete, Pin)

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/chat_model.dart';
import '../controllers/chat_controller.dart';
import 'reaction_picker.dart';

class MessageBubble extends GetView<ChatController> {
  final MessageModel message;
  final bool isMe;
  const MessageBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showContextMenu(context),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe) _buildAvatar(),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (message.repliedToMessage != null) _buildReplyPreview(message.repliedToMessage!),
                  if (message.isDeleted) _buildDeletedBubble()
                  else if (message.type == MessageType.sticker) _buildStickerBubble()
                  else _buildTextBubble(),
                  if (message.reactions.isNotEmpty) _buildReactions(),
                  if (message.isPinned) _buildPinnedBadge(),
                ],
              ),
            ),
            if (isMe) const SizedBox(width: 8),
            if (isMe) _buildAvatar(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() => CircleAvatar(radius: 18, backgroundImage: NetworkImage(message.senderAvatar ?? 'https://picsum.photos/100'));

  Widget _buildTextBubble() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: isMe ? Colors.blue.shade100 : Colors.grey.shade200,
      borderRadius: BorderRadius.only(
        topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
        bottomLeft: Radius.circular(isMe ? 16 : 4), bottomRight: Radius.circular(isMe ? 4 : 16),
      ),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (!isMe) Text(message.senderName, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w500, fontSize: 12)),
      Text(message.text ?? '', style: const TextStyle(fontSize: 16)),
    ]),
  );

  Widget _buildStickerBubble() => Container(
    width: 120, height: 120, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
    child: Image.network(message.stickerUrl!, fit: BoxFit.cover),
  );

  Widget _buildDeletedBubble() => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16)),
    child: const Text('This message was deleted', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
  );

  Widget _buildReplyPreview(MessageModel replied) => Container(
    padding: const EdgeInsets.all(8), margin: const EdgeInsets.only(bottom: 4),
    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8),
      border: Border(left: BorderSide(color: isMe ? Colors.blue : Colors.grey, width: 3))),
    child: Text(replied.isDeleted ? 'Deleted message' : (replied.text ?? 'Sticker'),
      maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
  );

  Widget _buildReactions() => Wrap(spacing: 4, children: message.reactions.entries.map((entry) {
    return GestureDetector(
      onTap: () => controller.toggleReaction(message.id, entry.key),
      child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: entry.value.userIds.contains('currentUserId') ? Colors.blue.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text('${entry.key} ${entry.value.userIds.length}'),
      ),
    );
  }).toList());

  Widget _buildPinnedBadge() => const Row(mainAxisAlignment: MainAxisAlignment.end, children: [
    Icon(Icons.push_pin, size: 14, color: Colors.orange),
    SizedBox(width: 4),
    Text('Pinned', style: TextStyle(color: Colors.orange, fontSize: 12)),
  ]);

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(context: context, builder: (ctx) => SafeArea(child: Wrap(children: [
      ListTile(leading: const Icon(Icons.reply), title: const Text('Reply'),
        onTap: () { controller.setReply(message); Navigator.pop(ctx); }),
      if (!message.isDeleted) ...[
        ListTile(leading: const Icon(Icons.emoji_emotions), title: const Text('React'),
          onTap: () { Navigator.pop(ctx); _showReactionPicker(context); }),
        if (isMe) ListTile(leading: const Icon(Icons.delete), title: const Text('Delete'),
          onTap: () { controller.deleteMessage(message.id); Navigator.pop(ctx); }),
        ListTile(leading: Icon(message.isPinned ? Icons.push_pin : Icons.push_pin_outlined),
          title: Text(message.isPinned ? 'Unpin' : 'Pin'),
          onTap: () { controller.pinMessage(message.id, pin: !message.isPinned); Navigator.pop(ctx); }),
      ],
    ])));
  }

  void _showReactionPicker(BuildContext context) {
    showModalBottomSheet(context: context, builder: (ctx) => ReactionPicker(
      onReactionSelected: (emoji) { controller.toggleReaction(message.id, emoji); Navigator.pop(ctx); },
    ));
  }
}