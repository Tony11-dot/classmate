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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
        child: Row(
          children: [
            _circle(Icons.camera_alt_rounded, onCamera),
            const SizedBox(width: 6),
            _circle(Icons.attach_file_rounded, onAttach),
            const SizedBox(width: 6),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 4,
                  style: const TextStyle(fontSize: 15),
                  decoration: InputDecoration.collapsed(hintText: hint),
                ),
              ),
            ),
            const SizedBox(width: 6),
            _circle(Icons.mic_none_rounded, onMic),
            const SizedBox(width: 6),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF2A6DF4),
                borderRadius: BorderRadius.circular(22),
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded, size: 20),
                onPressed: onSend,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circle(IconData icon, VoidCallback onTap) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        shape: BoxShape.circle,
      ),
      child: IconButton(icon: Icon(icon, size: 18), onPressed: onTap),
    );
  }
}
