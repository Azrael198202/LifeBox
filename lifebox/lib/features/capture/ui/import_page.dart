import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lifebox/features/capture/ui/ocr_results_page.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:lifebox/l10n/app_localizations.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/risk_badge.dart';
import '../../capture/state/import_controller.dart';
import '../../capture/state/import_providers.dart';

class ImportPage extends ConsumerStatefulWidget {
  const ImportPage({super.key});

  @override
  ConsumerState<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends ConsumerState<ImportPage> {
  final ScrollController _scroll = ScrollController();
  bool _queuePanelOpen = true;

  // ✅ 新增：记录“本次加入队列”的 assetIds，用于 OCR 全部完成后自动跳转
  Set<String>? _autoJumpIds;
  bool _autoJumping = false;

  @override
  void initState() {
    super.initState();

    // 首次进入时请求权限并初始化
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final c = ref.read(importControllerProvider);
      if (!c.permissionGranted && !c.loading) {
        await c.init();
      }
    });

    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    final c = ref.read(importControllerProvider);
    if (!_scroll.hasClients) return;
    final pos = _scroll.position;
    if (pos.pixels > pos.maxScrollExtent - 600) {
      c.loadMore();
    }
  }

  String _rangeText(DateTimeRange? r, String allTimeText) {
    if (r == null) return allTimeText;
    final fmt = DateFormat('yyyy/MM/dd');
    return '${fmt.format(r.start)} - ${fmt.format(r.end)}';
  }

  Future<void> _pickDateRange(ImportController c) async {
    final now = DateTime.now();
    final initial = c.range ??
        DateTimeRange(
          start: DateTime(now.year, now.month, now.day)
              .subtract(const Duration(days: 7)),
          end: DateTime(now.year, now.month, now.day, 23, 59, 59),
        );

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime(now.year + 1, 12, 31),
      initialDateRange: initial,
    );

    if (picked != null) {
      final normalized = DateTimeRange(
        start: DateTime(picked.start.year, picked.start.month, picked.start.day),
        end: DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59),
      );
      await c.setRange(normalized);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(importControllerProvider);
    final q = ref.watch(ocrQueueManagerProvider);
    final l10n = AppLocalizations.of(context);

    // ✅ 新增：监听 OCR 队列状态 —— 当本次加入队列的那批全部完成时自动跳到结果页
    ref.listen(ocrQueueManagerProvider, (prev, next) {
      final ids = _autoJumpIds;
      if (ids == null || ids.isEmpty) return;
      if (_autoJumping) return;

      // completedJobs 中属于本次 ids 的数量
      final completedForThisBatch = next.completedJobs
          .where((job) => ids.contains(job.assetId))
          .length;

      // ✅ 成功/失败都算完成：只要这批都进入 completedJobs 就跳转
      if (completedForThisBatch == ids.length) {
        _autoJumping = true;

        Future.microtask(() async {
          if (!mounted) return;

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OcrResultsPage(filterAssetIds: ids.toList()),
            ),
          );

          // 返回后重置，避免反复跳
          if (!mounted) return;
          setState(() {
            _autoJumpIds = null;
            _autoJumping = false;
          });
        });
      }
    });

    if (!c.permissionGranted && !c.loading) {
      return AppScaffold(
        title: l10n.import_title,
        body: EmptyState(
          title: l10n.import_perm_title,
          subtitle: l10n.import_perm_subtitle_ios,
          action: PrimaryButton(
            label: l10n.import_perm_retry,
            icon: Icons.lock_open,
            onPressed: () => c.init(),
          ),
        ),
      );
    }

    return AppScaffold(
      title: l10n.import_title_full,
      actions: [
        IconButton(
          onPressed: () => c.reloadAssets(),
          icon: const Icon(Icons.refresh),
          tooltip: l10n.import_action_refresh,
        ),
      ],
      body: Column(
        children: [
          _FilterBar(
            type: c.type,
            rangeText: _rangeText(c.range, l10n.all_Time),
            screenshotsAlbumName: c.screenshotsAlbumName,
            onPickRange: () => _pickDateRange(c),
            onClearRange: c.range == null ? null : () => c.setRange(null),
            onTypeChanged: (t) => c.setType(t),
          ),
          _SelectionBar(
            selectedCount: c.selectedAssetIds.length,
            onSelectAllVisible:
                c.assets.isEmpty ? null : () => c.selectAllVisible(),
            onClear:
                c.selectedAssetIds.isEmpty ? null : () => c.clearSelection(),
            queueCount: q.queuedCount + (q.current == null ? 0 : 1),
            queuePanelOpen: _queuePanelOpen,
            onToggleQueuePanel: () =>
                setState(() => _queuePanelOpen = !_queuePanelOpen),
          ),
          const Divider(height: 1),
          Expanded(
            child: _Grid(
              controller: _scroll,
              assets: c.assets,
              loading: c.loading,
              isSelected: c.isSelected,
              onTap: (id) => c.toggleSelect(id),
            ),
          ),
          _BottomActions(
            enabled: c.selectedAssetIds.isNotEmpty,
            selectedCount: c.selectedAssetIds.length,
            onEnqueue: () {
              final ids = c.selectedAssetIds.toList();

              // ✅ 记录本次 ids，用于 OCR 完成后自动跳转
              setState(() {
                _autoJumpIds = ids.toSet();
                _autoJumping = false;
                _queuePanelOpen = true;
              });

              q.enqueueMany(ids);
              c.clearSelection();
            },
          ),
          if (_queuePanelOpen) _QueuePanel(queue: q),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.type,
    required this.rangeText,
    required this.screenshotsAlbumName,
    required this.onPickRange,
    required this.onClearRange,
    required this.onTypeChanged,
  });

  final ImportPhotoType type;
  final String rangeText;
  final String? screenshotsAlbumName;
  final VoidCallback onPickRange;
  final VoidCallback? onClearRange;
  final ValueChanged<ImportPhotoType> onTypeChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<ImportPhotoType>(
                  initialValue: type,
                  decoration: InputDecoration(
                    labelText: l10n.type_label,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: ImportPhotoType.values
                      .map((t) => DropdownMenuItem(
                          value: t, child: Text(t.label(context))))
                      .toList(),
                  onChanged: (v) => v == null ? null : onTypeChanged(v),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: onPickRange,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: l10n.import_filter_range_label,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(rangeText, overflow: TextOverflow.ellipsis),
                        ),
                        const Icon(Icons.date_range, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const RiskBadge(risk: RiskLevel.low),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  screenshotsAlbumName == null
                      ? l10n.import_screenshots_not_found
                      : l10n.import_screenshots_album_prefix(
                          screenshotsAlbumName as String),
                  style: TextStyle(
                    fontSize: 12,
                    color: screenshotsAlbumName == null
                        ? Colors.orange[800]
                        : Colors.green[700],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: onClearRange,
                child: Text(l10n.import_filter_clear_range),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SelectionBar extends StatelessWidget {
  const _SelectionBar({
    required this.selectedCount,
    required this.onSelectAllVisible,
    required this.onClear,
    required this.queueCount,
    required this.queuePanelOpen,
    required this.onToggleQueuePanel,
  });

  final int selectedCount;
  final VoidCallback? onSelectAllVisible;
  final VoidCallback? onClear;
  final int queueCount;
  final bool queuePanelOpen;
  final VoidCallback onToggleQueuePanel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  l10n.import_selected_count(selectedCount),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                TextButton(
                  onPressed: onSelectAllVisible,
                  child: Text(
                    l10n.import_select_all_visible,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed: onClear,
                  child: Text(
                    l10n.import_clear_selection,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: onToggleQueuePanel,
            icon: Icon(queuePanelOpen ? Icons.expand_more : Icons.expand_less),
            label: Text(
              l10n.import_queue_label(queueCount),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ),
        ],
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({
    required this.controller,
    required this.assets,
    required this.loading,
    required this.isSelected,
    required this.onTap,
  });

  final ScrollController controller;
  final List<AssetEntity> assets;
  final bool loading;
  final bool Function(String id) isSelected;
  final void Function(String id) onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (assets.isEmpty && loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (assets.isEmpty) {
      return EmptyState(
        title: l10n.import_empty_title,
        subtitle: l10n.import_empty_subtitle,
      );
    }

    return Stack(
      children: [
        GridView.builder(
          controller: controller,
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
          ),
          itemCount: assets.length,
          itemBuilder: (context, i) {
            final a = assets[i];
            final selected = isSelected(a.id);
            return _AssetTile(
              asset: a,
              selected: selected,
              onTap: () => onTap(a.id),
            );
          },
        ),
        if (loading)
          Positioned(
            left: 0,
            right: 0,
            bottom: 10,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  l10n.import_loading_more,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _AssetTile extends StatelessWidget {
  const _AssetTile({
    required this.asset,
    required this.selected,
    required this.onTap,
  });

  final AssetEntity asset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final thumb = AssetEntityImage(
      asset,
      isOriginal: false,
      thumbnailSize: const ThumbnailSize.square(260),
      fit: BoxFit.cover,
    );

    return InkWell(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            Positioned.fill(child: thumb),
            if (selected)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.35),
                  alignment: Alignment.topRight,
                  padding: const EdgeInsets.all(6),
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, size: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.enabled,
    required this.selectedCount,
    required this.onEnqueue,
  });

  final bool enabled;
  final int selectedCount;
  final VoidCallback onEnqueue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          children: [
            Expanded(
              child: PrimaryButton(
                label: enabled
                    ? l10n.import_enqueue_button_with_count(selectedCount)
                    : l10n.import_enqueue_button,
                icon: Icons.queue,
                enabled: enabled,
                onPressed: enabled ? onEnqueue : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QueuePanel extends StatelessWidget {
  const _QueuePanel({required this.queue});

  final dynamic queue;

  @override
  Widget build(BuildContext context) {
    final cur = queue.current;
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.65),
        border: Border(top: BorderSide(color: Colors.black.withOpacity(0.06))),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(l10n.ocr_queue_title,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const Spacer(),
                TextButton(
                  onPressed: queue.queuedJobs.isEmpty ? null : queue.clearQueued,
                  child: Text(l10n.ocr_queue_clear),
                ),
                // ✅ “结果”按钮仍保留（你说下面部分还需要）
                TextButton(
                  onPressed: queue.completedJobs.isEmpty
                      ? null
                      : () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const OcrResultsPage()),
                          );
                        },
                  child: Text(l10n.ocr_results_button(queue.completedJobs.length)),
                ),
              ],
            ),
            if (cur != null) ...[
              Row(
                children: [
                  const Icon(Icons.play_circle, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      // 你原来这里传的是 Set，会怪；先按 string 输出
                      '${l10n.ocr_processing_prefix('')}${cur.assetId}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text('${(cur.progress * 100).toStringAsFixed(0)}%'),
                ],
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(value: cur.progress),
              const SizedBox(height: 10),
            ] else ...[
              Row(
                children: [
                  const Icon(Icons.pause_circle, size: 18),
                  const SizedBox(width: 8),
                  Text(l10n.ocr_no_current),
                ],
              ),
              const SizedBox(height: 10),
            ],
            if (queue.queuedJobs.isNotEmpty)
              SizedBox(
                height: 72,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: queue.queuedJobs.length,
                  itemBuilder: (context, i) {
                    final j = queue.queuedJobs[i];
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black.withOpacity(0.06)),
                      ),
                      child: Center(
                        child: Text(
                          '${l10n.ocr_queued_prefix('')}${j.assetId}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              Align(
                alignment: Alignment.centerLeft,
                child: Text(l10n.ocr_queue_empty),
              ),
          ],
        ),
      ),
    );
  }
}
