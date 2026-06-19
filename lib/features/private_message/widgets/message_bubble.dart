import 'package:flutter/material.dart';
import '../models/private_message_model.dart';

class MessageBubble extends StatelessWidget {
  final PrivateMessage message;
  final bool isCurrentUser;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: isCurrentUser ? () => _showOptions(context) : null,
      child: Align(
        alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isCurrentUser ? Colors.blue : Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMessageContent(),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message.getTimeString(),
                    style: TextStyle(
                      fontSize: 10,
                      color: isCurrentUser ? Colors.white70 : Colors.grey,
                    ),
                  ),
                  if (isCurrentUser) ...[
                    const SizedBox(width: 4),
                    Icon(
                      message.isRead ? Icons.done_all : Icons.done,
                      size: 12,
                      color: message.isRead ? Colors.blue : Colors.white70,
                    ),
                  ],
                  if (message.isEdited) ...[
                    const SizedBox(width: 4),
                    Text(
                      'edited',
                      style: TextStyle(
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                        color: isCurrentUser ? Colors.white70 : Colors.grey,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageContent() {
    switch (message.messageType) {
      case 'text':
        return Text(
          message.content,
          style: TextStyle(
            color: isCurrentUser ? Colors.white : Colors.black,
          ),
        );
      case 'image':
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            message.mediaUrl ?? '',
            width: 200,
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 200,
                height: 200,
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image),
              );
            },
          ),
        );
      case 'video':
        return Container(
          width: 200,
          height: 200,
          color: Colors.grey[300],
          child: const Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.play_circle, size: 50, color: Colors.white),
              Text(
                'Video',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        );
      case 'voice':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.play_arrow,
              color: isCurrentUser ? Colors.white : Colors.black,
            ),
            const SizedBox(width: 8),
            Text(
              'Voice: ${_formatDuration()}',
              style: TextStyle(
                color: isCurrentUser ? Colors.white : Colors.black,
              ),
            ),
          ],
        );
      case 'file':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.attach_file,
              color: isCurrentUser ? Colors.white : Colors.black,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.fileName ?? 'File',
                    style: TextStyle(
                      color: isCurrentUser ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _formatFileSize(),
                    style: TextStyle(
                      fontSize: 10,
                      color: isCurrentUser ? Colors.white70 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      default:
        return Text(message.content);
    }
  }

  String _formatDuration() {
    if (message.durationSeconds == null) return '0:00';
    final minutes = (message.durationSeconds! ~/ 60).toInt();
    final seconds = (message.durationSeconds! % 60).toInt();
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatFileSize() {
    if (message.fileSizeBytes == null) return '0 B';
    final bytes = message.fileSizeBytes!;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit'),
            onTap: () {
              Navigator.pop(context);
              onEdit();
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              onDelete();
            },
          ),
        ],
      ),
    );
  }
}