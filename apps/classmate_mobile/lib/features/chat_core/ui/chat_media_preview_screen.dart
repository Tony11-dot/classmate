import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:image_editor_plus/options.dart' as o;
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/widgets/cm_loading.dart';

class ChatMediaPreviewResult {
  const ChatMediaPreviewResult({required this.paths, required this.caption});

  final List<String> paths;
  final String caption;
}

class ChatMediaPreviewScreen extends StatefulWidget {
  const ChatMediaPreviewScreen({
    super.key,
    required this.initialPaths,
    this.title,
  });

  final List<String> initialPaths;
  final String? title;

  @override
  State<ChatMediaPreviewScreen> createState() => _ChatMediaPreviewScreenState();
}

class _ChatMediaPreviewScreenState extends State<ChatMediaPreviewScreen> {
  late final TextEditingController _captionCtl;

  late List<String> _paths;
  late List<int> _quarterTurns;
  late List<bool> _mirrored;
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
    _mirrored = List<bool>.filled(_paths.length, false);
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

  void _rotateCurrent(int delta) {
    if (_paths.isEmpty || _isVideo(_paths[_index])) return;
    setState(() {
      _quarterTurns[_index] = (_quarterTurns[_index] + delta) % 4;
      if (_quarterTurns[_index] < 0) {
        _quarterTurns[_index] += 4;
      }
    });
  }

  void _mirrorCurrent() {
    if (_paths.isEmpty || _isVideo(_paths[_index])) return;
    setState(() {
      _mirrored[_index] = !_mirrored[_index];
    });
  }

  void _resetCurrentEdits() {
    if (_paths.isEmpty || _isVideo(_paths[_index])) return;
    setState(() {
      _quarterTurns[_index] = 0;
      _mirrored[_index] = false;
    });
  }

  Future<void> _openEditor() async {
    if (_paths.isEmpty || _isVideo(_paths[_index])) return;
    final bytes = await File(_paths[_index]).readAsBytes();
    if (!mounted) return;
    final result = await Navigator.push<Uint8List>(
      context,
      MaterialPageRoute(
        builder: (_) => ImageEditor(
          image: bytes,
          outputFormat: o.OutputFormat.jpeg,
          cropOption: const o.CropOption(),
          brushOption: const o.BrushOption(showBackground: true),
          flipOption: const o.FlipOption(),
          rotateOption: const o.RotateOption(),
          filtersOption: null,
          blurOption: null,
          emojiOption: null,
          textOption: null,
        ),
      ),
    );
    if (result == null || !mounted) return;
    final dir = await getTemporaryDirectory();
    final tmpPath =
        '${dir.path}/edited_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await File(tmpPath).writeAsBytes(result);
    setState(() {
      _paths = List<String>.from(_paths)..[_index] = tmpPath;
      _quarterTurns[_index] = 0;
      _mirrored[_index] = false;
    });
  }

  Future<void> _removeCurrent() async {
    if (_paths.isEmpty) return;

    setState(() {
      final idx = _index.clamp(0, _paths.length - 1);
      _paths = List<String>.from(_paths)..removeAt(idx);
      _quarterTurns = List<int>.from(_quarterTurns)..removeAt(idx);
      _mirrored = List<bool>.from(_mirrored)..removeAt(idx);

      if (_paths.isNotEmpty && _index >= _paths.length) {
        _index = _paths.length - 1;
      }
    });

    if (_paths.isEmpty) {
      if (mounted) {
        Navigator.of(context).pop(
          ChatMediaPreviewResult(
            paths: const [],
            caption: _captionCtl.text.trim(),
          ),
        );
      }
      return;
    }

    await _syncVideo();
  }

