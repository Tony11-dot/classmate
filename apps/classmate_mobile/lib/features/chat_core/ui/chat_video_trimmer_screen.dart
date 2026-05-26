import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_trimmer/video_trimmer.dart';

import '../../../l10n/app_localizations.dart';

class ChatVideoTrimmerScreen extends StatefulWidget {
  const ChatVideoTrimmerScreen({super.key, required this.videoPath});

  final String videoPath;

  @override
  State<ChatVideoTrimmerScreen> createState() => _ChatVideoTrimmerScreenState();
}

class _ChatVideoTrimmerScreenState extends State<ChatVideoTrimmerScreen> {
  final Trimmer _trimmer = Trimmer();

  double _start = 0.0;
  double _end = 0.0;
  bool _isPlaying = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _trimmer.loadVideo(videoFile: File(widget.videoPath));
  }

  @override
  void dispose() {
    _trimmer.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    String? outputPath;
    await _trimmer.saveTrimmedVideo(
      startValue: _start,
      endValue: _end,
      onSave: (String? path) {
        outputPath = path;
      },
    );
    if (!mounted) return;
    setState(() => _saving = false);
    final p = outputPath;
    if (p != null && p.isNotEmpty) {
      Navigator.of(context).pop<String>(p);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(l.chatVideoTrimTitle),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: Text(
              l.commonSave,
              style: TextStyle(
                color: _saving ? Colors.white38 : Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: VideoViewer(trimmer: _trimmer)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: TrimViewer(
                trimmer: _trimmer,
                viewerHeight: 56,
                viewerWidth: MediaQuery.of(context).size.width - 24,
                durationStyle: DurationStyle.FORMAT_MM_SS,
                maxVideoLength: const Duration(minutes: 5),
                editorProperties: TrimEditorProperties(
                  borderPaintColor: Theme.of(context).colorScheme.primary,
                  scrubberPaintColor: Colors.white,
                ),
                onChangeStart: (v) => _start = v,
                onChangeEnd: (v) => _end = v,
                onChangePlaybackState: (v) =>
                    setState(() => _isPlaying = v),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: () async {
                final playing = await _trimmer.videoPlaybackControl(
                  startValue: _start,
                  endValue: _end,
                );
                setState(() => _isPlaying = playing);
              },
              child: Icon(_isPlaying
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
