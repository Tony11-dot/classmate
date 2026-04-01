import 'package:flutter/material.dart';

import '../models/chat_message_info.dart';

class ChatMessageInfoRouteArgs {
  const ChatMessageInfoRouteArgs({
    required this.info,
    this.previewTitle = '',
    this.previewBody = '',
    this.previewMeta = '',
    this.previewBubble,
    this.previewBubbleBuilder,
    this.seenByNames = const <String>[],
    this.deliveredToNames = const <String>[],
  });

  final ChatMessageInfo info;
  final String previewTitle;
  final String previewBody;
  final String previewMeta;
  final Widget? previewBubble;
  final WidgetBuilder? previewBubbleBuilder;
  final List<String> seenByNames;
  final List<String> deliveredToNames;
}
