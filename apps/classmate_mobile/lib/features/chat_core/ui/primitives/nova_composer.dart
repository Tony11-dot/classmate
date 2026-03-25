import 'package:flutter/material.dart';

import '../chat_composer.dart';

class NovaComposer extends StatelessWidget {
  const NovaComposer({
    super.key,
    required this.controller,
    this.enabled = true,
    this.isStreaming = false,
    this.isRecording = false,
    this.hint,
    this.hintText,
    this.onSend,
    this.onAttach,
    this.onCamera,
    this.onMic,
  });

  final TextEditingController controller;
  final bool enabled;
  final bool isStreaming;
  final bool isRecording;
  final String? hint;
  final String? hintText;
  final VoidCallback? onSend;
  final VoidCallback? onAttach;
  final VoidCallback? onCamera;
  final VoidCallback? onMic;

  @override
  Widget build(BuildContext context) {
    return ChatComposer(
      controller: controller,
      enabled: enabled,
      isStreaming: isStreaming,
      isRecording: isRecording,
      hint: hint,
      hintText: hintText,
      onSend: onSend ?? () {},
      onAttach: onAttach ?? () {},
      onCamera: onCamera ?? () {},
      onMic: onMic ?? () {},
    );
  }
}
