import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Wraps [SpeechToText] to provide on-device speech recognition.
///
/// Usage:
/// 1. Call [initialize] once (lazily or in initState).
/// 2. Call [startListening] to begin streaming partial results.
/// 3. Call [stopListening] to end recognition and receive the final transcript.
/// 4. Call [cancel] to abort without producing a result.
/// 5. Dispose via [dispose] when the owning widget is disposed.
class OnDeviceTranscriber {
  final SpeechToText _stt = SpeechToText();

  bool _initialized = false;
  String _lastResult = '';

  /// Whether the recognizer is currently listening.
  bool get isListening => _stt.isListening;

  /// Initialises the STT engine and requests the required platform permissions.
  ///
  /// Returns `true` if the device supports speech recognition and permission
  /// was granted, `false` otherwise.
  Future<bool> initialize() async {
    if (_initialized) return true;
    _initialized = await _stt.initialize(
      onError: (_) {},
      onStatus: (_) {},
    );
    return _initialized;
  }

  /// Begins listening and fires [onResult] with each partial transcript.
  ///
  /// Throws a [StateError] if [initialize] has not been called or if the
  /// device / OS denied permission.
  Future<void> startListening({
    required void Function(String partial) onResult,
    String localeId = 'en_US',
  }) async {
    if (!_initialized) {
      throw StateError(
        'OnDeviceTranscriber: call initialize() before startListening().',
      );
    }

    _lastResult = '';

    await _stt.listen(
      onResult: (SpeechRecognitionResult result) {
        _lastResult = result.recognizedWords;
        onResult(_lastResult);
      },
      localeId: localeId,
      listenFor: const Duration(minutes: 5),
      pauseFor: const Duration(seconds: 8),
      listenOptions: SpeechListenOptions(partialResults: true),
    );
  }

  /// Stops the current listening session and returns the final recognised text.
  Future<String> stopListening() async {
    await _stt.stop();
    return _lastResult.trim();
  }

  /// Cancels the current session without returning a result.
  Future<void> cancel() async {
    await _stt.cancel();
    _lastResult = '';
  }

  /// Returns all locales available for recognition on this device.
  Future<List<LocaleName>> availableLocales() => _stt.locales();

  /// Releases resources held by the underlying [SpeechToText] instance.
  void dispose() {
    _stt.cancel();
  }
}
