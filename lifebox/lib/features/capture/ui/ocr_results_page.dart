import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

import '../../capture/state/import_providers.dart';
import '../../../core/services/ocr_queue_manager.dart';
import 'package:lifebox/l10n/app_localizations.dart';

class OcrResultsPage extends ConsumerStatefulWidget {
  const OcrResultsPage({super.key});

  @override
  ConsumerState<OcrResultsPage> createState() => _OcrResultsPageState();
}

class _OcrResultsPageState extends ConsumerState<OcrResultsPage> {
  final Set<String> _selected = <String>{};

  @override
  Widget build(BuildContext context) {
    final q = ref.watch(ocrQueueManagerProvider);
    final jobs = q.completedJobs;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.ocrResultsTitle(jobs.length)),
        actions: [
          TextButton(
            onPressed: jobs.isEmpty
                ? null
                : () => setState(() {
                      _selected
                        ..clear()
                        ..addAll(jobs.map((e) => e.assetId));
                    }),
            child: Text(l10n.selectAll),
          ),
          TextButton(
            onPressed: _selected.isEmpty ? null : () => setState(_selected.clear),
            child: Text(l10n.clearSelection),
          ),
          IconButton(
            tooltip: l10n.clearResultsTooltip,
            onPressed: jobs.isEmpty ? null : () => q.clearCompleted(),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: FilledButton.icon(
            onPressed: _selected.isEmpty
                ? null
                : () {
                    // 你下一步操作可以用 selectedAssetIds 继续处理
                    Navigator.pop(context, _selected.toList());
                  },
            icon: const Icon(Icons.check),
            label: Text(_selected.isEmpty ? l10n.confirmButtonPleaseSelect : l10n.confirmButtonSelectedCount(_selected.length)),
          ),
        ),
      ),
      body: jobs.isEmpty
          ? Center(child: Text(l10n.emptyOcrResults))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: jobs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final job = jobs[i];
                final selected = _selected.contains(job.assetId);
                return _OcrResultCard(
                  job: job,
                  selected: selected,
                  onTap: () => setState(() {
                    if (selected) {
                      _selected.remove(job.assetId);
                    } else {
                      _selected.add(job.assetId);
                    }
                  }),
                );
              },
            ),
    );
  }
}

class _OcrResultCard extends StatelessWidget {
  const _OcrResultCard({
    required this.job,
    required this.selected,
    required this.onTap,
  });

  final OcrJob job;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context);

    final statusText = switch (job.status) {
      OcrJobStatus.success => l10n.ocrStatusSuccess,
      OcrJobStatus.failed => l10n.ocrStatusFailed,
      OcrJobStatus.running => l10n.ocrStatusRunning,
      OcrJobStatus.queued => l10n.ocrStatusQueued,
    };    

    final subtitle = job.status == OcrJobStatus.failed
        ? (job.error ?? l10n.ocrFailedDefaultError)
        : (job.resultText ?? '');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? Theme.of(context).colorScheme.primary : Colors.black.withOpacity(0.08),
            width: selected ? 1.5 : 1,
          ),
          color: selected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.06)
              : Theme.of(context).colorScheme.surface,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Thumb(assetId: job.assetId),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(statusText, style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(width: 8),
                      Text(
                        job.createdAt.toLocal().toString().substring(0, 19),
                        style: TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.55)),
                      ),
                      const Spacer(),
                      if (selected)
                        Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle.isEmpty ? l10n.noTextPlaceholder : subtitle,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, height: 1.25),
                  ),
                  if (job.status == OcrJobStatus.success && (job.resultText?.isNotEmpty ?? false)) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            final text = job.resultText ?? '';
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text(l10n.ocrFullTextTitle),
                                content: SingleChildScrollView(child: Text(text)),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(l10n.close),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(Icons.article_outlined, size: 18),
                          label: Text(l10n.viewFullText),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.assetId});
  final String assetId;

  @override
  Widget build(BuildContext context) {

    return FutureBuilder<AssetEntity?>(
      future: AssetEntity.fromId(assetId),
      builder: (context, snap) {
        final asset = snap.data;
        if (asset == null) {
          return Container(
            width: 72,
            height: 72,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.black.withOpacity(0.05),
            ),
            child: const Icon(Icons.image_not_supported_outlined),
          );
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 72,
            height: 72,
            child: AssetEntityImage(
              asset,
              isOriginal: false,
              thumbnailSize: const ThumbnailSize.square(200),
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }
}
