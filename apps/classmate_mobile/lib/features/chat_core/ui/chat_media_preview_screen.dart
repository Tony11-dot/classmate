import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:image_editor_plus/options.dart' as o;
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/widgets/cm_loading.dart';
import '../domain/outgoing_media.dart';
import 'chat_video_trimmer_screen.dart';

class ChatMediaPreviewResult {
  const ChatMediaPreviewResult({required this.media, required this.caption});

  final List<OutgoingMedia> media;
  final String caption;
}

class ChatMediaPreviewScreen extends StatefulWidget {
  const ChatMediaPreviewScreen({
    super.key,
    required this.initialMedia,
    this.title,
  });

  final List<OutgoingMedia> initialMedia;
  final String? title;

  @override
  State<ChatMediaPreviewScreen> createState() => _ChatMediaPreviewScreenState();
}

class _ChatMediaPreviewScreenState extends State<ChatMediaPreviewScreen> {
  late final TextEditingController _captionCtl;

  late List<OutgoingMedia> _media;
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

  bool _isVideoItem(OutgoingMedia m) {
    final mime = (m.mime ?? '').toLowerCase();
    if (mime.startsWith('video/')) return true;
    final lower = m.name.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.m4v') ||
        lower.endsWith('.avi') ||
        lower.endsWith('.webm');
  }

  bool get _currentIsVideo => _media.isNotEmpty && _isVideoItem(_media[_index]);

  @override
  void initState() {
    super.initState();
    _media = List<OutgoingMedia>.from(
      widget.initialMedia.where((e) => e.hasBytes || (e.path ?? '').trim().isNotEmpty),
    );
    _quarterTurns = List<int>.filled(_media.length, 0);
    _mirrored = List<bool>.filled(_media.length, false);
    _captionCtl = TextEditingController();
    _syncVideo();
  }

  Future<void> _syncVideo() async {
    // Video preview is a mobile-only path (VideoPlayerController.file needs a
    // filesystem). Web media is images/files only, so this is a no-op there.
    if (kIsWeb || _media.isEmpty || !_isVideoItem(_media[_index])) {
      if (_videoCtl != null) {
        await _videoCtl!.dispose();
        _videoCtl = null;
        _videoPath = null;
      }
      if (mounted) setState(() {});
      return;
    }

    final currentPath = _media[_index].path ?? '';
    if (currentPath.isEmpty) return;
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
    if (_media.isEmpty || _currentIsVideo) return;
    setState(() {
      _quarterTurns[_index] = (_quarterTurns[_index] + delta) % 4;
      if (_quarterTurns[_index] < 0) {
        _quarterTurns[_index] += 4;
      }
    });
  }

  void _mirrorCurrent() {
    if (_media.isEmpty || _currentIsVideo) return;
    setState(() {
      _mirrored[_index] = !_mirrored[_index];
    });
  }

  void _resetCurrentEdits() {
    if (_media.isEmpty || _currentIsVideo) return;
    setState(() {
      _quarterTurns[_index] = 0;
      _mirrored[_index] = false;
    });
  }

