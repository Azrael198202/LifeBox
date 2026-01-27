import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:lifebox/core/services/legal_api.dart';
import 'package:lifebox/features/settings/state/legal_providers.dart';

class LegalPage extends ConsumerWidget {
  const LegalPage({
    super.key,
    required this.type,
  });

  final LegalType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    String pickLang(BuildContext context) {
      final code = Localizations.localeOf(context).languageCode.toLowerCase();
      if (code == 'ja') return 'ja';
      if (code == 'zh') return 'zh';
      return 'en';
    }

    final lang = pickLang(context);

    final asyncDoc = ref.watch(legalDocProvider((type: type, lang: lang)));

    return asyncDoc.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Failed to load. $e'),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref.refresh(
                    legalDocProvider((type: type, lang: lang)),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (doc) => Scaffold(
        appBar: AppBar(title: Text(doc.title.isEmpty ? _fallbackTitle() : doc.title)),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Html(
            data: doc.html,
            // 可选：限制样式/字体
            style: {
              "body": Style(margin: Margins.zero, padding: HtmlPaddings.zero),
            },
          ),
        ),
      ),
    );
  }

  String _fallbackTitle() {
    if (type == LegalType.terms) return 'Terms of Service';
    return 'Privacy Policy';
  }
}