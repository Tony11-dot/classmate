import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/api_client.dart';
import '../../ui/liquid_dropdown.dart';
import 'me_subjects_provider.dart';
import 'solutions_controller.dart';

class UploadSolutionSheet extends ConsumerStatefulWidget {
  final int? initialGrade;
  final String? initialSubjectId;
  final String? initialBook;
  final int? initialPage;
  final String? initialQuestion;

  const UploadSolutionSheet({
    super.key,
    this.initialGrade,
    this.initialSubjectId,
    this.initialBook,
    this.initialPage,
    this.initialQuestion,
  });

  @override
  ConsumerState<UploadSolutionSheet> createState() =>
      _UploadSolutionSheetState();
}

class _UploadSolutionSheetState extends ConsumerState<UploadSolutionSheet> {
  final book = TextEditingController();
  final page = TextEditingController();
  final question = TextEditingController();
  final caption = TextEditingController();
  final mediaUrl = TextEditingController();

  int grade = 10;
  String? subjectId;

  bool loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialGrade != null) grade = widget.initialGrade!;
    if (widget.initialSubjectId != null) subjectId = widget.initialSubjectId;
    if (widget.initialBook != null) book.text = widget.initialBook!;
    if (widget.initialPage != null) page.text = widget.initialPage!.toString();
    if (widget.initialQuestion != null) question.text = widget.initialQuestion!;
  }

  String? err;

  @override
  void dispose() {
    book.dispose();
    page.dispose();
    question.dispose();
    caption.dispose();
    mediaUrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      loading = true;
      err = null;
    });

    try {
      if (subjectId == null || subjectId!.trim().isEmpty) {
        setState(() => err = "Pick a subject.");
        return;
      }

      final p = int.tryParse(page.text.trim());
      if (p == null || p <= 0) {
        setState(() => err = "Page must be a number.");
        return;
      }

      if (book.text.trim().isEmpty) {
        setState(() => err = "Book is required.");
        return;
      }
      if (question.text.trim().isEmpty) {
        setState(() => err = "Question is required.");
        return;
      }
      if (mediaUrl.text.trim().isEmpty) {
        setState(() => err = "Media URL is required (for now).");
        return;
      }

      await ApiClient.instance.post(
        "/solutions",
        data: {
          "subjectId": subjectId,
          "grade": grade,
          "book": book.text.trim(),
          "page": p,
          "question": question.text.trim(),
          "caption": caption.text.trim().isEmpty ? null : caption.text.trim(),
          "mediaUrl": mediaUrl.text.trim(),
        },
      );

      if (!mounted) return;

      // refresh feed
      ref.read(solutionsProvider.notifier).refresh();

      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("✅ Uploaded")));
    } catch (e) {
      setState(() => err = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final subs = ref.watch(meSubjectsProvider);

    final subjectItems = <DropdownMenuItem<String?>>[
      const DropdownMenuItem<String?>(
        value: null,
        child: Text("Choose…", overflow: TextOverflow.ellipsis),
      ),
      ...subs.maybeWhen(
        data: (rows) => rows
            .map(
              (x) => DropdownMenuItem<String?>(
                value: x.id,
                child: Text(x.name, overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(),
        orElse: () => const <DropdownMenuItem<String?>>[
          DropdownMenuItem<String?>(
            value: null,
            child: Text("Loading…", overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    ];

    final gradeItems = const [7, 8, 9, 10, 11, 12]
        .map(
          (g) => DropdownMenuItem<int>(
            value: g,
            child: Text("$g", overflow: TextOverflow.ellipsis),
          ),
        )
        .toList();

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ListView(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Upload solution",
                style: t.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: LiquidDropdown<int>(
                    value: grade,
                    label: "Grade",
                    searchable: true,
                    items: gradeItems,
                    onChanged: loading
                        ? null
                        : (v) => setState(() => grade = v ?? 10),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: LiquidDropdown<String?>(
                    value: subjectId,
                    label: "Subject",
                    searchable: true,
                    items: subjectItems,
                    onChanged: loading
                        ? null
                        : (v) => setState(() => subjectId = v),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            TextField(
              controller: book,
              decoration: const InputDecoration(labelText: "Book"),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: page,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Page"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: question,
                    decoration: const InputDecoration(labelText: "Question"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: caption,
              decoration: const InputDecoration(
                labelText: "Caption (optional)",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: mediaUrl,
              decoration: const InputDecoration(labelText: "Media URL (image)"),
            ),

            if (err != null) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(err!, style: TextStyle(color: t.colorScheme.error)),
              ),
            ],

            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: loading ? null : _submit,
                child: Text(loading ? "Uploading…" : "Upload"),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
