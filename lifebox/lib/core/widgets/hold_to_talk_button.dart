import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:lifebox/l10n/app_localizations.dart';

class HoldToTalkButton extends StatefulWidget {
  const HoldToTalkButton({
    super.key,
    required this.onFinalText,
    this.localeId,
  });

  final void Function(String text) onFinalText;
  final String? localeId;

  @override
  State<HoldToTalkButton> createState() => _HoldToTalkButtonState();
}

class _HoldToTalkButtonState extends State<HoldToTalkButton> {
  final stt.SpeechToText _stt = stt.SpeechToText();

  bool _available = false;
  bool _listening = false;

  String _partial = '';
  String? _finalText; // ✅ 关键：补上
  SpeechRecognitionResult? _lastResult;

  DateTime _lastLevelLog = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    _init();
  }

  String? _lastStatus;
  String? _lastError;
  Future<void> _init() async {
    final ok = await _stt.initialize(
      onStatus: (s) {
        _lastStatus = s;
        debugPrint('STT status=$s');
      },
      onError: (e) {
        _lastError = '${e.errorMsg} (${e.permanent})';
        debugPrint('STT error=$e');
      },
    );
    if (!mounted) return;
    setState(() => _available = ok);
    debugPrint('STT available=$ok');
  }

  Future<void> _start() async {
    if (!_available || _listening) {
      debugPrint('START blocked: available=$_available listening=$_listening');
      return;
    }

    setState(() {
      _listening = true;
      _partial = '';
      _finalText = null;
      _lastResult = null;
    });

    await _stt.listen(
      localeId: widget.localeId,
      listenMode: stt.ListenMode.confirmation,
      partialResults: true,
      listenFor: const Duration(seconds: 20),
      pauseFor: const Duration(milliseconds: 700),
      onSoundLevelChange: (level) {
        // ✅ 节流，避免 skipped frames
        final now = DateTime.now();
        if (now.difference(_lastLevelLog).inMilliseconds < 120) return;
        _lastLevelLog = now;
        debugPrint('soundLevel=$level');
      },
      onResult: (r) {
        _lastResult = r;
        debugPrint(
            'RESULT final=${r.finalResult} words="${r.recognizedWords}" conf=${r.confidence}');
        if (!mounted) return;

        setState(() => _partial = r.recognizedWords);

        // ✅ 最终结果只在 finalResult=true 时写入
        if (r.finalResult) {
          final t = r.recognizedWords.trim();
          if (t.isNotEmpty) {
            _finalText = t;
            debugPrint('FINAL SET: $_finalText');
          } else {
            debugPrint('FINAL but empty words');
          }
        }
      },
    );
  }

  Future<void> _stop() async {
    if (!_listening) return;

    await Future.delayed(const Duration(milliseconds: 250));
    await _stt.stop();

    final hasPerm = await _stt.hasPermission;
    final isListening = _stt.isListening;

    debugPrint('STOP: status=$_lastStatus error=$_lastError '
        'available=$_available hasPerm=$hasPerm isListening=$isListening '
        'final="$_finalText" partial="$_partial"');

    setState(() => _listening = false);

    final text = (_finalText ?? _partial).trim();
    if (text.isNotEmpty) widget.onFinalText(text);
  }

  @override
  void dispose() {
    _stt.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color =
        _listening ? Colors.red : Theme.of(context).colorScheme.primary;

    final l10n = AppLocalizations.of(context);

    return GestureDetector(
      onLongPressStart: (_) => _start(),
      onLongPressEnd: (_) => _stop(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_listening ? Icons.mic : Icons.mic_none, color: color),
            const SizedBox(width: 8),
            Text(
              _listening ? l10n.holdToTalkReleaseToStop : (_available ? l10n.holdToTalkHoldToSpeak : l10n.holdToTalkUnavailable),
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