  Widget _toolButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool destructive = false,
  }) {
    final fg = destructive ? const Color(0xFFFF7D73) : Colors.white;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF151A20),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: fg),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: fg,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumb(String itemPath, int i) {
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

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..rotateZ((_quarterTurns[i] % 4) * (math.pi / 2))
        ..multiply(Matrix4.diagonal3Values(_mirrored[i] ? -1.0 : 1.0, 1.0, 1.0)),
      child: Image.file(
        File(itemPath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.black12,
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image_outlined),
        ),
      ),
    );
  }

  Widget _buildImagePreview(String currentPath) {
    return InteractiveViewer(
      minScale: 0.8,
      maxScale: 4,
      child: Center(
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..rotateZ((_quarterTurns[_index] % 4) * (math.pi / 2))
            ..multiply(Matrix4.diagonal3Values(_mirrored[_index] ? -1.0 : 1.0, 1.0, 1.0)),
          child: Image.file(
            File(currentPath),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Center(
              child: Icon(
                Icons.broken_image_outlined,
                color: Colors.white70,
                size: 40,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPreview() {
    if (_videoCtl == null || !_videoCtl!.value.isInitialized) {
      return const Center(child: const CmLoading());
    }

    final c = _videoCtl!;
    final pos = c.value.position;
    final dur = c.value.duration;
    final maxMs = dur.inMilliseconds <= 0 ? 1.0 : dur.inMilliseconds.toDouble();
    final liveMs = pos.inMilliseconds.clamp(0, dur.inMilliseconds).toDouble();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: c.value.aspectRatio == 0 ? 16 / 9 : c.value.aspectRatio,
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
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
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
                Text(_fmt(pos), style: const TextStyle(color: Colors.white70)),
                const Spacer(),
                Text(_fmt(dur), style: const TextStyle(color: Colors.white70)),
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
                icon: const Icon(Icons.replay_10_rounded, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white),
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
                    c.value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
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
                icon: const Icon(Icons.forward_10_rounded, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainPreview() {
    if (_paths.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.chatMediaPreviewEmptyState,
          style: const TextStyle(color: Colors.white70),
        ),
      );
    }

    final currentPath = _paths[_index];
    return _isVideo(currentPath) ? _buildVideoPreview() : _buildImagePreview(currentPath);
  }

  Widget _buildToolsTray() {
    if (_paths.isEmpty) return const SizedBox.shrink();
    final isVideo = _isVideo(_paths[_index]);
    final l = AppLocalizations.of(context)!;

    return SizedBox(
      height: 52,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
        scrollDirection: Axis.horizontal,
        children: [
          if (!isVideo) ...[
            _toolButton(
              icon: Icons.draw_rounded,
              label: l.chatMediaPreviewDrawCropAction,
              onTap: _openEditor,
            ),
            const SizedBox(width: 8),
            _toolButton(
              icon: Icons.rotate_left_rounded,
              label: l.chatMediaPreviewRotateLeftAction,
              onTap: () => _rotateCurrent(-1),
            ),
            const SizedBox(width: 8),
            _toolButton(
              icon: Icons.rotate_right_rounded,
              label: l.chatMediaPreviewRotateRightAction,
              onTap: () => _rotateCurrent(1),
            ),
            const SizedBox(width: 8),
            _toolButton(
              icon: Icons.flip_rounded,
              label: l.chatMediaPreviewMirrorAction,
              onTap: _mirrorCurrent,
            ),
            const SizedBox(width: 8),
            _toolButton(
              icon: Icons.refresh_rounded,
              label: l.chatMediaPreviewResetAction,
              onTap: _resetCurrentEdits,
            ),
            const SizedBox(width: 8),
          ],
          _toolButton(
            icon: Icons.delete_outline_rounded,
            label: l.chatMediaPreviewRemoveAction,
            onTap: _removeCurrent,
            destructive: true,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _videoCtl?.dispose();
    _captionCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(widget.title ?? l.tutorPreviewTitle),
        actions: [
          if (_paths.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${_index + 1}/${_paths.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildMainPreview()),
            _buildToolsTray(),
            if (_paths.length > 1)
              SizedBox(
                height: 82,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  scrollDirection: Axis.horizontal,
                  itemCount: _paths.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
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
                        child: _buildThumb(itemPath, i),
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
                        border: Border.all(color: Colors.white),
                      ),
                      child: TextField(
                        controller: _captionCtl,
                        minLines: 1,
                        maxLines: 4,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: l.chatMediaPreviewCaptionHint,
                          hintStyle: const TextStyle(color: Colors.white54),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 54,
                    height: 54,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: EdgeInsets.zero,
                      ),
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
