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

  String _fmt(Duration d) {
    final total = d.inSeconds < 0 ? 0 : d.inSeconds;
    final hh = total ~/ 3600;
    final mm = (total % 3600) ~/ 60;
    final ss = total % 60;
    if (hh > 0) {
      return '${hh.toString().padLeft(2, '0')}:${mm.toString().padLeft(2, '0')}:${ss.toString().padLeft(2, '0')}';
    }
    return '${mm.toString().padLeft(2, '0')}:${ss.toString().padLeft(2, '0')}';
  }

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
    ctl.addListener(() {
      if (mounted) setState(() {});
    });

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

      final c = _videoCtl!;
      final pos = c.value.position;
      final dur = c.value.duration;
      final maxMs =
          dur.inMilliseconds <= 0 ? 1.0 : dur.inMilliseconds.toDouble();
      final liveMs =
          pos.inMilliseconds.clamp(0, dur.inMilliseconds).toDouble();

      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: c.value.aspectRatio == 0
                      ? 16 / 9
                      : c.value.aspectRatio,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      color: Colors.black,
                      child: VideoPlayer(c),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 7,
                ),
                overlayShape: const RoundSliderOverlayShape(
                  overlayRadius: 14,
                ),
              ),
              child: Slider(
                value: liveMs.clamp(0.0, maxMs),
                min: 0,
                max: maxMs,
                onChanged: (v) async {
                  await c.seekTo(Duration(milliseconds: v.round()));
                  if (mounted) setState(() {});
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Row(
                children: [
                  Text(
                    _fmt(pos),
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const Spacer(),
                  Text(
                    _fmt(dur),
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () async {
                    final back = pos - const Duration(seconds: 10);
                    await c.seekTo(back.isNegative ? Duration.zero : back);
                    if (mounted) setState(() {});
                  },
                  icon: const Icon(
                    Icons.replay_10_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: IconButton(
                    onPressed: () async {
                      if (c.value.isPlaying) {
                        await c.pause();
                      } else {
                        await c.play();
                      }
                      if (mounted) setState(() {});
                    },
                    icon: Icon(
                      c.value.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () async {
                    final next = pos + const Duration(seconds: 10);
                    await c.seekTo(next > dur ? dur : next);
                    if (mounted) setState(() {});
                  },
                  icon: const Icon(
                    Icons.forward_10_rounded,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
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
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Page ${_index + 1} / ${_paths.length}',
                  style: const TextStyle(color: Colors.white54),
                ),
              ),
            if (_paths.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                  ),
                  child: ExpansionTile(
                    collapsedBackgroundColor: const Color(0xFF151A20),
                    backgroundColor: const Color(0xFF151A20),
                    collapsedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                    leading: const Icon(Icons.tune_rounded, color: Colors.white),
                    title: const Text(
                      'Editing tools',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      _isVideo(_paths[_index])
                          ? 'Preview tools'
                          : 'Rotate or remove this item',
                      style: const TextStyle(color: Colors.white54),
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                    children: [
                      if (!_isVideo(_paths[_index]))
                        ListTile(
                          leading: const Icon(
                            Icons.rotate_left_rounded,
                            color: Colors.white,
                          ),
                          title: const Text(
                            'Rotate left',
                            style: TextStyle(color: Colors.white),
                          ),
                          onTap: () => _rotateCurrent(-1),
                        ),
                      if (!_isVideo(_paths[_index]))
                        ListTile(
                          leading: const Icon(
                            Icons.rotate_right_rounded,
                            color: Colors.white,
                          ),
                          title: const Text(
                            'Rotate right',
                            style: TextStyle(color: Colors.white),
                          ),
                          onTap: () => _rotateCurrent(1),
                        ),
                      if (!_isVideo(_paths[_index]))
                        ListTile(
                          leading: const Icon(
                            Icons.refresh_rounded,
                            color: Colors.white,
                          ),
                          title: const Text(
                            'Reset rotation',
                            style: TextStyle(color: Colors.white),
                          ),
                          onTap: () {
                            setState(() {
                              _quarterTurns[_index] = 0;
                            });
                          },
                        ),
                      ListTile(
                        leading: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.redAccent,
                        ),
                        title: const Text(
                          'Remove current item',
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: _removeCurrent,
                      ),
                    ],
                  ),
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
