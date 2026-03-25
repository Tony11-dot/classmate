import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class ChatCameraCaptureResult {
  const ChatCameraCaptureResult({required this.paths});

  final List<String> paths;
}

class ChatCameraCaptureScreen extends StatefulWidget {
  const ChatCameraCaptureScreen({super.key, this.title = 'Camera'});

  final String title;

  @override
  State<ChatCameraCaptureScreen> createState() =>
      _ChatCameraCaptureScreenState();
}

class _ChatCameraCaptureScreenState extends State<ChatCameraCaptureScreen> {
  final _picker = ImagePicker();
  bool _busy = false;
  final List<String> _shots = [];

  Future<void> _capture() async {
    String? path;

    if (Platform.isMacOS) {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      path = picked?.files.single.path;
    } else {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );
      path = picked?.path;
    }

    if (path == null || path.trim().isEmpty || !mounted) return;
    setState(() => _shots.add(path!));
  }

  Future<void> _pickFromGallery() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final picked = await _picker.pickMultiImage(imageQuality: 92);
      if (!mounted || picked.isEmpty) return;
      final paths = picked
          .map((x) => x.path)
          .where((p) => p.trim().isNotEmpty)
          .toList(growable: false);
      if (paths.isEmpty) return;
      Navigator.of(context).pop(ChatCameraCaptureResult(paths: paths));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final previewPath = _shots.isEmpty ? null : _shots.last;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.title),
        actions: [
          if (_shots.isNotEmpty)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(
                  ChatCameraCaptureResult(paths: List<String>.from(_shots)),
                );
              },
              child: Text(
                'Use',
                style: TextStyle(
                  color: cs.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: previewPath == null
                ? const Center(
                    child: Icon(
                      Icons.camera_alt_outlined,
                      size: 72,
                      color: Colors.white38,
                    ),
                  )
                : Image.file(
                    File(previewPath),
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
          ),
          if (_shots.isNotEmpty)
            SizedBox(
              height: 84,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                scrollDirection: Axis.horizontal,
                itemCount: _shots.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final path = _shots[index];
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(path),
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: -2,
                        top: -2,
                        child: IconButton(
                          visualDensity: const VisualDensity(
                            horizontal: -4,
                            vertical: -4,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black54,
                          ),
                          onPressed: () {
                            setState(() => _shots.removeAt(index));
                          },
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
            child: Row(
              children: [
                FilledButton.tonalIcon(
                  onPressed: _busy ? null : _pickFromGallery,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Gallery'),
                ),
                const Spacer(),
                InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: _busy ? null : _capture,
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: Center(
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 112,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      _shots.isEmpty
                          ? '0 selected'
                          : '${_shots.length} selected',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
