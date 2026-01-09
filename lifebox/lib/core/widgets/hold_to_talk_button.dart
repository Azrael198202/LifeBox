import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class HoldToTalkButton extends StatefulWidget {
  const HoldToTalkButton({
    super.key,
    required this.onFinalText,
    this.localeId, // 例如 'zh_CN' / 'ja_JP'
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

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _available = await _stt.initialize(
      onStatus: (s) {
        // debugPrint('stt status=$s');
      },
      onError: (e) {
        // debugPrint('stt error=$e');
      },
    );
    if (mounted) setState(() {});
  }

  Future<void> _start() async {
    if (!_available || _listening) return;

    setState(() {
      _listening = true;
      _partial = '';
    });

    await _stt.listen(
      localeId: widget.localeId,
      listenMode: stt.ListenMode.confirmation,
      partialResults: true,
      onResult: (r) {
        if (!mounted) return;
        setState(() => _partial = r.recognizedWords);
      },
    );
  }

  Future<void> _stop() async {
    if (!_listening) return;

    await _stt.stop();
    final finalText = _partial.trim();

    setState(() => _listening = false);

    if (finalText.isNotEmpty) {
      widget.onFinalText(finalText);
    }
  }

  @override
  void dispose() {
    _stt.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _listening ? Colors.red : Theme.of(context).colorScheme.primary;

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
              _listening ? '松开结束' : '按住说话',
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