  Future<void> _openEditor() async {
    if (_media.isEmpty || _currentIsVideo) return;
    // image_editor_plus (Draw & Crop) is not reliable in a browser — its
    // canvas path throws at render time, which escapes any try/catch here and
    // white-screens the whole app, forcing a refresh (web QA #4/#25). Keep it
    // degraded on web, matching the video-trim path; rotate/mirror still work.
    if (kIsWeb) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.chatMediaWebUnsupported),
        ),
      );
      return;
    }
    final current = _media[_index];
    try {
      // Editor works on bytes on every platform. Mobile reads them from the
      // file; web already holds them in memory.
      final Uint8List bytes = current.hasBytes
          ? current.bytes!
          : await File(current.path!).readAsBytes();
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
      final edited = OutgoingMedia(
        name: tmpPath.split('/').last,
        path: tmpPath,
        mime: 'image/jpeg',
        previewUrl: tmpPath,
      );
      setState(() {
        _media = List<OutgoingMedia>.from(_media)..[_index] = edited;
        _quarterTurns[_index] = 0;
        _mirrored[_index] = false;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.chatCouldNotSendMedia),
        ),
      );
    }
  }

  Future<void> _trimCurrent() async {
    if (_media.isEmpty || kIsWeb) return;
    final current = _media[_index];
    if (!_isVideoItem(current) || (current.path ?? '').isEmpty) return;
    final currentPath = current.path!;

    // Release the preview player so the trimmer can take exclusive access
    // to the file. Without this the trimmer's own VideoPlayerController
    // fails to initialize on iOS for the same path.
    await _videoCtl?.dispose();
    _videoCtl = null;
    _videoPath = null;
    if (mounted) setState(() {});

    final trimmedPath = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => ChatVideoTrimmerScreen(videoPath: currentPath),
      ),
    );
    if (!mounted) return;
    if (trimmedPath != null && trimmedPath.isNotEmpty) {
      setState(() {
        _media = List<OutgoingMedia>.from(_media)
          ..[_index] = OutgoingMedia(
            name: trimmedPath.split('/').last,
            path: trimmedPath,
            mime: current.mime,
            previewUrl: trimmedPath,
          );
      });
    }
    await _syncVideo();
  }

  Future<void> _removeCurrent() async {
    if (_media.isEmpty) return;

    setState(() {
      final idx = _index.clamp(0, _media.length - 1);
      _media = List<OutgoingMedia>.from(_media)..removeAt(idx);
      _quarterTurns = List<int>.from(_quarterTurns)..removeAt(idx);
      _mirrored = List<bool>.from(_mirrored)..removeAt(idx);

      if (_media.isNotEmpty && _index >= _media.length) {
        _index = _media.length - 1;
      }
    });

    if (_media.isEmpty) {
      if (mounted) {
        Navigator.of(context).pop(
          ChatMediaPreviewResult(
            media: const [],
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

  /// Renders a still image for [m] with the given rotation/mirror transform,
  /// choosing `Image.memory` (web bytes) vs `Image.file` (mobile path).
  Widget _imageFor(OutgoingMedia m, Matrix4 transform, BoxFit fit) {
    final broken = Container(
      color: Colors.black12,
      alignment: Alignment.center,
      child: const Icon(Icons.broken_image_outlined, color: Colors.white70),
    );
    final Widget img = m.hasBytes
        ? Image.memory(
            m.bytes!,
            fit: fit,
            errorBuilder: (context, error, stackTrace) => broken,
          )
        : Image.file(
            File(m.path!),
            fit: fit,
            errorBuilder: (context, error, stackTrace) => broken,
          );
    return Transform(
      alignment: Alignment.center,
      transform: transform,
      child: img,
    );
  }

  Matrix4 _transformFor(int i) => Matrix4.identity()
    ..rotateZ((_quarterTurns[i] % 4) * (math.pi / 2))
    ..multiply(Matrix4.diagonal3Values(_mirrored[i] ? -1.0 : 1.0, 1.0, 1.0));

  Widget _buildThumb(OutgoingMedia m, int i) {
    if (_isVideoItem(m)) {
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
    return _imageFor(m, _transformFor(i), BoxFit.cover);
  }

  Widget _buildImagePreview(OutgoingMedia m) {
    return InteractiveViewer(
      minScale: 0.8,
      maxScale: 4,
      child: Center(
        child: _imageFor(m, _transformFor(_index), BoxFit.contain),
      ),
    );
  }

  Widget _buildVideoPreview() {
    if (_videoCtl == null || !_videoCtl!.value.isInitialized) {
      return const Center(child: CmLoading());
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
                tooltip: AppLocalizations.of(context)!.a11yPrevious,
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
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  tooltip: c.value.isPlaying
                      ? AppLocalizations.of(context)!.a11yPause
                      : AppLocalizations.of(context)!.a11yPlay,
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
                    color: Colors.black,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                tooltip: AppLocalizations.of(context)!.a11yNext,
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
    if (_media.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.chatMediaPreviewEmptyState,
          style: const TextStyle(color: Colors.white70),
        ),
      );
    }

    final current = _media[_index];
    return _isVideoItem(current)
        ? _buildVideoPreview()
        : _buildImagePreview(current);
  }

  Widget _buildToolsTray() {
    if (_media.isEmpty) return const SizedBox.shrink();
    final isVideo = _currentIsVideo;
    final l = AppLocalizations.of(context)!;

    return SizedBox(
      height: 52,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
        scrollDirection: Axis.horizontal,
        children: [
          if (isVideo) ...[
            _toolButton(
              icon: Icons.content_cut_rounded,
              label: l.chatMediaPreviewTrimAction,
              onTap: _trimCurrent,
            ),
            const SizedBox(width: 8),
          ],
          if (!isVideo) ...[
            // Draw & Crop is mobile-only — the editor's canvas crashes on web.
            if (!kIsWeb) ...[
              _toolButton(
                icon: Icons.draw_rounded,
                label: l.chatMediaPreviewDrawCropAction,
                onTap: _openEditor,
              ),
              const SizedBox(width: 8),
            ],
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
          if (_media.isNotEmpty)
            Container(
              margin: const EdgeInsetsDirectional.only(end: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${_index + 1}/${_media.length}',
                style: const TextStyle(
                  color: Colors.black,
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
            if (_media.length > 1)
              SizedBox(
                height: 82,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  scrollDirection: Axis.horizontal,
                  itemCount: _media.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final item = _media[i];
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
                        child: _buildThumb(item, i),
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
                    // Single rounded pill — the prior white Border.all on
                    // the dark fill was reading as a separate frame around
                    // the TextField's own content area, giving a
                    // "box-in-box" feel. Dropped the border so only the
                    // dark fill defines the input.
                    child: TextField(
                      controller: _captionCtl,
                      minLines: 1,
                      maxLines: 4,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: l.chatMediaPreviewCaptionHint,
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: const Color(0xFF151A20),
                        // No visible border in any state — the fill is the
                        // box. enabled/focused/etc. all map to the same
                        // BorderSide.none variant so focus doesn't flash a
                        // frame.
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(18)),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(18)),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(18)),
                          borderSide: BorderSide.none,
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
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
                            media: _media,
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
