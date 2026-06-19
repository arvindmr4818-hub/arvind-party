import 'package:flutter/material.dart';

class VoiceRecorder extends StatefulWidget {
  final Function(String filePath, double duration) onRecordingComplete;

  const VoiceRecorder({super.key, required this.onRecordingComplete});

  @override
  State<VoiceRecorder> createState() => _VoiceRecorderState();
}

class _VoiceRecorderState extends State<VoiceRecorder> {
  bool isRecording = false;
  double recordingDuration = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isRecording ? Colors.red[50] : Colors.white,
        border: Border.all(
          color: isRecording ? Colors.red : Colors.grey[300]!,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            isRecording ? Icons.mic : Icons.mic_none,
            color: isRecording ? Colors.red : Colors.grey,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isRecording
                  ? 'Recording... ${recordingDuration.toStringAsFixed(1)}s'
                  : 'Press to record voice',
              style: TextStyle(
                color: isRecording ? Colors.red : Colors.grey,
              ),
            ),
          ),
          if (isRecording)
            TextButton(
              onPressed: () {
                setState(() => isRecording = false);
                widget.onRecordingComplete('', recordingDuration);
              },
              child: const Text('Send'),
            ),
        ],
      ),
    );
  }
}