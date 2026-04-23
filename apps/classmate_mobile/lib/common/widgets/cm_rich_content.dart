import 'package:flutter/material.dart';
import 'package:classmate_mobile/common/widgets/cm_ai_message.dart';

class CMRichContent extends StatelessWidget {
  final String data;

  const CMRichContent({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return CMAiMessage(data, compact: true);
  }
}
