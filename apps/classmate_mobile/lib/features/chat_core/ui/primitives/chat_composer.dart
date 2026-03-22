import 'package:flutter/material.dart';

class ChatComposer extends StatelessWidget {
  const ChatComposer({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onCamera,
    required this.onAttach,
    required this.onMic,
    this.hint = 'Message',
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onCamera;
  final VoidCallback onAttach;
  final VoidCallback onMic;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Row(
            children: [
              _circle(Icons.camera_alt_rounded, onCamera),
              const SizedBox(width: 5),
              _circle(Icons.attach_file_rounded, onAttach),
              const SizedBox(width: 5),
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(minHeight: 40),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.42),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TextField(
                    controller: controller,
                    minLines: 1,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 13.5),
                    decoration: InputDecoration.collapsed(hintText: hint),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              _circle(Icons.mic_none_rounded, onMic),
              const SizedBox(width: 5),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A6DF4),
                  borderRadius: BorderRadius.circular(21),
                ),
                child: IconButton(
                  icon: const Icon(Icons.send_rounded, size: 19),
                  onPressed: onSend,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circle(IconData icon, VoidCallback onTap) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 17),
        onPressed: onTap,
      ),
    );
  }
}
