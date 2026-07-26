import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'classnotes_models.dart';

/// The ClassNotes library data layer. Today it serves the sample [CnLibrary]
/// (there is no notebooks backend yet — the native ClassNotes app stores them
/// locally on the iPad). It is deliberately a single provider so that when real
/// sync lands, only this line changes: swap the sample source for a repository
/// that fetches/streams the user's actual notebooks (e.g. a `FutureProvider` /
/// `StreamProvider` over a `CnLibraryRepository`). Every widget already reads
/// through here and re-sorts nothing, so the UI needs no changes.
final classNotesLibraryProvider = Provider<CnLibrary>((ref) {
  return CnSampleData.library();
});
