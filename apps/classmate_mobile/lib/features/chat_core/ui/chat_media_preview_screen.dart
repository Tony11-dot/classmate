import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ChatMediaPreviewResult {
  const ChatMediaPreviewResult({required this.paths, required this.caption});

  final List<String> paths;
  final String caption;
}

class ChatMediaPreviewScreen extends StatefulWidget {
  const ChatMediaPreviewScreen({
    super.key,
    required this.initialPaths,
    this.title = 'Preview',
  });

  final List<String> initialPaths;
  final String title;

  @override
  State<ChatMediaPreviewScreen> createState() => _ChatMediaPreviewScreenState();
}

class _ChatMediaPreviewScreenState extends State<ChatMediaPreviewScreen> {
  late final PageController _pageCtl;
  late final TextEditingController _captionCtl;

  late List<String> _paths;
  late List<int> _quarterTurns;
  int _index = 0;

  VideoPlayerController? _videoCtl;
  String? _videoPath;

  bool _isVideo(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.m4v') ||
        lower.endsWith('.avi') ||
        lower.endsWith('.webm');
  }

  @override
  void initState() {
    super.initState();
    _paths = List<String>.from(
      widget.initialPaths.where((e) => e.trim().isNotEmpty),
    );
    _quarterTurns = List<int>.filled(_paths.length, 0);
    _pageCtl = PageController();
    _captionCtl = TextEditingController();
    _syncVideo();
  }

  Future<void> _syncVideo() async {
    if (_paths.isEmpty) {
      if (_videoCtl != null) {
        await _videoCtl!.dispose();
        _videoCtl = null;
        _videoPath = null;
      }
      if (mounted) setState(() {});
      return;
    }

    final currentPath = _paths[_index];
    if (!_isVideo(currentPath)) {
      if (_videoCtl != null) {
        await _videoCtl!.dispose();
        _videoCtl = null;
        _videoPath = null;
      }
      if (mounted) setState(() {});
      return;
    }

    if (_videoCtl != null && _videoPath == currentPath) return;

    if (_videoCtl != null) {
      await _videoCtl!.dispose();
      _videoCtl = null;
      _videoPath = null;
    }

    final ctl = VideoPlayerController.file(File(currentPath));
    await ctl.initialize();
    await ctl.setLooping(true);

    _videoCtl = ctl;
    _videoPath = currentPath;
    if (mounted) setState(() {});
  }

  Widget _buildThumb(String itemPath) {
    if (_isVideo(itemPath)) {
      return Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: const Icon(
          Icons.videocam_rounded,
          color: Colors.white70,
          size: 28,
        ),
      );
    }

    final thumbIndex = _paths.indexOf(itemPath);
    final turns = thumbIndex >= 0 && thumbIndex < _quarterTurns.length
        ? _quarterTurns[thumbIndex]
        : 0;

    return Transform.rotate(
      angle: (turns % 4) * (math.pi / 2),
      child: Image.file(
        File(itemPath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.black12,
            alignment: Alignment.center,
            child: const Icon(Icons.broken_image_outlined),
          );
        },
      ),
    );
  }

  Widget _buildMainPreview() {
    if (_paths.isEmpty) {
      return const Center(
        child: Text(
          'Nothing to preview',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    final currentPath = _paths[_index];

    if (_isVideo(currentPath)) {
      if (_videoCtl == null || !_videoCtl!.value.isInitialized) {
        return const Center(child: CircularProgressIndicator());
      }

      return Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _videoCtl!.value.aspectRatio == 0
                ? 1
                : _videoCtl!.value.aspectRatio,
            child: VideoPlayer(_videoCtl!),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.36),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () async {
                if (_videoCtl == null) return;
                if (_videoCtl!.value.isPlaying) {
                  await _videoCtl!.pause();
                } else {
                  await _videoCtl!.play();
                }
                if (mounted) setState(() {});
              },
              icon: Icon(
                (_videoCtl?.value.isPlaying ?? false)
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),
          ),
        ],
      );
    }

    return InteractiveViewer(
      minScale: 0.8,
      maxScale: 4,
      child: Transform.rotate(
        angle: (_quarterTurns[_index] % 4) * (math.pi / 2),
        child: Image.file(
          File(currentPath),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(
                Icons.broken_image_outlined,
                color: Colors.white70,
                size: 40,
              ),
            );
          },
        ),
      ),
    );
  }

  void _rotateCurrent(int delta) {
    if (_paths.isEmpty) return;
    setState(() {
      _quarterTurns[_index] = (_quarterTurns[_index] + delta) % 4;
      if (_quarterTurns[_index] < 0) {
        _quarterTurns[_index] += 4;
      }
    });
  }

  void _removeCurrent() {
    if (_paths.isEmpty) return;

    setState(() {
      final idx = _index.clamp(0, _paths.length - 1);
      _paths = List<String>.from(_paths)..removeAt(idx);
      if (_quarterTurns.length > idx) {
        _quarterTurns = List<int>.from(_quarterTurns)..removeAt(idx);
      }

      if (_paths.isEmpty) {
        Navigator.of(context).pop(
          ChatMediaPreviewResult(
            paths: const [],
            caption: _captionCtl.text.trim(),
          ),
        );
        return;
      }

      if (_index >= _paths.length) {
        _index = _paths.length - 1;
      }
    });
  }

  @override
  void dispose() {
    _videoCtl?.dispose();
    _pageCtl.dispose();
    _captionCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: _paths.isEmpty
                ? null
                : () async {
                    setState(() {
                      _paths = List<String>.from(_paths)..removeAt(_index);
                      if (_paths.isNotEmpty && _index >= _paths.length) {
                        _index = _paths.length - 1;
                      }
                    });

                    if (_paths.isEmpty) {
                      if (mounted) Navigator.of(context).pop();
                      return;
                    }

                    await _syncVideo();
                  },
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildMainPreview()),
            if (_paths.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                child: Row(
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: () => _rotateCurrent(-1),
                      icon: const Icon(Icons.rotate_left_rounded),
                      label: const Text('Rotate'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.tonalIcon(
                      onPressed: () => _rotateCurrent(1),
                      icon: const Icon(Icons.rotate_right_rounded),
                      label: const Text('Rotate'),
                    ),
                    const Spacer(),
                    FilledButton.tonalIcon(
                      onPressed: _removeCurrent,
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text('Remove'),
                    ),
                  ],
                ),
              ),
            if (_paths.length > 1)
              SizedBox(
                height: 82,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  scrollDirection: Axis.horizontal,
                  itemCount: _paths.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final itemPath = _paths[i];
                    final active = i == _index;
                    return GestureDetector(
                      onTap: () async {
                        setState(() => _index = i);
                        await _syncVideo();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 58,
                        height: 58,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: active ? cs.primary : Colors.white24,
                            width: active ? 2 : 1,
                          ),
                        ),
                        child: _buildThumb(itemPath),
                      ),
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF151A20),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                      child: TextField(
                        controller: _captionCtl,
                        minLines: 1,
                        maxLines: 4,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Add a caption...',
                          hintStyle: TextStyle(color: Colors.white54),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop(
                        ChatMediaPreviewResult(
                          paths: _paths,
                          caption: _captionCtl.text.trim(),
                        ),
                      );
                    },
                    child: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
