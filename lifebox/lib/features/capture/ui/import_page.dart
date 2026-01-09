import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:provider/provider.dart';

import '../../../core/services/ocr_queue_manager.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/risk_badge.dart';
import '../state/import_controller.dart';

class ImportPage extends StatefulWidget {
  const ImportPage({super.key});

  @override
  State<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  final ScrollController _scroll = ScrollController();
  bool _queuePanelOpen = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final c = context.read<ImportController>();
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
    final c = context.read<ImportController>();
    if (!_scroll.hasClients) return;
    final pos = _scroll.position;
    if (pos.pixels > pos.maxScrollExtent - 600) {
      c.loadMore();
    }
  }

  Future<void> _pickDateRange(ImportController c) async {
    final now = DateTime.now();
    final initial = c.range ??
        DateTimeRange(
          start: DateTime(now.year, now.month, now.day).subtract(const Duration(days: 7)),
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

  String _rangeText(DateTimeRange? r) {
    if (r == null) return '不限时间';
    final fmt = DateFormat('yyyy/MM/dd');
    return '${fmt.format(r.start)} - ${fmt.format(r.end)}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ImportController, OcrQueueManager>(
      builder: (context, c, q, _) {
        if (!c.permissionGranted && !c.loading) {
          return AppScaffold(
            title: '导入',
            body: EmptyState(
              title: '未获得相册权限',
              subtitle: '请到 iOS 设置 → 隐私与安全性 → 照片 中允许访问。',
              action: PrimaryButton(
                label: '重新请求权限',
                onPressed: () => c.init(),
                icon: Icons.lock_open,
              ),
            ),
          );
        }

        return AppScaffold(
          title: 'Import（筛选 + 队列）',
          actions: [
            IconButton(
              onPressed: () => c.reloadAssets(),
              icon: const Icon(Icons.refresh),
              tooltip: '刷新',
            ),
            IconButton(
              onPressed: () => Navigator.pushNamed(context, '/inbox'),
              icon: const Icon(Icons.inbox_outlined),
              tooltip: 'Inbox',
            ),
          ],
          body: Column(
            children: [
              _FilterBar(
                type: c.type,
                rangeText: _rangeText(c.range),
                onPickRange: () => _pickDateRange(c),
                onClearRange: c.range == null ? null : () => c.setRange(null),
                screenshotsAlbumName: c.screenshotsAlbumName,
                onTypeChanged: (t) => c.setType(t),
              ),
              _SelectionBar(
                selectedCount: c.selectedAssetIds.length,
                onSelectAllVisible: c.assets.isEmpty ? null : () => c.selectAllVisible(),
                onClear: c.selectedAssetIds.isEmpty ? null : () => c.clearSelection(),
                queueCount: q.queuedCount + (q.current == null ? 0 : 1),
                onToggleQueuePanel: () => setState(() => _queuePanelOpen = !_queuePanelOpen),
                queuePanelOpen: _queuePanelOpen,
              ),
              const Divider(height: 1),
              Expanded(
                child: _Grid(
                  controller: _scroll,
                  assets: c.assets,
                  isSelected: c.isSelected,
                  onTap: (id) => c.toggleSelect(id),
                  loading: c.loading,
                ),
              ),
              _BottomActions(
                enabled: c.selectedAssetIds.isNotEmpty,
                selectedCount: c.selectedAssetIds.length,
                onEnqueue: () {
                  q.enqueueMany(c.selectedAssetIds.toList());
                  c.clearSelection();
                  setState(() => _queuePanelOpen = true);
                },
              ),
              if (_queuePanelOpen) _QueuePanel(queue: q),
            ],
          ),
        );
      },
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.type,
    required this.rangeText,
    required this.onPickRange,
    required this.onClearRange,
    required this.screenshotsAlbumName,
    required this.onTypeChanged,
  });

  final ImportPhotoType type;
  final String rangeText;
  final VoidCallback onPickRange;
  final VoidCallback? onClearRange;
  final String? screenshotsAlbumName;
  final ValueChanged<ImportPhotoType> onTypeChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<ImportPhotoType>(
                  value: type,
                  decoration: const InputDecoration(
                    labelText: '类型',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: ImportPhotoType.values
                      .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                      .toList(),
                  onChanged: (v) => v == null ? null : onTypeChanged(v),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: onPickRange,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: '时间段',
                      border: OutlineInputBorder(),
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
              if (screenshotsAlbumName == null)
                RiskBadge.text('未检测到截图相册，将自动降级筛选', tone: BadgeTone.warning)
              else
                RiskBadge.text('截图相册：$screenshotsAlbumName', tone: BadgeTone.success),
              const Spacer(),
              TextButton(
                onPressed: onClearRange,
                child: const Text('清除时间'),
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
    required this.onToggleQueuePanel,
    required this.queuePanelOpen,
  });

  final int selectedCount;
  final VoidCallback? onSelectAllVisible;
  final VoidCallback? onClear;
  final int queueCount;
  final VoidCallback onToggleQueuePanel;
  final bool queuePanelOpen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      child: Row(
        children: [
          Text('已选 $selectedCount 张'),
          const SizedBox(width: 10),
          TextButton(
            onPressed: onSelectAllVisible,
            child: const Text('全选当前'),
          ),
          TextButton(
            onPressed: onClear,
            child: const Text('取消全选'),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: onToggleQueuePanel,
            icon: Icon(queuePanelOpen ? Icons.expand_more : Icons.expand_less),
            label: Text('队列 $queueCount'),
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
    required this.isSelected,
    required this.onTap,
    required this.loading,
  });

  final ScrollController controller;
  final List<AssetEntity> assets;
  final bool Function(String id) isSelected;
  final void Function(String id) onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (assets.isEmpty && loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (assets.isEmpty) {
      return const EmptyState(
        title: '没有符合条件的照片',
        subtitle: '尝试更换时间范围或类型筛选。',
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
                child: const Text(
                  '加载中…',
                  style: TextStyle(color: Colors.white, fontSize: 12),
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
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          children: [
            Expanded(
              child: PrimaryButton(
                label: enabled ? '加入待处理队列（$selectedCount）' : '加入待处理队列',
                onPressed: enabled ? onEnqueue : null,
                icon: Icons.queue,
                enabled: enabled,
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

  final OcrQueueManager queue;

  @override
  Widget build(BuildContext context) {
    final cur = queue.current;

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
                const Text('OCR 队列', style: TextStyle(fontWeight: FontWeight.w600)),
                const Spacer(),
                TextButton(
                  onPressed: queue.queuedJobs.isEmpty ? null : queue.clearQueued,
                  child: const Text('清空排队'),
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
                      '处理中：${cur.assetId}',
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
              const Row(
                children: [
                  Icon(Icons.pause_circle, size: 18),
                  SizedBox(width: 8),
                  Text('当前无处理中任务'),
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
                          '排队：${j.assetId}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('排队为空'),
              ),
          ],
        ),
      ),
    );
  }
}
